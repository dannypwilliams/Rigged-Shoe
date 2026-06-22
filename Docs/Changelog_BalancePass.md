# Rigged Shoe Balance Pass Changelog

Updated: 2026-06-22

## Headless Simulation

- Replaced the stale upgrade-era simulator with a rebuilt roguelite simulator at `Tools/Simulation/rigged_shoe_sim.py`.
- The simulator now models:
  - 10 short stages.
  - Baccarat hand resolution.
  - Opponent profit scoring.
  - Boss stages at 5, 8, and 10.
  - Bankroll, Chips, and Heat.
  - Starting contacts.
  - Reward cash and Chips.
  - Four-offer shop drafting.
  - Six AI policies: random beginner, conservative banker, build-aware simple, greedy high roller, tie hunter, and small ball.
- The simulator writes compact JSON and `Docs/BalanceReport.md`.
- Latest batch: 600 runs, 19.92 MB peak RSS, 0.3 seconds.
- Balance reports now include stage attempt and clear counts so late-stage percentages are easier to interpret.

## Gameplay Tuning

- Fixed a bet-cap edge case where the bankroll percentage cap could fall below the table minimum, leaving players unable to bet even though they could cover the ante.
- Early opponent-clear tolerance now ramps down more gently:
  - Stage 1: 9x ante tolerance.
  - Stage 2: 3x ante tolerance.
  - Stage 3: 2x ante tolerance.
  - Stage 4: 0.5x ante tolerance.
  - Stage 7: 8x ante tolerance to prevent the pre-Boss-2 table from becoming a hard wall.
- Stage 1 and Stage 2 clear rewards now pay 2x ante instead of 1x ante.
- Pit Boss repeated-side score pressure was softened from 0.5x ante to 0.2x ante.
- Pit Boss Heat pressure now triggers after betting the same side 4 times in a row.
- The House now uses stronger repeated-side opponent pressure than Pit Boss while keeping the same every-fourth-repeat Heat cadence. This moved the final boss from unwinnable in the stale simulation mirror to the target band without making early boss tables harsher.
- The Inspector now adds visible opponent audit pressure and +2 Heat the first time it catches reveal or shoe-control. This moved Boss 2 from 71.7% clear to 47.8% clear in the headless model.
- The Cooler now uses a cold Banker-lean style instead of copying the player's bet side, and Cold Table now applies first-loss Heat plus opponent momentum. This moved Stage 9 from 69.7% clear to 45.5%.

## Content Expansion

- Expanded modifier catalog from 80 to 120 total modifiers.
- Added eight new modifier branches:
  - Natural Hunter.
  - Pair Hunter.
  - Loaded Shoe.
  - Counter Master.
  - Boss Killer.
  - Debt / Loan.
  - Opponent Sabotage.
  - Final Hand Specialist.
- Expanded consumables from 20 to 30.
- Expanded attachments from 20 to 30.
- Expanded boss relics from 12 to 20.
- Expanded non-boss opponents from 12 to 16.
- Expanded table events from 12 to 16.
- Expanded starting contacts from 8 to 12.
- Expanded meta future hooks from 2 to 10.
- Added broader boss/elite entries for The Whale, The Insider, The Auditor, and The Collector.

## Latest Mobile UX Fixes

- Reworked the first-run starting contact screen from a tall two-column grid into a featured selected contact plus a horizontal contact rail. This keeps the start-run flow within the phone viewport and should prevent the SE simulator from opening visually in the middle of the contact list.
- Disabled shop Buy and Reroll buttons now render with visibly dimmed text, muted fill, and a subtle disabled outline so players can tell the action is unavailable before tapping.
- Stage 1 physical smoke testing previously verified the invalid tutorial `$10` soft-lock, stale bet dock, legacy upgrade overlay interruption, and stale Stage 2 unlock copy were fixed. The new contact/shop visual changes still need a fresh physical tap-through.

## Latest Balance Findings

- Stage 1, Stage 2, Stage 3, Boss 1, Stage 7, and Final Boss are in target bands.
- Stage 4 is slightly too easy.
- Stage 6 is barely above target.
- Boss 2 and Stage 9 are still slightly too easy among runs that reach them, but are much closer than before. Boss 2 had 38 attempts; Stage 9 had 19 attempts.
- Completion rate remains very low at 0.3%, which is acceptable for a vertical-slice stress batch but needs more physical playtest evidence before final tuning.

## Why These Changes Are Conservative

- No reward exceeds the ante-scaling rules.
- No new runaway cash source was added.
- Changes primarily affect pacing, table eligibility, and opponent-comparison tolerances.
- Boss counterplay remains visible instead of randomly disabling upgrades.

## Next Balance Targets

1. Add physical UI playtest evidence before tightening Boss 2 and Stage 9.
2. Watch Stage 3 bankroll-minimum failures even though the latest aggregate clear rate is in target.
3. Watch `banker.house-favorite`, which is the most picked and most triggered modifier in the latest report.
4. Confirm whether `final.closer` is genuinely under-triggering or whether final-hand hooks need stronger simulator/live reducer support.
