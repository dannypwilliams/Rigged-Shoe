# Rigged Shoe Rebuild Plan

Audit date: 2026-06-22

Goal: turn Rigged Shoe into a fast baccarat roguelite with Super Auto Pets-style pacing while keeping it an active baccarat/deck-manipulation game. The player should still choose bet side, bet amount, consumable timing, Heat risk, and build direction. The desired pacing is short battle phases, readable trigger feedback, compact shop/reward phases, and quick run completion.

This document is intentionally documentation-only. It does not prescribe a broad rewrite as the first step.

## Current Architecture Summary

### 1. Run Structure

Current run state lives mostly in:

- `RiggedShoe/Models/GameState.swift`
- `RiggedShoe/Models/RunManager.swift`
- `RiggedShoe/ViewModels/GameViewModel.swift`
- `RiggedShoe/Models/RunPersistenceManager.swift`

The run starts from `RunManager.defaultStartingBankrollCents`, currently `$250`. `GameState` owns bankroll, selected bet, shoe, current/pending rewards, acquired upgrades, challenge mode, daily seed, boss state, tutorial flags, and many one-off upgrade counters.

The run is a 10-stage ladder. A stage is cleared by meeting either a target profit or a teaching objective. A stage fails when the objective fails or rounds run out. Stage clear creates a stage reward screen; boss stages create boss reward screens.

Current flow:

1. Start or restore a run.
2. Play baccarat rounds.
3. Offer shoe upgrade rewards after an early 2-round hook, then every 3 rounds.
4. Clear or fail the stage based on objective/round limit.
5. Choose a stage reward or boss reward.
6. Advance to the next stage.
7. Finish after Stage 10 or fail earlier.

This is functional, but it is not yet a battle/shop loop. The player is progressing through long stage objectives while upgrade rewards interrupt the table flow.

### 2. Stage Structure

Current stage definitions are in `RiggedShoe/Models/Stage.swift`.

Current stages:

- Stage 1: survive 10 hands without dropping below `$200`; bets: `$10`.
- Stage 2: finish 10 hands without losing more than `$60`; bets: `$10`, `$20`.
- Stage 3: grow bankroll by `$15`; bets: `$10`, `$20`, `$30`.
- Stage 4: target profit `$60` or one upgrade/reveal-influenced win; bets up to `$50`.
- Stage 5: grow bankroll by `$125`; bets up to `$75`.
- Stages 6-10: profit targets `$150`, `$250`, `$450`, `$750`, `$1,250`; bet caps expand up to `$1,000`.

This is much clearer than older debt-target versions, but it still reads as a stage ladder rather than short casino battles. Stage 4 is a mixed objective with both `targetProfitCents` and a teaching objective; this may clear through money before the intended upgrade-learning objective matters.

### 3. Bankroll And Reward Scaling

Bankroll is cents-based and stored directly in `GameState.bankrollCents`.

Payout math is centralized in `GameViewModel.payoutCents(...)`, with a payout ledger that explains bankroll deltas. This should be preserved.

Stage rewards are in `RiggedShoe/Models/StageReward.swift`:

- Cash: `$25`, `$40`, `$75`, `$125`.
- Remove/duplicate random acquired upgrade.
- Add random rare/legendary upgrade.
- Increase Tie payout by `+2`.
- Add high-value cards.
- Remove face cards.

Boss rewards are in `RiggedShoe/Models/BossReward.swift` and are much larger:

- Double Player/Banker bonuses.
- Add 20 high-value cards.
- Reveal 15 cards permanently.
- Tie payout becomes 30:1.
- Gain `$25,000`.
- Duplicate 3 upgrades.
- Remove all face cards.
- Gain a legendary upgrade.
- Add 3 future rounds.

Balance risk: boss rewards are scaled for a much larger economy than the current `$250` start and short early stages. `Vault Leak` can trivialize the rest of the run. `Open Ledger`/permanent 15-card reveal may destroy information tension. `Remove one random acquired upgrade` is usually negative and may feel like a trap reward unless it is part of a sell/shop system.

### 4. Upgrade / Modifier System

Current upgrade models are in:

- `RiggedShoe/Models/UpgradeCard.swift`
- `RiggedShoe/Models/BuildVarietyModels.swift`
- `RiggedShoe/ViewModels/GameViewModel.swift`

Current counts from the source:

- Common: 48
- Rare: 57
- Legendary: 57
- Total: 162

