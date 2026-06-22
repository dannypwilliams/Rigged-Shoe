# Opponents And Stages

Rigged Shoe stages now use compact opponent battles instead of generic profit chores.

## Core Stage Shape

- A run has 10 stages.
- Stages are short baccarat battles of 5-12 hands.
- The player clears a stage by surviving the hand count and finishing with equal or better stage profit than the opponent, with small early tolerance.
- Legacy teaching objectives remain as secondary flavor and progress support, not the main win condition.

## Opponent Model

Defined in `RiggedShoe/Models/OpponentModels.swift`.

Each opponent contains:

- Name and subtitle.
- Stage tier.
- Ante.
- Betting style.
- Active modifier instances.
- Table rules.
- Weakness.
- Flavor text.
- Reward tier.
- Difficulty rating.

## Betting Styles

Implemented styles:

- Conservative Banker.
- Player Pivot.
- Tie Chaser.
- High Roller.
- Small Ball Grinder.
- Streak Better.
- Counter Better.
- Random Tourist.
- Boss Style.
- House Style.

## Non-Boss Opponent Pool

The current pool contains 16 opponents:

- Nervous Tourist.
- Weekend Regular.
- Card Room Grinder.
- Tie Chaser.
- Pattern Player.
- The Counter.
- The Whale Junior.
- Quiet Regular.
- The Mechanic's Friend.
- The Inside Man.
- The Cooler.
- The Floor Favorite.
- The Whale.
- The Insider.
- The Auditor.
- The Collector.

## UI Integration

Stage preview shows:

- Opponent name.
- Trait/subtitle.
- Betting style.
- Weakness.
- Flavor text.
- Table event.
- Secondary objective.
- Reward tier.

Stage result compares:

- Player stage profit.
- Opponent stage profit.
- Table event.
- Secondary objective completion.
- Main build archetype.

## Verification

`RiggedShoeTests/ShopBackboneTests.swift` verifies:

- 16 opponents exist.
- Opponent IDs are unique.
- Stage previews use opponent, table event, and secondary objective data.
- Stage clear compares player profit against opponent profit.
