# QA Report

## 2026-06-23

### Commands

- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100 CODE_SIGNING_ALLOWED=NO`
- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E -derivedDataPath /tmp/RiggedShoeDerivedData-UIRoute -only-testing:RiggedShoeUITests/ReleaseFlowUITests/testReleaseRouteSurfacesAndScreenshots`
- `xcodebuild build -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100 CODE_SIGNING_ALLOWED=NO`
- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E -derivedDataPath /tmp/RiggedShoeDerivedData-UIRouteStdFinal -only-testing:RiggedShoeUITests`
- `xcrun simctl ui F44A22A5-86FD-45C8-A5C3-9B4B59AB8946 content_size accessibility-extra-extra-extra-large`
- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=F44A22A5-86FD-45C8-A5C3-9B4B59AB8946 -derivedDataPath /tmp/RiggedShoeDerivedData-UIRouteCompactA11yFull -only-testing:RiggedShoeUITests`
- `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination id=8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100Final CODE_SIGNING_ALLOWED=NO -only-testing:RiggedShoeTests`
- `xcodebuild build -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/RiggedShoeDerivedData-Goal100FinalBuild CODE_SIGNING_ALLOWED=NO`
- `git diff --check`

### Result

- Build: passed.
- Tests: passed, 43/43 in `ShopBackboneTests`.
- Unit test result bundle: `/tmp/RiggedShoeDerivedData-Goal100Final/Logs/Test/Test-RiggedShoe-2026.06.23_22-21-10--0700.xcresult`
- Standard UI route suite: passed, 2/2 in `ReleaseFlowUITests`.
- Standard UI result bundle: `/tmp/RiggedShoeDerivedData-UIRouteStdFinal/Logs/Test/Test-RiggedShoe-2026.06.23_22-16-43--0700.xcresult`
- Compact accessibility UI route suite: passed, 2/2 in `ReleaseFlowUITests` with `content_size accessibility-extra-extra-extra-large`.
- Compact accessibility UI result bundle: `/tmp/RiggedShoeDerivedData-UIRouteCompactA11yFull/Logs/Test/Test-RiggedShoe-2026.06.23_22-13-01--0700.xcresult`
- Generic simulator build: passed with `CODE_SIGNING_ALLOWED=NO` and `/tmp/RiggedShoeDerivedData-Goal100FinalBuild`.
- Diff check: passed.

### Simulator Coverage

- Compact: `RiggedShoe-SE-UIHardening-TextAudit`, iOS 26.5, full UI route suite passed at `accessibility-extra-extra-extra-large`.
- Compact automated route screenshots: `primary-01-contact-selection`, `primary-02-scout-report`, `primary-03-battle`, `primary-04-game-info`, `primary-05-resolved-hand`, `primary-06-stage-result`, `primary-07-reward-draft`, `primary-08-shop`, `primary-09-stage-2-scout-report`, plus matrix contact start and Stage 2 attachments, kept in the compact UI result bundle.
- Standard: `iPhone 17e`, iOS 26.5, full UI route suite and automated unit tests passed.
- Standard automated route screenshots: `primary-01-contact-selection`, `primary-02-scout-report`, `primary-03-battle`, `primary-04-game-info`, `primary-05-resolved-hand`, `primary-06-stage-result`, `primary-07-reward-draft`, `primary-08-shop`, `primary-09-stage-2-scout-report`, plus matrix contact start and Stage 2 attachments, kept in the standard UI result bundle.

### Route Matrix

- Domain route coverage: all six starting contacts now complete a two-stage route through reward/shop progression at the domain level.
- Contact startup coverage: all six contacts can start a run and apply identity/effects once.
- Automated standard-device UI route: each of the six contacts reaches Stage 2 scout report, and the detailed route covers contact selection -> scout report -> battle -> Game Info -> rapid Deal interaction -> resolved hand -> Stage Result -> reward draft -> shop -> Stage 2 scout report.
- Automated compact accessibility UI route: each of the six contacts reaches Stage 2 scout report at the largest accessibility content size, and the detailed route covers the same major surfaces with screenshots.
- 12-route matrix evidence: 6 contacts x 2 device/content-size profiles passed in UI automation.

### Lifecycle And Persistence

- Restore after Stage 1 reward selection now returns to shop with the reward already consumed and without reapplying it.
- Stage 2 clear now continues to run complete/replay without a stray reward draft.
- Below-minimum bankroll now resolves to a stage result rather than a dead battle screen.
- Reduce Motion presentation completion now clears the Deal lock synchronously after a resolved hand, which keeps rapid UI route taps from stranding the Deal button on a stale accessibility handle.
- Deterministic restore checkpoints cover battle, reward, shop, run completion, and transient-presentation cleanup at the unit level.
- App-level background/resume checkpoints now pass in UI automation at battle, reward, and shop on both standard and compact accessibility runs.

### Baccarat And Logging Coverage

- Standard four-card and third-card baccarat rounds now have explicit shoe-decrement coverage.
- Player, Banker, and Tie payout math covers push behavior and Banker commission rounding.
- Structured logging now emits prompt-aligned event names for run/contact/stage/hand/shoe/payout/modifier/reward/shop/persistence/run-end flow.
- The logger contract test verifies that hand reconstruction fields include run ID, seed, stage, hand, bet, shoe counts, bankroll/chip/heat before and after, result, and modifier/payout events.

### Accessibility And Layout

- Game Info now uses a high-contrast custom SwiftUI sheet instead of the low-contrast native confirmation dialog.
- Game Info sheet now uses scrollable content plus a toolbar Close action so the dismiss control remains reachable at compact accessibility sizes.
- Added stable accessibility identifiers for the automated release route surfaces and controls.
- Dynamic Type: compact route suite passed at `accessibility-extra-extra-extra-large`.
- VoiceOver: not verified because the available `xcrun simctl ui` controls on this machine expose appearance, increase contrast, and content size, but not VoiceOver.

### Build Environment Note

Building with `DerivedData` inside the synced Documents workspace failed at simulator code signing because the generated app bundle received file-provider/Finder metadata. Using `/tmp/RiggedShoeDerivedData` avoids that metadata and signs successfully.
`Scripts/mac_build_simulator.sh` and `Scripts/mac_test_simulator.sh` now default to `/tmp/RiggedShoeDerivedData` while preserving `DERIVED_DATA_PATH` overrides.
UI test bundles require simulator signing enabled; app/unit validation and generic simulator builds continue to pass with `CODE_SIGNING_ALLOWED=NO`.
