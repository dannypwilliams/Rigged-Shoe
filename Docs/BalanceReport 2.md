# Rigged Shoe Balance Report

Generated: 2026-06-22 10:11:48

## Simulator

- Runner: `Tools/Simulation/rigged_shoe_sim.py`
- JSON output: `Docs/sim-post-contact-ui-fix-20260622.json`
- Runs: 600
- Strategies: random_beginner, conservative_banker, build_aware_simple, greedy_high_roller, tie_hunter, small_ball
- Seed: 20260622
- Elapsed: 0.3s
- Peak RSS: 19.92 MB

## Summary

- Completion rate: 0.3%
- Average final stage: 4.22
- Average hands: 27.9
- Average ending bankroll: $1,452.80
- Average highest bankroll: $1,917.26

## Stage Clear Rates

| Stage | Attempts | Clears | Actual | Target | Notes |
|---|---:|---:|---:|---:|---|
| 1 | 600 | 564 | 94.0% | 90%-95% | OK |
| 2 | 564 | 487 | 86.3% | 80%-90% | OK |
| 3 | 487 | 341 | 70.0% | 70%-80% | OK |
| 4 | 341 | 250 | 73.3% | 60%-70% | Too easy |
| 5 Boss | 250 | 140 | 56.0% | 50%-65% | OK |
| 6 | 140 | 86 | 61.4% | 45%-60% | Too easy |
| 7 | 86 | 38 | 44.2% | 35%-50% | OK |
| 8 Boss | 38 | 19 | 50.0% | 30%-45% | Too easy |
| 9 | 19 | 9 | 47.4% | 20%-35% | Too easy |
| 10 Boss | 9 | 2 | 22.2% | 10%-25% | OK |

## Strategy Comparison

| Strategy | Completion | Avg Final Stage | Stage 1 | Stage 2 | Stage 3 | Boss 1 |
|---|---:|---:|---:|---:|---:|---:|
| build_aware_simple | 0.0% | 4.26 | 91.0% | 90.1% | 72.0% | 71.1% |
| conservative_banker | 0.0% | 4.76 | 95.0% | 95.8% | 79.1% | 50.9% |
| greedy_high_roller | 1.0% | 4.00 | 88.0% | 86.4% | 71.1% | 48.8% |
| random_beginner | 0.0% | 3.35 | 96.0% | 67.7% | 58.5% | 30.4% |
| small_ball | 0.0% | 5.15 | 97.0% | 97.9% | 77.9% | 69.5% |
| tie_hunter | 1.0% | 3.82 | 97.0% | 80.4% | 56.4% | 50.0% |

## Economy

Average bankroll, Heat, and Chips after each reached stage.

| Stage | Bankroll | Heat | Chips |
|---|---:|---:|---:|
| 1 | $297.46 | 0.17 | 6.76 |
| 2 | $415.09 | 0.16 | 7.13 |
| 3 | $602.16 | 0.16 | 8.23 |
| 4 | $1,030.46 | 0.16 | 10.88 |
| 5 | $1,672.65 | 1.94 | 15.42 |
| 6 | $2,785.34 | 2.38 | 22.42 |
| 7 | $4,357.60 | 2.38 | 30.50 |
| 8 | $8,912.64 | 3.61 | 48.82 |
| 9 | $13,072.40 | 5.11 | 58.68 |
| 10 | $21,269.42 | 6.89 | 82.78 |

## Common Failure Points

- stage_5_boss_loss: 110
- stage_3_opponent_loss: 90
- stage_4_opponent_loss: 80
- stage_3_bankroll_minimum: 56
- stage_6_opponent_loss: 52
- stage_7_opponent_loss: 46
- stage_2_opponent_loss: 39
- stage_2_bankroll_minimum: 38
- stage_1_opponent_loss: 36
- stage_8_boss_loss: 19
- stage_4_bankroll_minimum: 11
- stage_9_opponent_loss: 8

## Modifiers

### Most Picked

- banker.house-favorite: 147
- player.punto-insurance: 128
- core.player-surge: 110
- core.lucky-chip: 96
- debt.emergency-marker: 85
- core.tie-insurance: 69
- counter.false-read: 62
- core.opening-tell: 61
- bet.careful-hands: 54
- player.countertrend: 54
- core.clean-hands: 51
- debt.last-dollar: 43

### Most Triggered

- banker.house-favorite: 3118
- core.lucky-chip: 1708
- economy.interest-ledger: 1078
- core.tie-insurance: 719
- core.opening-tell: 592
- banker.banker-anchor: 393
- core.banker-bias: 321
- core.player-surge: 241
- debt.emergency-marker: 237
- natural.natural-bonus: 232
- banker.commission-dodge: 218
- tie.equalizer: 202

### Picked But Never Triggered

- bet.careful-hands

## Diagnostics

- Stage 4 clear rate 73% is above target 60%-70%.
- Stage 6 clear rate 61% is above target 45%-60%.
- Stage 8 clear rate 50% is above target 30%-45%.
- Stage 9 clear rate 47% is above target 20%-35%.

## Notes

- This is a headless balance model, not a UI test.
- It intentionally stores compact run summaries only.
- Modifier effects are simplified but tied to current catalog IDs, tags, tiers, and common effect families.
- Physical iOS Simulator testing is tracked separately in `Docs/PhysicalPlaytestReport.md`.

