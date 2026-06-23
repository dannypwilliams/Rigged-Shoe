# Rigged Shoe Playtest Report

Date: 2026-06-22
Device: RiggedShoe-SE-Layout-Test, iOS 26.5 simulator
Build: Debug simulator build from current workspace

## Summary

Fresh build initially failed, then passed after a one-line compile fix in `RiggedShoe/Models/ModifierModels.swift`.

The playthrough covered:
- Fresh launch
- Contact selection
- Stage 1 preview
- Stage 1 battle through all 5 hands
- Stage 1 result
- Reward draft
- Shop purchase
- Stage 2 preview
- Stage 2 battle entry
- Stage 2 bet switch to Banker
- First real Stage 2 deal

No app crash, fatal error, or Swift exception was observed in the captured app log.

## Gameplay Errors Encountered

1. Build blocker before gameplay
   - Current source failed to compile because `Modifier.definition(id:)` called `allContent.first` without returning it.
   - Evidence: initial build output showed `missing return in static method expected to return 'Modifier?'` at `RiggedShoe/Models/ModifierModels.swift:735`.
   - Action taken: added the missing `return` so the latest build could be played.

2. Stage 2 battle starts with stale previous-hand presentation
   - After leaving the Stage 2 scout report and entering battle, the table showed `LAST HAND RESULT` immediately, before any Stage 2 deal.
   - The stale result mixed prior hand cards/history with Stage 2 state, including the new `$50` selected bet and Emergency Marker stage-start bonus text.
   - Evidence: `visuals/11-stage-2-battle-start.png` and `visuals/12-stage-2-banker-selected.png`.
   - Severity: High. The gameplay state may be correct internally, but the first view of a new stage is misleading.

3. Stage result headline reads like the wrong payout
   - Stage 1 result said `You beat Nervous Tourist +$151.25` while the Player Score, Profit / Loss, and Bankroll Change were all `+$75`.
   - This appears to be score margin, but it reads like a bankroll gain and conflicts with the rest of the result panel.
   - Evidence: `visuals/06-stage-result.png`.
   - Severity: Medium.

4. Shop layout overlaps the status-bar area after buying
   - After buying `Comp Points`, the `Shop Phase` title moved upward into the iOS status-bar/time area on the SE simulator.
   - Evidence: `visuals/09-after-shop-buy.png`.
   - Severity: Medium.

5. Shop cards and current-build entries truncate important names/descriptions on SE
   - Examples include `Comp P...`, `Reversa...`, `Emergency...`, and `Comp Point...`.
   - This makes it hard to understand purchases and owned build pieces.
   - Evidence: `visuals/08-shop-phase.png` and `visuals/09-after-shop-buy.png`.
   - Severity: Medium.

6. Stage preview text truncates on SE
   - Stage 2 scout report title shows `Stage 2 - 6 han...`.
   - Some optional/objective text sits very close to the panel edge.
   - Evidence: `visuals/10-stage-2-preview.png` and `visuals/02-stage-preview.png`.
   - Severity: Low to Medium.

7. Contact carousel is partially clipped on SE
   - The contact selection row cuts off neighboring cards. The selected contact and primary button remain usable.
   - Evidence: `visuals/01-launch.png`.
   - Severity: Low.

## Working Flow Observed

- Contact selection advanced to Stage 1 preview.
- Stage 1 preview advanced to battle.
- Tutorial first hand locked Player correctly and unlocked later betting controls after resolution.
- Stage 1 hand counter, bankroll, cards, and battle history advanced through all 5 hands.
- Tie result on a Player bet pushed for `$0`.
- Stage 1 result advanced to reward draft.
- Reward draft advanced to shop.
- Shop purchase reduced Chips and increased current build count.
- Stage 2 preview advanced to battle.
- Banker bet selection worked in Stage 2.
- First real Stage 2 hand resolved correctly after the stale-start presentation.

## Evidence Files

- `visuals/playthrough.mp4`
- `visuals/01-launch.png`
- `visuals/02-stage-preview.png`
- `visuals/03-battle-start.png`
- `visuals/04-after-first-deal.png`
- `visuals/05-mid-stage.png`
- `visuals/06-stage-result.png`
- `visuals/07-reward-draft.png`
- `visuals/08-shop-phase.png`
- `visuals/09-after-shop-buy.png`
- `visuals/10-stage-2-preview.png`
- `visuals/11-stage-2-battle-start.png`
- `visuals/12-stage-2-banker-selected.png`
- `visuals/13-stage-2-first-real-hand.png`
- `logs/app-log.txt`

