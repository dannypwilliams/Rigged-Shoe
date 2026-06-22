# Rigged Shoe Modifier Catalog

Updated: 2026-06-22

The rebuilt modifier catalog lives in `RiggedShoe/Models/ModifierModels.swift`.

## Current Count

- 6 core engine-test modifiers in `Modifier.sampleDebugPool`.
- 114 expanded shop modifiers across 16 archetype groups.
- 120 total modifiers available through `Modifier.allContent`.

## Archetype Groups

### Banker Engine

Stable baccarat edge. Banker modifiers reward betting Banker, refund Banker misses, and create Chips from loyal Banker play.

Examples:
- Banker Bias
- Commission Dodge
- House Favorite
- Banker Anchor
- Banker Lock

### Player Pivot

Counter-trend and tempo play. Player modifiers make the less-stable Player side feel viable through bursts, first-win bonuses, and comeback refunds.

Examples:
- Player Surge
- Side Step
- Countertrend
- Punto Insurance
- Underdog Side

### Tie Hunter

Risky longshot play. Tie modifiers give insurance, reveal help, chip bursts, and jackpot-style rewards without making Tie safe by default.

Examples:
- Tie Insurance
- Tie Whisperer
- Equalizer
- Longshot Ledger
- Tie Master

### Shoe Vision

Information-first builds. These reveal upcoming cards at stage start, after wins, or when the player commits to high-information bets.

Examples:
- Opening Tell
- Dealer Glance
- Soft Peek
- Deep Read
- Third Card Forecast

### Shoe Control / Card Sculpting

The core "rig the shoe" fantasy. These burn, delay, add, or reshape cards before the deal. The engine now returns deferred shoe effects so the ViewModel applies the actual shoe mutation outside SwiftUI.

Examples:
- Burn Notice
- Soft Cut
- Dealer Slip
- Shoe Pocket
- Hot Cut

### Bet Control

Pacing and risk management. These support small-ball consistency, limited refunds, parlay-style chip gain, and future cap-bending.

Examples:
- Small Ball
- Careful Hands
- Press the Edge
- High Roller
- Loss Limit

### Economy

Shop resource and scaling support. Economy modifiers create Chips, ante-scaled bankroll, discounts, and duplicate/shop hooks.

Examples:
- Lucky Chip
- Interest Ledger
- Shop Regular
- Coupon Book
- Chip Stipend

### Heat / Stealth

Casino pressure management. Heat modifiers prevent Heat spikes, reduce Heat at stage start, or make boss tables less punishing.

Examples:
- Clean Hands
- Low Profile
- Floor Distraction
- Soft Footsteps
- Cool Customer

### Natural Hunter

Rewards natural 8/9 hands with reads, bankroll, and light card sculpting.

Examples:
- Natural Read
- Natural Bonus
- Snap Nine
- Natural Comp
- Perfect Nine

### Pair Hunter

Turns rare pair events into information, Chips, and Tie-adjacent planning.

Examples:
- Pair Hunter
- Twin Signal
- Matchbook
- Split Pocket
- Twin Engine

### Loaded Shoe

Adds 8s and 9s to make the shoe-manipulation fantasy more explicit.

Examples:
- Add Nine
- Marked Nine
- Nine Worship
- Eight Stack+
- Nine Engine

### Counter Master

Comeback and reversal tools that make losses create tactical information.

Examples:
- False Read
- Countertrend+
- Mirror Punish
- Reverse Count
- Turnaround Table

### Boss Killer

Boss-specific counterplay, Heat relief, and bounded late-run payout tools.

Examples:
- Final Table Pass
- Inside Job
- Countermeasure
- Boss Bounty
- House Crack

### Debt / Loan

Controlled borrowing and comeback economy with Heat as the limiter.

Examples:
- Emergency Marker
- Debt Collector
- Last Dollar
- Credit Line
- Marker Chain

### Opponent Sabotage

Disrupts opponent pressure without removing baccarat decision-making.

Examples:
- Tempo Theft
- Opponent Tax
- Cold Read
- Table Chat
- House Static

### Final Hand Specialist

Short-battle closers that make the last hand of a stage matter.

Examples:
- Closer
- Redemption Hand
- Last Look
- Crown Hand
- House Breaker

## Functional Integration Notes

The live battle path currently emits these modifier events:

- `stageStarted`
- `betPlaced`
- `beforeDeal`
- `playerWonBet`
- `playerLostBet`
- `tieOccurred`
- `heatGained` when a modifier would add Heat

The following effect families are live in normal hands:

- bankroll and ante-scaled bankroll
- payout bonuses
- loss refunds
- chip gain
- Heat gain/reduction/prevention
- reveal requests
- deferred shoe effects: burn, move top card, add cards, remove cards
- attachment effects on compatible active modifiers

Some catalog hooks are intentionally documented but not fully live yet:

- `shopEntered` and `shopRerolled` effects currently log or reserve future discount behavior.
- `bossStarted`, `bossDefeated`, and opponent sabotage hooks are catalog-ready. Core boss pressure is routed through the live boss bridge, while future catalog-specific boss modifiers can move into a dedicated boss reducer.
- `adjustBetLimit`, `addTableRule`, and custom effects are placeholders for future reducers.

## Adding A New Modifier

1. Add a `contentModifier(...)` entry in the matching archetype array.
2. Give it stable tags; shop bias, synergies, and bosses depend on tags.
3. Prefer ante-scaled effects over large flat cash.
4. Use `conditions` to avoid broad always-on bonuses.
5. Use `useLimits` for effects that could fire too often.
6. If the effect changes the shoe, return a deferred `ModifierEffect` and apply it in `GameViewModel.applyModifierResolutions`.
7. Verify the effect creates battle-log or trigger feedback through `ModifierResolution.messages`.
