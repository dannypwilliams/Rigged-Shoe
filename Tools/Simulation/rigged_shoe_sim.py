#!/usr/bin/env python3
"""Headless balance simulator for the rebuilt Rigged Shoe roguelite loop.

This is intentionally compact and RAM-conscious. It mirrors the current Swift
model layer at the level needed for balance work: 10 short baccarat battles,
opponent scoring, bankroll, Chips, Heat, boss pressure, reward/shop drafting,
and simplified modifier effects. It does not launch the iOS app.
"""

from __future__ import annotations

import argparse
import json
import random
import re
import resource
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path
from statistics import mean
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


ROOT = Path(__file__).resolve().parents[2]
MODIFIER_SWIFT = ROOT / "RiggedShoe" / "Models" / "ModifierModels.swift"
SHOP_SWIFT = ROOT / "RiggedShoe" / "Models" / "ShopModels.swift"
REPORT_PATH = ROOT / "Docs" / "BalanceReport.md"

SUITS = ["C", "D", "H", "S"]
RANKS = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
VALUES = {"A": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 0, "J": 0, "Q": 0, "K": 0}
BET_TYPES = ["player", "banker", "tie"]


@dataclass(frozen=True)
class Stage:
    id: int
    hands: int
    ante: int
    max_bet: int
    allowed_bets: Tuple[int, ...]
    opponent: str
    opponent_style: str
    table_event: str
    secondary: str
    is_boss: bool = False

    def min_bet(self) -> int:
        return self.ante


STAGES: Tuple[Stage, ...] = (
    Stage(1, 5, 2_500, 10_000, (2_500, 5_000, 7_500, 10_000), "Nervous Tourist", "randomTourist", "Tourist Rush", "Clean Run"),
    Stage(2, 6, 5_000, 15_000, (5_000, 10_000, 15_000), "Weekend Regular", "conservativeBanker", "No Commission Night", "Ahead of Schedule"),
    Stage(3, 7, 7_500, 25_000, (7_500, 15_000, 22_500, 25_000), "Card Room Grinder", "smallBallGrinder", "Tie Promo", "Engine Online"),
    Stage(4, 8, 10_000, 40_000, (10_000, 20_000, 30_000, 40_000), "Tie Chaser", "tieChaser", "High Minimums", "Longshot Hit"),
    Stage(5, 8, 15_000, 60_000, (15_000, 30_000, 45_000, 60_000), "Pattern Player", "streakBetter", "Tight Surveillance", "Stay Small", True),
    Stage(6, 8, 20_000, 80_000, (20_000, 40_000, 60_000, 80_000), "The Counter", "counterBetter", "Private Table", "Use the Layout"),
    Stage(7, 9, 30_000, 120_000, (30_000, 60_000, 90_000, 120_000), "The Whale Junior", "highRoller", "Rich Crowd", "Beat the Spread"),
    Stage(8, 10, 40_000, 175_000, (40_000, 80_000, 120_000, 160_000, 175_000), "Quiet Regular", "smallBallGrinder", "Bad Cut", "Close Strong", True),
    Stage(9, 10, 60_000, 250_000, (60_000, 120_000, 180_000, 240_000, 250_000), "The Cooler", "conservativeBanker", "Cold Table", "No Props"),
    Stage(10, 12, 80_000, 400_000, (80_000, 160_000, 240_000, 320_000, 400_000), "The Floor Favorite", "conservativeBanker", "Final Hand Spotlight", "Comeback Table", True),
)

TARGET_CLEAR_RATES = {
    1: (0.90, 0.95),
    2: (0.80, 0.90),
    3: (0.70, 0.80),
    4: (0.60, 0.70),
    5: (0.50, 0.65),
    6: (0.45, 0.60),
    7: (0.35, 0.50),
    8: (0.30, 0.45),
    9: (0.20, 0.35),
    10: (0.10, 0.25),
}


@dataclass
class ModifierDef:
    id: str
    name: str
    rarity: str
    tags: Tuple[str, ...]
    trigger: str
    min_tier: int
    cost: int
    side: Optional[str] = None
    payout_percent: int = 0
    bankroll_ante_percent: int = 0
    chips: int = 0
    reveal: int = 0
    refund_percent: int = 0
    prevent_heat: int = 0
    heat_cost: int = 0

    @property
    def score(self) -> int:
        return (
            self.payout_percent
            + self.bankroll_ante_percent // 2
            + self.chips * 45
            + self.reveal * 12
            + self.refund_percent
            + self.prevent_heat * 25
            - self.heat_cost * 20
        )


@dataclass
class Contact:
    id: str
    name: str
    starting_modifiers: Tuple[str, ...]
    tags: Tuple[str, ...]
    bankroll_adjust: int = 0
    chips_adjust: int = 0
    heat_adjust: int = 0
    cash_multiplier: float = 1.0
    early_max_bet_multiplier: float = 1.0


@dataclass
class SimState:
    rng: random.Random
    strategy: str
    contact: Contact
    bankroll: int
    chips: int
    heat: int
    active_mods: List[str]
    bench_mods: List[str] = field(default_factory=list)
    bosses_defeated: int = 0
    highest_bankroll: int = 0
    total_hands: int = 0
    modifiers_triggered: Dict[str, int] = field(default_factory=dict)
    picked_modifiers: List[str] = field(default_factory=list)
    shop_offers_seen: int = 0
    last_winner: Optional[str] = None
    last_bet_side: Optional[str] = None
    repeated_side_count: int = 0
    heat_deaths: int = 0
    bankruptcies: int = 0

    def trigger(self, modifier_id: str) -> None:
        self.modifiers_triggered[modifier_id] = self.modifiers_triggered.get(modifier_id, 0) + 1


@dataclass
class StageRecord:
    stage: int
    clear: bool
    boss: bool
    bankroll_start: int
    bankroll_end: int
    heat_start: int
    heat_end: int
    chips_start: int
    chips_end: int
    player_profit: int
    opponent_profit: int
    hands: int
    failure: str = ""


