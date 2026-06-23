# Source Review

Date: 2026-06-22
Workspace: `/Users/danielwilliams/Documents/RiggedShoe_FullProject_ShoeDashboard_2026-06-21_1202`

## Files Reviewed

- Latest playtest report: `gameplay-analysis/playtest-20260622-165754/PLAYTEST_REPORT.md`
- Latest playtest log: `gameplay-analysis/playtest-20260622-165754/logs/app-log.txt` (242 lines reviewed)
- Latest compact-phone screenshots: `gameplay-analysis/playtest-20260622-165754/visuals/01-launch.png` through `13-stage-2-first-real-hand.png`
- Latest playtest video: `gameplay-analysis/playtest-20260622-165754/visuals/playthrough.mp4`
- Extracted video frames/contact sheet: `review-captures/source-review-video-frames/`
- Baseline build and launch artifacts: `playtest-artifacts/before/20260622-230008/`
- Project and target settings: `RiggedShoe.xcodeproj/project.pbxproj`, `RiggedShoe.xcodeproj/xcshareddata/xcschemes/RiggedShoe.xcscheme`, `RiggedShoe/Info.plist`
- Core model/state files: `RiggedShoe/Models/BalanceRules.swift`, `Stage.swift`, `RunManager.swift`, `GameState.swift`, `Shoe.swift`, `BaccaratHand.swift`, `RoundResult.swift`, `ModifierModels.swift`, `ShopModels.swift`, `RunPersistenceManager.swift`
- View model and app flow: `RiggedShoe/ViewModels/GameViewModel.swift`, `RiggedShoe/App/ContentView.swift`
- Release-route UI files: `RiggedShoe/Views/RunFlowViews.swift`, `StageClearView.swift`, `CasinoLobbyView.swift`, `BetSelectionView.swift`, `ShoeView.swift`, `RoundResultView.swift`, `HistoryView.swift`, `CrookedCasinoTheme.swift`, `CasinoTheme.swift`
- Existing tests: `RiggedShoeTests/ShopBackboneTests.swift`

## Build Baseline

- Project: `RiggedShoe.xcodeproj`
- Scheme: `RiggedShoe`
- Targets found: `RiggedShoe`, `RiggedShoeTests`
- Deployment target: iOS 17.0
- Bundle identifier: `com.danielwilliams.RiggedShoe`
- Target device family: iPhone

The first untouched signed simulator build failed during app bundle signing with:

`resource fork, Finder information, or similar detritus not allowed`

This was caused by local macOS/File Provider extended metadata being copied into the generated simulator app bundle, not by Swift source compilation. A second signed attempt after clearing ordinary source/project extended attributes failed with the same generated-bundle signing error. The no-sign simulator build succeeded and was used for clean-install baseline launches on:

- `RiggedShoe-SE-Fresh-Playtest` (iOS 26.5 simulator)
- `iPhone 17` (iOS 26.5 simulator)

Baseline screenshots and logs are saved under `playtest-artifacts/before/20260622-230008/`.

## Video Durations

- `gameplay-analysis/playtest-20260622-165754/visuals/playthrough.mp4`: 249.145 seconds, 750x1334.
- `ffprobe` was unavailable in this environment. Duration and dimensions were verified with macOS metadata and Swift AVFoundation frame extraction.

## Chronological Interaction Notes

- 0:00: Recording starts on the simulator home screen.
- 0:15: App is on `Choose Contact`; selected contact detail is visible, but contact selection is a clipped horizontal strip.
- 0:30: Stage 1 Scout Report is visible. It communicates stage, hand count, ante, opponent, objective, table event, optional bonus, bankroll, chips, and heat. It still uses dense two-column rows and green/glass styling.
- 0:45: Stage 1 battle initial state. Tutorial preselects Player $25 and disables other sides/amounts. Copy communicates the tutorial lock.
- 1:00-1:15: First hand resolves, with Player natural result and reward ledger. Deal appears briefly disabled during presentation.
- 1:30: Stage 1 mid-stage after a loss. Shoe count has dropped to 306, confirming non-guided hands consume cards.
- 1:45: Tie hand is visible; Player/Banker wager push appears to net $0.
- 2:00: Hand 5 is visible with updated shoe count and battle history.
- 2:15: Stage result appears. Headline says the player beat the opponent by +$151.25, while bankroll change is +$75. This reads like the wrong payout.
- 2:30-2:45: Shop phase appears with three offers. Offer names/effects truncate on SE. Freeze, bench, and sell dominate the release-route shop despite the two-stage slice not needing them.
- 3:00: After buying Comp Points, the shop title is pushed into the status bar area and purchased card state is dimmed.
- 3:15: Stage 2 Scout Report appears. Title truncates as `Stage 2 - 6 han...`; table rule is No Commission Night.
- 3:30-3:45: Stage 2 battle entry shows `LAST HAND RESULT` and prior cards before any Stage 2 deal. This stale result is the clearest high-severity state defect.
- 4:00: First real Stage 2 hand has resolved after switching to Banker. The actual hand flow continues, but the stale-start presentation made the stage transition misleading.

## Log Review

The latest playtest app log contains no app-owned crash, fatal error, Swift exception, or assertion failure. Lines matching error-like text are simulator/framework noise, including `BoardServices` XPCErrors, `libCoreFSCache` missing cache files, Metal shader compilation, and render pipeline timing.

The baseline launch logs likewise show no app-owned crash/fatal/Swift exception lines. Error-like lines are framework noise.

## Confirmed Defects

1. Stage 2 battle starts with stale previous-hand result cards and ledger before the first Stage 2 deal.
2. Stage result headline uses score margin in a way that reads like bankroll gain and conflicts with bankroll-change rows.
3. Shop can move into the status-bar area after purchase on SE.
4. Shop cards/current build truncate important offer and owned-modifier text on SE.
5. Shop still emphasizes freeze, bench, and sell controls even though the release route calls for one compact three-offer shop.
6. Stage 2 scout title truncates on SE.
7. Contact selection uses a clipped horizontal strip instead of showing all six contacts.
8. Current legal wager logic still includes the hidden `bankroll / 4` cap and allows Stage 2 $150 despite the release-route fixed $100 maximum.
9. Theme still reads as dominant green/glass rather than the requested opaque crooked casino paper/dark table direction.

## Positive Findings

- Fresh launch and clean-install baseline both reach the contact-selection flow.
- Stage 1 tutorial hand preselects Player $25 and disables other visible controls.
- Baccarat flow resolves multiple hands without crashing.
- Tie on Player bet pushes for $0 in the observed flow.
- Shoe count decreases during normal hands.
- Stage 1 result advances to reward draft, reward draft advances to shop, and shop advances to Stage 2 preview.
- Stage 2 Banker selection works and the first real Stage 2 hand resolves.
- Background logs show no fatal persistence or lifecycle issue during the captured playtest.

## Evidence Discrepancies

- The playtest report states the build initially failed on `Modifier.definition(id:)` and was fixed before capture; the current workspace no longer reproduces that Swift compile failure.
- The video and screenshots agree on the Stage 2 stale-result defect.
- The video and screenshots agree on shop truncation/status-bar overlap.
- No referenced playtest video was missing or unreadable.
- The requested compact-phone evidence exists. A separate standard-phone baseline launch screenshot was created in `playtest-artifacts/before/20260622-230008/iphone17/launch.png`.
