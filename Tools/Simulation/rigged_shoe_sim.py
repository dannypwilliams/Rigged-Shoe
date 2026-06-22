#!/usr/bin/env python3
"""Lightweight Rigged Shoe balance simulator.

This intentionally mirrors the current model layer at a compact level instead
of launching the UI. It keeps only run summaries so it stays safe on low-RAM
machines, and it parses upgrade values from the Swift source so balance passes
do not drift silently.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import resource
import time
from dataclasses import dataclass, field
from pathlib import Path
from statistics import mean
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


ROOT = Path(__file__).resolve().parents[2]
UPGRADE_SWIFT = ROOT / "RiggedShoe" / "Models" / "UpgradeCard.swift"
PROFILE_SWIFT = ROOT / "RiggedShoe" / "Models" / "PlayerProfile.swift"
VM_SWIFT = ROOT / "RiggedShoe" / "ViewModels" / "GameViewModel.swift"


SUITS = ["C", "D", "H", "S"]
RANKS = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
VALUES = {"A": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 0, "J": 0, "Q": 0, "K": 0}


@dataclass(frozen=True)
class Stage:
    id: int
    round_limit: int
    allowed_bets: Tuple[int, ...]
    objective: str
    target: int
    min_bankroll: int = 0
    target_profit: int = 0
    loss_limit: int = 0


STAGES = [
    Stage(1, 10, (1000,), "survive", 10, min_bankroll=20_000),
    Stage(2, 10, (1000, 2000), "loss_limit", 10, loss_limit=6_000),
    Stage(3, 12, (1000, 2000, 3000), "grow_by", 1_500),
    Stage(4, 12, (1000, 2000, 3000, 5000), "upgrade_win", 1, target_profit=6_000),
    Stage(5, 12, (1000, 2000, 3000, 5000, 7500), "grow_by", 12_500),
    Stage(6, 12, (1000, 2000, 3000, 5000, 7500, 10_000), "profit", 15_000),
    Stage(7, 12, (1000, 2000, 3000, 5000, 7500, 10_000, 20_000), "profit", 25_000),
    Stage(8, 12, (1000, 2000, 3000, 5000, 7500, 10_000, 20_000, 30_000), "profit", 45_000),
    Stage(9, 12, (1000, 2000, 3000, 5000, 7500, 10_000, 20_000, 30_000, 50_000), "profit", 75_000),
    Stage(10, 12, (1000, 2000, 3000, 5000, 7500, 10_000, 20_000, 30_000, 50_000, 100_000), "profit", 125_000),
]


@dataclass
class Upgrade:
    name: str
    description: str
    rarity: str
    tags: Tuple[str, ...]
    effect: str
    money_score: int = 0
    reveal_count: int = 0
    charged_reveal_count: int = 0
    player_bonus: int = 0
    banker_bonus: int = 0
    chosen_bonus: int = 0
    forecast_bonus: int = 0
    round_stipend: int = 0
    stage_start_cash: int = 0
    card_exit_income: int = 0
    loss_rebate_percent: int = 0
    damage_rebate_percent: int = 0
    small_bet_multiplier: int = 100
    small_bet_max: int = 0
    small_streak_required: int = 0
    small_streak_bonus: int = 0
    press_multiplier: int = 100
    profit_multiplier_all: int = 100
    profit_multiplier_player: int = 100
    profit_multiplier_banker: int = 100
    profit_multiplier_tie: int = 100
    loss_multiplier: int = 100
    tie_multiplier: int = 8
    no_commission: bool = False
    low_value_duplicate: bool = False


@dataclass
class Effects:
    player_bonus: int = 0
    banker_bonus: int = 0
    chosen_bonus: int = 0
    forecast_bonus: int = 0
    round_stipend: int = 0
    stage_start_cash: int = 0
    card_exit_income: int = 0
    loss_rebate_percent: int = 0
    damage_rebate_percent: int = 0
    damage_every_hands: int = 3
    small_bet_multiplier: int = 100
    small_bet_max: int = 0
    small_streak_required: int = 0
    small_streak_bonus: int = 0
    press_multiplier: int = 100
    profit_multiplier_all: int = 100
    profit_multiplier_player: int = 100
    profit_multiplier_banker: int = 100
    profit_multiplier_tie: int = 100
    loss_multiplier: int = 100
    reveal_count: int = 0
    charged_reveal_count: int = 0
    tie_multiplier: int = 8
    no_commission: bool = False


@dataclass
class RunSummary:
    seed: int
    strategy: str
    pool: str
    starting_bankroll: int
    ending_bankroll: int
    highest_bankroll: int
    stage_reached: int
    rounds_played: int
    bosses_defeated: int
    upgrade_choices_offered: int
    upgrades_taken: List[str]
    useful_upgrade_triggers: Dict[str, int]
    failure_point: str
    cleared_first_three: bool
    used_max_bet_ratio: float


def cents(amount: int) -> str:
    return f"${amount / 100:,.0f}" if amount % 100 == 0 else f"${amount / 100:,.2f}"


def parse_int(token: str) -> int:
    return int(token.replace("_", ""))


def parse_card_line(line: str) -> Optional[Tuple[str, str, str, str, Tuple[str, ...]]]:
    match = re.search(r'card\("([^"]+)",\s*"([^"]+)",\s*\.(\w+),\s*(.*),\s*\[([^\]]*)\]\)', line.strip())
    if not match:
        return None
    tags = tuple(re.findall(r"\.(\w+)", match.group(5)))
    return match.group(1), match.group(2), match.group(3), match.group(4), tags


def parse_upgrades() -> List[Upgrade]:
    upgrades: List[Upgrade] = []
    for line in UPGRADE_SWIFT.read_text().splitlines():
        parsed = parse_card_line(line)
        if not parsed:
            continue
        name, description, rarity, effect, tags = parsed
        upgrade = Upgrade(name=name, description=description, rarity=rarity, tags=tags, effect=effect)
        apply_effect_parse(upgrade)
        upgrade.low_value_duplicate = not has_meaningful_duplicate_value(effect)
        upgrade.money_score = (
            upgrade.player_bonus
            + upgrade.banker_bonus
            + upgrade.chosen_bonus
            + upgrade.forecast_bonus
            + upgrade.round_stipend * 6
            + upgrade.stage_start_cash
            + upgrade.card_exit_income * 24
            + upgrade.small_streak_bonus
        )
        upgrades.append(upgrade)
    return upgrades


def has_meaningful_duplicate_value(effect: str) -> bool:
    stackable_tokens = (
        ".addExtraNines", ".addExtraEights", ".addCards", ".addRandomCards", ".addTiePairCards",
        ".removeZeroValueCards", ".removeCards", ".playerWinBonus", ".bankerWinBonus",
        ".chosenBetWinBonus", ".forecastWinBonus", ".tiePayoutBonus", ".revealAfterRound",
        ".hotShoe", ".coldShoe", ".profitMultiplier", ".lossMultiplier", ".lossRebatePercent",
        ".roundStipend", ".stageStartCash", ".cardExitIncome", ".streakBonus",
        ".firstTieEachStageMultiplier", ".consecutiveTiePayoutBonus", ".previousLossRefundOnTie",
        ".bossStageCash", ".safetyNet", ".smallBetWinMultiplier", ".smallBetStreakBonus",
        ".pressAfterWinMultiplier", ".lossRebateEveryHands", ".bankerInitialTotalBonus",
        ".firstNaturalEachStageBonus", ".comebackWinBonus", ".firstLargeBetStageMultiplier",
        ".steadyBetWinBonus", ".raiseWinBonus",
    )
    return any(token in effect for token in stackable_tokens)


def apply_effect_parse(upgrade: Upgrade) -> None:
    effect = upgrade.effect
    for value in re.findall(r"\.playerWinBonus\(cents:\s*([0-9_]+)\)", effect):
        upgrade.player_bonus += parse_int(value)
    for value in re.findall(r"\.bankerWinBonus\(cents:\s*([0-9_]+)\)", effect):
        upgrade.banker_bonus += parse_int(value)
    for value in re.findall(r"\.chosenBetWinBonus\(cents:\s*([0-9_]+)\)", effect):
        upgrade.chosen_bonus += parse_int(value)
    for value in re.findall(r"\.forecastWinBonus\(cents:\s*([0-9_]+)\)", effect):
        upgrade.forecast_bonus += parse_int(value)
    for value in re.findall(r"\.roundStipend\(cents:\s*([0-9_]+)\)", effect):
        upgrade.round_stipend += parse_int(value)
    for value in re.findall(r"\.stageStartCash\(cents:\s*([0-9_]+)\)", effect):
        upgrade.stage_start_cash += parse_int(value)
    for value in re.findall(r"\.cardExitIncome\(centsPerCard:\s*([0-9_]+)\)", effect):
        upgrade.card_exit_income += parse_int(value)
    for value in re.findall(r"\.lossRebatePercent\(percent:\s*([0-9_]+)\)", effect):
        upgrade.loss_rebate_percent = max(upgrade.loss_rebate_percent, parse_int(value))
    for value in re.findall(r"\.lossMultiplier\(percent:\s*([0-9_]+)\)", effect):
        upgrade.loss_multiplier += max(0, parse_int(value) - 100)
    for max_bet, percent in re.findall(r"\.smallBetWinMultiplier\(maxBetCents:\s*([0-9_]+),\s*percent:\s*([0-9_]+)\)", effect):
        upgrade.small_bet_max = max(upgrade.small_bet_max, parse_int(max_bet))
        upgrade.small_bet_multiplier += max(0, parse_int(percent) - 100)
    for max_bet, wins, value in re.findall(r"\.smallBetStreakBonus\(maxBetCents:\s*([0-9_]+),\s*requiredWins:\s*([0-9_]+),\s*cents:\s*([0-9_]+)\)", effect):
        upgrade.small_bet_max = max(upgrade.small_bet_max, parse_int(max_bet))
        upgrade.small_streak_required = parse_int(wins)
        upgrade.small_streak_bonus += parse_int(value)
    for percent in re.findall(r"\.pressAfterWinMultiplier\(percent:\s*([0-9_]+)\)", effect):
        upgrade.press_multiplier += max(0, parse_int(percent) - 100)
    for percent, every in re.findall(r"\.lossRebateEveryHands\(percent:\s*([0-9_]+),\s*everyHands:\s*([0-9_]+)\)", effect):
        upgrade.damage_rebate_percent = max(upgrade.damage_rebate_percent, parse_int(percent))
    for multiplier in re.findall(r"\.improveTiePayout\(multiplier:\s*([0-9_]+)\)", effect):
        upgrade.tie_multiplier = max(upgrade.tie_multiplier, parse_int(multiplier))
    for amount in re.findall(r"\.tiePayoutBonus\(amount:\s*([0-9_]+)\)", effect):
        upgrade.tie_multiplier += parse_int(amount)
    if ".noCommission" in effect:
        upgrade.no_commission = True
    for bet, percent in re.findall(r"\.profitMultiplier\(betType:\s*([^,]+),\s*percent:\s*([0-9_]+)\)", effect):
        value = parse_int(percent)
        if ".player" in bet:
            upgrade.profit_multiplier_player += max(0, value - 100)
        elif ".banker" in bet:
            upgrade.profit_multiplier_banker += max(0, value - 100)
        elif ".tie" in bet:
            upgrade.profit_multiplier_tie += max(0, value - 100)
        else:
            upgrade.profit_multiplier_all += max(0, value - 100)
    for value in re.findall(r"\.revealCards\(count:\s*([0-9_]+)\)", effect):
        upgrade.reveal_count = max(upgrade.reveal_count, min(5, parse_int(value)))
    reveal_map = {
        ".peek": 1,
        ".readTheShoe": 2,
        ".smudgedLens": 3,
        ".bentCorner": 3,
        ".xRay": 0,
        ".fullXRay": 0,
    }
    for key, count in reveal_map.items():
        if key in effect:
            upgrade.reveal_count = max(upgrade.reveal_count, count)
    if ".xRay" in effect:
        upgrade.charged_reveal_count = max(upgrade.charged_reveal_count, 3)
    if ".fullXRay" in effect:
        upgrade.charged_reveal_count = max(upgrade.charged_reveal_count, 4)


def parse_default_unlocked() -> set[str]:
    text = PROFILE_SWIFT.read_text()
    match = re.search(r"defaultUnlockedUpgradeNames:\s*Set<String>\s*=\s*\[(.*?)\]", text, re.S)
    if not match:
        return set()
    return set(re.findall(r'"([^"]+)"', match.group(1)))


def parse_guided_bonus() -> int:
    text = VM_SWIFT.read_text()
    match = re.search(r"private func guidedFirstWinBonusIfNeeded.*?\n    \}", text, re.S)
    if not match:
        return 7_500
    returns = re.findall(r"return\s+([0-9_]+)", match.group(0))
    non_zero_returns = [parse_int(value) for value in returns if parse_int(value) > 0]
    return non_zero_returns[-1] if non_zero_returns else 0


def new_shoe(rng: random.Random) -> List[Tuple[str, str]]:
    cards = [(rank, suit) for _ in range(6) for suit in SUITS for rank in RANKS]
    rng.shuffle(cards)
    return cards


def baccarat_value(card: Tuple[str, str]) -> int:
    return VALUES[card[0]]


def hand_total(cards: Sequence[Tuple[str, str]]) -> int:
    return sum(baccarat_value(card) for card in cards) % 10


def should_banker_draw(banker_total: int, player_third: Optional[Tuple[str, str]]) -> bool:
    if player_third is None:
        return banker_total <= 5
    value = baccarat_value(player_third)
    if banker_total <= 2:
        return True
    if banker_total == 3:
        return value != 8
    if banker_total == 4:
        return 2 <= value <= 7
    if banker_total == 5:
        return 4 <= value <= 7
    if banker_total == 6:
        return 6 <= value <= 7
    return False


def deal_hand(shoe: List[Tuple[str, str]]) -> Tuple[str, int, int, int, bool]:
    p1 = shoe.pop(0)
    b1 = shoe.pop(0)
    p2 = shoe.pop(0)
    b2 = shoe.pop(0)
    player = [p1, p2]
    banker = [b1, b2]
    p_total = hand_total(player)
    b_total = hand_total(banker)
    natural = p_total in (8, 9) or b_total in (8, 9)
    dealt = 4
    if not natural:
        player_third = None
        if p_total <= 5:
            player_third = shoe.pop(0)
            player.append(player_third)
            dealt += 1
            p_total = hand_total(player)
        if should_banker_draw(hand_total(banker), player_third):
            banker.append(shoe.pop(0))
            dealt += 1
            b_total = hand_total(banker)
    if p_total > b_total:
        winner = "player"
    elif b_total > p_total:
        winner = "banker"
    else:
        winner = "tie"
    return winner, p_total, b_total, dealt, natural


def forecast_from_preview(shoe: Sequence[Tuple[str, str]], count: int) -> Optional[str]:
    if count < 4 or len(shoe) < 4:
        return None
    copy = list(shoe[:6])
    try:
        winner, _, _, _, _ = deal_hand(copy)
        return winner
    except IndexError:
        return None


def combine_effects(upgrades: Iterable[Upgrade]) -> Effects:
    effects = Effects()
    for upgrade in upgrades:
        effects.player_bonus += upgrade.player_bonus
        effects.banker_bonus += upgrade.banker_bonus
        effects.chosen_bonus += upgrade.chosen_bonus
        effects.forecast_bonus += upgrade.forecast_bonus
        effects.round_stipend += upgrade.round_stipend
        effects.stage_start_cash += upgrade.stage_start_cash
        effects.card_exit_income += upgrade.card_exit_income
        effects.loss_rebate_percent = max(effects.loss_rebate_percent, upgrade.loss_rebate_percent)
        effects.damage_rebate_percent = max(effects.damage_rebate_percent, upgrade.damage_rebate_percent)
        effects.small_bet_multiplier += max(0, upgrade.small_bet_multiplier - 100)
        effects.small_bet_max = max(effects.small_bet_max, upgrade.small_bet_max)
        if upgrade.small_streak_required:
            effects.small_streak_required = upgrade.small_streak_required if effects.small_streak_required == 0 else min(effects.small_streak_required, upgrade.small_streak_required)
        effects.small_streak_bonus += upgrade.small_streak_bonus
        effects.press_multiplier += max(0, upgrade.press_multiplier - 100)
        effects.profit_multiplier_all += max(0, upgrade.profit_multiplier_all - 100)
        effects.profit_multiplier_player += max(0, upgrade.profit_multiplier_player - 100)
        effects.profit_multiplier_banker += max(0, upgrade.profit_multiplier_banker - 100)
        effects.profit_multiplier_tie += max(0, upgrade.profit_multiplier_tie - 100)
        effects.loss_multiplier += max(0, upgrade.loss_multiplier - 100)
        effects.reveal_count = max(effects.reveal_count, upgrade.reveal_count)
        effects.charged_reveal_count = max(effects.charged_reveal_count, upgrade.charged_reveal_count)
        effects.tie_multiplier = max(effects.tie_multiplier, upgrade.tie_multiplier)
        effects.no_commission = effects.no_commission or upgrade.no_commission
    return effects


def weighted_upgrade_choices(rng: random.Random, pool: List[Upgrade], acquired: List[Upgrade], count: int = 3) -> List[Upgrade]:
    choices: List[Upgrade] = []
    used: set[str] = set()
    low_value_duplicate_names = {upgrade.name for upgrade in acquired if upgrade.low_value_duplicate}
    for _ in range(160):
        if len(choices) == count:
            break
        roll = rng.randint(1, 100)
        rarity = "common" if roll <= 70 else "rare" if roll <= 95 else "legendary"
        candidates = [
            card for card in pool
            if card.rarity == rarity and card.name not in used and card.name not in low_value_duplicate_names
        ]
        if not candidates:
            continue
        card = rng.choice(candidates)
        choices.append(card)
        used.add(card.name)
    if len(choices) < count:
        for card in rng.sample(pool, len(pool)):
            if card.name not in used and card.name not in low_value_duplicate_names:
                choices.append(card)
                used.add(card.name)
                if len(choices) == count:
                    break
    if len(choices) < count:
        for card in rng.sample(pool, len(pool)):
            if card.name not in used:
                choices.append(card)
                used.add(card.name)
                if len(choices) == count:
                    break
    return choices


def choose_upgrade(strategy: str, choices: List[Upgrade], acquired: List[Upgrade]) -> Upgrade:
    preferred_tags = {
        "conservative": ["conservative", "economy", "comeback", "reveal"],
        "aggressive": ["risk", "aggressive", "economy", "banker"],
        "synergy": most_common_tags(acquired) + ["reveal", "economy", "shoe"],
        "unclear": ["reveal", "shoe", "tie"],
    }.get(strategy, ["economy", "reveal"])
    def score(card: Upgrade) -> Tuple[int, int]:
        tag_score = sum(12 for tag in card.tags if tag in preferred_tags)
        rarity_score = {"common": 0, "rare": 4, "legendary": 8}.get(card.rarity, 0)
        return tag_score + rarity_score + min(20, card.money_score // 2_500), card.money_score
    return max(choices, key=score)


def most_common_tags(upgrades: List[Upgrade]) -> List[str]:
    counts: Dict[str, int] = {}
    for upgrade in upgrades:
        for tag in upgrade.tags:
            counts[tag] = counts.get(tag, 0) + 1
    return [tag for tag, _ in sorted(counts.items(), key=lambda item: -item[1])[:2]]


def choose_bet(strategy: str, stage: Stage, bankroll: int, stage_start: int, effects: Effects, shoe: List[Tuple[str, str]], xray_active: bool) -> Tuple[str, int, bool]:
    legal_amounts = [amount for amount in stage.allowed_bets if amount <= bankroll]
    if not legal_amounts:
        return "banker", 0, False
    min_bet = min(legal_amounts)
    max_bet = max(legal_amounts)
    reveal_count = effects.charged_reveal_count if xray_active else effects.reveal_count
    forecast = forecast_from_preview(shoe, reveal_count)
    used_max = False

    if strategy == "aggressive":
        bet = max_bet if bankroll >= stage_start else min(max_bet, max(min_bet, bankroll // 4))
        used_max = bet == max_bet
    elif strategy == "synergy":
        bet = min(max_bet, legal_amounts[min(1, len(legal_amounts) - 1)])
    else:
        bet = min_bet

    if xray_active:
        bet = min(bet, min_bet * 3)
    bet_type = forecast if forecast in ("player", "banker") else "banker"
    if strategy == "unclear" and forecast is None:
        bet_type = "player"
    return bet_type, bet, used_max


def payout_for_round(winner: str, bet_type: str, bet: int, effects: Effects, cards_dealt: int, forecast: Optional[str], was_natural: bool, last_win: bool, last_bet: int, small_win_streak: int) -> Tuple[int, Dict[str, int], bool]:
    triggers: Dict[str, int] = {}
    passive = effects.round_stipend + effects.card_exit_income * cards_dealt
    if passive:
        triggers["passive_income"] = passive

    if winner == "tie" and bet_type != "tie":
        return bet + passive, triggers, True

    if winner != bet_type:
        rebate = bet * effects.loss_rebate_percent // 100
        if effects.damage_rebate_percent:
            rebate = max(rebate, bet * effects.damage_rebate_percent // 100)
        extra_loss = bet * max(0, effects.loss_multiplier - 100) // 100
        if rebate:
            triggers["loss_rebate"] = rebate
        if extra_loss:
            triggers["risk_penalty"] = -extra_loss
        return passive + rebate - extra_loss, triggers, False

    if bet_type == "player":
        profit = bet
    elif bet_type == "banker":
        profit = bet if effects.no_commission else bet * 95 // 100
    else:
        profit = bet * effects.tie_multiplier

    multiplier = effects.profit_multiplier_all
    if bet_type == "player":
        multiplier += effects.profit_multiplier_player - 100
    elif bet_type == "banker":
        multiplier += effects.profit_multiplier_banker - 100
    else:
        multiplier += effects.profit_multiplier_tie - 100
    profit = profit * multiplier // 100

    flat = passive + effects.chosen_bonus
    if effects.chosen_bonus:
        triggers["chosen_bonus"] = effects.chosen_bonus
    if bet_type == "player" and effects.player_bonus:
        flat += effects.player_bonus
        triggers["player_bonus"] = effects.player_bonus
    if bet_type == "banker" and effects.banker_bonus:
        flat += effects.banker_bonus
        triggers["banker_bonus"] = effects.banker_bonus
    if forecast == winner and effects.forecast_bonus:
        flat += effects.forecast_bonus
        triggers["forecast_bonus"] = effects.forecast_bonus
    if bet <= effects.small_bet_max and effects.small_bet_multiplier > 100:
        before = profit
        profit = profit * effects.small_bet_multiplier // 100
        triggers["small_bet_multiplier"] = profit - before
    if last_win and bet > last_bet and effects.press_multiplier > 100:
        before = profit
        profit = profit * effects.press_multiplier // 100
        triggers["press_multiplier"] = profit - before
    if effects.small_streak_required and (small_win_streak + 1) % effects.small_streak_required == 0:
        flat += effects.small_streak_bonus
        triggers["small_streak"] = effects.small_streak_bonus
    return bet + profit + flat, triggers, False


def stage_complete(stage: Stage, bankroll: int, stage_start: int, rounds: int, min_bankroll: int, upgrade_wins: int) -> bool:
    profit = bankroll - stage_start
    if stage.target_profit and profit >= stage.target_profit:
        return True
    if stage.objective == "survive":
        return rounds >= stage.target and min_bankroll >= stage.min_bankroll
    if stage.objective == "break_even":
        return rounds >= stage.target and profit >= 0
    if stage.objective == "loss_limit":
        return rounds >= stage.target and profit >= -stage.loss_limit
    if stage.objective == "grow_percent":
        return profit * 100 >= stage_start * stage.target
    if stage.objective == "upgrade_win":
        return upgrade_wins >= stage.target
    if stage.objective == "grow_by":
        return profit >= stage.target
    if stage.objective == "profit":
        return profit >= stage.target
    return False


def stage_failed(stage: Stage, bankroll: int, rounds: int, min_bankroll: int) -> bool:
    if stage.objective == "survive" and min_bankroll < stage.min_bankroll:
        return True
    return rounds >= stage.round_limit


def simulate_run(seed: int, strategy: str, pool_name: str, upgrades: List[Upgrade], default_unlocked: set[str], guided_bonus: int) -> RunSummary:
    rng = random.Random(seed)
    pool = [u for u in upgrades if pool_name == "all" or u.name in default_unlocked]
    bankroll = 25_000
    starting = bankroll
    highest = bankroll
    shoe = new_shoe(rng)
    acquired: List[Upgrade] = []
    rounds_since_upgrade = 0
    total_rounds = 0
    bosses_defeated = 0
    choices_offered = 0
    useful_triggers: Dict[str, int] = {}
    max_bet_uses = 0
    last_win = False
    last_bet = 0
    small_win_streak = 0
    guided_first = True
    guided_upgrade_offered = False
    failure = "season_completed"

    stage_index = 0
    while stage_index < len(STAGES):
        stage = STAGES[stage_index]
        stage_start = bankroll
        stage_rounds = 0
        min_bankroll = bankroll
        upgrade_wins = 0
        effects = combine_effects(acquired)
        bankroll += effects.stage_start_cash
        highest = max(highest, bankroll)
        xray_charges = 2 if effects.charged_reveal_count else 0

        while True:
            if len(shoe) < 20:
                shoe = new_shoe(rng)

            if rounds_since_upgrade >= (2 if not acquired else 3):
                if not guided_upgrade_offered:
                    curated_names = ["Opening Tell", "Conservative Edge", "Press the Advantage"]
                    choices = [card for name in curated_names for card in pool if card.name == name]
                    guided_upgrade_offered = True
                else:
                    choices = weighted_upgrade_choices(rng, pool, acquired)
                choices_offered += 1
                pick = choose_upgrade(strategy, choices, acquired)
                acquired.append(pick)
                rounds_since_upgrade = 0
                effects = combine_effects(acquired)
                xray_charges = max(xray_charges, 2 if effects.charged_reveal_count else 0)

            xray_active = effects.charged_reveal_count > 0 and xray_charges > 0 and strategy in ("aggressive", "synergy", "unclear")
            bet_type, bet, used_max = choose_bet(strategy, stage, bankroll, stage_start, effects, shoe, xray_active)
            if bet <= 0:
                failure = f"stage_{stage.id}_bankrupt"
                return summarize(seed, strategy, pool_name, starting, bankroll, highest, stage, total_rounds, bosses_defeated, choices_offered, acquired, useful_triggers, failure, max_bet_uses)
            if used_max:
                max_bet_uses += 1

            if guided_first:
                bet_type = "player"
                bet = 1_000
                winner, p_total, b_total, dealt, natural = "player", 9, 5, 4, True
                guided_first = False
            else:
                preview_count = effects.charged_reveal_count if xray_active else effects.reveal_count
                forecast = forecast_from_preview(shoe, preview_count)
                winner, p_total, b_total, dealt, natural = deal_hand(shoe)

            preview_count = effects.charged_reveal_count if xray_active else effects.reveal_count
            forecast = forecast_from_preview(shoe, preview_count) if not guided_first else None
            bankroll_before = bankroll
            bankroll -= bet
            payout, triggers, push = payout_for_round(winner, bet_type, bet, effects, dealt, forecast, natural, last_win, last_bet, small_win_streak)
            if guided_first is False and total_rounds == 0 and winner == bet_type:
                payout += guided_bonus
                triggers["tutorial_bonus"] = guided_bonus
            bankroll += payout

            for key, value in triggers.items():
                if value:
                    useful_triggers[key] = useful_triggers.get(key, 0) + 1
            won = (winner == bet_type and not push)
            if won and (triggers or preview_count > 0):
                upgrade_wins += 1
            if won and bet <= 1_000:
                small_win_streak += 1
            elif not push:
                small_win_streak = 0
            last_win = won
            last_bet = bet
            total_rounds += 1
            stage_rounds += 1
            rounds_since_upgrade += 1
            if xray_active:
                xray_charges -= 1
            highest = max(highest, bankroll)
            min_bankroll = min(min_bankroll, bankroll)

            if bankroll <= 0:
                failure = f"stage_{stage.id}_bankrupt"
                return summarize(seed, strategy, pool_name, starting, bankroll, highest, stage, total_rounds, bosses_defeated, choices_offered, acquired, useful_triggers, failure, max_bet_uses)
            if stage_complete(stage, bankroll, stage_start, stage_rounds, min_bankroll, upgrade_wins):
                if stage.id in (3, 6, 9, 10):
                    bosses_defeated += 1
                bankroll += choose_stage_reward_cash(strategy, rng)
                highest = max(highest, bankroll)
                stage_index += 1
                break
            if stage_failed(stage, bankroll, stage_rounds, min_bankroll):
                failure = f"stage_{stage.id}_{stage.objective}"
                return summarize(seed, strategy, pool_name, starting, bankroll, highest, stage, total_rounds, bosses_defeated, choices_offered, acquired, useful_triggers, failure, max_bet_uses)
    return summarize(seed, strategy, pool_name, starting, bankroll, highest, STAGES[-1], total_rounds, bosses_defeated, choices_offered, acquired, useful_triggers, failure, max_bet_uses)


def choose_stage_reward_cash(strategy: str, rng: random.Random) -> int:
    base = [2_500, 4_000, 7_500, 0, 0, 0]
    sample = rng.sample(base, 3)
    return max(sample)


def summarize(seed: int, strategy: str, pool: str, starting: int, bankroll: int, highest: int, stage: Stage, rounds: int, bosses: int, choices: int, acquired: List[Upgrade], triggers: Dict[str, int], failure: str, max_bet_uses: int) -> RunSummary:
    return RunSummary(
        seed=seed,
        strategy=strategy,
        pool=pool,
        starting_bankroll=starting,
        ending_bankroll=bankroll,
        highest_bankroll=highest,
        stage_reached=stage.id,
        rounds_played=rounds,
        bosses_defeated=bosses,
        upgrade_choices_offered=choices,
        upgrades_taken=[u.name for u in acquired],
        useful_upgrade_triggers=triggers,
        failure_point=failure,
        cleared_first_three=stage.id > 3 or failure == "season_completed",
        used_max_bet_ratio=max_bet_uses / max(1, rounds),
    )


def aggregate(runs: List[RunSummary]) -> Dict[str, object]:
    failures: Dict[str, int] = {}
    upgrades: Dict[str, int] = {}
    triggers: Dict[str, int] = {}
    for run in runs:
        failures[run.failure_point] = failures.get(run.failure_point, 0) + 1
        for upgrade in run.upgrades_taken:
            upgrades[upgrade] = upgrades.get(upgrade, 0) + 1
        for key, value in run.useful_upgrade_triggers.items():
            triggers[key] = triggers.get(key, 0) + value
    return {
        "runs": len(runs),
        "avg_stage": round(mean(r.stage_reached for r in runs), 2) if runs else 0,
        "avg_rounds": round(mean(r.rounds_played for r in runs), 2) if runs else 0,
        "avg_ending_bankroll": round(mean(r.ending_bankroll for r in runs), 1) if runs else 0,
        "stage_1_clear_rate": round(sum(r.stage_reached > 1 or r.failure_point == "season_completed" for r in runs) / max(1, len(runs)), 2),
        "stage_2_clear_rate": round(sum(r.stage_reached > 2 or r.failure_point == "season_completed" for r in runs) / max(1, len(runs)), 2),
        "stage_3_clear_rate": round(sum(r.cleared_first_three for r in runs) / max(1, len(runs)), 2),
        "avg_max_bet_ratio": round(mean(r.used_max_bet_ratio for r in runs), 3) if runs else 0,
        "failure_points": dict(sorted(failures.items(), key=lambda item: (-item[1], item[0]))),
        "top_upgrades": dict(sorted(upgrades.items(), key=lambda item: (-item[1], item[0]))[:10]),
        "upgrade_triggers": dict(sorted(triggers.items(), key=lambda item: (-item[1], item[0]))[:10]),
    }


def suspicious_upgrades(upgrades: List[Upgrade]) -> List[Dict[str, object]]:
    rows = []
    for upgrade in upgrades:
        if upgrade.money_score >= 20_000 and upgrade.rarity in ("common", "rare"):
            rows.append({
                "name": upgrade.name,
                "rarity": upgrade.rarity,
                "money_score": upgrade.money_score,
                "description": upgrade.description,
            })
    return sorted(rows, key=lambda row: (-int(row["money_score"]), str(row["name"])))[:20]


def main() -> None:
    parser = argparse.ArgumentParser(description="Run compact deterministic Rigged Shoe balance simulations.")
    parser.add_argument("--runs", type=int, default=8, help="Runs per strategy/pool. Keep small on low-RAM machines.")
    parser.add_argument("--seed", type=int, default=70121)
    parser.add_argument("--pool", choices=["fresh", "all", "both"], default="both")
    parser.add_argument("--json", type=Path, default=None)
    args = parser.parse_args()

    start = time.perf_counter()
    upgrades = parse_upgrades()
    default_unlocked = parse_default_unlocked()
    guided_bonus = parse_guided_bonus()
    pools = ["fresh", "all"] if args.pool == "both" else [args.pool]
    strategies = ["conservative", "aggressive", "synergy", "unclear"]
    all_runs: List[RunSummary] = []
    seed_log: List[int] = []

    for pool in pools:
        for strategy in strategies:
            for offset in range(args.runs):
                seed = args.seed + len(seed_log) * 37
                seed_log.append(seed)
                all_runs.append(simulate_run(seed, strategy, pool, upgrades, default_unlocked, guided_bonus))

    groups: Dict[str, List[RunSummary]] = {}
    for run in all_runs:
        key = f"{run.pool}:{run.strategy}"
        groups.setdefault(key, []).append(run)

    elapsed = time.perf_counter() - start
    raw_rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    rss_mb = raw_rss / (1024 * 1024) if raw_rss > 10_000_000 else raw_rss / 1024
    report = {
        "run_count": len(all_runs),
        "runs_per_strategy": args.runs,
        "seeds": seed_log,
        "elapsed_seconds": round(elapsed, 3),
        "max_rss_mb": round(rss_mb, 2),
        "guided_first_bonus_cents": guided_bonus,
        "groups": {key: aggregate(value) for key, value in sorted(groups.items())},
        "suspicious_upgrades": suspicious_upgrades(upgrades),
        "sample_runs": [run.__dict__ for run in all_runs[: min(8, len(all_runs))]],
    }

    print(json.dumps(report, indent=2))
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