@dataclass
class RunSummary:
    seed: int
    strategy: str
    contact: str
    final_stage: int
    completed: bool
    failure: str
    starting_bankroll: int
    ending_bankroll: int
    highest_bankroll: int
    heat: int
    chips: int
    hands: int
    bosses_defeated: int
    picked_modifiers: List[str]
    triggered_modifiers: Dict[str, int]
    stages: List[StageRecord]


def cents(value: int) -> str:
    sign = "-" if value < 0 else ""
    value = abs(value)
    dollars = value / 100
    return f"{sign}${dollars:,.0f}" if value % 100 == 0 else f"{sign}${dollars:,.2f}"


def rank_value(card: Tuple[str, str]) -> int:
    return VALUES[card[0]]


def hand_total(cards: Sequence[Tuple[str, str]]) -> int:
    return sum(rank_value(card) for card in cards) % 10


def new_shoe(rng: random.Random) -> List[Tuple[str, str]]:
    cards = [(rank, suit) for _ in range(6) for suit in SUITS for rank in RANKS]
    rng.shuffle(cards)
    return cards


def should_banker_draw(total: int, player_third: Optional[Tuple[str, str]]) -> bool:
    if player_third is None:
        return total <= 5
    value = rank_value(player_third)
    if total <= 2:
        return True
    if total == 3:
        return value != 8
    if total == 4:
        return 2 <= value <= 7
    if total == 5:
        return 4 <= value <= 7
    if total == 6:
        return 6 <= value <= 7
    return False


def deal_hand(shoe: List[Tuple[str, str]]) -> Tuple[str, int, int, bool, int]:
    p1 = shoe.pop(0)
    b1 = shoe.pop(0)
    p2 = shoe.pop(0)
    b2 = shoe.pop(0)
    player = [p1, p2]
    banker = [b1, b2]
    player_total = hand_total(player)
    banker_total = hand_total(banker)
    natural = player_total in (8, 9) or banker_total in (8, 9)
    cards_dealt = 4
    if not natural:
        player_third = None
        if player_total <= 5:
            player_third = shoe.pop(0)
            player.append(player_third)
            player_total = hand_total(player)
            cards_dealt += 1
        if should_banker_draw(hand_total(banker), player_third):
            banker.append(shoe.pop(0))
            banker_total = hand_total(banker)
            cards_dealt += 1
    if player_total > banker_total:
        return "player", player_total, banker_total, natural, cards_dealt
    if banker_total > player_total:
        return "banker", player_total, banker_total, natural, cards_dealt
    return "tie", player_total, banker_total, natural, cards_dealt


def forecast(shoe: Sequence[Tuple[str, str]], reveal_count: int) -> Optional[str]:
    if reveal_count < 4 or len(shoe) < 6:
        return None
    preview = list(shoe[:6])
    try:
        return deal_hand(preview)[0]
    except IndexError:
        return None


def rarity_cost(rarity: str) -> int:
    return {
        "common": 3,
        "uncommon": 4,
        "rare": 5,
        "epic": 6,
        "legendary": 8,
        "boss": 0,
    }.get(rarity, 3)


def parse_tags(raw: str) -> Tuple[str, ...]:
    return tuple(re.findall(r"\.([A-Za-z][A-Za-z0-9_]*)", raw))


def extract_side(raw: str) -> Optional[str]:
    if ".banker" in raw:
        return "banker"
    if ".player" in raw:
        return "player"
    if ".tie" in raw:
        return "tie"
    return None


def parse_ints(raw: str, pattern: str) -> List[int]:
    return [int(value.replace("_", "")) for value in re.findall(pattern, raw)]


def parse_modifiers() -> Dict[str, ModifierDef]:
    text = MODIFIER_SWIFT.read_text()
    mods: Dict[str, ModifierDef] = {}

    # Six core engine-test modifiers are deliberately small and reliable.
    core = [
        ModifierDef("core.banker-bias", "Banker Bias", "common", ("banker", "betControl"), "playerWonBet", 1, 3, side="banker", payout_percent=10),
        ModifierDef("core.player-surge", "Player Surge", "common", ("player", "tempo"), "playerWonBet", 1, 3, side="player", bankroll_ante_percent=100),
        ModifierDef("core.tie-insurance", "Tie Insurance", "common", ("tie", "comeback"), "playerLostBet", 1, 3, side="tie", refund_percent=40),
        ModifierDef("core.opening-tell", "Opening Tell", "rare", ("shoeVision",), "stageStarted", 1, 5, reveal=3),
        ModifierDef("core.clean-hands", "Clean Hands", "common", ("heat",), "heatGained", 1, 3, prevent_heat=1),
        ModifierDef("core.lucky-chip", "Lucky Chip", "common", ("economy",), "playerWonBet", 1, 3, chips=1),
    ]
    mods.update({item.id: item for item in core})

    # Expanded catalog entries mostly live on one line through contentModifier.
    for line in text.splitlines():
        if "contentModifier(" not in line:
            continue
        id_match = re.search(r'id:\s*"([^"]+)"', line)
        name_match = re.search(r'name:\s*"([^"]+)"', line)
        rarity_match = re.search(r'rarity:\s*\.(\w+)', line)
        trigger_match = re.search(r'trigger:\s*\.(\w+)', line)
        tier_match = re.search(r'minShopTier:\s*([0-9]+)', line)
        tags_match = re.search(r'tags:\s*\[([^\]]*)\]', line)
        if not (id_match and name_match and rarity_match and trigger_match and tier_match and tags_match):
            continue
        mod_id = id_match.group(1)
        raw_effects = line
        payout_values = parse_ints(raw_effects, r"payoutLevels\([^,]+,\s*([0-9_]+)")
        ante_values = parse_ints(raw_effects, r"anteLevels\(\s*([0-9_]+)")
        grant_bankroll = parse_ints(raw_effects, r"grantBankrollFromAnte\(percent:\s*([0-9_]+)")
        grant_chips = parse_ints(raw_effects, r"grantChips(?:OnFirstStageTrigger)?\(amount:\s*([0-9_]+)")
        reveals = parse_ints(raw_effects, r"revealUpcomingCards(?:WithForecast)?\(count:\s*([0-9_]+)")
        refunds = parse_ints(raw_effects, r"lossRefund\(percent:\s*([0-9_]+)")
        prevents = parse_ints(raw_effects, r"preventHeat\(amount:\s*([0-9_]+)")
        heat_cost = parse_ints(raw_effects, r"heatCost:\s*([0-9_]+)")
        mod = ModifierDef(
            id=mod_id,
            name=name_match.group(1),
            rarity=rarity_match.group(1),
            tags=parse_tags(tags_match.group(1)),
            trigger=trigger_match.group(1),
            min_tier=int(tier_match.group(1)),
            cost=rarity_cost(rarity_match.group(1)),
            side=extract_side(raw_effects),
            payout_percent=max(payout_values or [0]),
            bankroll_ante_percent=max((ante_values + grant_bankroll) or [0]),
            chips=max(grant_chips or [0]),
            reveal=max(reveals or [0]),
            refund_percent=max(refunds or [0]),
            prevent_heat=max(prevents or ([1] if "preventHeat(amount: nil)" in raw_effects else [0])),
            heat_cost=max(heat_cost or [0]),
        )
        mods[mod.id] = mod
    return mods


