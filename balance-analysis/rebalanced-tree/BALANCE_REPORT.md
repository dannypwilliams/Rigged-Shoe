# Executive Verdict

The rebalanced tree remains meaningfully volatile. Player choices matter: optimized play beat novice play by 0.1% completion rate and random play by 4%. Baccarat randomness still dominates individual hands and produces wide bankroll tails; the active-roster filter prevents retired mechanics from being treated as production options.

The challenge curve is understandable in broad strokes, but not clean. Early stages mostly test bankroll survival, boss stages add visible pressure, and late results depend heavily on whether a player assembles a small number of economy, refund, and bet-control engines. Confidence is moderate for the measured command-line model and lower for exact production parity because Swift parity could not be executed in this Windows environment.

- Optimized completion: 4.9% across 1000 baseline runs.
- Novice completion: 4.8%; random completion: 0.9%.
- Total simulations completed: 33000.
- Production/simulation parity: source-mirrored static parity only; compiled production parity did not run locally.

# Most Important Findings

## 1. Trigger coverage is now explicit.

- Evidence: Declared hooks not modeled by the command-line battle flow: `cardRevealed`, `modifierSold`.
- Effect size: 0 sampled effects flagged DEAD/NO-OP.
- Sample size: Sampled ablations: 24
- Confidence interval: N/A
- Player-facing consequence: Players should not be offered mechanics whose hooks are absent from production flow.
- Recommended classification: CUT/REDESIGN
- Smallest credible intervention: Keep production modifiers on modeled hooks or add matching event emissions before making them shop-eligible.

## 2. Player agency is present but concentrated.

- Evidence: Completion gap optimized vs novice is 0.1%; optimized vs random is 4%.
- Effect size: Agency gap measured on paired-style deterministic policies.
- Sample size: Baseline samples: 1000 optimized, 1000 novice, 1000 random.
- Confidence interval: See simulation_summary.csv.
- Player-facing consequence: Some choices matter a lot while many catalog choices are decorative.
- Recommended classification: TUNE
- Smallest credible intervention: Make dead/fake choices live before tuning win rates.

## 3. Baccarat volatility remains important.

- Evidence: Fixed-shoe and fixed-tree variance experiments still show wide ending bankroll spread.
- Effect size: Optimized p05/p95 bankroll: $22.5 / $10,656.5.
- Sample size: Variance study samples: 2000 per config.
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

## 5. Tie, natural, and pair content is reliability-sensitive.

- Evidence: Tie wins are rare; natural and pair hooks are modeled but depend on low-frequency baccarat outcomes.
- Effect size: Many such picks show low trigger or selection rates.
- Sample size: Mechanic samples: 24.
- Confidence interval: See mechanic_effects.csv.
- Player-facing consequence: These mechanics need clearer payoff framing than steady wager hooks.
- Recommended classification: TUNE/REDESIGN
- Smallest credible intervention: Use low-frequency hooks for sharp moments, not as the only value in normal shop picks.

## 6. Soft Footsteps is a high-impact balance lever.

- Evidence: Ablation marginal completion: 3.2%; bankroll delta: $41.76.
- Effect size: Offer 86%, select 70.8%, trigger/run 0.868.
- Sample size: Paired seeds: 250.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 7. Comp Points is a high-impact balance lever.

- Evidence: Ablation marginal completion: 2.8%; bankroll delta: $944.84.
- Effect size: Offer 242%, select 97.6%, trigger/run 2.828.
- Sample size: Paired seeds: 250.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 8. Lucky Chip is a high-impact balance lever.

- Evidence: Ablation marginal completion: 2.4%; bankroll delta: $522.47.
- Effect size: Offer 0%, select 0%, trigger/run 5.6.
- Sample size: Paired seeds: 250.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 9. Interest Ledger is a high-impact balance lever.

- Evidence: Ablation marginal completion: 2.4%; bankroll delta: $430.32.
- Effect size: Offer 222.8%, select 128.4%, trigger/run 3.128.
- Sample size: Paired seeds: 250.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

## 10. Banco Press is a high-impact balance lever.

- Evidence: Ablation marginal completion: 0.8%; bankroll delta: $463.62.
- Effect size: Offer 97.2%, select 7.6%, trigger/run 0.568.
- Sample size: Paired seeds: 250.
- Confidence interval: Normal approximation; see CSV.
- Player-facing consequence: May become a mandatory or dominant pick if acquisition odds rise.
- Recommended classification: TUNE
- Smallest credible intervention: Use parameter sweeps before changing production values.

# Baccarat Randomness vs Player Agency

The shoe still matters. Even optimized play has broad ending-bankroll tails and stage hazards. Player agency appears mainly through bet sizing, use of legal reveal information, reward selection, and shop consolidation. The healthier target is not lower randomness; it is making more offered mechanics convert that randomness into distinct decisions.

# Difficulty and Run Pacing

| Stage | Random | Novice | Greedy | Risk-aware | Optimized |
|---:|---:|---:|---:|---:|---:|
| 1 | 9.3% | 10.9% | 10% | 11% | 10.5% |
| 2 | 30.32% | 6.397% | 13.111% | 14.157% | 5.922% |
| 3 | 39.557% | 13.789% | 67.647% | 24.215% | 11.995% |
| 4 | 34.555% | 11.683% | 10.672% | 21.071% | 10.796% |
| 5 | 34% | 16.063% | 26.106% | 22.538% | 12.708% |
| 6 | 38.182% | 9.178% | 29.747% | 14.245% | 11.702% |
| 7 | 64.356% | 35.345% | 49.505% | 37.793% | 34.969% |
| 8 | 22.857% | 14.286% | 41.667% | 13.514% | 13.505% |
| 9 | 44.444% | 26.36% | 64% | 29.333% | 26.82% |
| 10 | 40% | 70.238% | 77.778% | 51.429% | 72.34% |


