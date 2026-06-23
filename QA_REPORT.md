# QA Report

## 2026-06-23

### Commands

- `xcodebuild build -scheme RiggedShoe -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/RiggedShoeDerivedData`
- `xcodebuild test -scheme RiggedShoe -destination 'platform=iOS Simulator,name=RiggedShoe-SE-Layout-Test,OS=26.5' -derivedDataPath /tmp/RiggedShoeDerivedData`

### Result

- Build: passed.
- Tests: passed, 31/31 in `ShopBackboneTests`.
- Test result bundle: `/tmp/RiggedShoeDerivedData/Logs/Test/Test-RiggedShoe-2026.06.23_10-19-30--0700.xcresult`

### Simulator Coverage

- Compact: `RiggedShoe-SE-Layout-Test`, iOS 26.5, automated tests passed.
- Compact visual evidence: `PlaytestArtifacts/ReleasePass20260623/01-clean-launch-se.png`.
- Standard: `iPhone 17`, iOS 26.5, boot attempted but simulator entered a shutting-down state before install/screenshot. Not counted as verified.

### Route Matrix

- Domain route coverage: representative two-stage routes for Banker Bias, Player Surge, and Opening Tell passed.
- Contact startup coverage: all six contacts can start a run and apply identity/effects once.
- Full 12-route manual visual matrix: not completed in this pass.

### Lifecycle And Persistence

- Restore after Stage 1 reward selection now returns to shop with the reward already consumed and without reapplying it.
- Stage 2 clear now continues to run complete/replay without a stray reward draft.
- Below-minimum bankroll now resolves to a stage result rather than a dead battle screen.
- Full checkpoint matrix from the release prompt was not manually completed.

### Accessibility And Layout

- Game Info now uses a high-contrast custom SwiftUI sheet instead of the low-contrast native confirmation dialog.
- SE launch screenshot captured. Broader Dynamic Type, VoiceOver, and 12-route visual checks remain unverified.

### Build Environment Note

Building with `DerivedData` inside the synced Documents workspace failed at simulator code signing because the generated app bundle received file-provider/Finder metadata. Using `/tmp/RiggedShoeDerivedData` avoids that metadata and signs successfully.

