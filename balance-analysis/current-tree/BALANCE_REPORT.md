# Executive Verdict

The current tree is meaningfully volatile, but the measured strategic layer is uneven. Player choices matter: optimized play beat novice play by 10.67% completion rate and random play by 12.03%. Baccarat randomness still dominates individual hands and produces wide bankroll tails, but the tree also contains large dead zones because many declared modifier triggers are not emitted by the live battle flow.

The challenge curve is understandable in broad strokes, but not clean. Early stages mostly test bankroll survival, boss stages add visible pressure, and late results depend heavily on whether a player assembles a small number of economy, refund, and bet-control engines. Confidence is moderate for the measured command-line model and lower for exact production parity because Swift parity could not be executed in this Windows environment.

- Optimized completion: 12.162% across 100000 baseline runs.
- Novice completion: 1.492%; random completion: 0.132%.
- Total simulations completed: 1379000.
- Production/simulation parity: source-mirrored static parity only; compiled production parity did not run locally.

# Most Important Findings

## 1. Several modifier trigger families are dead in the observed battle flow.

- Evidence: Modifiers using `bossStarted`, `naturalOccurred`, `pairOccurred`, `cardDrawn`, `handStarted`, and `finalHand` have no matching `resolveActiveModifiers` emission.
- Effect size: 20 sampled effects flagged DEAD/NO-OP.
- Sample size: Sampled ablations: 120
- Confidence interval: N/A
- Player-facing consequence: Players can buy or draft mechanics that never fire.
- Recommended classification: CUT/REDESIGN
- Smallest credible intervention: Wire the trigger events or remove those shop entries until they are live.

## 2. Player agency is present but concentrated.

- Evidence: Completion gap optimized vs novice is 10.67%; optimized vs random is 12.03%.
- Effect size: Agency gap measured on paired-style deterministic policies.
- Sample size: Baseline samples: 100000 optimized, 100000 novice, 100000 random.
- Confidence interval: See simulation_summary.csv.
- Player-facing consequence: Some choices matter a lot while many catalog choices are decorative.
- Recommended classification: TUNE
- Smallest credible intervention: Make dead/fake choices live before tuning win rates.

## 3. Baccarat volatility remains important.

- Evidence: Fixed-shoe and fixed-tree variance experiments still show wide ending bankroll spread.
- Effect size: Optimized p05/p95 bankroll: $20 / $178,421.25.
- Sample size: Variance study samples: 6000 per config.
- Confidence interval: See variance chart.
- Player-facing consequence: Runs do not collapse into deterministic outcomes.
- Recommended classification: KEEP
- Smallest credible intervention: Avoid increasing always-on reveal or payout multipliers.

## 4. Strong practical builds lean toward economy/refund/bet-control stability.

- Evidence: Top build rankings repeatedly contain economy, comeback, banker, and bet-control tags.
- Effect size: Best observed build completion exceeds baseline optimized mean in build_rankings.csv.
- Sample size: Build samples from all baseline runs.
- Confidence interval: See build_rankings.csv.
- Player-facing consequence: Late-game success can become about assembling a narrow engine.
- Recommended classification: TUNE
- Smallest credible intervention: Keep opportunity costs high for repeatable bankroll/refund pieces.

## 5. Tie, natural, and pair content has poor practical reliability.

- Evidence: Tie wins are rare, while natural/pair hooks are not emitted as modifier events.
- Effect size: Many such picks show low trigger-rate or dead tags.
- Sample size: Mechanic samples: 120.
- Confidence interval: See mechanic_effects.csv.
- Player-facing consequence: These mechanics add cognitive load without dependable payoff.
- Recommended classification: CUT/MERGE/REDESIGN
- Smallest credible intervention: Merge unsupported trigger families into emitted result hooks.

## 6. Opening Tell is a high-impact balance lever.

- Evidence: Ablation marginal completion: 11.633%; bankroll delta: $34,606.23.
- Effect size: Offer 115.333%, select 28.133%, trigger/run 5.203.
- Sample size: Paired seeds: 3000.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 7. Soft Footsteps is a high-impact balance lever.

- Evidence: Ablation marginal completion: 4.467%; bankroll delta: $4,881.96.
- Effect size: Offer 33.5%, select 22.933%, trigger/run 0.267.
- Sample size: Paired seeds: 3000.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 8. Clean Hands is a high-impact balance lever.

- Evidence: Ablation marginal completion: 4%; bankroll delta: -$220.63.
- Effect size: Offer 32.4%, select 22.533%, trigger/run 0.288.
- Sample size: Paired seeds: 3000.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 9. Careful Hands is a high-impact balance lever.

