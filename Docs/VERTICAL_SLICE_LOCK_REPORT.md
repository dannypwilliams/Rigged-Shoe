# Rigged Shoe Vertical Slice Lock Report

Date: 2026-06-22

## Summary

This pass locks the early run loop around a clearer Stage 1 to Stage 2 flow. The main bug was stale Stage 1 hand/result state carrying into Stage 2; that is now reset whenever a run starts or a shop phase advances to the next stage. Stage result language now separates bankroll change from objective score margin, Heat is visible and reactive, and reward/shop cards carry more crooked-casino fantasy.

## Fixed Flow

- Stage 2 now starts on a blank board with "NEXT HAND", empty Player/Banker slots, objective progress at 0, and the deal button labeled "Deal First Hand".
- Battle history, presentation cards, reward draft state, modifier reveal counts, shoe manipulation flags, streak/loss counters, and selected bet defaults are reset on stage entry.
- Stage transition events are logged with `[StageFlow]` debug lines for future troubleshooting.

## Result Language

- Stage success now reads as opponent defeat plus score margin, for example: `Opponent defeated: Nervous Tourist. Score margin +25.00 pts.`
- Stage result rows now show Started, Ended, Bankroll Change, Objective, Progress, Score Margin, Heat Change, Chips Earned, Table Event, Optional, Main Build, and Modifier Activity.
- Score margin uses `pts` instead of looking like a cash payout, which avoids the confusing "won $25" interpretation.

## Heat System

- Baseline Heat now changes from suspicious betting patterns:
  - max bet,
  - large bet,
  - medium bet from Stage 2 onward,
  - max-bet wins,
  - Tie wins,
  - table-event rules,
  - high-heat losses cooling slightly.
- Heat feedback appears in the round feedback strip and battle log as `Table Heat`.
- If Heat reaches the cap, the Pit Boss warning applies a bankroll penalty, cools Heat back down, and records a visible ledger line.
- UI now shows Heat bands such as `Cool`, `Noticed`, and `Heat Hot` in run strips and stage overlays.

## Archetypes And Modifiers

- Added three vertical-slice archetypes: Card Reader, Comp Scammer, and Heat Gambler.
- Starting contacts now map directly to those archetypes:
  - The Dealer's Nephew: Card Reader.
  - The Comp Queen: Comp Scammer.
  - The Red Marker: Heat Gambler.
- Reward and shop cards show archetype/fantasy tags, trigger, effect, and Heat impact.
- Renamed the most visible early modifiers toward crooked-casino fantasy while preserving IDs and saved-data compatibility:
  - Bent Corner
  - Dealer's Blink
  - Burn Watcher
  - Marked Sleeve
  - Dirty Streak
  - Red Flag Bet
  - Loyalty Fraud
  - Room Credit
  - Free Drink Ticket
  - Comp Points
  - All-In Alibi
  - Backroom Break
  - Pit Boss Stare

## SE Layout Pass

- Stage result overlays now scroll vertically and wrap long rows instead of clipping.
- Reward draft cards use readable crooked-paper cards instead of compact rows.
- Shop phase uses a single-column card layout on narrow screens.
- Header, result, contact, reward, shop, and inventory copy now wraps more safely on iPhone SE.

## Playtest Evidence

Screenshots were saved in `PlaytestArtifacts/VerticalSliceLock/`:

1. `01-launch.png` - fresh contact chooser.
2. `02-stage-preview.png` - Stage 1 scout report.
3. `03-battle-initial.png` - Stage 1 clean start.
4. `04-first-hand-result.png` - first resolved hand.
5. `05-stage-result-failed.png` - natural failed result with clearer summary rows.
6. `06-run-over.png` - run over summary.
7. `07-heat-trigger-feedback.png` - visible Table Heat trigger after a large bet.
8. `08-stage-cleared.png` - Stage 1 clear result with score margin language.
9. `09-reward-draft.png` - reward draft cards with trigger/effect/Heat text.
10. `10-shop-phase.png` - one-column shop phase with archetype tags.
11. `11-stage-2-preview.png` - Stage 2 scout report.
12. `12-stage-2-clean-start.png` - Stage 2 battle starts blank with Deal First Hand.

The first natural physical pass failed Stage 1 because the opponent high-rolled, which was useful for checking failure copy. The Stage 2 path was then verified through the debug-only Instant Stage Clear control after confirming the fixed stage-clear code path.

## Verification

- Build passed:
  - `xcodebuild build -project RiggedShoe.xcodeproj -scheme RiggedShoe -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO`
- Tests passed on iPhone SE simulator:
  - `xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'platform=iOS Simulator,id=6590A5F4-E23F-4F58-A86D-21346721F429' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO`
- Result bundle:
  - `DerivedData/Logs/Test/Test-RiggedShoe-2026.06.22_17-59-13--0700.xcresult`

## Remaining Follow-Up

- Wider modifier catalog still contains some older tactical names by design; this pass renamed the highest-visibility vertical-slice set.
- Full art replacement is tracked in `Docs/ASSET_ROADMAP.md`.
- A future balance pass should tune Heat thresholds after more real runs, because the current values are intentionally visible for early playtesting.