Tags include Player, Banker, Tie, Streak, Reveal, Shoe, Economy, Risk, Conservative, Aggressive, Comeback, Dealer Exploit, Boss, Legendary.

The system already supports:

- Actual shoe manipulation.
- Reveal configurations and charged X-Ray.
- Payout bonuses.
- Streak bonuses.
- Stage-start cash.
- Round stipends.
- Loss rebates.
- Tie payout changes.
- Boss/tag suppression.
- Synergy definitions.

`UpgradeEffectSummary` rolls all acquired upgrades and synergy effects into one summary. This is valuable and should be kept, but the current upgrade pool is too large and too heterogeneous for a compact SAP-style engine. It lacks shop concepts such as cost, tier, level, sell value, freeze, combine/level-up, turn-start triggers, and board/bench limits.

Current reward-choice logic avoids exact duplicate choices and filters some low-value duplicates. That is useful, but it is not a shop.

### 5. Boss Modifier System

Bosses are modeled in:

- `RiggedShoe/Models/Boss.swift`
- `RiggedShoe/Models/BossManager.swift`

There are 13 bosses. Boss effects are modular:

- Reveal suppression.
- Continuous shuffle.
- Pit Boss upgrade disable.
- Tag suppression.
- Tie payout clamp.
- Final boss combined House effect.

Boss schedule is:

- Stage 10: The House.
- Multiples of 3: random boss from pool.
- Boss Rush: every stage.

This system is worth preserving. For a SAP-like rebuild, bosses should become casino opponents or battle modifiers with a clear pre-battle warning and a compact post-battle reward. The current architecture already supports temporary suppression and restoration, which is a good foundation.

### 6. Baccarat Hand Resolution

Baccarat hand resolution currently lives in `GameViewModel.playBaccaratRound(...)`.

The hand logic is correct and should be preserved:

- Player and Banker receive two cards.
- Natural 8/9 stands.
- Player draws on 0-5.
- Banker draw follows third-card rules.
- Tie pushes Player/Banker bets.
- Banker commission and no-commission effects are handled in payout math.

The shoe is real, not cosmetic:

- `RiggedShoe/Models/Shoe.swift` owns the actual ordered card array.
- Draw removes from the top.
- Burn/move/shuffle/add/remove operations mutate the actual card sequence.
- Reveal preview is based on actual upcoming cards.

This is the core identity of the game and should not be replaced.

### 7. UI Flow

Main UI entry points:

- `RiggedShoe/App/ContentView.swift`
- `RiggedShoe/Views/CasinoFloorPagerView.swift`
- `RiggedShoe/Views/CasinoLobbyView.swift`

Current structure:

- Horizontal page navigation through Game Room, Casino Room, Lounge, and Settings.
- Game Room is built inside `CasinoLobbyView.swift`.
- Stage/boss/reward/run-over screens are shown as top-level conditional overlays in `ContentView`.
- Upgrade, profile, challenge, collection, theme, and settings areas exist but are still broad information rooms.

Risks:

- `CasinoLobbyView.swift` is over 4,000 lines and mixes Game Room, room pages, help, table rendering, bet dock, shoe display, and supporting UI.
- `GameViewModel.swift` is over 2,400 lines and owns too many responsibilities.
- Current UI is cleaner than the older lobby, but it is not yet a battle screen plus shop screen.

### 8. Persistence And Meta Progression

Persistence:

- Active run state: `RunPersistenceManager`, UserDefaults key `riggedShoe.activeRun.v2`.
- Meta profile: `MetaProgressionManager`, UserDefaults key `riggedShoe.playerProfile.v1`.
- Analytics: `AnalyticsManager`, UserDefaults key `riggedShoe.analytics.events.v1`.
- Settings: `SettingsManager`, UserDefaults keys per setting.

Meta progression includes:

- Casino Chips.
- Reputation.
- Total runs/wins/rounds.
- Highest bankroll/profit.
- Unlockable upgrades/rewards/run modifiers.
- Achievements.
- Boss collection.
- Challenge records.
- Daily run record.

This should be preserved, but active-run persistence will need a version bump if the run structure changes from stage ladder to battle/shop phases.

### 9. Simulator / Test Support

Current support:

- `Tools/Simulation/rigged_shoe_sim.py` is a lightweight headless simulator.
- It parses some values from Swift sources to reduce balance drift.
- It runs deterministic seeds and tracks compact run summaries.
- `GameViewModel` has DEBUG-only tools and a `runInternalAudit()` method for core assumptions.

