# Pre-Change Audit

Generated before production balance edits for the rebalanced-tree pass.

## Repository Context

- Current branch: `main`, read from `.git/HEAD`.
- Default branch: `origin/main`, read from `.git/refs/remotes/origin/HEAD`.
- Git status: unavailable. The Windows shell could not find a `git` executable on `PATH` or in common `C:\Program Files\Git` locations, so uncommitted files and diffs could not be mechanically classified.
- Existing uncommitted files: unknown for the same reason. Treat all existing files as user/worktree state and do not discard them.
- Git available in shell: no.

## Available Build Tools

- PowerShell: available at `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`.
- .NET runtime: available, but no .NET SDK installed.
- Swift: not available.
- Xcode / Apple build environment: not available.
- Python: `python.exe` exists as a WindowsApps shim, but failed to execute.
- Node/npm: not available.

Implication: production Swift/Xcode tests and compiled production parity cannot run in this Windows environment. The current-tree simulator entry point is PowerShell-based and uses `Add-Type`; it is the only local validation path expected to be runnable here.

## Baseline Report Verification

The current-tree report package was read before editing:

- `BALANCE_REPORT.md`
- `MECHANICS_CATALOG.md`
- `METHODOLOGY.md`
- `README.md`
- `simulation_summary.csv`
- `mechanic_effects.csv`
- `build_rankings.csv`
- `synergy_matrix.csv`
- `parameter_sweeps.csv`

Verified baseline findings from the report artifacts:

- Optimized completion: 12.162% across 100,000 baseline runs.
- Novice completion: 1.492%.
- Random completion: 0.132%.
- Total simulations completed: 1,379,000.
- Swift/Xcode parity did not run locally; the baseline is source-mirrored static parity only.
- Optimized conditional hazards are irregular, with Stage 3 at 37.118% and Stage 10 at 49.304%.
- Optimized ending bankroll has a large upper tail: p95 `$178,421.25`.
- `mechanic_effects.csv` contains metric-definition defects; for example `core.opening-tell` reports `offer_rate=115.333%`, so offer rate and offers-per-run are currently conflated.

## Source Files Read

Production and simulator files inspected before this note:

- `RiggedShoe/ViewModels/GameViewModel.swift`
- `RiggedShoe/Models/ModifierModels.swift`
- `RiggedShoe/Models/Stage.swift`
- `RiggedShoe/Models/StageReward.swift`
- `RiggedShoe/Models/ShopModels.swift`
- `RiggedShoe/Models/Boss.swift`
- `RiggedShoe/Models/BossManager.swift`
- `RiggedShoe/Models/BossReward.swift`
- `RiggedShoe/Models/OpponentModels.swift`
- `RiggedShoe/Models/RunManager.swift`
- `RiggedShoe/Models/RunState.swift`
- `RiggedShoe/Models/RunPersistenceManager.swift`
- `RiggedShoe/Models/UpgradeCard.swift`
- `RiggedShoe/Models/Shoe.swift`
- `RiggedShoe/Models/BetType.swift`
- `RiggedShoe/Models/BaccaratHand.swift`
- `RiggedShoe/Models/RoundResult.swift`
- `RiggedShoe/Models/BuildVarietyModels.swift`
- `balance-analysis/current-tree/tools/BalanceSimulator.cs`
- `balance-analysis/current-tree/reproduce.ps1`
- `RiggedShoeTests/ShopBackboneTests.swift`

## Current Live Modifier Count

- Unique modifier IDs found in `ModifierModels.swift`: 120.
- `Modifier.allContent` is `sampleDebugPool + expandedContent`; shops and modifier drafts use this full set with no active-roster availability class.
- Current starter identity comes from `StartingContact` objects, not from an explicit six-starter draft.

## Current Reachable Legacy-Upgrade Count

- Legacy `UpgradeCard` definitions found through the `card(...)` helper: 162 unique names.
- Legacy per-hand upgrade drafts are gated by `shouldOfferLegacyShoeUpgradeDrafts == false`.
- Legacy upgrades remain reachable through stage rewards, boss rewards, debug grants, save restore, and pending upgrade choices.

Reachable live paths include:

- `StageRewardEffect.duplicateRandomAcquiredUpgrade`
- `StageRewardEffect.addRandomUpgrade`
- `BossRewardEffect.duplicateRandomUpgrades`
- `BossRewardEffect.addRandomLegendaryUpgrade`
- `GameViewModel.applyStageReward`
- `GameViewModel.applyBossReward`
- `GameViewModel.debugGrantUpgrade`
- `GameViewModel.debugGrantLegendaryUpgrade`
- `RunPersistenceManager.restore`, which rebuilds saved acquired and pending upgrade names from `UpgradeCard.allCards`

## Current Emitted And Missing Trigger Events

Baseline catalog says observed emitted triggers are:

