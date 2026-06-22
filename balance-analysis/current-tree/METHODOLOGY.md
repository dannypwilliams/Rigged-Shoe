# Methodology

## Harness Architecture

`reproduce.ps1` is the Windows entry point. It compiles `tools/BalanceSimulator.cs` through PowerShell `Add-Type`, so it does not require Bash, Python, Node, Xcode, or a .NET SDK. The simulator is deterministic and uses the same linear-congruential `SeededRandomGenerator` formula implemented in `BuildVarietyModels.swift`.

The simulator mirrors the production battle flow rather than the older compact Python model: 6-deck shoe, stage rules, opponent score, stage tolerances, boss pressure, emitted modifier events, stage rewards, boss rewards, shop offers, modifier leveling, active/bench slots, heat, chips, and bankroll.

## Seed Design

Each run derives separate deterministic streams from the recorded run seed: shoe/card order, tree/reward/shop generation, and policy tie-breaking. Paired studies reuse the same run index and seed derivation for control and treatment arms.

## Player Policies

- Random: chooses randomly among legal visible bets, rewards, and affordable shop offers.
- Novice/simple: prefers small Banker bets, takes obvious survival/cash rewards, and buys affordable economy/comeback pieces.
- Greedy: uses any visible forecast, otherwise bets the immediate expected-value side and presses high legal amounts.
- Risk-aware: balances forecast, bankroll, heat, and stage pressure; avoids Tie unless visible information supports it.
- Optimized: uses legal visible information plus local EV estimates, build tags, stage pressure, and shop/reward scoring. It does not inspect future unrevealed cards unless a reveal effect is active.

## Validation

Static parity checks were performed against Swift source for baccarat draw rules, payout rules, stage tables, opponent styles, seeded RNG, emitted modifier triggers, and boss pressure. The local environment had no Swift/Xcode toolchain, so 10,000 compiled Swift production parity seeds could not be executed here. This is an unresolved fidelity limitation; the model should be treated as source-mirrored rather than production-executed.

## Sampling

Mode: `audit`. Total simulations completed by this run: 1379000.
Baseline policies: random, novice, greedy, risk_aware, optimized.
Ablations use paired seeds and compare optimized policy with and without each sampled modifier. Parameter sweeps scale numeric effect families around current values.
Diagnostic traces in `traces/sample_traces.md` are deterministic examples generated from the same root seed; they are not included in aggregate rates.

## Checkpoints And Resume

The runner writes `checkpoints/manifest.csv` with completed high-level phases, configurations, sample counts, and output artifacts. `-Resume` reuses the artifact set when that manifest and all required report files are already present. Mid-chunk recovery is not implemented; if a run is interrupted before final artifact write, rerun the same command and seed for deterministic regeneration.

## Confidence Methods

Completion-rate intervals use a normal approximation for binomial proportions. Continuous metrics report means and percentiles from aggregate samples. Multiple comparisons are interpreted by effect size first; classifications avoid p-value-only claims.

## Limitations

- Production Swift parity did not run locally.
- UI-timed manual consumable actions and manual active/bench rearrangement are approximated as policy choices at reward/shop boundaries.
- Some legacy `UpgradeCard` effects are modeled by effect family, but the disabled legacy per-hand draft overlay is not simulated as active because production disables it.
- Resume support is artifact-level rather than mid-chunk recovery.
- Human fun, clarity, and emotional pacing still require playtests.
