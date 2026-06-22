# Codex Handoff

Updated: 2026-06-22

## What changed
- Fixed modal flow screens so inactive Game Room controls are hidden from hit testing and the accessibility tree while contact, stage, result, reward, shop, game-over, or run-complete overlays are active.
- Fixed the iPhone SE shop header so `Shop Phase` no longer truncates beside the Chips panel.
- Changed the temporarily locked deal button fallback copy to `Resolving`.

## Files touched
- `RiggedShoe/App/ContentView.swift`
- `RiggedShoe/Views/RunFlowViews.swift`
- `Docs/CODEX_HANDOFF.md`
- `Docs/PlaytestScreenshots/current-sim-before-launch-20260622.png`
- `Docs/PlaytestScreenshots/current-sim-launch-20260622.png`
- `Docs/PlaytestScreenshots/current-sim-shop-after-fix-20260622.png`

## Build and test
- `./Scripts/mac_build_simulator.sh` passed.
- `xcodebuild -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination "platform=iOS Simulator,id=6590A5F4-E23F-4F58-A86D-21346721F429" -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO -parallel-testing-enabled NO test` passed: 13 tests, 0 failures.
- Initial `./Scripts/mac_test_simulator.sh` stalled while the named simulator was shut down; the direct booted-device retry passed.

## Simulator/device validation
- Fresh installed and launched on `RiggedShoe-SE-Layout-Test` running iOS 26.5.
- Tap-tested contact selection, Stage 1 preview, table battle, Stage Result, reward draft, and shop.
- Verified contact, stage, result, reward, and shop overlays no longer expose hidden table controls through accessibility.
- Verified the fixed shop header on iPhone SE and saved a screenshot.
- Physical iPhone validation was not performed in this environment.

## Playtest notes
- Table readability, tutorial bet lock, betting controls, cards, history, result explanation, reward draft, and shop cards were readable on SE.
- Stage 1 pacing felt fast and clear, and Stage Result explained why the player won or lost.
- The reward-to-shop flow is smoother now that overlays focus only on the active screen.

## Known issues
- Boss 1, deeper shop turns, game-over, and run-complete screens still need physical/manual verification.
- Late-stage balance remains Windows-owned per current balance docs.

## Windows next
- Continue Stage 8/9 tuning and monitor Stage 3 bankroll-minimum failures.
- Re-run deterministic batches after any GameCore or balance edits.

## Next recommended Codex prompt
"Continue the Mac iOS validation pass: run a fresh SE simulator playthrough through Boss 1, focusing on boss warning clarity, reward/shop pacing, and accessibility tree cleanliness."