This is valuable and should be expanded before major balance changes. The simulator currently models the stage ladder, not a battle/shop loop. It should be extended once the new models exist.

### 10. Rewards That Are Useless Or Overpowered

Likely underpowered/useless:

- `Clean Slate`: removing a random acquired upgrade is usually a penalty, not a reward, unless the new shop supports intentional selling/removing for money, Heat reduction, or trait pruning.
- Random duplicate rewards can feel bad when they hit a non-scaling utility effect.
- Pure cash stage rewards are understandable but less interesting than engine pieces and can flatten build decisions.

Likely overpowered:

- `Vault Leak`: `$25,000` is wildly above current run scale.
- `Open Ledger`: permanent 15-card reveal can erase shoe uncertainty.
- `Tie Conspiracy`: 30:1 Tie payout can dominate if paired with Tie support.
- `Face Card Blackout`: removing all J/Q/K from the current shoe is huge and may be too opaque.
- Large boss rewards arrive through a system that can appear before the run economy has earned that scale.

Likely unclear:

- Rewards that mutate the shoe should show compact before/after composition impact.
- Rewards that add/remove random upgrades need player-facing control if the future shop has levels/sell values.
- Reveal rewards need clear charge/duration labels.

## What Should Be Preserved

- Correct baccarat rules and current hand resolution.
- Real ordered shoe model and actual card manipulation.
- Shoe reveal source-of-truth model.
- Payout ledger and explicit upgrade attribution.
- Boss effect modularity and temporary suppression.
- Upgrade tags and synergy definitions.
- Cents-based bankroll accounting.
- Deterministic daily seed support.
- UserDefaults-backed profile/meta progression.
- Lightweight headless simulator.
- Polished Game Room table/shoe/bet dock direction.

## What Should Be Replaced Or Reworked

- Replace long stage ladder pacing with short battle/shop loops.
- Replace passive stage reward interruption with a clear shop/reward phase.
- Replace unlimited acquired-upgrade accumulation with a compact modifier engine.
- Replace random duplicate/remove rewards with explicit buy/sell/level/freeze decisions.
- Replace large boss rewards with tiered battle rewards scaled to current run economy.
- Replace `GameViewModel` as the owner of every gameplay responsibility.
- Replace monolithic `CasinoLobbyView.swift` room/table file with smaller screen components.
- Replace stage-only objectives with opponent/battle goals: survive N hands, beat casino quota, keep Heat under threshold, or leave with positive battle profit.

## Proposed New Data Models

Add these models in small steps, not all at once:

### Run Phase

```swift
enum RunPhase {
    case battle
    case shop
    case reward
    case bossPreview
    case runOver
    case victory
}
```

Purpose: make the current run state explicit instead of inferring it from pending arrays and `RunStatus`.

### CasinoBattle

Fields:

- `id`
- `roundLimit`
- `startingBankrollCents`
- `targetProfitCents`
- `opponent: CasinoOpponent`
- `heatRules: HeatRules`
- `availableBetAmountsCents`
- `battleNumber`

Purpose: replace broad stages with short table battles.

### CasinoOpponent

Fields:

- `id`
- `name`
- `description`
- `difficulty`
- `rules`
- `rewardTier`
- `bossEffect?`

Purpose: make bosses and normal casino opponents share one battle-facing surface.

### HeatState

Fields:

- `currentHeat`
- `maxHeat`
- `heatPerCheat`
- `heatPerReveal`
- `heatDecayPerBattle`
- `bustThreshold`

Purpose: create pressure for cheating/modifier use without removing player agency.

### ModifierDefinition

Fields:

- `id`
- `name`
- `description`
- `rarity`
- `tags`
- `shopTier`
- `cost`
- `sellValue`
- `maxLevel`
- `effectsByLevel`

Purpose: turn upgrades into shop-compatible modifier cards.

### ModifierInstance

Fields:

- `instanceID`
- `definitionID`
- `level`
- `charges`
- `isFrozen`
- `createdBattle`

Purpose: separate permanent definitions from run-specific state.

### ShopState

Fields:

- `coins`
- `slots`
- `frozenSlotIDs`
- `rerollCost`
- `sellRefundRules`
- `offeredModifiers`
- `offeredConsumables`

Purpose: create a real shop phase with SAP-like pacing.

### Consumable

Fields:

- `id`
- `name`
- `description`
- `cost`
- `effect`
- `timing`

