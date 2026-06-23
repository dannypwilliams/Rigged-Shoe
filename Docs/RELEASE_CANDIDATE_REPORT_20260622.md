# Rigged Shoe Release Candidate Report

Date: 2026-06-22, updated 2026-06-23

## Summary

This pass converts the current build into the requested two-stage vertical slice:

- Choose one of six contacts.
- Preview Stage 1.
- Play a five-hand Stage 1.
- Take one reward.
- Buy from a three-offer shop.
- Continue to a six-hand Stage 2.
- Finish at result or replay.

The hard source-review gate was completed before source edits. The review is saved at `SOURCE_REVIEW.md` and covers the latest playtest report, full app log, screenshots, and video timeline.

## Rule Lock

- Starting run values are now `$250`, `3 Chips`, `0 Heat`, and `5` active modifier slots.
- Stage 1 is `5` hands with legal wagers `$25`, `$50`, `$75`.
- Stage 2 is `6` hands with legal wagers `$50`, `$100`.
- Legal wagers now use one rule: at least table minimum, at most fixed stage maximum, and affordable by bankroll.
- The hidden quarter-bankroll cap was removed from logic and player-facing copy.
- Stage clear is now based on staying solvent after the fixed hand count, not beating opponent profit.
- Stage 1 awards `+2 Chips`; its optional bonus is `+1 Chip` for clearing with Heat `3` or less.
- Stage 2 optional bonus remains `+1 Chip` for positive stage profit.

## Baccarat And Shoe

- Banker commission remains `0.95:1` unless a visible table rule changes it.
- Stage 2's No Commission Night visibly changes Banker to `1:1`.
- Tie remains `8:1` unless a visible table rule changes it, and Player/Banker push on Tie.
- Guided first hand now replaces the shoe's top cards instead of adding extra cards.
- Verified guided first hand starts from `312` cards and resolves to `308` after the four-card natural.

## Heat

- Generic hidden heat from large bets, max bets, Tie wins, and ordinary losses was removed.
- Heat changes now come from visible table rules or modifier resolutions.
- Heat bands are `Cool`, `Noticed`, `Watched`, and `Crackdown`.
- Heat `7+` after a profitable hand triggers a visible `Pit Boss Skim`, skimming positive profit and lowering Heat by `2`.
- Heat `10` triggers a visible `Crackdown` bankroll penalty and lowers Heat by `2`; it is not an unexplained run failure.

## UI

- Contact select is now a two-column grid showing all six contacts, selected detail, Bankroll/Chips/Heat, and a full-width `Preview Stage 1` button.
- Scout Report now shows stage/table facts quickly: hands, ante/max, clear rule, table rule, optional bonus, and resources.
- Reward draft title is `Take 1 Reward` and reward cards no longer show redundant `Trigger: Stage reward draft`.
- Shop shows three offers, buy, reroll for Chips, current build, and `Continue to Stage 2`; freeze/bench/sell controls are removed from the visible two-stage shop route.
- Stage result copy now says `Table Cleared` and explains solvency clear instead of score-margin victory.

## Verification

- Build passed:
  - `xcodebuild -project RiggedShoe.xcodeproj -scheme RiggedShoe -configuration Debug -destination 'id=1962409B-F201-4EDD-AA8B-9D8ADBDBEA15' -derivedDataPath DerivedData-Check CODE_SIGNING_ALLOWED=NO build`
- Tests passed:
  - `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'id=1962409B-F201-4EDD-AA8B-9D8ADBDBEA15' -derivedDataPath DerivedData-Check CODE_SIGNING_ALLOWED=NO`
- Latest result bundle:
  - `DerivedData-Check/Logs/Test/Test-RiggedShoe-2026.06.23_00-08-40--0700.xcresult`
- The final test run includes guided shoe count coverage, duplicate deal lock coverage, and representative two-stage route completion.

## Artifacts

- Source review artifacts:
  - `SOURCE_REVIEW.md`
  - `review-captures/source-review-video-frames/video-contact-sheet.png`
- Before baseline:
  - `playtest-artifacts/before/20260622-230008/se/launch.png`
  - `playtest-artifacts/before/20260622-230008/iphone17/launch.png`
- After verification:
  - `playtest-artifacts/after/20260622-234050/se/contact-after-shoe-fix.png`
  - `playtest-artifacts/after/20260622-234050/se/stage1-scout.png`
  - `playtest-artifacts/after/20260622-234050/se/tutorial-first-hand.png`
  - `playtest-artifacts/after/20260622-234050/se/tutorial-first-hand-after-deal.png`
  - `playtest-artifacts/after/20260622-234050/iphone17/contact-after-shoe-fix.png`

## Notes

- The first fresh simulator smoke test found the guided shoe counter still showing `312` after the scripted hand. That was fixed by changing guided card placement to replace the top cards, and the final test plus screenshot verify `308`.
- A signed simulator build still fails on local extended-attribute/code-signing metadata, so verification used `CODE_SIGNING_ALLOWED=NO`, matching the baseline workaround.
- Remaining release limitation: manual full-route playthroughs for all six contacts across compact and standard layouts, plus a dedicated suspend/resume stress pass, are documented in `QA_REPORT.md`.
