# Current Tree Balance Analysis

## Smoke Test

```powershell
powershell -ExecutionPolicy Bypass -File .\balance-analysis\current-tree\reproduce.ps1 -Mode smoke -RunsPerPolicy 1000 -PairedRuns 250
```

## Full Audit

```powershell
powershell -ExecutionPolicy Bypass -File .\balance-analysis\current-tree\reproduce.ps1 -Mode audit -Workers 0 -Seed 20260622
```

## Resume

The `-Resume` switch reuses the existing artifact set when `checkpoints/manifest.csv` and all required report files are already present.

```powershell
powershell -ExecutionPolicy Bypass -File .\balance-analysis\current-tree\reproduce.ps1 -Mode audit -Workers 0 -Seed 20260622 -Resume
```

Current limitation: resume is artifact-level, not mid-chunk recovery. If a run is interrupted before final artifact write, rerun the same command and seed for deterministic regeneration.

## Outputs

- `BALANCE_REPORT.md`: verdict and findings.
- `MECHANICS_CATALOG.md`: source-grounded mechanics catalog.
- `METHODOLOGY.md`: harness, policies, validation, and limitations.
- `simulation_summary.csv`, `mechanic_effects.csv`, `build_rankings.csv`, `synergy_matrix.csv`, `parameter_sweeps.csv`: aggregate data.
- `charts/*.svg`: generated charts.
- `checkpoints/manifest.csv`: phase/configuration manifest for completed aggregates.
- `traces/sample_traces.md` and `traces/sample_traces_index.csv`: deterministic representative and anomaly traces.

## Parity

This Windows environment does not provide Swift/Xcode, so compiled production parity tests cannot run here. Re-run parity on macOS by comparing deterministic `GameViewModel` traces against the same seeds.