Purpose: support active decisions such as burn, cut, peek, reduce Heat, or inject a card.

### TriggerEvent And TriggerQueue

Fields:

- `eventType`
- `sourceID`
- `target`
- `amount`
- `message`

Purpose: make fast trigger feedback readable and testable.

### BattleResult

Fields:

- `handsPlayed`
- `startingBankrollCents`
- `endingBankrollCents`
- `profitCents`
- `heatDelta`
- `bossDefeated`
- `triggerLedger`
- `rewardChoices`

Purpose: cleanly bridge battle into shop/reward.

## Existing Files Likely To Be Refactored

High-impact files:

- `RiggedShoe/ViewModels/GameViewModel.swift`
- `RiggedShoe/Models/GameState.swift`
- `RiggedShoe/Models/RunManager.swift`
- `RiggedShoe/Models/Stage.swift`
- `RiggedShoe/Models/StageReward.swift`
- `RiggedShoe/Models/UpgradeCard.swift`
- `RiggedShoe/Models/Boss.swift`
- `RiggedShoe/Models/BossManager.swift`
- `RiggedShoe/Models/RunPersistenceManager.swift`
- `RiggedShoe/App/ContentView.swift`
- `RiggedShoe/Views/CasinoLobbyView.swift`
- `RiggedShoe/Views/CasinoFloorPagerView.swift`
- `Tools/Simulation/rigged_shoe_sim.py`

Likely new files:

- `RiggedShoe/Models/RunPhase.swift`
- `RiggedShoe/Models/CasinoBattle.swift`
- `RiggedShoe/Models/CasinoOpponent.swift`
- `RiggedShoe/Models/HeatState.swift`
- `RiggedShoe/Models/ModifierDefinition.swift`
- `RiggedShoe/Models/ModifierInstance.swift`
- `RiggedShoe/Models/ShopState.swift`
- `RiggedShoe/Models/Consumable.swift`
- `RiggedShoe/Models/TriggerEvent.swift`
- `RiggedShoe/Models/BattleResult.swift`
- `RiggedShoe/Services/BaccaratRoundResolver.swift`
- `RiggedShoe/Services/PayoutResolver.swift`
- `RiggedShoe/Services/ModifierEngine.swift`
- `RiggedShoe/Services/ShopGenerator.swift`
- `RiggedShoe/Views/BattleView.swift`
- `RiggedShoe/Views/ShopView.swift`
- `RiggedShoe/Views/ModifierCardView.swift`

## Exact Risks Before Changing Code

1. `GameViewModel` is the current gameplay hub. Large edits there can break dealing, stage progression, rewards, persistence, analytics, and tutorial flow at once.
2. Active run persistence is versioned but not designed for phase-based battle/shop state. A migration plan is required.
3. Meta unlocks refer to upgrade names. Renaming upgrades or converting them to modifier IDs can break profiles unless mapped.
4. Boss suppression currently disables acquired upgrade IDs and tags. Modifier instances will need equivalent suppression semantics.
5. Reveal trust has been a major historical bug area. Any new shop consumable/reveal timing must keep one source of truth.
6. Bankroll and reward scaling are fragile because current boss rewards can dwarf the starting economy.
7. UI files are large. Moving to battle/shop screens should happen with wrapper screens first, then extracted components.
8. The simulator mirrors current Swift values manually. It can drift if new battle/shop rules are added only in Swift.
9. Daily runs depend on seeded randomness. Shop generation and opponent selection must use the seeded generator.
10. App Store/TestFlight build stability should be protected; each milestone should build before moving on.

## Suggested Implementation Order

### Milestone 1: Extract Pure Round Services

Goal: preserve current gameplay while moving baccarat and payout math out of `GameViewModel`.

Checklist:

- Add `BaccaratRoundResolver`.
- Add `PayoutResolver`.
- Keep payout ledger output identical.
- Keep current `GameViewModel.dealRound()` behavior.
- Add model-level tests or DEBUG audit checks for natural hands, third-card rules, tie push, banker commission, and reveal forecast.
- Run simulator smoke batch.
- Run Xcode simulator build.

### Milestone 2: Add RunPhase Without Changing Gameplay

Goal: replace implicit pending-array flow with explicit phase state.

Checklist:

- Add `RunPhase`.
- Store phase in `GameState`.
- Map existing states to phases: battle, upgrade reward, stage reward, boss preview, boss reward, run over, victory.
- Update `ContentView` conditionals to use phase where possible.
- Keep saved-run restore compatible with a default phase inference.
- Build and launch.

