# Release Playability Report

## 2026-06-23 Assessment

**CONDITIONAL GO** for the automated/domain slice covered in this pass.

The core two-stage route is more coherent and safer: Stage 2 completes into replay, reward selection cannot apply twice, below-minimum bankroll cannot strand the player, full modifier capacity blocks new shop modifiers visibly, and Game Info now explains the release rules in a readable custom sheet. The latest pass also broadens the domain route coverage to every starting contact, adds baccarat shoe/payout accounting tests, verifies prompt-aligned structured logger events for hand reconstruction, and adds one automated standard-device UI route with kept screenshots through contact, scout, battle, Game Info, hand resolution, Stage Result, reward, shop, and Stage 2 scout.

This is not a full GO against the entire master prompt because the full 12-route manual visual matrix, every lifecycle checkpoint, VoiceOver, Dynamic Type, and the full standard-device screenshot matrix were not completed.

## Locked Invariants Verified By Tests

- Base run uses $250, 3 Chips, 0 Heat, and 5 active modifier slots.
- Exactly six starting contacts exist and resolve their starting content.
- Release route uses Stage 1 and Stage 2.
- Stage 1 uses 5 hands, $25/$50/$75, and a $75 max.
- Stage 2 uses 6 hands, $50/$100, and a $100 max.
- Hidden quarter-bankroll cap is absent from legal wager caps.
- Stage 2 No Commission Night pays Banker 1:1.
- Guided first hand consumes the scripted four cards from the six-deck shoe, 312 to 308.
- Duplicate Deal calls remain locked until presentation completes.
- Reduce Motion UI presentation completion clears the Deal lock synchronously after a resolved hand.
- Stage clear uses solvency after fixed hands.
- Stage 2 starts from shop with clean current-hand presentation.
- Reward selection, shop purchase/reroll flow, and restore-after-reward are covered at the domain level.
- All six starting contacts complete a two-stage route through reward/shop progression at the domain level.
- Standard four-card and third-card baccarat rounds decrement the six-deck shoe correctly.
- Player, Banker, and Tie payout math covers push behavior and Banker commission rounding.
- Structured logs include prompt event names for run/contact/stage/hand/shoe/payout/modifier/reward/shop/persistence/run-end flow and carry hand reconstruction fields.
- The automated UI release route covers contact selection, Stage 1 scout, battle, Game Info, rapid Deal interaction, resolved hand, Stage Result, reward draft, shop, and Stage 2 scout report.

## Evidence

- Build passed with `/tmp/RiggedShoeDerivedData-Goal100`.
- Unit test suite passed: 43/43.
- Unit test result bundle: `/tmp/RiggedShoeDerivedData-Goal100/Logs/Test/Test-RiggedShoe-2026.06.23_21-56-15--0700.xcresult`.
- UI route test passed: `ReleaseFlowUITests.testReleaseRouteSurfacesAndScreenshots`.
- UI route result bundle: `/tmp/RiggedShoeDerivedData-UIRoute/Logs/Test/Test-RiggedShoe-2026.06.23_21-54-45--0700.xcresult`.
- UI route screenshot attachments: `01-contact-selection`, `02-scout-report`, `03-battle`, `04-game-info`, `05-resolved-hand`, `06-stage-result`, `07-reward-draft`, `08-shop`, `09-stage-2-scout-report`.
- SE clean launch screenshot: `PlaytestArtifacts/ReleasePass20260623/01-clean-launch-se.png`.

## Remaining Risks

- **P1 visual risk:** one standard-device automated route has screenshots, but the full compact and standard route matrix was not manually walked after these edits. Next action: run the 12-route matrix and capture named screenshots.
- **P1 accessibility risk:** VoiceOver and large Dynamic Type were not verified. Next action: run the accessibility checklist on contact, battle, result, reward, shop, Game Info, and replay.
- **P1 lifecycle risk:** deterministic restore checkpoints are covered at the unit level, but the full manual background/resume matrix was not completed. Next action: run app-level background/resume checks for contact, battle, reward, shop, and run-complete phases.
- **Environment risk:** local simulator signing should use `/tmp/RiggedShoeDerivedData` or another non-synced DerivedData path to avoid file-provider metadata in app bundles. The build/test scripts now default to `/tmp/RiggedShoeDerivedData`.
