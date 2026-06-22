# Battle Log and Modifier Feedback

Rigged Shoe now has a single player-facing feedback path for hand outcomes, payout math, and future modifier-engine resolutions.

## Runtime Flow

1. `GameViewModel.dealRound()` resolves the baccarat hand.
2. The payout resolver returns named `PayoutLedgerLine` values.
3. `ModifierEngine` resolutions are converted into structured money, Chip, Heat, reveal, and shoe effect lines.
4. `RoundPresentationState.triggerFeedback` is built from structured modifier resolutions first, then non-structural payout lines and legacy activation messages.
5. A `BattleLogEntry` is appended to `GameState.battleLog`.
6. The Game Room shows the compact trigger feed and the expanded Battle Log sheet.

## Modifier Engine Connection

Each `ModifierResolution` now converts into:

- `PayoutLedgerLine` for money changes.
- `ModifierTriggerFeedback` for short in-hand pop feedback, including non-money badges such as `+1 Chip`, `+1 Heat`, `Blocked 1 Heat`, and reveal counts.
- `BattleLogEffectLine` for the expanded log, including money, Chips, Heat, reveal requests, Tie charges, and deferred shoe manipulation effects.
- debug event strings in `GameState.debugGameEventLog` during DEBUG builds.

The intended order is:

```swift
let event = GameEvent.playerWonBet(...)
let context = ModifierContext(...)
let resolutions = modifierEngine.resolve(
    event: event,
    modifiers: activeModifiers,
    library: modifierLibrary,
    context: context
)
// Apply resolution deltas to bankroll, chips, Heat, reveal state, and shoe state.
// Convert resolution messages/effects to trigger pills, payout ledger rows, and battle log lines.
```

## UI Behavior

- The Game Room top bar has a Battle Log button.
- The compact trigger feed shows the newest modifier/payout/reveal/shoe effects without pushing the bet dock off screen.
- Trigger pills pulse when a new hand presentation sequence appears and can display money or resource badges.
- The expanded sheet shows hand number, bet, cards, winner, base payout, modifiers, Chips, Heat, and final bankroll change.
- DEBUG builds also show recent game-event debug strings in the sheet.

## Current Scope

Legacy upgrade payout logic and rebuilt `ModifierEngine` effects now flow through the same log model. This keeps the current playable game understandable while the new modifier catalog/shop loop continues to expand.
