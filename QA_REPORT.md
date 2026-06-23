# Rigged Shoe QA Report

Date: 2026-06-23

## Verdict

Release-candidate code path: passed for the requested two-stage vertical slice.

Full App Store RC signoff: not complete until the remaining long-form manual route matrix is run on physical signing settings. The current evidence is strong for build stability, deterministic rules, guided tutorial behavior, compact/standard simulator layouts, and representative two-stage route completion.

## Evidence Reviewed Before Source Edits

- Latest source playtest report: `gameplay-analysis/playtest-20260622-165754/PLAYTEST_REPORT.md`
- Latest source app log: `gameplay-analysis/playtest-20260622-165754/logs/app-log.txt`
- Latest source screenshots: `gameplay-analysis/playtest-20260622-165754/screenshots/`
- Latest source video: `gameplay-analysis/playtest-20260622-165754/visuals/playthrough.mp4`
- Video duration reviewed: `249.145` seconds
- Source review output: `SOURCE_REVIEW.md`
- Extracted video review frames: `review-captures/source-review-video-frames/`

## Build And Test Results

### Passed

- No-sign simulator build passed on compact device:
  - Destination: `1962409B-F201-4EDD-AA8B-9D8ADBDBEA15`
  - Command: `xcodebuild -project RiggedShoe.xcodeproj -scheme RiggedShoe -configuration Debug -destination 'id=1962409B-F201-4EDD-AA8B-9D8ADBDBEA15' -derivedDataPath DerivedData-Check CODE_SIGNING_ALLOWED=NO build`
- Unit tests passed on compact device:
  - Command: `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'id=1962409B-F201-4EDD-AA8B-9D8ADBDBEA15' -derivedDataPath DerivedData-Check CODE_SIGNING_ALLOWED=NO`
  - Result bundle: `DerivedData-Check/Logs/Test/Test-RiggedShoe-2026.06.23_00-08-40--0700.xcresult`
  - Test count observed: `26` passing tests

### Signing Note

A signed local simulator build still fails on local extended-attribute/code-signing metadata in this workspace, so final validation used `CODE_SIGNING_ALLOWED=NO`. That matches the baseline workaround and does not indicate a Swift compile failure.

## Functional QA Matrix

| Area | Status | Evidence |
| --- | --- | --- |
| Source review before source edits | Pass | `SOURCE_REVIEW.md`, extracted frames, source screenshots/log/video |
| Two-stage vertical slice route exists | Pass | Stage list locked to Stage 1 and Stage 2; route test passed |
| Contacts discoverable | Pass | All six contacts visible in two-column select; compact and standard screenshots reviewed |
| Starting resources | Pass | Tests and UI show `$250`, `3 Chips`, `0 Heat` |
| Stage 1 rules | Pass | 5 hands, $25/$50/$75 bets, $75 max, solvency clear |
| Stage 2 rules | Pass | 6 hands, $50/$100 bets, $100 max, solvency clear |
| Hidden quarter-bankroll bet cap | Pass | Logic/copy removed; test verifies cap is not applied |
| Guided first hand | Pass | Test and simulator verify 312-card six-deck shoe resolves to 308 after scripted four-card natural |
| Tutorial lock behavior | Pass | First hand locks to Player $25; Player/Banker/Tie unlock after first result |
| Heat behavior | Pass | Hidden generic heat removed; visible Pit Boss Skim and Crackdown logic covered by tests |
| Stage result readability | Pass | Result copy uses solvency clear/fail language, not score-margin victory |
| Reward draft | Pass | Shows `Take 1 Reward`; one reward selection progresses to shop |
| Shop flow | Pass | Buy/reroll/continue route present; freeze/bench/sell hidden from vertical-slice shop |
| Modifier arithmetic/log order | Pass | Existing modifier engine suite passed in final test run |
| Compact simulator screenshot review | Pass | SE contact, scout, first-hand tutorial, and post-deal screenshots reviewed |
| Standard simulator screenshot review | Pass | iPhone17 contact screenshot reviewed |
| Duplicate deal prevention | Pass | Rapid repeated deal calls are ignored until presentation completion; dedicated unit test passed |
| Background/resume stress route | Partial | Full manual suspend/resume route not rerun |
| Full clean-install route per contact | Partial | Clean-install smoke covered two simulators; representative archetype route is automated, not manually played for all six |

## Screenshot Artifacts

- Baseline compact launch: `playtest-artifacts/before/20260622-230008/se/launch.png`
- Baseline standard launch: `playtest-artifacts/before/20260622-230008/iphone17/launch.png`
- Final compact contact select: `playtest-artifacts/after/20260622-234050/se/contact-after-shoe-fix.png`
- Final compact Stage 1 scout: `playtest-artifacts/after/20260622-234050/se/stage1-scout.png`
- Final compact tutorial pre-deal: `playtest-artifacts/after/20260622-234050/se/tutorial-first-hand.png`
- Final compact tutorial post-deal: `playtest-artifacts/after/20260622-234050/se/tutorial-first-hand-after-deal.png`
- Final standard contact select: `playtest-artifacts/after/20260622-234050/iphone17/contact-after-shoe-fix.png`

## Open Limitations

- Complete physical-device or signed-simulator release validation remains pending because local signing metadata blocked signed simulator builds in this workspace.
- Manual full-route playthroughs for all six contacts on both compact and standard devices remain pending; the final automated route covers representative archetype contacts.
- A dedicated suspend/resume stress pass remains pending. Duplicate-deal protection is covered by unit test and rapid-tap simulator smoke showed no duplicate hand.
