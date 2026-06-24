# Rigged Shoe Visual Playtest Implementation Plan

## Audit Findings

- Live source of truth: `GameViewModel` owns run actions, hand resolution, reward/shop flow, debug/beta helpers, and persistence calls.
- Run structure: `RunManager` owns flow state, stage progression, bankroll/Chips/Heat counters, stage results, and final completion.
- Stage content: `Stage.allStages` is data driven for stages 1-30. Stage 30 is the only final-clear path.
- Boss cadence after this pass: stages 5, 10, 15, 20, 25, and 30.
- Canonical terminology: `Contact` for opening choices; `House Profile` / `Table Profile` for casino pressure. Internal model names may still use `OpponentState`.
- Hidden wager cap: early legal wager sets are fixed stage denominations; no bankroll-quarter cap is used for legal bet availability.
- Visual risk: functional UI had inherited crooked shapes through `CrookedStickerShape`, panel modifiers, and pressed button rotation.

## Implemented Plan

1. Normalize functional panel and button geometry through reusable SwiftUI components.
2. Add reusable equivalents for scaffold, centered content, panels, metric tiles, section header, primary button, compact HUD, bottom nav, run summary grid, and modifier detail sheet.
3. Replace production-facing `Opponent` labels in run-flow screens with `House Profile` or `Table Profile`.
4. Expand Contact details with model-derived bankroll, Chips, Heat, starting item, exact trigger, risk, and play-style data.
5. Correct boss cadence to 5/10/15/20/25/30 and update tests.
6. Keep Stage 30 as the only Casino Cleared path.
7. Add debug-only QA controls for act starts, boss starts, resource fixtures, seed application, save clearing, and diagnostics export.
8. Produce beta-readiness documents and known-risk disclosure.

## Migration Risks

- Historical docs still mention older Stage 8 boss tuning; the new content matrix supersedes those notes.
- Some internal type names still use `Opponent` for compatibility. Production-facing copy has been changed where it appears in the run flow.
- Full snapshot automation is not yet implemented; visual screenshots are captured manually/through simulator commands for this pass.

## Validation Gate

- Build must pass with `CODE_SIGNING_ALLOWED=NO`.
- Unit tests must pass or any failures must be listed in `Docs/KNOWN_ISSUES.md`.
- Screenshot artifacts must be saved under `playtest-artifacts/visual-pass-20260624/`.
