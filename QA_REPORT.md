# QA Report

## 2026-06-23

### Commands

- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100 CODE_SIGNING_ALLOWED=NO`
- `xcodebuild build -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100 CODE_SIGNING_ALLOWED=NO`

### Result

- Build: passed.
- Tests: passed, 43/43 in `ShopBackboneTests`.
- Test result bundle: `/tmp/RiggedShoeDerivedData-Goal100/Logs/Test/Test-RiggedShoe-2026.06.23_21-24-15--0700.xcresult`

### Simulator Coverage

- Compact: `RiggedShoe-SE-Layout-Test`, iOS 26.5, automated tests passed in the earlier release pass.
- Compact visual evidence: `PlaytestArtifacts/ReleasePass20260623/01-clean-launch-se.png`.
- Standard: `iPhone 17e`, iOS 26.5, automated tests passed.
- Standard-device screenshot matrix: not completed in this pass.

### Route Matrix

- Domain route coverage: all six starting contacts now complete a two-stage route through reward/shop progression at the domain level.
- Contact startup coverage: all six contacts can start a run and apply identity/effects once.
- Full 12-route manual visual matrix: not completed in this pass.

### Lifecycle And Persistence

- Restore after Stage 1 reward selection now returns to shop with the reward already consumed and without reapplying it.
- Stage 2 clear now continues to run complete/replay without a stray reward draft.
- Below-minimum bankroll now resolves to a stage result rather than a dead battle screen.
- Deterministic restore checkpoints cover battle, reward, shop, run completion, and transient-presentation cleanup at the unit level.
- Full manual background/resume checkpoint matrix from the release prompt was not completed.

### Baccarat And Logging Coverage

- Standard four-card and third-card baccarat rounds now have explicit shoe-decrement coverage.
- Player, Banker, and Tie payout math covers push behavior and Banker commission rounding.
- Structured logging now emits prompt-aligned event names for run/contact/stage/hand/shoe/payout/modifier/reward/shop/persistence/run-end flow.
- The logger contract test verifies that hand reconstruction fields include run ID, seed, stage, hand, bet, shoe counts, bankroll/chip/heat before and after, result, and modifier/payout events.

### Accessibility And Layout

- Game Info now uses a high-contrast custom SwiftUI sheet instead of the low-contrast native confirmation dialog.
- SE launch screenshot captured. Broader Dynamic Type, VoiceOver, and 12-route visual checks remain unverified.

### Build Environment Note

Building with `DerivedData` inside the synced Documents workspace failed at simulator code signing because the generated app bundle received file-provider/Finder metadata. Using `/tmp/RiggedShoeDerivedData` avoids that metadata and signs successfully.
`Scripts/mac_build_simulator.sh` and `Scripts/mac_test_simulator.sh` now default to `/tmp/RiggedShoeDerivedData` while preserving `DERIVED_DATA_PATH` overrides.