- Evidence: Ablation marginal completion: 1.6%; bankroll delta: -$229.97.
- Effect size: Offer 29.7%, select 1.6%, trigger/run 0.065.
- Sample size: Paired seeds: 3000.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 10. Dealer Slip is a high-impact balance lever.

- Evidence: Ablation marginal completion: 1.467%; bankroll delta: $1,740.53.
- Effect size: Offer 11.4%, select 0.033%, trigger/run 0.002.
- Sample size: Paired seeds: 3000.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: CUT
- Smallest credible intervention: Use parameter sweeps before changing production values.

# Baccarat Randomness vs Player Agency

The shoe still matters. Even optimized play has broad ending-bankroll tails and stage hazards. Player agency appears mainly through bet sizing, use of legal reveal information, reward selection, and shop consolidation. The healthier target is not lower randomness; it is making more offered mechanics convert that randomness into distinct decisions.

# Difficulty and Run Pacing

| Stage | Random | Novice | Greedy | Risk-aware | Optimized |
|---:|---:|---:|---:|---:|---:|
| 1 | 8.618% | 9.559% | 9.898% | 11.935% | 10.934% |
| 2 | 40.039% | 3.716% | 21.338% | 20.026% | 16.719% |
| 3 | 52.772% | 27.668% | 72.807% | 37.774% | 37.118% |
| 4 | 56.316% | 34.307% | 70.091% | 49.303% | 12.098% |
| 5 | 56.041% | 43.209% | 96.149% | 55.572% | 14.305% |
| 6 | 50.859% | 34.398% | 85.185% | 44.263% | 6.218% |
| 7 | 62.245% | 42.649% | 81.818% | 45.74% | 8.089% |
| 8 | 46.554% | 29.837% | 50% | 23.175% | 10.714% |
| 9 | 34.11% | 26.512% | 0% | 14.643% | 11.237% |
| 10 | 57.556% | 66.734% | 100% | 17.668% | 49.304% |


# Mechanics That Do Too Little

Low offer/selection/trigger rates or dead triggers.
- `banker.banker-lock` Banker Lock: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `bet.overbet-permit` Overbet Permit: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `control.control-burn` Control Burn: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `control.dealers-thumb` Dealer's Thumb: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `control.hot-cut` Hot Cut: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `debt.credit-line` Credit Line: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `heat.cool-customer` Cool Customer: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `loaded.nine-engine` Nine Engine: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `tie.final-hand-tie` Final Hand Tie: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `tie.tie-master` Tie Master: trigger 0/run, selected 0%, marginal completion 0%, CUT.

# Mechanics That Do Too Much

Largest positive paired marginal effects.
- `core.opening-tell` Opening Tell: trigger 5.203/run, selected 28.133%, marginal completion 11.633%, TUNE.
- `heat.soft-footsteps` Soft Footsteps: trigger 0.267/run, selected 22.933%, marginal completion 4.467%, TUNE.
- `core.clean-hands` Clean Hands: trigger 0.288/run, selected 22.533%, marginal completion 4%, TUNE.
- `bet.careful-hands` Careful Hands: trigger 0.065/run, selected 1.6%, marginal completion 1.6%, TUNE.
- `control.dealer-slip` Dealer Slip: trigger 0.002/run, selected 0.033%, marginal completion 1.467%, CUT.
- `player.sharp-turn` Sharp Turn: trigger 0.016/run, selected 1%, marginal completion 1.067%, TUNE.
- `economy.shop-regular` Shop Regular: trigger 0/run, selected 0.267%, marginal completion 0.967%, CUT.
- `tie.equalizer` Equalizer: trigger 0.087/run, selected 4.267%, marginal completion 0.967%, TUNE.
- `tie.mirror-bet` Mirror Bet: trigger 0.039/run, selected 2.1%, marginal completion 0.8%, TUNE.
- `economy.comp-points` Comp Points: trigger 0.118/run, selected 4.367%, marginal completion 0.8%, TUNE.

# Overpowered and Dominant Builds

See `build_rankings.csv` for practical build rankings. The strongest observed practical builds are not single theoretical jackpots; they are stable combinations of economy, comeback, and bet-control pieces that keep the bankroll above rising table minimums.

# Healthy and Scalable Modifiers

- False Read (`counter.false-read`): triggers at 2.133/run with marginal completion -1.533%.
- Side Step (`player.side-step`): triggers at 2.235/run with marginal completion -1.3%.
- Soft Peek (`vision.soft-peek`): triggers at 1.04/run with marginal completion -0.467%.

# Convoluted or Unnecessary Mechanics

Mechanics with `custom(...)` effects, unsupported trigger hooks, or hidden stage timing have the worst complexity-to-payoff ratio. Their strategic promise is often visible in text but absent from measured outcomes.

