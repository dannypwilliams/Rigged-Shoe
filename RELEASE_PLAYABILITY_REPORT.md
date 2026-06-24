# Release Playability Report

## 2026-06-23 Assessment

**GO** for the automated standard and compact release-route slice covered in this pass.

The core two-stage route is more coherent and safer: Stage 2 completes into replay, reward selection cannot apply twice, below-minimum bankroll cannot strand the player, full modifier capacity blocks new shop modifiers visibly, and Game Info now explains the release rules in a readable custom sheet with a toolbar Close action that remains reachable at compact accessibility text sizes. The latest pass broadens route coverage to every starting contact on standard and compact simulators, adds baccarat shoe/payout accounting tests, verifies prompt-aligned structured logger events for hand reconstruction, and captures automated route screenshots through contact, scout, battle, Game Info, hand resolution, Stage Result, reward, shop, and Stage 2 scout.

VoiceOver remains the only unverified prompt item in this local pass because the available `xcrun simctl ui` controls expose content size, contrast, and appearance, but not VoiceOver toggling.

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
- The UI contact matrix covers all six starting contacts on standard and compact accessibility-size simulators.
- App-level background/resume is covered at battle, reward, and shop in the detailed UI route.
- Compact Dynamic Type coverage passes at `accessibility-extra-extra-extra-large`.

## Evidence

- Generic simulator build passed with `/tmp/RiggedShoeDerivedData-Goal100FinalBuild` and `CODE_SIGNING_ALLOWED=NO`.
- Unit test suite passed: 43/43.
- Unit test result bundle: `/tmp/RiggedShoeDerivedData-Goal100Final/Logs/Test/Test-RiggedShoe-2026.06.23_22-21-10--0700.xcresult`.
- Standard UI suite passed: 2/2 in `ReleaseFlowUITests`.
- Standard UI result bundle: `/tmp/RiggedShoeDerivedData-UIRouteStdFinal/Logs/Test/Test-RiggedShoe-2026.06.23_22-16-43--0700.xcresult`.
- Compact accessibility UI suite passed: 2/2 in `ReleaseFlowUITests` with `content_size accessibility-extra-extra-extra-large`.
- Compact accessibility UI result bundle: `/tmp/RiggedShoeDerivedData-UIRouteCompactA11yFull/Logs/Test/Test-RiggedShoe-2026.06.23_22-13-01--0700.xcresult`.
- UI route screenshot attachments: `primary-01-contact-selection`, `primary-02-scout-report`, `primary-03-battle`, `primary-04-game-info`, `primary-05-resolved-hand`, `primary-06-stage-result`, `primary-07-reward-draft`, `primary-08-shop`, `primary-09-stage-2-scout-report`, plus per-contact matrix start and Stage 2 attachments.
- SE clean launch screenshot: `PlaytestArtifacts/ReleasePass20260623/01-clean-launch-se.png`.
- `git diff --check` passed.

## Remaining Risks

- **P1 accessibility risk:** VoiceOver was not verified because local simulator tooling exposed no VoiceOver control. Next action: run the VoiceOver checklist manually or with an automation environment that can enable it.
- **P2 manual visual risk:** the route matrix was walked by UI automation with kept screenshots, not by a human visual QA pass. Next action: inspect the standard and compact result-bundle screenshots before external release.
- **Environment risk:** local simulator signing should use `/tmp/RiggedShoeDerivedData` or another non-synced DerivedData path to avoid file-provider metadata in app bundles. The build/test scripts now default to `/tmp/RiggedShoeDerivedData`.
