# Rigged Shoe Simulation Beta Report

## Pre-Change Pass

Date: 2026-06-21

### What Was Tested

- Project structure, main game loop, stage definitions, bet caps, upgrade generation, payout modifiers, stage rewards, boss stage schedule, and Game Room flow were inspected.
- Added a lightweight headless simulator at `Tools/Simulation/rigged_shoe_sim.py`.
- Ran compact deterministic simulations using fresh-player content and all-content-unlocked pools.
- Strategies simulated: conservative, aggressive, synergy-seeking, and unclear-power testing.

### Simulation Setup

- Runs: 64 total baseline runs.
- Batch size: 8 runs per strategy per content pool.
- Seed start: 70121.
- Seed step: 37.
- Runtime: 0.083 seconds.
- Peak memory: 17.3 MB.
- No simulator or UI process was required for the baseline batch.

### Baseline Results

Fresh-player pool:

- Stage 1 clear rate: 100% across all strategies.
- Stage 2 clear rate: 38%-62% for non-aggressive strategies.
- Stage 3 clear rate: 12%-38% for non-aggressive strategies.
- Aggressive play reached farther but used maximum bet almost every hand.

All-content pool:

- Most strategies completed the season nearly every time.
- Ending bankrolls regularly exceeded $600K-$1.5M in the simulator.
- Passive-income and oversized chosen-win bonuses dominated upgrade value.

### Biggest Gameplay Problems

1. Stage 2 is too punishing for careful play. A strict break-even requirement over 12 hands still depends heavily on variance.
2. Stage 3 asks for 10% growth too early, before most builds have reliable tools.
3. Several later common/rare upgrades still use the old large economy and can trivialize the run once unlocked.
4. Aggressive strategy can still outperform careful strategy by repeatedly using the largest unlocked bet.

### Biggest Usability Problems

- Fresh progression mostly teaches the right concepts, but Stage 2 failure can feel like the game punished normal play.
- Some economy upgrade descriptions promise huge money values that do not match the current $250 starting-bankroll scale.

### Broken or Suspicious Systems

- No broken shoe preview or payout-ledger behavior was found from code inspection during this pass.
- Suspicious upgrade values: VIP Lounge, Equals Sign, House Ledger, Table Hero, Comped Drinks, Danger Money, Casino Coupon, Known Shoe, High Limit Permit, Security Badge, Private Marker, Accounting Trick, Boss Ledger.

### Recommended Fixes Ranked By Impact

1. Make Stage 2 a controlled-risk objective instead of strict break-even.
2. Reduce Stage 3 growth target from 10% to a softer first-profit target.
3. Re-scale common/rare economy upgrades to the $250 bankroll economy.
4. Re-run the same compact simulation batch and compare first-three-stage clear rates.

## Changes Made

- Stage 2 changed from strict break-even over 12 hands to a 10-hand controlled-risk objective with a $60 loss limit.
- Stage 3 growth target reduced from 10% to 6%.
- Stage 5 growth target reduced from +$150 to +$125.
- Oversized common/rare economy upgrades were re-scaled to the current $250-start economy.
- Simulator was kept deterministic and source-aware by parsing upgrade values from `UpgradeCard.swift`.

## Post-Change Pass

### Simulation Setup

- Runs: 64 total post-change runs.
- Same seed range and strategy mix as baseline.
- Runtime: 0.117 seconds.
- Peak memory: 17.31 MB.

### Before / After Highlights

Fresh-player pool:

- Conservative Stage 2 clear rate improved from 62% to 100%.
- Conservative Stage 3 clear rate improved from 12% to 75%.
- Synergy Stage 2 clear rate improved from 50% to 88%.
- Synergy Stage 3 clear rate improved from 38% to 62%.
- Unclear-power testing Stage 2 clear rate improved from 62% to 100%.
- Aggressive play still reaches farther, but it is clearly identified by a near-constant max-bet ratio.

All-content pool:

- Baseline all-content runs were effectively guaranteed and often ended above $1M.
- Post-change all-content runs still allow strong builds, but no common/rare upgrade is flagged by the simulator as an obvious runaway.
- Season completion remained possible, but failures returned in late stages, especially Stage 7-10, which is healthier for replayability.

### Remaining Balance Risks

- Stage 3 is now achievable but still a meaningful filter for non-aggressive strategies.
- Stage 4 can fail if players collect information/control upgrades but do not land an upgrade-influenced win quickly.
- Aggressive max-bet play is still viable; this may be acceptable as a risky archetype, but it should stay under watch.
- Legendary economy upgrades remain intentionally explosive and need a later late-game-only balance pass.

### Current Recommendation

Keep this tuning for the next beta build and gather player feedback on Stage 3 and Stage 4. The early game now has a softer learning curve without turning the whole run into free money.

## Heartbeat UI Pass - 2026-06-21 14:35

### What Was Tested