def parse_contacts() -> Dict[str, Contact]:
    text = SHOP_SWIFT.read_text()
    contacts: Dict[str, Contact] = {}
    pattern = re.compile(r'StartingContact\(id:\s*"([^"]+)".*?\)', re.S)
    for match in pattern.finditer(text):
        raw = match.group(0)
        id_match = re.search(r'id:\s*"([^"]+)"', raw)
        name_match = re.search(r'name:\s*"([^"]+)"', raw)
        mods_match = re.search(r'startingModifiers:\s*\[([^\]]*)\]', raw)
        tags_match = re.search(r'shopBiasTags:\s*\[([^\]]*)\]', raw)
        bankroll = parse_ints(raw, r"bankrollAdjustmentCents:\s*(-?[0-9_]+)")
        chips = parse_ints(raw, r"chipsAdjustment:\s*(-?[0-9_]+)")
        heat = parse_ints(raw, r"heatAdjustment:\s*(-?[0-9_]+)")
        cash_multiplier = parse_ints(raw, r"cashRewardMultiplierPercent:\s*([0-9_]+)")
        early_cap = parse_ints(raw, r"earlyMaxBetMultiplierPercent:\s*([0-9_]+)")
        if not (id_match and name_match):
            continue
        contacts[id_match.group(1)] = Contact(
            id=id_match.group(1),
            name=name_match.group(1),
            starting_modifiers=tuple(re.findall(r'"([^"]+)"', mods_match.group(1) if mods_match else "")),
            tags=parse_tags(tags_match.group(1) if tags_match else ""),
            bankroll_adjust=bankroll[0] if bankroll else 0,
            chips_adjust=chips[0] if chips else 0,
            heat_adjust=heat[0] if heat else 0,
            cash_multiplier=(cash_multiplier[0] / 100.0) if cash_multiplier else 1.0,
            early_max_bet_multiplier=(early_cap[0] / 100.0) if early_cap else 1.0,
        )
    if not contacts:
        contacts["contact.tourist"] = Contact("contact.tourist", "The Tourist", ("core.lucky-chip",), ("economy", "banker", "player"))
    return contacts


def shop_tier(stage_id: int, bosses_defeated: int) -> int:
    if stage_id >= 9 or bosses_defeated >= 2:
        return 5
    if stage_id >= 8 or bosses_defeated >= 2:
        return 4
    if stage_id >= 5 or bosses_defeated >= 1:
        return 3
    if stage_id >= 3:
        return 2
    return 1


def choose_contact(strategy: str, contacts: Dict[str, Contact]) -> Contact:
    preferred = {
        "random_beginner": "contact.tourist",
        "conservative_banker": "contact.accountant",
        "build_aware_simple": "contact.dealer",
        "greedy_high_roller": "contact.whale",
        "tie_hunter": "contact.tie-chaser",
        "small_ball": "contact.accountant",
    }.get(strategy, "contact.tourist")
    return contacts.get(preferred) or next(iter(contacts.values()))