### Milestone 3: Introduce Battle Model Beside Stage Model

Goal: create short battles while still using existing `Stage` data as the source.

Checklist:

- Add `CasinoBattle` and `CasinoOpponent`.
- Generate battles from current stages.
- Keep Stage 1-10 playable.
- Show battle number/opponent copy in UI while still using existing objectives.
- Add simulator fields for battle summaries.
- Do not add shop yet.

### Milestone 4: Build Minimal Shop Phase

Goal: replace stage rewards and round-based upgrade interruptions with a clear shop phase.

Checklist:

- Add `ShopState`.
- Give the player a small number of shop coins after each battle.
- Convert a small curated subset of current upgrades into `ModifierDefinition`.
- Show 3-5 shop offers.
- Support buy and continue.
- Keep old upgrade reward path disabled only after the new shop is stable.
- No sell/freeze/leveling yet.

### Milestone 5: Compact Modifier Engine

Goal: turn upgrades into a small, readable engine.

Checklist:

- Add `ModifierInstance`.
- Add a build limit, such as 5 active modifiers.
- Convert `UpgradeEffectSummary` to read modifier instances.
- Preserve tags and synergies.
- Show compact build row in Game Room.
- Move detailed modifier list to shop/build screen.

### Milestone 6: Add Heat

Goal: add pressure without making the game passive.

Checklist:

- Add `HeatState`.
- Define Heat gains for reveal, burn, card injection, boss-suppressed cheating, and high-risk actions.
- Add Heat decay or reduction options in shop.
- Add casino opponent rules that punish high Heat.
- Add clear ledger lines: what raised Heat and why.
- Ensure Heat never hides baccarat results or payout math.

### Milestone 7: Add SAP-Style Shop Depth

Goal: make draft decisions matter quickly.

Checklist:

- Add sell values.
- Add reroll.
- Add freeze.
- Add leveling by combining duplicate modifiers.
- Add tiered shop pools by battle number.
- Add consumables: peek, burn, cut, Heat wash, inject one card, temporary commission dodge.
- Add simulator support for shop strategies.

### Milestone 8: Reframe Bosses As Casino Opponents

Goal: preserve boss identity while fitting battle cadence.

Checklist:

- Map current `BossEffect` into `CasinoOpponent.rules`.
- Use boss battles at predictable intervals.
- Reward boss wins with stronger shop currency, not massive unbounded cash.
- Scale or retire `Vault Leak`, `Open Ledger`, and 30:1 Tie rewards.
- Ensure boss suppression is visible before the battle starts.

### Milestone 9: Rebuild UI Around Battle / Shop

Goal: fast loop, readable build, no scrolling table.

Checklist:

- Game page shows active battle only: opponent, bankroll, Heat, shoe, hands, bet dock.
- Shop page shows modifiers, coins, buy/sell/freeze/reroll.
- Trigger feedback is queued and short.
- Battle recap shows profit, Heat, key triggers, and reward.
- Keep Profile/Lounge/Settings secondary.

### Milestone 10: Balance And Run Length

Goal: one run should be quick, learnable, and replayable.

Checklist:

- Target early battle length: 3-5 hands.
- Target full run: 15-25 minutes.
- Simulate conservative/aggressive/reveal/tie/banker/player strategies.
- Tune shop costs and payout modifiers.
- Remove or nerf rewards that trivialize bankroll.
- Confirm no strategy degenerates into max-bet gambling.

## Milestone Acceptance Checklist

Every milestone should satisfy:

- Baccarat rules still pass audit.
- Shoe reveal only shows earned information.
- Payout ledger reconciles every bankroll change.
- Deal button is never available during resolution.
- Main Game Room remains playable on iPhone SE size.
- Existing saved profile does not corrupt.
- Active run either restores safely or intentionally resets with migration handling.
- Lightweight simulator runs with compact logs.
- Xcode simulator build succeeds.

## Recommended Next Phase

Do not begin by rewriting the UI or replacing all upgrades.

Recommended next implementation phase:

1. Extract baccarat resolution and payout resolution from `GameViewModel`.
2. Add `RunPhase` as a non-breaking wrapper around the current flow.
3. Add `CasinoBattle` as an adapter over current `Stage`.
4. Only then introduce a minimal shop using 10-15 curated existing upgrades.

That path protects the working game while moving it toward the intended fast battle/shop cadence.