- Ran a fresh 20-run deterministic headless batch using fresh-player content only.
- Relaunched a fresh install on the small-screen iPhone simulator.
- Verified the opening Game Room state, tutorial bet lock, hidden shoe, bottom bet controls, and readable Stage 1 objective.

### Findings

- The UI remains readable on the small-screen simulator.
- The Game Room still clearly presents the scripted first Player hand and locked early bet controls.
- The next highest-impact design issue was Stage 4: the objective said upgrades/reveal/shoe control could contribute, but model logic only counted wins with explicit upgrade trigger messages.
- This made reveal-assisted wins feel like they should satisfy the objective, while the run could still fail Stage 4.

### Change Made

- Stage 4 now counts reveal-assisted winning bets as upgrade-influenced wins.
- Stage 4 copy was clarified to "Upgrade or Reveal Win."
- The simulator now mirrors that same rule.

### Post-Change Mini Batch

- Runs: 20 fresh-player runs.
- Runtime: 0.03 seconds.
- Peak memory: 17.27 MB.
- Synergy strategy Stage 4 failures dropped from 3/5 to 0/5 in this seed batch.
- Remaining synergy failures moved to Stage 5 or Stage 2, which is healthier than failing the first upgrade-teaching objective.

## Heartbeat Reward Variety Pass - 2026-06-21 14:41

### What Was Tested

- Ran a fresh 20-run deterministic headless batch using seed `74147`.
- Attempted a fresh-install iPhone SE Simulator pass; the simulator reached the home screen, but `simctl install` stalled before Rigged Shoe launched.
- Kept logs compact and confirmed the Python pass stayed at 17.36 MB peak memory.

### Finding

- Fresh-player upgrade rewards were still offering repeated non-stacking information upgrades.
- X-Ray Shoe appeared as many as 37 times across 5 unclear-power runs before this pass, even though extra copies do not improve the charged reveal summary.
- This made reward choices feel less trustworthy: players could spend reward picks on cards that appeared exciting but did not add a clear new benefit.

### Change Made

- Upgrade rewards now avoid offering duplicates for naturally non-stacking effects when other choices are available.
- Stackable duplicates are still allowed, including money bonuses, card injection/removal, Hot/Cold Shoe effects, and combined cards with stackable payout bonuses.
- The lightweight simulator mirrors the same duplicate-filtering rule.

### Post-Change Mini Batch

- Runs: 20 fresh-player runs.
- Runtime: 5.761 seconds.
- Peak memory: 17.36 MB.
- X-Ray Shoe dropped from 28-37 picks per 5-run reveal-focused group to 5 picks, roughly one per run.
- Upgrade variety improved: reward paths now include more Safety Net, Damage Control, Small Ball, Burn Control, Face Card Purge, and shoe cards instead of repeated dead X-Ray picks.
- First-three-stage clear rates remained comparable: Stage 1 and Stage 2 stayed at 100%; Stage 3 ranged from 40%-100% depending on strategy.

### Verification Notes

- Edited Swift files passed a syntax parse check.
- Full `xcodebuild` verification was blocked by the simulator/build service stalling before compilation output; the stalled build process was interrupted and no Rigged Shoe build or simulator process was left running.

## Heartbeat Stage 3 Pacing Pass - 2026-06-21 15:13

### What Was Tested

- Ran a fresh 20-run deterministic headless batch using seed `81334`.
- Ran a smaller 12-run confirmation batch using seed `82134`.
- Launched Rigged Shoe on the iPhone SE simulator and clicked through the opening Game Room, first hand, and first upgrade offer.
- Kept memory use compact: the 20-run batch peaked at 17.36 MB before changes and 17.48 MB after changes.

### Finding

- Stage 3 was still acting like a variance wall for careful play in some seed batches.
- Before this pass, the seed `81334` batch produced a 0% Stage 3 clear rate for conservative play and 40%-60% for non-aggressive non-conservative strategies.
- The problem was the 6% target scaling upward after early cash rewards. A player could play sensibly, avoid reckless betting, and still fail the first profit-growth lesson.

### Change Made

- Stage 3 now asks the player to grow bankroll by a fixed $15 from stage start instead of growing by 6%.
- This keeps Stage 3 as the first profit-growth lesson, but avoids punishing players for entering the stage with a healthier bankroll.
- The simulator stage table was updated to mirror the app model.

### Post-Change Mini Batch

- Runs: 20 fresh-player runs using the same seed `81334`.
- Runtime: 0.086 seconds.
- Peak memory: 17.48 MB.
- Stage 3 clear rates improved:
  - Aggressive: 80% -> 100%.
  - Conservative: 0% -> 60%.
  - Synergy: 60% -> 80%.
  - Unclear-power testing: 40% -> 60%.
- Stage 5 remains the most common first real profit gate, which is acceptable for the current pacing target.

### UI Play Notes

