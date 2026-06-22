# Rigged Shoe Modifier Event Engine

The modifier engine lives in `RiggedShoe/Models/ModifierModels.swift`. It is intentionally model-first: battle, shop, boss, and UI systems emit a `GameEvent`, pass active `ModifierInstance` values plus the modifier content library into `ModifierEngine`, then apply returned `ModifierResolution` deltas through their own authoritative state.

## Core Flow

1. Build a `ModifierContext` for the current event.
2. Call `ModifierEngine.resolve(event:modifiers:library:context:)`.
3. The engine checks matching `ModifierTrigger` values.
4. Disabled modifiers and exhausted use limits are skipped.
5. `ModifierCondition` values are evaluated.
6. `ModifierEffect` values are expanded for the instance level.
7. The engine returns transparent `ModifierResolution` records for payout ledgers, battle logs, and UI feedback.

## Adding a Modifier

Add a `Modifier` content record with:

- `id`: stable string key, such as `core.banker-bias`.
- `tags`: strategy tags for synergy and future boss suppression.
- `triggers`: one or more event hooks.
- `conditions`: reusable checks like selected bet side or first win this stage.
- `useLimits`: optional per-hand, per-stage, or per-run caps.
- `effects`: one or more effects, usually wrapped in `.levelScaled(...)` for levels 1-3.

Example shape:

```swift
Modifier(
    id: "core.example",
    name: "Example",
    summary: "Short player-facing summary.",
    rulesText: "Exact mechanical text.",
    rarity: .common,
    tags: [.banker],
    triggers: [.playerWonBet],
    effects: [
        .levelScaled(
            level1: [.payoutMultiplier(betType: .banker, percent: 10)],
            level2: [.payoutMultiplier(betType: .banker, percent: 18)],
            level3: [.payoutMultiplier(betType: .banker, percent: 25)]
        )
    ],
    baseCostChips: 3,
    conditions: [.all([.betType(.banker), .winningSide(.banker)])]
)
```

## First Implemented Modifiers

- Banker Bias
- Player Surge
- Tie Insurance
- Opening Tell
- Clean Hands
- Lucky Chip

These are currently in `Modifier.sampleDebugPool` and are ready to move into a production content library when the shop/reward draft is wired to the rebuilt run loop.

## Debug Tests

`ModifierEngineDebugTests.runAll()` is available in DEBUG builds. It validates trigger matching, condition checks, level scaling, stage use limits, reveal requests, battle-log messages, and Heat prevention reset behavior without launching a heavy simulator pass.

## Integration Notes

The engine does not mutate bankroll, Heat, Chips, or the shoe directly. This is deliberate. The caller should apply:

- `bankrollDeltaCents`
- `payoutBonusCents`
- `chipDelta`
- `heatDelta`
- `heatPrevented`
- `tieChargesDelta`
- `revealRequest`

This keeps baccarat resolution separate from roguelite progression and makes every modifier-visible change ledger-friendly.
