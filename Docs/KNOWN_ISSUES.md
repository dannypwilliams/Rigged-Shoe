# Known Issues

## P1: Snapshot Automation Not Yet Implemented

- Reproduction: run current test suite; no automated snapshot target checks clipping across every major screen.
- Impact: visual regressions still require manual simulator screenshots.

## P1: 10,000-Run Balance Simulation Gate Not Yet Complete

- Reproduction: no current command generates the required 10,000-run distribution report from this pass.
- Impact: beta balance is preliminary and should not be called final.

## P2: Internal Model Names Still Use Opponent

- Reproduction: inspect `OpponentState` and related internal fields.
- Impact: player-facing run-flow copy is corrected, but source naming still reflects earlier architecture.

## P2: Historical Docs Mention Stage 8 Boss

- Reproduction: search older docs for Stage 8 boss references.
- Impact: historical reports are stale; `Docs/CONTENT_MATRIX_1_30.md` is the current cadence.