- The small-screen Game Room was readable.
- Deal remained visible and reachable.
- The first tutorial state clearly locked Banker and Tie and explained the scripted Player bet.
- The shoe remained hidden by default.
- The first upgrade cards were readable and returned cleanly to the table after selection.
- One automation tap appeared to advance to the first upgrade offer with Stage 1 showing 2 hands completed. This may be an accessibility-click artifact, but it should be watched in future human-device testing.

### Verification Notes

- Edited Swift files passed syntax parsing.
- Full Xcode simulator build passed after the code changes.
- No Rigged Shoe simulator/build processes were left running after the pass.

## Heartbeat Deal Trust Pass - 2026-06-21 15:18

### What Was Tested

- Inspected the Deal button path from `ContentView` through `GameViewModel`.
- Revisited the prior UI note where one automation tap appeared to advance two hands.
- Ran a fresh 12-run deterministic headless batch using seed `81855`.
- Built and launched the app on the iPhone SE simulator.
- Performed an intentional double-tap on the Deal button during a live simulator run.

### Finding

- The Game Room had a local animation guard, and `ContentView` delayed reward/run-over overlays until result reveal.
- The shared game model still allowed another deal as soon as the first synchronous `dealRound()` finished, before the result presentation necessarily finished.
- This could let rapid taps or accessibility actions accept an unintended second hand, which is a direct player-trust issue.
- While inspecting the dock copy, stale guidance still referenced Stage 2 as a 12-hand break-even stage and Stage 3 as a 10% growth stage.

### Change Made

- Added a non-persistent ViewModel-level deal-resolution lock.
- `canDeal` now stays false from the start of a hand until the result reveal completes.
- `ContentView` releases the lock after result presentation, including the reduce-motion path.
- Debug fast-forward uses a private bypass so internal tools still work without weakening production tap protection.
- Updated Stage 2 and Stage 3 guidance copy to match the current objectives.

### Verification

- Edited Swift files passed syntax parsing.
- Full Xcode simulator build passed.
- iPhone SE simulator launched the updated build.
- Intentional double-tap on Deal accepted only one hand: Stage 1 moved from 8 rounds left to 7 rounds left, not 6.
- The table remained readable and the Deal button stayed reachable.
- No Rigged Shoe simulator/build processes were left running after cleanup.

### Balance Notes

- The 12-run model batch stayed lightweight at 17.27 MB peak memory.
- Stage 5 remains the common first real profit gate.
- This pass changed tap-safety and clarity only; it did not alter bankroll math or upgrade effects.

## Heartbeat Stage 5 Guidance Pass - 2026-06-21 15:35

### What Was Tested

- Ran a fresh 20-run deterministic headless batch using seed `83554`.
- Reviewed current stage objectives, Stage Clear preview copy, and Game Room deal guidance.
- Built and launched the app on the iPhone SE simulator for a small-screen table smoke check.

### Finding

- Stage 5 is still the most common first real profit gate, but not a universal wall.
- Conservative play sometimes reached Stage 9, while aggressive play regularly reached Stage 8-9 in the test batch.
- That suggests Stage 5 is doing useful build-check work and should not be softened blindly.
- The missing piece was player guidance: the Game Room did not clearly tell players that Stage 5 is where they should stop pure minimum-bet survival and start using upgrade edges plus larger unlocked bets.

### Change Made

- Added Stage 4 deal guidance: chase one upgrade-powered win and let the best bonus or reveal guide the bet.
- Added Stage 5 deal guidance: this is the first profit gate, so use the build and press $50-$75 only when upgrades or reveals give an edge.
- Updated Stage 5 objective description to frame it as a first profit gate rather than a plain money demand.

### Verification

- Edited Swift files passed syntax parsing.
- Full Xcode simulator build passed.
- iPhone SE simulator launched the updated build.
- The restored Game Room remained readable, with the Deal button and bet controls reachable.
- No gameplay math, upgrade effects, or stage targets were changed in this pass.

## Heartbeat Risk Warning Pass - 2026-06-21 15:55

### What Was Tested

- Ran a fresh 20-run deterministic headless batch using seed `85513`.
- Reviewed the Game Room deal guidance order and current stage objective copy.
- Built and launched the app on the iPhone SE simulator for a small-screen smoke check.

### Finding

- Aggressive play still uses the maximum unlocked bet very frequently, but this seed batch did not show it as a guaranteed win path.
- The more concrete UX problem was that the high-risk bet warning sat below stage-specific guidance.
- On Stages 1-5, the stage guidance returned first, so a player could select a bet above 25% of bankroll without seeing the risk warning.

### Change Made

- Moved the high-risk bet warning above stage-specific tips.
- The Game Room now prioritizes bankroll-risk feedback whenever the selected bet is more than 25% of bankroll.
- No bankroll math, bet limits, upgrade effects, or stage targets were changed.

### Verification

- Edited Swift files passed syntax parsing.
- Full Xcode simulator build passed.
- iPhone SE simulator launched the updated build.
- The restored Game Room remained readable, with the Deal button and bet controls reachable.
- The 20-run batch stayed lightweight at 17.38 MB peak memory.
