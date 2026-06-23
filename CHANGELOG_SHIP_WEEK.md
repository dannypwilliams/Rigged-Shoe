# Rigged Shoe Ship Week Changelog

Date: 2026-06-23

## Player-Facing Changes

- Rebuilt the first-run route around a clear two-stage vertical slice: contact, scout report, Stage 1, reward, shop, Stage 2, result.
- Contact select now exposes all six contacts immediately in a compact two-column grid.
- Stage preview now states the facts players need before play: hands, ante, max bet, clear rule, table rule, reward, optional bonus, and starting resources.
- Stage 1 is now five hands with $25/$50/$75 wagers and a $75 max.
- Stage 2 is now six hands with $50/$100 wagers and a $100 max.
- Stage results now explain whether the table was cleared by staying solvent after the fixed hand count.
- Reward draft now presents as `Take 1 Reward`.
- Shop now focuses on the vertical-slice loop: buy from three offers, reroll with Chips, review current build, continue to Stage 2.
- Tutorial first hand now clearly locks to Player $25, then unlocks normal bets after the opening result.
- Heat pressure is now visible and recoverable through Pit Boss Skim and Crackdown events instead of surprise fail states.

## Rules And Balance

- Starting run values are locked to `$250`, `3 Chips`, `0 Heat`, and `5` active modifier slots.
- The hidden quarter-bankroll wager cap was removed.
- Legal wagers now use fixed table min/max plus bankroll affordability.
- Stage clear now depends on solvency after the fixed hand count, not opponent score margin.
- Stage 1 awards `+2 Chips`; its optional bonus is `+1 Chip` for clearing at Heat `3` or less.
- Stage 2 keeps a visible table rule for No Commission Night.
- Generic hidden heat from large bets, max bets, Tie wins, and ordinary losses was removed.

## Technical Changes

- Added shared vertical-slice balance constants in `VerticalSliceBalance`.
- Locked `RunManager` to two production stages for this slice.
- Updated bet normalization so unavailable wagers visibly adjust to the largest affordable legal bet.
- Reworked guided shoe setup so scripted cards replace the top of the six-deck shoe instead of adding extra cards.
- Reset stage battle presentation when a new stage begins, avoiding stale result state after shop continue.
- Added deterministic tests for fixed stage count, fixed wager caps, solvency clear, recoverable heat cap, guided shoe count, and representative two-stage routes.
- Preserved existing modifier engine tests and deterministic content catalog coverage.

## QA Artifacts

- Source review: `SOURCE_REVIEW.md`
- Release candidate report: `Docs/RELEASE_CANDIDATE_REPORT_20260622.md`
- QA report: `QA_REPORT.md`
- Source video review frames: `review-captures/source-review-video-frames/`
- Before/after simulator screenshots: `playtest-artifacts/`