- `stageStarted`
- `betPlaced`
- `beforeDeal`
- `playerWonBet`
- `playerLostBet`
- `tieOccurred`
- `heatGained`
- `shopEntered`
- `shopRerolled`
- `modifierBought`
- `modifierSold`
- `modifierLeveled`

Observed in source:

- `GameViewModel` emits out-of-hand shop and modifier events through `emitOutOfHandModifierEvent`.
- `dealRound` resolves `betPlaced`, `beforeDeal`, `playerWonBet` / `playerLostBet`, and `tieOccurred`.
- `stageStarted` is resolved by `resolveStageStartedModifiersIfNeeded`.
- `handStarted` and `handResolved` are currently appended to the debug log but are not passed to `ModifierEngine.resolve`.
- `bossDefeated` is represented in progress tracking and boss reward setup but not emitted as an active modifier event before reward resolution.

Declared but missing from live modifier resolution:

- `runStarted`
- `handStarted`
- `cardRevealed`
- `cardDrawn`
- `handResolved`
- `naturalOccurred`
- `pairOccurred`
- `bossStarted`
- `bossDefeated`
- `finalHand`
- `runEnded`

Naming mismatch:

- The current engine uses `playerWonBet` and `playerLostBet`; the rebalance requires `wagerWon` and `wagerLost` because Player is also a baccarat side.

## Current Stage Table

The baccarat foundation is in production source and must be preserved in the first pass:

| Stage | Hands | Ante | Legal Bets |
|---:|---:|---:|---|
| 1 | 5 | $25 | $25, $50, $75, $100 |
| 2 | 6 | $50 | $50, $100, $150 |
| 3 | 7 | $75 | $75, $150, $225, $250 |
| 4 | 8 | $100 | $100, $200, $300, $400 |
| 5 | 8 | $150 | $150, $300, $450, $600 |
| 6 | 8 | $200 | $200, $400, $600, $800 |
| 7 | 9 | $300 | $300, $600, $900, $1,200 |
| 8 | 10 | $400 | $400, $800, $1,200, $1,600, $1,750 |
| 9 | 10 | $600 | $600, $1,200, $1,800, $2,400, $2,500 |
| 10 | 12 | $800 | $800, $1,600, $2,400, $3,200, $4,000 |

Current opponent clear tolerance is hard-coded in `RunManager.opponentClearToleranceCents`:

- Stage 1: 9 ante
- Stage 2: 3 ante
- Stage 3: 2 ante
- Stage 4: 0.5 ante
- Stage 7: 8 ante
- Other stages: 0

## Current Shop And Reward Flow

Current shop:

- `ShopState.generated` creates four offers, preserving frozen offers.
- A roll under 68 or slot 0 creates a modifier offer.
- Other rolls create consumables or attachments.
- Modifier candidates are `Modifier.allContent.filter { $0.minShopTier <= tier && $0.rarity != .boss }`.
- No active roster, starter exclusion, capstone exclusion, retired-content exclusion, or build-contract slot logic exists.

Current stage rewards:

- `StageReward.allRewards` mixes cash/chip/heat rewards, rebuild bridge rewards, legacy upgrade duplication/grants, Tie payout, and shoe mutation rewards.
- `StageReward.randomDraftChoices` weights by dominant tags, but can still choose legacy upgrade rewards.

Current boss rewards:

- `BossReward.allRewards` includes strong legacy-like rewards such as permanent reveal, Tie payout set to 30:1, 5x ante plus 6 chips, duplicate three upgrades, all-face-card removal, and random legendary upgrade.
- `BossManager.defeatActiveBoss` creates boss reward choices immediately after a boss is defeated.

## Current Save-Data Implications

- Save schema version is 5.
- Saves store legacy upgrade names in `acquiredUpgradeNames` and `pendingUpgradeNames`.
- Restore maps those names back through `UpgradeCard.allCards`, so old saves can reactivate retired legacy effects.
- `activeModifiers`, `benchModifiers`, consumables, attachments, and boss relic IDs are already separately persisted.
- A rebalanced migration must increment the schema version, stop restoring legacy effects, and convert old legacy upgrades into deterministic modest compensation.

## Source / Report Mismatches Or Warnings

- The report correctly identifies missing emitted trigger families, but source inspection shows `handStarted` and `handResolved` log entries exist, which can be mistaken for live events; they do not currently resolve modifiers.
- Some report metrics are not normalized correctly. Offer percentages can exceed 100%, and build/synergy tables promote very small samples as perfect-completion rows.
- Current tests intentionally assert broad-content counts such as `Modifier.allContent.count >= 120`, so tests must be updated to distinguish archived definitions from the active production roster.
- The pasted rebalance spec ended mid-way through Section 16 at the Phase A command. This audit uses all available text and current source evidence.
