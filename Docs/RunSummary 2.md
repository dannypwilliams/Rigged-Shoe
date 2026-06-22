# Run Summary

The run summary is designed to explain why a run ended and what kind of build the player made.

## Current UI

Implemented in `RiggedShoe/Views/RunOverView.swift`.

The screen shows:

- Stage reached.
- Final bankroll.
- Total rounds.
- Player/Banker/Tie results.
- Bosses defeated.
- Highest bankroll.
- Highest profit.
- Top modifier.
- Heat.
- Boss relic count.
- Main build archetype.
- Loss explanation.
- Start New Run button.

## Build Archetype Detection

Implemented in `BuildArchetypeDetector`.

It reads active modifier tags and returns labels such as:

- Banker Engine.
- Player Pivot.
- Tie Hunter.
- Shoe Vision.
- Shoe Control.
- High Roller.
- Small Ball Economy.
- Comeback.
- Heat Ghost.
- Boss Killer.
- Hybrid Build.

## Loss Explanation

Implemented in `RunManager.lossExplanation`.

Examples:

- Bankroll could not cover table minimum.
- Heat maxed out.
- Boss outscored or shut down the build.
- Opponent outscored player by a visible profit amount.

`StageResultData` carries the explanation into the run-over screen.

## Unlock Hooks

Permanent profile already includes placeholder buckets for future hooks, including unlocked rewards and future hook IDs. This pass preserves that framework but does not build full meta-progression expansions.

## Verification

Tests verify build archetype support indirectly through reward draft and stage result data. Manual QA should still check small-screen layout and copy density.