# Recommended Keep / Tune / Redesign / Merge / Cut Table

| Mechanic | Classification | Evidence Tags |
|---|---|---|
| `banker.backroom-banco` | CUT | COMEBACK |
| `banker.banco-battery` | TUNE | SCALABLE |
| `banker.banco-press` | TUNE | SCALABLE |
| `banker.banker-anchor` | TUNE | SCALABLE |
| `banker.banker-lock` | CUT | TOO RARE TO MATTER |
| `banker.commission-dodge` | TUNE | SCALABLE |
| `banker.dealers-nod` | TUNE | SCALABLE |
| `banker.house-favorite` | TUNE | LOW PLAYER AGENCY |
| `banker.loyal-customer` | CUT | SCALABLE |
| `bet.careful-hands` | TUNE | SCALABLE |
| `bet.flat-better` | TUNE | SCALABLE |
| `bet.high-roller` | TUNE | COMEBACK |
| `bet.insurance-marker` | CUT | SCALABLE |
| `bet.loss-limit` | CUT | SCALABLE |
| `bet.overbet-permit` | CUT | DEAD / NO-OP\|COMEBACK |
| `bet.parlay-slip` | CUT | SCALABLE |
| `bet.press-edge` | TUNE | SCALABLE |
| `bet.safe-marker` | CUT | SCALABLE |
| `bet.small-ball` | TUNE | SCALABLE |
| `boss.boss-bounty` | CUT | DEAD / NO-OP |
| `boss.countermeasure` | CUT | COMEBACK |
| `boss.final-table-pass` | CUT | DEAD / NO-OP\|COMEBACK |
| `boss.house-crack` | CUT | TOO RARE TO MATTER\|COMEBACK |
| `boss.inside-job` | CUT | DEAD / NO-OP |
| `control.burn-notice` | TUNE | SCALABLE |
| `control.card-delay` | CUT | SCALABLE |
| `control.control-burn` | CUT | TOO RARE TO MATTER\|COMEBACK |
| `control.dealer-slip` | CUT | SCALABLE |
| `control.dealers-thumb` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER |
| `control.discard-favor` | TUNE | SCALABLE |
| `control.hot-cut` | CUT | TOO RARE TO MATTER |
| `control.shoe-pocket` | CUT | SCALABLE |
| `control.slipstream` | TUNE | SCALABLE |
| `control.soft-cut` | TUNE | SCALABLE |
| `core.banker-bias` | TUNE | SCALABLE |
| `core.clean-hands` | TUNE | OVERTUNED\|COMEBACK |
| `core.lucky-chip` | TUNE | SCALABLE |
| `core.opening-tell` | TUNE | OVERTUNED\|RANDOMNESS-ERASING |
| `core.player-surge` | TUNE | SCALABLE |
| `core.tie-insurance` | TUNE | SCALABLE |
| `counter.countertrend-plus` | TUNE | SCALABLE |
| `counter.false-read` | KEEP | DOMINANT PICK\|LOW PLAYER AGENCY |
| `counter.mirror-punish` | TUNE | SCALABLE |
| `counter.reverse-count` | CUT | DEAD / NO-OP\|CONVOLUTED |
| `counter.turnaround-table` | CUT | SCALABLE |
| `debt.credit-line` | CUT | DEAD / NO-OP\|COMEBACK |
| `debt.debt-collector` | CUT | COMEBACK |
| `debt.emergency-marker` | TUNE | SCALABLE |
| `debt.last-dollar` | TUNE | SCALABLE |
| `debt.marker-chain` | TUNE | SCALABLE |
| `economy.boss-bonus` | CUT | DEAD / NO-OP |
| `economy.chip-stipend` | CUT | TOO RARE TO MATTER |
| `economy.comp-points` | TUNE | SCALABLE |
| `economy.coupon-book` | CUT | SCALABLE |
| `economy.duplicate-finder` | CUT | CONVOLUTED |
| `economy.freeze-discount` | CUT | SCALABLE |
| `economy.interest-ledger` | TUNE | SCALABLE |
| `economy.sellback` | CUT | SCALABLE |
| `economy.shop-regular` | CUT | SCALABLE |
| `final.closer` | CUT | DEAD / NO-OP |
| `final.crown-hand` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER |
| `final.house-breaker` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER\|COMEBACK |
| `final.last-look` | CUT | DEAD / NO-OP |
| `final.redemption-hand` | CUT | DEAD / NO-OP |
| `heat.backroom-pass` | CUT | DEAD / NO-OP\|COMEBACK |
| `heat.camera-blindspot` | CUT | COMEBACK |
| `heat.cool-customer` | CUT | TOO RARE TO MATTER\|COMEBACK |
| `heat.floor-distraction` | CUT | COMEBACK |
| `heat.low-profile` | TUNE | COMEBACK |
| `heat.pit-boss-bribe` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER\|COMEBACK |
| `heat.quiet-dealer` | CUT | COMEBACK |
| `heat.soft-footsteps` | TUNE | OVERTUNED\|COMEBACK |
| `heat.surveillance-loop` | CUT | DEAD / NO-OP\|COMEBACK\|CONVOLUTED |
| `loaded.add-nine` | TUNE | SCALABLE |
| `loaded.eight-stack` | CUT | SCALABLE |
| `loaded.marked-nine` | TUNE | SCALABLE |
| `loaded.nine-engine` | CUT | TOO RARE TO MATTER |
| `loaded.nine-worship` | CUT | SCALABLE |
| `natural.natural-bonus` | CUT | DEAD / NO-OP |
| `natural.natural-comp` | CUT | DEAD / NO-OP |
| `natural.natural-read` | CUT | DEAD / NO-OP |
| `natural.perfect-nine` | CUT | DEAD / NO-OP |
| `natural.snap-nine` | CUT | DEAD / NO-OP |
| `pair.matchbook` | CUT | DEAD / NO-OP |
| `pair.pair-hunter` | CUT | DEAD / NO-OP |
| `pair.split-pocket` | CUT | DEAD / NO-OP |
| `pair.twin-engine` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER |
| `pair.twin-signal` | CUT | DEAD / NO-OP |
| `player.break-pattern` | CUT | TOO RARE TO MATTER |
| `player.countertrend` | TUNE | SCALABLE |
| `player.player-tempo` | TUNE | SCALABLE |
| `player.punto-insurance` | TUNE | SCALABLE |
| `player.punto-strike` | TUNE | SCALABLE |
| `player.reversal-read` | TUNE | SCALABLE |
| `player.sharp-turn` | TUNE | SCALABLE |
| `player.side-step` | KEEP | LOW PLAYER AGENCY |
| `player.underdog-side` | CUT | COMEBACK |
| `sabotage.cold-read` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER |
| `sabotage.house-static` | CUT | COMEBACK |
| `sabotage.opponent-tax` | CUT | CONVOLUTED |
| `sabotage.table-chat` | CUT | DEAD / NO-OP\|CONVOLUTED |
| `sabotage.tempo-theft` | CUT | CONVOLUTED |
| `tie.dead-heat` | CUT | SCALABLE |
| `tie.equalizer` | TUNE | SCALABLE |
| `tie.final-hand-tie` | CUT | DEAD / NO-OP\|TOO RARE TO MATTER |
| `tie.jackpot-discipline` | CUT | SCALABLE |
| `tie.longshot-ledger` | CUT | SCALABLE |
| `tie.mirror-bet` | TUNE | SCALABLE |
| `tie.split-signal` | TUNE | SCALABLE |
| `tie.tie-master` | CUT | TOO RARE TO MATTER |
| `tie.tie-whisperer` | TUNE | SCALABLE |
| `vision.banker-forecast` | TUNE | SCALABLE |
| `vision.boss-scout` | CUT | DEAD / NO-OP |
| `vision.dealer-glance` | TUNE | SCALABLE |
| `vision.deep-read` | TUNE | SCALABLE |
| `vision.face-down-count` | CUT | DEAD / NO-OP\|CONVOLUTED |
| `vision.pattern-memory` | TUNE | SCALABLE |
| `vision.soft-peek` | KEEP | DOMINANT PICK |
| `vision.third-card-forecast` | CUT | SCALABLE |
| `vision.tie-forecast` | TUNE | SCALABLE |

# Minimal Balance Pass

1. First, either emit or remove the unsupported trigger families. This is a content-validity fix, not a numeric rebalance.
2. Keep Baccarat volatility intact by avoiding broader passive forecast counts until dead content is resolved.
3. Tune high-impact economy/refund/bet-control pieces only after re-running the parameter sweeps with production Swift parity available.
4. Merge pair/natural/final-hand mechanics into emitted `handResolved`, `playerWonBet`, or `tieOccurred` paths if those fantasy lines remain desirable.

# Remaining Uncertainty and Required Human Playtests

Simulation supports claims about rates, tails, trigger coverage, and relative build strength. It cannot prove subjective fun, perceived fairness, comprehension, or whether dead mechanics are noticed before purchase. Human playtests should focus on whether players understand why boss pressure happens, whether shop decisions feel meaningfully different, and whether losing to early table minimums feels fair.