# Mechanics That Do Too Little

Low offer/selection/trigger rates or dead triggers.
- `boss.boss-bounty` Boss Bounty: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `control.hot-cut` Hot Cut: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `control.slipstream` Slipstream: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `core.banker-bias` Banker Bias: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `core.clean-hands` Clean Hands: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `core.opening-tell` Opening Tell: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `core.player-surge` Player Surge: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `core.tie-insurance` Tie Insurance: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `bet.press-edge` Press the Edge: trigger 0/run, selected 0%, marginal completion -0.4%, CUT.
- `banker.banker-lock` Banker Lock: trigger 0/run, selected 0%, marginal completion 0.4%, CUT.

# Mechanics That Do Too Much

Largest positive paired marginal effects.
- `heat.soft-footsteps` Soft Footsteps: trigger 0.868/run, selected 70.8%, marginal completion 3.2%, TUNE.
- `economy.comp-points` Comp Points: trigger 2.828/run, selected 97.6%, marginal completion 2.8%, TUNE.
- `core.lucky-chip` Lucky Chip: trigger 5.6/run, selected 0%, marginal completion 2.4%, TUNE.
- `economy.interest-ledger` Interest Ledger: trigger 3.128/run, selected 128.4%, marginal completion 2.4%, TUNE.
- `banker.banco-press` Banco Press: trigger 0.568/run, selected 7.6%, marginal completion 0.8%, TUNE.
- `banker.banker-lock` Banker Lock: trigger 0/run, selected 0%, marginal completion 0.4%, CUT.
- `control.soft-cut` Soft Cut: trigger 0.184/run, selected 1.2%, marginal completion 0.4%, TUNE.
- `boss.boss-bounty` Boss Bounty: trigger 0/run, selected 0%, marginal completion 0%, CUT.
- `boss.house-crack` House Crack: trigger 0.008/run, selected 0%, marginal completion 0%, CUT.
- `control.hot-cut` Hot Cut: trigger 0/run, selected 0%, marginal completion 0%, CUT.

# Overpowered and Dominant Builds

See `build_rankings.csv` for practical build rankings. The strongest observed practical builds are not single theoretical jackpots; they are stable combinations of economy, comeback, and bet-control pieces that keep the bankroll above rising table minimums.

# Healthy and Scalable Modifiers

- Commission Dodge (`banker.commission-dodge`): triggers at 5.808/run with marginal completion -2.4%.
- Emergency Marker (`debt.emergency-marker`): triggers at 2.204/run with marginal completion -6.4%.

# Convoluted or Unnecessary Mechanics

Mechanics with `custom(...)` effects, unsupported trigger hooks, or hidden stage timing have the worst complexity-to-payoff ratio. Their strategic promise is often visible in text but absent from measured outcomes.

# Recommended Keep / Tune / Redesign / Merge / Cut Table

| Mechanic | Classification | Evidence Tags |
|---|---|---|
| `banker.banco-press` | TUNE | SCALABLE |
| `banker.banker-anchor` | TUNE | LOW PLAYER AGENCY |
| `banker.banker-lock` | CUT | TOO RARE TO MATTER |
| `banker.commission-dodge` | KEEP | DOMINANT PICK\|LOW PLAYER AGENCY |
| `banker.dealers-nod` | CUT | LOW PLAYER AGENCY |
| `bet.high-roller` | TUNE | COMEBACK |
| `bet.press-edge` | CUT | SCALABLE |
| `boss.boss-bounty` | CUT | TOO RARE TO MATTER |
| `boss.house-crack` | CUT | TOO RARE TO MATTER\|COMEBACK |
| `control.hot-cut` | CUT | TOO RARE TO MATTER |
| `control.slipstream` | CUT | SCALABLE |
| `control.soft-cut` | TUNE | SCALABLE |
| `core.banker-bias` | CUT | TOO RARE TO MATTER |
| `core.clean-hands` | CUT | TOO RARE TO MATTER\|COMEBACK |
| `core.lucky-chip` | TUNE | TOO RARE TO MATTER |
| `core.opening-tell` | CUT | TOO RARE TO MATTER |
| `core.player-surge` | CUT | TOO RARE TO MATTER |
| `core.tie-insurance` | CUT | TOO RARE TO MATTER |
| `debt.emergency-marker` | KEEP | DOMINANT PICK\|LOW PLAYER AGENCY |
| `debt.last-dollar` | TUNE | DOMINANT PICK\|LOW PLAYER AGENCY |
| `economy.comp-points` | TUNE | DOMINANT PICK |
| `economy.interest-ledger` | TUNE | DOMINANT PICK |
| `heat.low-profile` | TUNE | COMEBACK |
| `heat.soft-footsteps` | TUNE | DOMINANT PICK\|COMEBACK |

# Minimal Balance Pass

1. Keep declared-but-unmodeled hooks out of production modifiers until the app and simulator both emit them.
2. Keep Baccarat volatility intact by avoiding broader passive forecast counts until dead content is resolved.
3. Tune high-impact economy/refund/bet-control pieces only after re-running the parameter sweeps with production Swift parity available.
4. Keep low-frequency pair/natural/final-hand mechanics paired with broader `handResolved`, `wagerWon`, or `tieOccurred` value when they enter normal shops.

# Remaining Uncertainty and Required Human Playtests

Simulation supports claims about rates, tails, trigger coverage, and relative build strength. It cannot prove subjective fun, perceived fairness, comprehension, or whether dead mechanics are noticed before purchase. Human playtests should focus on whether players understand why boss pressure happens, whether shop decisions feel meaningfully different, and whether losing to early table minimums feels fair.