def legal_bets(stage: Stage, bankroll: int, contact: Contact) -> List[int]:
    cap = min(stage.max_bet, bankroll // 4)
    if stage.id <= 2:
        cap = int(cap * contact.early_max_bet_multiplier)
    if bankroll >= stage.min_bet():
        cap = max(stage.min_bet(), cap)
    return [amount for amount in stage.allowed_bets if stage.min_bet() <= amount <= cap and amount <= bankroll]


def active_defs(state: SimState, mods: Dict[str, ModifierDef]) -> List[ModifierDef]:
    return [mods[mid] for mid in state.active_mods if mid in mods]


def reveal_count(state: SimState, mods: Dict[str, ModifierDef]) -> int:
    return max([mod.reveal for mod in active_defs(state, mods)] + [0])


def choose_bet(state: SimState, stage: Stage, shoe: List[Tuple[str, str]], mods: Dict[str, ModifierDef]) -> Tuple[str, int, bool]:
    options = legal_bets(stage, state.bankroll, state.contact)
    if not options:
        return "banker", 0, False
    low, high = min(options), max(options)
    read = forecast(shoe, reveal_count(state, mods))

    if state.strategy == "random_beginner":
        side = state.rng.choice(BET_TYPES)
        amount = state.rng.choice(options[: min(2, len(options))])
    elif state.strategy == "conservative_banker":
        side = "banker"
        amount = low
    elif state.strategy == "build_aware_simple":
        tag_counts: Dict[str, int] = {}
        for mod in active_defs(state, mods):
            for tag in mod.tags:
                tag_counts[tag] = tag_counts.get(tag, 0) + 1
        side = read or ("tie" if tag_counts.get("tie", 0) >= 2 and state.rng.random() < 0.18 else "banker")
        if tag_counts.get("player", 0) > tag_counts.get("banker", 0):
            side = read or "player"
        amount = options[min(1, len(options) - 1)]
    elif state.strategy == "greedy_high_roller":
        side = read or "banker"
        amount = high
    elif state.strategy == "tie_hunter":
        side = "tie" if state.rng.random() < (0.28 if read != "tie" else 0.75) else (read or "banker")
        amount = low if side == "tie" else options[min(1, len(options) - 1)]
    else:  # small_ball
        side = read or "banker"
        amount = low
    return side, amount, amount == high


def opponent_side(style: str, hand_index: int, previous_winner: Optional[str], player_side: str, actual_winner: str) -> str:
    if style == "conservativeBanker":
        return "player" if hand_index % 5 == 0 else "banker"
    if style == "playerPivot":
        return "player" if previous_winner == "banker" else "banker"
    if style == "tieChaser":
        return "tie" if hand_index % 4 == 0 else "banker"
    if style == "highRoller":
        return actual_winner if hand_index % 3 == 0 else "banker"
    if style == "smallBallGrinder":
        return ("banker", "player", "banker", "banker")[(hand_index - 1) % 4]
    if style == "streakBetter":
        return previous_winner or "banker"
    if style == "counterBetter":
        return "player" if previous_winner == "banker" else "banker"
    if style == "randomTourist":
        return BET_TYPES[(hand_index * 7 + len(actual_winner)) % len(BET_TYPES)]
    if style == "bossStyle":
        return player_side
    if style == "houseStyle":
        return "banker" if actual_winner == "tie" else actual_winner
    return "banker"


def opponent_profit(stage: Stage, hand_index: int, previous_winner: Optional[str], player_side: str, winner: str) -> int:
    side = opponent_side(stage.opponent_style, hand_index, previous_winner, player_side, winner)
    multiplier = 1
    if stage.opponent_style == "highRoller":
        multiplier = 3 if hand_index % 3 == 0 else 1
    elif stage.opponent_style in ("bossStyle", "houseStyle"):
        multiplier = 2 if hand_index <= 6 else 3
    amount = min(stage.max_bet, max(stage.ante, stage.ante * multiplier))
    if winner == "tie" and side != "tie":
        return 0
    if side != winner:
        return -amount
    if side == "player":
        return amount
    if side == "banker":
        return amount * 95 // 100
    return amount * 8


def trigger_stage_start(state: SimState, stage: Stage, mods: Dict[str, ModifierDef]) -> int:
    reveal = 0
    for mod in active_defs(state, mods):
        if mod.trigger != "stageStarted":
            continue
        if mod.bankroll_ante_percent:
            state.bankroll += stage.ante * mod.bankroll_ante_percent // 100
            state.trigger(mod.id)
        if mod.chips:
            state.chips += mod.chips
            state.trigger(mod.id)
        if mod.prevent_heat and state.heat > 0:
            state.heat = max(0, state.heat - mod.prevent_heat)
            state.trigger(mod.id)
        if mod.reveal:
            reveal = max(reveal, mod.reveal)
            state.trigger(mod.id)
    return reveal


def apply_heat(state: SimState, amount: int, mods: Dict[str, ModifierDef]) -> None:
    remaining = amount
    for mod in active_defs(state, mods):
        if remaining <= 0:
            break
        if mod.trigger == "heatGained" and mod.prevent_heat:
            blocked = min(remaining, mod.prevent_heat)
            remaining -= blocked
            state.trigger(mod.id)
    state.heat += remaining


def resolve_payout(
    state: SimState,
    stage: Stage,
    mods: Dict[str, ModifierDef],
    bet_side: str,
    amount: int,
    winner: str,
    natural: bool,
) -> Tuple[int, int]:
    if winner == "tie" and bet_side != "tie":
        return amount, 0
    if winner != bet_side:
        refund = 0
        for mod in active_defs(state, mods):
            if mod.trigger == "playerLostBet" and (mod.side is None or mod.side == bet_side):
                if mod.refund_percent:
                    refund += amount * mod.refund_percent // 100
                    state.trigger(mod.id)
                if mod.heat_cost:
                    apply_heat(state, mod.heat_cost, mods)
        return refund, -amount + refund

    base = amount if bet_side == "player" else amount * 95 // 100 if bet_side == "banker" else amount * 8
    bonus = 0
    for mod in active_defs(state, mods):
        if mod.trigger not in ("playerWonBet", "tieOccurred", "naturalOccurred"):
            continue
        if mod.side is not None and mod.side != bet_side:
            continue
        if mod.payout_percent:
            bonus += base * mod.payout_percent // 100
            state.trigger(mod.id)
        if mod.bankroll_ante_percent:
            bonus += stage.ante * mod.bankroll_ante_percent // 100
            state.trigger(mod.id)
        if mod.chips:
            state.chips += mod.chips
            state.trigger(mod.id)
        if mod.heat_cost:
            apply_heat(state, mod.heat_cost, mods)
    if natural:
        for mod in active_defs(state, mods):
            if "natural" in mod.tags and mod.bankroll_ante_percent:
                bonus += stage.ante * mod.bankroll_ante_percent // 100
                state.trigger(mod.id)
    payout = amount + base + bonus
    return payout, base + bonus


def reward_cash(stage: Stage, bankroll: int, contact: Contact) -> int:
    multiplier = 3 if stage.id == 5 else 4 if stage.id == 8 else 5 if stage.id == 10 else 2 if stage.id <= 2 else 2
    raw = int(stage.ante * multiplier * contact.cash_multiplier)
    return min(raw, max(raw if bankroll <= 0 else bankroll // 2, 0))


def reward_chips(stage: Stage, secondary_complete: bool) -> int:
    if stage.is_boss:
        base = 5 if stage.id == 5 else 6 if stage.id == 8 else 8
    else:
        base = 2 if stage.id <= 3 else 3 if stage.id <= 7 else 4
    return base + (1 if secondary_complete else 0) + (1 if stage.table_event == "Private Table" else 0)


def choose_shop_modifier(state: SimState, stage: Stage, mods: Dict[str, ModifierDef]) -> Optional[ModifierDef]:
    tier = shop_tier(stage.id, state.bosses_defeated)
    owned = set(state.active_mods + state.bench_mods)
    candidates = [
        mod for mod in mods.values()
        if mod.min_tier <= tier and mod.rarity != "boss" and (mod.id not in owned or state.rng.random() < 0.18)
    ]
    if not candidates:
        return None
    state.rng.shuffle(candidates)
    offered = candidates[:4]
    state.shop_offers_seen += len(offered)
    tag_bias = set(state.contact.tags)
    strategy_tags = {
        "conservative_banker": {"banker", "economy", "heat"},
        "build_aware_simple": tag_bias | {"shoeVision", "economy"},
        "greedy_high_roller": {"betControl", "comeback", "banker"},
        "tie_hunter": {"tie", "comeback", "shoeVision"},
        "small_ball": {"economy", "betControl", "heat"},
        "random_beginner": tag_bias | {"economy"},
    }.get(state.strategy, tag_bias)

    def score(mod: ModifierDef) -> Tuple[int, int, int]:
        tag_score = sum(18 for tag in mod.tags if tag in strategy_tags)
        duplicate_bonus = 35 if mod.id in owned else 0
        affordability = 10 if mod.cost <= state.chips else -30
        return tag_score + duplicate_bonus + mod.score + affordability, -mod.cost, state.rng.randint(0, 20)

    pick = max(offered, key=score)
    if pick.cost > state.chips:
        return None
    state.chips -= pick.cost
    state.picked_modifiers.append(pick.id)
    if pick.id in owned:
        # Duplicate leveling is represented by an extra trigger weight copy.
        if len(state.active_mods) < 5:
            state.active_mods.append(pick.id)
        return pick
    if len(state.active_mods) < 5:
        state.active_mods.append(pick.id)
    elif len(state.bench_mods) < 2:
        state.bench_mods.append(pick.id)
    return pick


def secondary_complete(stage: Stage, stage_profit: int, heat_start: int, heat_end: int, winning_sides: set[str], trigger_count: int, final_hand_won: bool, fell_behind: bool, used_consumable: bool) -> bool:
    key = stage.secondary
    if key == "Clean Run":
        return heat_end <= heat_start
    if key == "Ahead of Schedule":
        return stage_profit > 0
    if key == "Engine Online":
        return trigger_count >= 3
    if key == "Longshot Hit":
        return "tie" in winning_sides
    if key == "Stay Small":
        return True
    if key == "Use the Layout":
        return len(winning_sides) >= 2
    if key == "Beat the Spread":
        return stage_profit >= stage.ante * 2
    if key == "Close Strong":
        return final_hand_won
    if key == "No Props":
        return not used_consumable
    if key == "Comeback Table":
        return fell_behind and stage_profit >= 0
    return False


def opponent_tolerance(stage: Stage) -> int:
    if stage.id == 1:
        return stage.ante * 9
    if stage.id == 2:
        return stage.ante * 3
    if stage.id == 3:
        return stage.ante * 2
    if stage.id == 4:
        return stage.ante // 2
    if stage.id == 7:
        return stage.ante * 8
    return 0


def simulate_run(seed: int, strategy: str, modifiers: Dict[str, ModifierDef], contacts: Dict[str, Contact]) -> RunSummary:
    rng = random.Random(seed)
    contact = choose_contact(strategy, contacts)
    state = SimState(
        rng=rng,
        strategy=strategy,
        contact=contact,
        bankroll=max(5_000, 25_000 + contact.bankroll_adjust),
        chips=max(0, 3 + contact.chips_adjust),
        heat=max(0, contact.heat_adjust),
        active_mods=[mid for mid in contact.starting_modifiers if mid in modifiers],
    )
    state.highest_bankroll = state.bankroll
    starting_bankroll = state.bankroll
    shoe = new_shoe(rng)
    stage_records: List[StageRecord] = []
    failure = "run_complete"

    for stage in STAGES:
        stage_start_bankroll = state.bankroll
        stage_start_heat = state.heat
        stage_start_chips = state.chips
        opponent_score = 0
        stage_trigger_start = sum(state.modifiers_triggered.values())
        winning_sides: set[str] = set()
        final_hand_won = False
        fell_behind = False
        used_consumable = False
        cold_table_triggered = False
        trigger_stage_start(state, stage, modifiers)

        for hand in range(1, stage.hands + 1):
            if len(shoe) < 20:
                shoe = new_shoe(rng)
            bet_side, amount, used_max = choose_bet(state, stage, shoe, modifiers)
            if amount <= 0 or state.bankroll < amount or state.bankroll < stage.min_bet():
                state.bankruptcies += 1
                failure = f"stage_{stage.id}_bankrupt"
                break

            if stage.id == 5:
                if state.last_bet_side == bet_side:
                    state.repeated_side_count += 1
                else:
                    state.repeated_side_count = 1
                if state.repeated_side_count >= 3:
                    opponent_score += stage.ante // 5
                    if state.repeated_side_count % 4 == 0:
                        apply_heat(state, 1, modifiers)
            elif stage.id == 8:
                if reveal_count(state, modifiers) > 0 and hand == 1:
                    opponent_score += stage.ante * 4
                    apply_heat(state, 2, modifiers)
            elif stage.id == 10:
                if state.last_bet_side == bet_side:
                    state.repeated_side_count += 1
                    if state.repeated_side_count >= 3:
                        # Mirror the live House pressure: repeated-side bets add
                        # small opponent score every time, but Heat only lands
                        # on every fourth repeated bet. The previous simulation
                        # applied Heat every hand after the third repeat, making
                        # the final boss mathematically unwinnable for stable
                        # Banker/Small Ball policies even when profit beat the
                        # opponent benchmark.
                        opponent_score += stage.ante * 3 // 4
                        if state.repeated_side_count % 4 == 0:
                            apply_heat(state, 1, modifiers)
                else:
                    state.repeated_side_count = 1

            state.last_bet_side = bet_side
            state.bankroll -= amount
            winner, _, _, natural, _ = deal_hand(shoe)
            payout, profit = resolve_payout(state, stage, modifiers, bet_side, amount, winner, natural)
            state.bankroll += payout
            did_win_bet = winner == bet_side
            is_push = winner == "tie" and bet_side != "tie"
            if stage.table_event == "Cold Table" and not cold_table_triggered and not did_win_bet and not is_push:
                cold_table_triggered = True
                opponent_score += stage.ante * 2
                apply_heat(state, 2, modifiers)
            if winner == bet_side:
                winning_sides.add(bet_side)
            if hand == stage.hands:
                final_hand_won = winner == bet_side
            opponent_score += opponent_profit(stage, hand, state.last_winner, bet_side, winner)
            stage_profit = state.bankroll - stage_start_bankroll
            fell_behind = fell_behind or stage_profit < opponent_score
            state.last_winner = winner
            state.total_hands += 1
            state.highest_bankroll = max(state.highest_bankroll, state.bankroll)

            if stage.table_event == "Tight Surveillance" and profit > stage.ante * 2:
                apply_heat(state, 1, modifiers)
            if stage.table_event == "Rich Crowd" and profit >= stage.ante * 2:
                state.chips += 1
            if state.heat >= 10:
                state.heat_deaths += 1
                failure = f"stage_{stage.id}_heat"
                break
            if state.bankroll < stage.min_bet():
                state.bankruptcies += 1
                failure = f"stage_{stage.id}_bankroll_minimum"
                break
        stage_profit = state.bankroll - stage_start_bankroll
        tolerance = opponent_tolerance(stage)
        clear = failure == "run_complete" and stage_profit >= opponent_score - tolerance
        stage_triggers = sum(state.modifiers_triggered.values()) - stage_trigger_start
        secondary = secondary_complete(stage, stage_profit, stage_start_heat, state.heat, winning_sides, stage_triggers, final_hand_won, fell_behind, used_consumable)
        if clear:
            if stage.is_boss:
                state.bosses_defeated += 1
            cash = reward_cash(stage, state.bankroll, contact)
            chips = reward_chips(stage, secondary)
            state.bankroll += cash
            state.chips += chips
            state.highest_bankroll = max(state.highest_bankroll, state.bankroll)
        else:
            if failure == "run_complete":
                failure = f"stage_{stage.id}_opponent_loss"
            if stage.is_boss and "stage_" in failure:
                failure = f"stage_{stage.id}_boss_loss"

        stage_records.append(
            StageRecord(
                stage=stage.id,
                clear=clear,
                boss=stage.is_boss,
                bankroll_start=stage_start_bankroll,
                bankroll_end=state.bankroll,
                heat_start=stage_start_heat,
                heat_end=state.heat,
                chips_start=stage_start_chips,
                chips_end=state.chips,
                player_profit=stage_profit,
                opponent_profit=opponent_score,
                hands=stage.hands,
                failure="" if clear else failure,
            )
        )

        if not clear:
            break
        choose_shop_modifier(state, stage, modifiers)

    completed = len(stage_records) == len(STAGES) and stage_records[-1].clear
    return RunSummary(
        seed=seed,
        strategy=strategy,
        contact=contact.name,
        final_stage=stage_records[-1].stage if stage_records else 1,
        completed=completed,
        failure="run_complete" if completed else failure,
        starting_bankroll=starting_bankroll,
        ending_bankroll=state.bankroll,
        highest_bankroll=state.highest_bankroll,
        heat=state.heat,
        chips=state.chips,
        hands=state.total_hands,
        bosses_defeated=state.bosses_defeated,
        picked_modifiers=state.picked_modifiers,
        triggered_modifiers=state.modifiers_triggered,
        stages=stage_records,
    )


def aggregate(runs: List[RunSummary]) -> Dict[str, object]:
    clear_counts = {stage.id: 0 for stage in STAGES}
    attempts = {stage.id: 0 for stage in STAGES}
    boss_clear_counts = {stage.id: 0 for stage in STAGES if stage.is_boss}
    modifier_picks: Dict[str, int] = {}
    modifier_triggers: Dict[str, int] = {}
    failures: Dict[str, int] = {}
    bankroll_by_stage: Dict[int, List[int]] = {stage.id: [] for stage in STAGES}
    heat_by_stage: Dict[int, List[int]] = {stage.id: [] for stage in STAGES}
    chips_by_stage: Dict[int, List[int]] = {stage.id: [] for stage in STAGES}

    for run in runs:
        failures[run.failure] = failures.get(run.failure, 0) + 1
        for picked in run.picked_modifiers:
            modifier_picks[picked] = modifier_picks.get(picked, 0) + 1
        for modifier_id, count in run.triggered_modifiers.items():
            modifier_triggers[modifier_id] = modifier_triggers.get(modifier_id, 0) + count
        for record in run.stages:
            attempts[record.stage] += 1
            if record.clear:
                clear_counts[record.stage] += 1
                if record.boss:
                    boss_clear_counts[record.stage] += 1
            bankroll_by_stage[record.stage].append(record.bankroll_end)
            heat_by_stage[record.stage].append(record.heat_end)
            chips_by_stage[record.stage].append(record.chips_end)

    def rate(stage_id: int) -> float:
        return clear_counts[stage_id] / attempts[stage_id] if attempts[stage_id] else 0.0

    return {
        "runs": len(runs),
        "completion_rate": sum(1 for run in runs if run.completed) / max(1, len(runs)),
        "avg_final_stage": mean(run.final_stage for run in runs) if runs else 0,
        "avg_hands": mean(run.hands for run in runs) if runs else 0,
        "avg_ending_bankroll": mean(run.ending_bankroll for run in runs) if runs else 0,
        "avg_highest_bankroll": mean(run.highest_bankroll for run in runs) if runs else 0,
        "stage_attempts": {str(stage.id): attempts[stage.id] for stage in STAGES},
        "stage_clears": {str(stage.id): clear_counts[stage.id] for stage in STAGES},
        "stage_clear_rates": {str(stage.id): round(rate(stage.id), 3) for stage in STAGES},
        "boss_clear_rates": {
            str(stage.id): round((boss_clear_counts[stage.id] / attempts[stage.id]) if attempts[stage.id] else 0, 3)
            for stage in STAGES if stage.is_boss
        },
        "avg_bankroll_by_stage": {
            str(stage_id): round(mean(values), 1) for stage_id, values in bankroll_by_stage.items() if values
        },
        "avg_heat_by_stage": {
            str(stage_id): round(mean(values), 2) for stage_id, values in heat_by_stage.items() if values
        },
        "avg_chips_by_stage": {
            str(stage_id): round(mean(values), 2) for stage_id, values in chips_by_stage.items() if values
        },
        "failures": dict(sorted(failures.items(), key=lambda item: (-item[1], item[0]))[:12]),
        "most_picked_modifiers": dict(sorted(modifier_picks.items(), key=lambda item: (-item[1], item[0]))[:12]),
        "most_triggered_modifiers": dict(sorted(modifier_triggers.items(), key=lambda item: (-item[1], item[0]))[:12]),
        "least_triggered_picked_modifiers": {
            key: modifier_triggers.get(key, 0)
            for key, _ in sorted(modifier_picks.items(), key=lambda item: (-item[1], item[0]))[:20]
            if modifier_triggers.get(key, 0) == 0
        },
    }


def grouped_aggregates(runs: List[RunSummary]) -> Dict[str, Dict[str, object]]:
    groups: Dict[str, List[RunSummary]] = {}
    for run in runs:
        groups.setdefault(run.strategy, []).append(run)
    return {key: aggregate(value) for key, value in sorted(groups.items())}


def diagnose(summary: Dict[str, object]) -> List[str]:
    notes: List[str] = []
    stage_rates = summary["stage_clear_rates"]
    assert isinstance(stage_rates, dict)
    for stage_id, target in TARGET_CLEAR_RATES.items():
        key = str(stage_id)
        if key not in stage_rates:
            continue
        rate = float(stage_rates[key])
        low, high = target
        if rate < low:
            notes.append(f"Stage {stage_id} clear rate {rate:.0%} is below target {low:.0%}-{high:.0%}.")
        elif rate > high:
            notes.append(f"Stage {stage_id} clear rate {rate:.0%} is above target {low:.0%}-{high:.0%}.")
    if float(summary["completion_rate"]) > 0.35:
        notes.append("Completion rate is high for an early vertical slice; late stages may be too forgiving.")
    if float(summary["avg_highest_bankroll"]) > float(summary["avg_ending_bankroll"]) * 4:
        notes.append("Large bankroll spikes are appearing; inspect high-roller and payout multiplier stacks.")
    if not notes:
        notes.append("No major clear-rate alarms in this batch.")
    return notes


def render_markdown(report: Dict[str, object], output_json: Path) -> str:
    generated = time.strftime("%Y-%m-%d %H:%M:%S")
    aggregate_report = report["aggregate"]
    assert isinstance(aggregate_report, dict)
    diagnostics = report["diagnostics"]
    assert isinstance(diagnostics, list)
    lines = [
        "# Rigged Shoe Balance Report",
        "",
        f"Generated: {generated}",
        "",
        "## Simulator",
        "",
        "- Runner: `Tools/Simulation/rigged_shoe_sim.py`",
        f"- JSON output: `{output_json}`",
        f"- Runs: {report['run_count']}",
        f"- Strategies: {', '.join(report['strategies'])}",
        f"- Seed: {report['seed']}",
        f"- Elapsed: {report['elapsed_seconds']}s",
        f"- Peak RSS: {report['max_rss_mb']} MB",
        "",
        "## Summary",
        "",
        f"- Completion rate: {float(aggregate_report['completion_rate']):.1%}",
        f"- Average final stage: {float(aggregate_report['avg_final_stage']):.2f}",
        f"- Average hands: {float(aggregate_report['avg_hands']):.1f}",
        f"- Average ending bankroll: {cents(int(float(aggregate_report['avg_ending_bankroll'])))}",
        f"- Average highest bankroll: {cents(int(float(aggregate_report['avg_highest_bankroll'])))}",
        "",
        "## Stage Clear Rates",
        "",
        "| Stage | Attempts | Clears | Actual | Target | Notes |",
        "|---|---:|---:|---:|---:|---|",
    ]
    stage_rates = aggregate_report["stage_clear_rates"]
    stage_attempts = aggregate_report["stage_attempts"]
    stage_clears = aggregate_report["stage_clears"]
    assert isinstance(stage_rates, dict)
    assert isinstance(stage_attempts, dict)
    assert isinstance(stage_clears, dict)
    for stage in STAGES:
        low, high = TARGET_CLEAR_RATES[stage.id]
        key = str(stage.id)
        actual = float(stage_rates.get(key, 0))
        status = "OK" if low <= actual <= high else ("Too hard" if actual < low else "Too easy")
        lines.append(
            f"| {stage.id}{' Boss' if stage.is_boss else ''} | "
            f"{int(stage_attempts.get(key, 0))} | {int(stage_clears.get(key, 0))} | "
            f"{actual:.1%} | {low:.0%}-{high:.0%} | {status} |"
        )
    lines += [
        "",
        "## Strategy Comparison",
        "",
        "| Strategy | Completion | Avg Final Stage | Stage 1 | Stage 2 | Stage 3 | Boss 1 |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    by_strategy = report.get("by_strategy", {})
    assert isinstance(by_strategy, dict)
    for strategy, strategy_report in by_strategy.items():
        assert isinstance(strategy_report, dict)
        rates = strategy_report["stage_clear_rates"]
        assert isinstance(rates, dict)
        lines.append(
            f"| {strategy} | {float(strategy_report['completion_rate']):.1%} | "
            f"{float(strategy_report['avg_final_stage']):.2f} | "
            f"{float(rates.get('1', 0)):.1%} | {float(rates.get('2', 0)):.1%} | "
            f"{float(rates.get('3', 0)):.1%} | {float(rates.get('5', 0)):.1%} |"
        )
    lines += [
        "",
        "## Economy",
        "",
        "Average bankroll, Heat, and Chips after each reached stage.",
        "",
        "| Stage | Bankroll | Heat | Chips |",
        "|---|---:|---:|---:|",
    ]
    bankrolls = aggregate_report["avg_bankroll_by_stage"]
    heats = aggregate_report["avg_heat_by_stage"]
    chips = aggregate_report["avg_chips_by_stage"]
    assert isinstance(bankrolls, dict) and isinstance(heats, dict) and isinstance(chips, dict)
    for stage in STAGES:
        key = str(stage.id)
        if key in bankrolls:
            lines.append(f"| {stage.id} | {cents(int(float(bankrolls[key])))} | {float(heats.get(key, 0)):.2f} | {float(chips.get(key, 0)):.2f} |")
    lines += [
        "",
        "## Common Failure Points",
        "",
    ]
    failures = aggregate_report["failures"]
    assert isinstance(failures, dict)
    for key, value in failures.items():
        lines.append(f"- {key}: {value}")
    lines += [
        "",
        "## Modifiers",
        "",
        "### Most Picked",
        "",
    ]
    for key, value in aggregate_report["most_picked_modifiers"].items():
        lines.append(f"- {key}: {value}")
    lines += [
        "",
        "### Most Triggered",
        "",
    ]
    for key, value in aggregate_report["most_triggered_modifiers"].items():
        lines.append(f"- {key}: {value}")
    lines += [
        "",
        "### Picked But Never Triggered",
        "",
    ]
    least = aggregate_report["least_triggered_picked_modifiers"]
    assert isinstance(least, dict)
    if least:
        for key in least:
            lines.append(f"- {key}")
    else:
        lines.append("- None in this batch.")
    lines += [
        "",
        "## Diagnostics",
        "",
    ]
    for note in diagnostics:
        lines.append(f"- {note}")
    lines += [
        "",
        "## Notes",
        "",
        "- This is a headless balance model, not a UI test.",
        "- It intentionally stores compact run summaries only.",
        "- Modifier effects are simplified but tied to current catalog IDs, tags, tiers, and common effect families.",
        "- Physical iOS Simulator testing is tracked separately in `Docs/PhysicalPlaytestReport.md`.",
        "",
    ]
    return "\n".join(lines)


def run_batch(runs: int, seed: int, strategies: Sequence[str]) -> Dict[str, object]:
    start = time.perf_counter()
    modifiers = parse_modifiers()
    contacts = parse_contacts()
    summaries: List[RunSummary] = []
    for strategy_index, strategy in enumerate(strategies):
        for offset in range(runs):
            summaries.append(simulate_run(seed + strategy_index * 10_000 + offset * 37, strategy, modifiers, contacts))
    elapsed = time.perf_counter() - start
    raw_rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    rss_mb = raw_rss / (1024 * 1024) if raw_rss > 10_000_000 else raw_rss / 1024
    aggregate_report = aggregate(summaries)
    return {
        "seed": seed,
        "runs_per_strategy": runs,
        "run_count": len(summaries),
        "strategies": list(strategies),
        "elapsed_seconds": round(elapsed, 3),
        "max_rss_mb": round(rss_mb, 2),
        "content_counts": {
            "modifiers_parsed": len(modifiers),
            "contacts_parsed": len(contacts),
            "stages": len(STAGES),
        },
        "aggregate": aggregate_report,
        "by_strategy": grouped_aggregates(summaries),
        "diagnostics": diagnose(aggregate_report),
        "sample_runs": [asdict(run) for run in summaries[: min(8, len(summaries))]],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Run headless Rigged Shoe roguelite balance simulations.")
    parser.add_argument("--runs", type=int, default=20, help="Runs per policy. Use 17 for 102 total runs across six policies.")
    parser.add_argument("--seed", type=int, default=20260622)
    parser.add_argument("--json", type=Path, default=ROOT / "Docs" / "sim-rebuild-balance-latest.json")
    parser.add_argument("--markdown", type=Path, default=REPORT_PATH)
    parser.add_argument(
        "--strategies",
        nargs="*",
        default=["random_beginner", "conservative_banker", "build_aware_simple", "greedy_high_roller", "tie_hunter", "small_ball"],
        choices=["random_beginner", "conservative_banker", "build_aware_simple", "greedy_high_roller", "tie_hunter", "small_ball"],
    )
    args = parser.parse_args()
    report = run_batch(args.runs, args.seed, args.strategies)
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(report, indent=2) + "\n")
    if args.markdown:
        args.markdown.parent.mkdir(parents=True, exist_ok=True)
        args.markdown.write_text(render_markdown(report, args.json) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
