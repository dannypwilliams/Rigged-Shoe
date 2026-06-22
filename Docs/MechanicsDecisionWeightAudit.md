# Mechanics Decision Weight Audit

Rigged Shoe code audit for the new player intro, mechanics explainer, warm-up hands, and tutorial system.

This report is based on the current Swift code in `RiggedShoe/Models`, `RiggedShoe/ViewModels/GameViewModel.swift`, and the existing app entry/UI files. It does not rely on design notes as truth. When a mechanic is modeled but not connected to the live `GameViewModel` loop, it is marked as designed but not implemented or broken/suspicious.

## Audit Summary

- Mechanics documented: 80
- Live run loop: `GameState` + `RunManager` + `GameViewModel`
- Future/rebuild loop present but not live: `RunState`, `ShopState`, `ModifierEngine`, `Modifier`, `Consumable`, `Attachment`, `BossRelic`
- Current player-facing tutorial: `OnboardingView`, `TutorialModels`, `GlossaryView`
- Requested prompt-pack tutorial files do not exist yet.
- Static compile risk found during audit and repaired in this pass: reward apply coverage and `ContentView`/`GameViewModel` flow glue. No local Swift/Xcode toolchain is available in this Windows workspace, so build verification still needs macOS/Xcode or simulator access.

## Decision Weight Scale

```swift
enum DecisionWeight {
    case low        // Flavor, minor optimization, or situational value
    case medium     // Meaningfully affects some choices
    case high       // Should noticeably change player behavior
    case critical   // Player must understand this to succeed
}
```

## Default Starting Bankroll

**Category:**  
Core Run / Economy

**Code Location:**  
`RunManager.defaultStartingBankrollCents`; `GameState.init(configuration:)`; `MetaProgressionManager.runConfiguration()`

**What It Does:**  
The default run starts with 25,000 cents, displayed as $250. This bankroll is both the player's money and survival buffer.

**When Player Encounters It:**  
Run start and every gameplay screen that displays bankroll.

**What Decision It Affects:**  
Bet size, risk tolerance, survival, comeback decisions.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Your bankroll is your health; if you cannot cover the table, the run is over.

**Advanced Explanation:**  
Bankroll determines how many bad outcomes you can survive and how aggressively you can press upgrades, forecasts, and payout multipliers.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Run Modifier Starting Bankroll Overrides

**Category:**  
Core Run / Economy / Modifier

**Code Location:**  
`RunModifierID.startingBankrollCents`; `ChallengeModeID.startingBankrollCents`; `MetaProgressionManager.runConfiguration()`

**What It Does:**  
High Roller challenge and High Roller run modifier can start the player at $5,000. Low Roller run modifier can start the player at $500 and boost chip rewards.

**When Player Encounters It:**  
Challenge/run setup and new run creation.

**What Decision It Affects:**  
Risk profile before a run starts, unlock selection, challenge choice.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some run setup choices change your starting bankroll before the first hand is dealt.

**Advanced Explanation:**  
Starting bankroll overrides can radically change bet sizing and survival math, but the run modifier versions must be unlocked before they can be activated.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Guided First Hand And Guided Upgrade

**Category:**  
Core Run / Hand Outcome / Upgrade

**Code Location:**  
`GameState.isGuidedFirstRun`; `GameViewModel.isGuidedOpeningHandLocked`; `prepareGuidedFirstDealIfNeeded()`; `guidedFirstWinBonusIfNeeded(for:)`; `queueShoeUpgradeRewardIfNeeded()`

**What It Does:**  
The first guided run locks the opening hand to a Player bet, places four cards on top of the shoe to create a Player natural-style win, and grants a $75 tutorial hand bonus if the bet wins. The first upgrade draft is curated to "Opening Tell", "Conservative Edge", and "Press the Advantage".

**When Player Encounters It:**  
First run only, before the player has completed the guided first-run flag.

**What Decision It Affects:**  
First hand side choice, first bet amount, first upgrade direction.

**Decision Weight:**  
High

**Beginner Explanation:**  
The first real hand is rigged in your favor so you can see a win, payout ledger, and upgrade choice.

**Advanced Explanation:**  
This is onboarding scaffolding, not normal strategy; after the first guided stage the run returns to normal rules.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Confusing

## Run Flow States

**Category:**  
Core Run

**Code Location:**  
`StageFlowState`; `RunManager.startRunPreview()`; `startStageBattle()`; `evaluateStage(bankrollCents:)`; `advanceAfterStageClear(bankrollCents:)`; `ContentView`

**What It Does:**  
The run moves through run start, stage preview, battle, stage result, reward draft, shop, run complete, and run failed states. The live UI uses these states to show overlays and block dealing.

**When Player Encounters It:**  
Every run.

**What Decision It Affects:**  
When the player can deal, choose rewards, continue to bosses, or start a new run.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
The game alternates between playing hands and resolving table results or rewards.

**Advanced Explanation:**  
Flow state gates all actions, so pending upgrades, stage rewards, boss warnings, and boss rewards must be cleared before new hands can be dealt.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Broken Or Suspicious

## Stage Survival Objectives And Round Limits

**Category:**  
Core Run / Pressure

**Code Location:**  
`Stage.allStages`; `StageObjective`; `RunManager.currentRoundLimit`; `RunManager.isStageClear(bankrollCents:)`

**What It Does:**  
All ten live stages currently have `targetProfitCents: 0` and use survival objectives: survive 5, 6, 7, 8, 8, 8, 9, 10, 10, and 12 hands. Future-stage round bonuses can add hands.

**When Player Encounters It:**  
Stage previews, battle HUD, stage result.

**What Decision It Affects:**  
Bet pacing, bankroll preservation, pressure timing.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Most stages are cleared by surviving the required number of hands, not by chasing a profit target.

**Advanced Explanation:**  
Because survival clears the current live stages, the dominant early skill is avoiding bankroll collapse while using upgrades to build long-term edge.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Profit Target Fields

**Category:**  
Core Run

**Code Location:**  
`Stage.targetProfitCents`; `RunManager.stageProgress(bankrollCents:)`; `RunManager.stageTargetBankrollCents()`

**What It Does:**  
The code supports profit targets and target-bankroll teaching objectives, but every current `Stage.allStages` entry sets `targetProfitCents` to 0.

**When Player Encounters It:**  
Potentially in progress UI and old glossary text, but not as a live stage requirement in the current stage data.

**What Decision It Affects:**  
Would affect bet sizing and stage pacing if used.

**Decision Weight:**  
Low currently, High if re-enabled

**Beginner Explanation:**  
The game has code for profit goals, but the live stages are currently survival tables.

**Advanced Explanation:**  
Tutorial copy should not over-teach profit targets until stage data actually uses them again.

**Tutorial Priority:**  
Reference Only

**Status:**  
Designed But Not Implemented

## Stage Progression And Bankroll Carryover

**Category:**  
Core Run

**Code Location:**  
`RunManager.advanceAfterStageClear(bankrollCents:)`; `GameViewModel.selectStageReward(_:)`; `selectBossReward(_:)`

**What It Does:**  
After clearing a stage and choosing any pending reward, the game increments the stage index, carries the current bankroll into the next stage, resets stage counters, and previews the next stage.

**When Player Encounters It:**  
After every cleared non-final stage.

**What Decision It Affects:**  
Whether to preserve bankroll or spend/risk it before the stage ends.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Money you save now follows you to the next table.

**Advanced Explanation:**  
Since bankroll carries forward, overbetting near the end of a cleared stage can sabotage later stages even if the current objective is nearly done.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Boss Stages

**Category:**  
Core Run / Boss / Pressure

**Code Location:**  
`Stage.isBossStage`; `BossManager.boss(forStageID:challengeID:)`; `GameViewModel.prepareBossAnnouncementIfNeeded()`; `continueToBoss()`

**What It Does:**  
Stages 5 and 8 spawn a random non-House boss. Stage 10 always uses The House. Boss Rush can make every stage a boss stage.

**When Player Encounters It:**  
Boss announcement before boss battle stages.

**What Decision It Affects:**  
Build direction, upgrade reliance, risk tolerance.

**Decision Weight:**  
High

**Beginner Explanation:**  
Boss tables temporarily attack parts of your build.

**Advanced Explanation:**  
Bosses can suppress reveal, tie, economy, streak, risk, banker, player, or shoe tags, so flexible builds and bankroll cushion matter before stages 5, 8, and 10.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Run Failure: Bankroll Below Minimum Bet

**Category:**  
Core Run / Betting / Pressure

**Code Location:**  
`RunManager.isStageFailed(bankrollCents:)`; `RunManager.failureReason(bankrollCents:)`; `Stage.minimumBetCents`

**What It Does:**  
The run fails when bankroll falls below the current stage minimum bet.

**When Player Encounters It:**  
After a round or stage evaluation.

**What Decision It Affects:**  
Bet size, whether to take defensive rewards, how hard to chase bonuses.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
You do not need to hit exactly zero; if you cannot cover the table minimum, the run dies.

**Advanced Explanation:**  
As antes climb, the effective danger line rises. A bankroll that was safe early can become fatal later.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Run Failure: Heat Reaches Max

**Category:**  
Pressure / Core Run

**Code Location:**  
`RunManager.heat`; `maxHeat`; `evaluateStage(bankrollCents:)`; `StageFailureReason.heatMaxed`

**What It Does:**  
Heat has a max of 10. If Heat reaches max, the run fails. Heat currently increases at stage clear if the stage profit is negative: +1 for normal stages, +2 for boss stages.

**When Player Encounters It:**  
Stage result and HUD.

**What Decision It Affects:**  
Whether to scrape through a stage at a loss, whether to value Heat-reduction rewards.

**Decision Weight:**  
High

**Beginner Explanation:**  
Surviving while losing money can raise Heat, and max Heat ends the run.

**Advanced Explanation:**  
Heat is a second survival track, but its live triggers are narrower than the future modifier architecture suggests.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Confusing

## Run Victory: Clear Stage 10

**Category:**  
Core Run

**Code Location:**  
`RunManager.advanceAfterStageClear(bankrollCents:)`; `GameViewModel.recordRunEndIfNeeded()`; `Achievement.casino_legend`

**What It Does:**  
After the final stage is cleared and advanced, status becomes `.completed`, run end is recorded, and meta rewards can be granted.

**When Player Encounters It:**  
After clearing Stage 10.

**What Decision It Affects:**  
Long-term build direction and survival planning.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Beat the final boss table to finish the run.

**Advanced Explanation:**  
The run is a ten-stage survival ladder, so short-term gains matter only if they carry a build through The House.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Stage Clear Chip Rewards

**Category:**  
Core Run / Economy

**Code Location:**  
`EconomyRewardCalculation.stageClear(stage:bankrollCents:)`; `RunManager.evaluateStage(bankrollCents:)`; `MetaProgressionManager.recordStageCleared(stageID:chipMultiplierPercent:)`

**What It Does:**  
Clearing a stage adds run chips to `RunManager.chips`, and also records meta chips through progression. Normal stages grant 2-4 run chips based on stage; boss stages grant 5, 6, or 8.

**When Player Encounters It:**  
Stage result and meta progression.

**What Decision It Affects:**  
Long-term unlock pacing and potential shop value.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Clearing tables earns Chips, which unlock more future options.

**Advanced Explanation:**  
Chip gain is both run-facing and profile-facing in different systems, so tutorial text should be careful about which Chips it means.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Confusing

## Stage Reward Drafts

**Category:**  
Core Run / Upgrade / Economy

**Code Location:**  
`StageReward.allRewards`; `StageReward.randomChoices(...)`; `GameViewModel.selectStageReward(_:)`; `applyStageReward(_:)`

**What It Does:**  
After non-boss stage clears, the player drafts one of three stage rewards. Rewards include cash, Chips, Heat reduction, upgrade duplication, rare/legendary upgrades, Tie payout, and shoe manipulation.

**When Player Encounters It:**  
After stage clear.

**What Decision It Affects:**  
Build direction, bankroll stabilization, meta/shop economy, shoe composition.

**Decision Weight:**  
High

**Beginner Explanation:**  
Stage rewards are one-shot chances to strengthen the run before the next table.

**Advanced Explanation:**  
Reward text now maps to live apply cases for ante-scaled cash, Chips, Heat reduction, upgrade duplication, upgrade grants, Tie payout, and shoe edits, but it still needs an Xcode build/simulator pass.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly, Needs Manual Verification

## Boss Reward Drafts

**Category:**  
Boss / Upgrade / Economy

**Code Location:**  
`BossReward.allRewards`; `BossReward.randomChoices(...)`; `GameViewModel.selectBossReward(_:)`; `applyBossReward(_:)`

**What It Does:**  
After defeating a boss, the player drafts one of three boss rewards. Rewards can double Player/Banker bonuses, add cards, reveal cards permanently, set Tie payout, duplicate upgrades, remove faces, add legendary upgrades, or add future rounds.

**When Player Encounters It:**  
After clearing a boss stage.

**What Decision It Affects:**  
Build direction, payout focus, shoe control, future-stage margin.

**Decision Weight:**  
High

**Beginner Explanation:**  
Boss rewards are stronger than normal rewards and can reshape your build.

**Advanced Explanation:**  
Boss rewards now cover the defined effect cases in the live apply switch, including Vault Leak's ante-scaled cash and Chip reward, but still need an Xcode build/simulator pass.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly, Needs Manual Verification

## Meta Currency: Casino Chips And Reputation

**Category:**  
Economy / Meta Progression

**Code Location:**  
`PlayerProfile`; `MetaProgressionManager.grantCurrency(...)`; `recordRunEnded(...)`; `recordBossDefeated(...)`

**What It Does:**  
Casino Chips and Reputation persist between runs. Chips unlock upgrades, rewards, run modifiers, and future hooks. Reputation is rarer and mostly earned from boss wins and full run completion.

**When Player Encounters It:**  
Profile office, unlock shop, run end, boss defeat.

**What Decision It Affects:**  
Permanent unlock priorities and challenge incentives.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Chips and Reputation are permanent progression currencies.

**Advanced Explanation:**  
Meta unlocks widen future drafts rather than directly guaranteeing power in the current hand.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Unlock Shop And Collection

**Category:**  
Economy / Meta Progression

**Code Location:**  
`Unlockable.allUnlockables`; `MetaProgressionManager.purchase(_:)`; `collectionEntries`

**What It Does:**  
The profile can purchase upgrade cards, stage rewards, boss rewards, run modifiers, and future hooks. Collection entries expose unlocked/encountered status.

**When Player Encounters It:**  
Profile/collection rooms.

**What Decision It Affects:**  
Long-term build availability and future run variety.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Unlocks add more things that can appear later.

**Advanced Explanation:**  
Unlocking more content can improve options but can also dilute drafts if the player unlocks unfocused tools too early.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Challenges And Daily Runs

**Category:**  
Core Run / Betting / Economy

**Code Location:**  
`ChallengeModeID`; `MetaProgressionManager.runConfiguration()`; `setChallenge(_:)`; `setDailyRunEnabled(_:)`

**What It Does:**  
Challenge modes restrict bet types, suppress reveal effects, increase loss damage, start with higher bankroll, make every stage a boss stage, or multiply chip rewards. Daily runs use a date-derived seed.

**When Player Encounters It:**  
Challenge room/run setup.

**What Decision It Affects:**  
Run difficulty, legal bet sides, reveal value, chip farming.

**Decision Weight:**  
High

**Beginner Explanation:**  
Challenges change the rules before the run starts.

**Advanced Explanation:**  
Challenge selection should match a player's unlocked pool: Tie Only needs Tie tools, No Reveal punishes reveal builds, and High Roller adds hidden loss pressure.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Bet Sides: Player, Banker, Tie

**Category:**  
Betting / Hand Outcome

**Code Location:**  
`BetType`; `GameViewModel.selectBetType(_:)`; `payoutCents(...)`

**What It Does:**  
The player can bet Player, Banker, or Tie unless challenge rules restrict the side. Player pays 1:1, Banker pays 0.95:1 after commission, and Tie pays 8:1 before upgrades.

**When Player Encounters It:**  
Every hand.

**What Decision It Affects:**  
Side selection, upgrade synergy, expected payout.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Pick which side you think wins: Player, Banker, or the long-shot Tie.

**Advanced Explanation:**  
Base Banker is slightly taxed, Tie has high payout but low frequency, and upgrades can make one side much more valuable than normal odds imply.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Bet Denominations

**Category:**  
Betting

**Code Location:**  
`GameViewModel.betAmountsCents`; `Stage.betLimit.allowedBetAmountsCents`

**What It Does:**  
The global denomination list includes $10, $20, $30, $50, $75, $100, $200, $300, $500, and $1,000. Stages expose smaller allowed subsets such as $25-$100 in stage 1 and up to $4,000 in stage 10.

**When Player Encounters It:**  
Bet selection UI.

**What Decision It Affects:**  
Bet size and bankroll risk.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Each stage only lets you choose certain bet sizes.

**Advanced Explanation:**  
Denomination availability is part of difficulty scaling; later stages force larger minimum exposure.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented But Confusing

## Stage Bet Limits And Minimum Bets

**Category:**  
Betting / Pressure

**Code Location:**  
`Stage.minimumBetCents`; `Stage.stageMaxBetCents`; `RunManager.minimumBetCents()`; `maximumBetCents(bankrollCents:)`; `isBetAmountAllowed(_:bankrollCents:)`

**What It Does:**  
Each stage has an ante/minimum bet and stage max. The effective maximum is the lower of the stage max and 25% of bankroll. The selected amount also must be one of the stage's allowed denominations.

**When Player Encounters It:**  
Every bet selection.

**What Decision It Affects:**  
Risk, pacing, whether a desired bet is legal.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
The table decides the legal bets, and your bankroll can cap them further.

**Advanced Explanation:**  
The 25% bankroll cap is a strong anti-all-in rule; it creates pressure to grow bankroll before larger denominations become playable.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Bankroll Risk Warnings

**Category:**  
Betting / Pressure

**Code Location:**  
`ContentView.dealGuidanceText`; `RunManager.maximumBetCents(bankrollCents:)`

**What It Does:**  
The UI warns when the selected bet is more than 25% of bankroll, and the run manager also blocks bets above the 25% maximum.

**When Player Encounters It:**  
Battle screen guidance.

**What Decision It Affects:**  
Bet size and risk tolerance.

**Decision Weight:**  
High

**Beginner Explanation:**  
Big bets are dangerous when they are a large slice of your bankroll.

**Advanced Explanation:**  
The warning and cap reinforce the same lesson: press only when the shoe, modifiers, or build make the risk worth taking.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly, Needs Manual Verification

## Reveal Bet Caps

**Category:**  
Betting / Shoe Control

**Code Location:**  
`ShoeRevealConfiguration.betCapMultiplierWhileActive`; `GameViewModel.activeRevealBetCapCents`; `selectedBetIsWithinRevealCap`; `clampSelectedBetForRevealCap()`

**What It Does:**  
Charged reveal effects cap the bet while active. X-Ray caps at 3x the minimum unlocked bet; Full X-Ray caps at 2x.

**When Player Encounters It:**  
When using charged X-Ray/Full X-Ray reveal.

**What Decision It Affects:**  
Whether to take information now or preserve freedom to bet larger.

**Decision Weight:**  
High

**Beginner Explanation:**  
Strong information can come with a bet cap.

**Advanced Explanation:**  
X-Ray is not permission to shove maximum size; it trades prediction quality for controlled exposure.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Challenge Bet Restrictions

**Category:**  
Betting / Challenge

**Code Location:**  
`ChallengeModeID.allowsBet(_:)`; `GameViewModel.selectBetType(_:)`; `canDealIgnoringPresentationLock`

**What It Does:**  
Tie Only, Banker Only, and Player Only restrict the legal bet side. The UI and deal gate prevent invalid sides.

**When Player Encounters It:**  
Challenge runs.

**What Decision It Affects:**  
Challenge selection, side upgrades, draft strategy.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some challenge modes force you to bet one side.

**Advanced Explanation:**  
Do not enter a side-locked challenge without a pool that can support that side.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Baccarat Totals And Naturals

**Category:**  
Hand Outcome

**Code Location:**  
`Rank.baccaratValue`; `BaccaratHand.total`; `BaccaratHand.isNatural`; `GameViewModel.playBaccaratRound(...)`

**What It Does:**  
Cards count baccarat-style: A=1, 2-9 face value, 10/J/Q/K=0, total is modulo 10. A two-card 8 or 9 is natural and stops third-card drawing.

**When Player Encounters It:**  
Every resolved hand.

**What Decision It Affects:**  
Understanding outcomes and shoe previews.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Only the ones digit matters, and 8 or 9 on the first two cards is a natural.

**Advanced Explanation:**  
Naturals are especially important when using forecast/reveal because they can lock outcomes before third-card uncertainty.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Player And Banker Draw Rules

**Category:**  
Hand Outcome

**Code Location:**  
`GameViewModel.playBaccaratRound(...)`; `shouldBankerDraw(bankerTotal:playerThirdCard:)`; `DealForecast.make(from:)`; `ShoePreview.dynamicThirdCardDestination(...)`

**What It Does:**  
Player draws on 0-5 and stands on 6-7 unless a natural occurs. Banker follows standard third-card rules based on its total and Player's third card.

**When Player Encounters It:**  
Every non-natural hand and every detailed forecast.

**What Decision It Affects:**  
Interpreting previews, forecast trust, side selection.

**Decision Weight:**  
High

**Beginner Explanation:**  
The game draws third cards automatically using baccarat rules.

**Advanced Explanation:**  
Shoe preview, forecast, and actual draw logic must stay identical for information mechanics to be trustworthy.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Suspicious

## Tie Push And Tie Bets

**Category:**  
Hand Outcome / Betting

**Code Location:**  
`GameViewModel.payoutCents(...)`; `RoundResult.isPush`

**What It Does:**  
If the hand winner is Tie and the player bet Player or Banker, the original stake is refunded as a push. A Tie bet must win the Tie to pay.

**When Player Encounters It:**  
Tie results.

**What Decision It Affects:**  
Tie strategy, side selection, loss avoidance.

**Decision Weight:**  
High

**Beginner Explanation:**  
Player and Banker bets push on a Tie; Tie bets win only when the hand ties.

**Advanced Explanation:**  
Tie pushes reduce downside for Player/Banker bets but also make Tie-specific builds harder to trigger without committed Tie betting.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Base Payouts And Banker Commission

**Category:**  
Hand Outcome / Betting

**Code Location:**  
`BetType.totalReturnCents(for:)`; `GameViewModel.payoutCents(...)`; `BossEffect.restoresBankerCommission`

**What It Does:**  
Player pays 1:1, Banker pays 0.95:1 after commission, and Tie pays 8:1. No Commission upgrades can remove Banker commission unless a boss restores it.

**When Player Encounters It:**  
Every winning hand.

**What Decision It Affects:**  
Side preference, upgrade value, boss counterplay.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Banker wins are taxed unless you have a working No Commission effect.

**Advanced Explanation:**  
Banker builds often need commission removal or ante bonuses to outperform other build paths.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Round Memory And Streaks

**Category:**  
Hand Outcome / Modifier / Synergy

**Code Location:**  
`GameState.playerWinStreak`; `bankerWinStreak`; `tieStreak`; `previousRoundLossCents`; `updateRoundMemory(result:bankrollBeforeRound:payout:)`

**What It Does:**  
After each round the game records previous loss, side streaks, consecutive losses, small-bet win streak, last bet amount, and once-per-stage flags.

**When Player Encounters It:**  
Behind the scenes after every hand.

**What Decision It Affects:**  
Streak builds, comeback builds, press/raise builds, Tie refund builds.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some upgrades care about what happened on previous hands.

**Advanced Explanation:**  
Round memory creates timing windows; pressing after a win or winning after losses can be more valuable than an isolated hand.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Six-Deck Shoe Creation And Draw Order

**Category:**  
Shoe Control

**Code Location:**  
`Shoe.init(deckCount:)`; `Shoe.makeCards(deckCount:)`; `Shoe.draw()`; `GameViewModel.drawCard()`

**What It Does:**  
The live shoe starts as six standard decks, shuffled randomly or with a daily seed. Cards are drawn from the front of the array.

**When Player Encounters It:**  
Every hand and shoe preview.

**What Decision It Affects:**  
Shoe-reading, card manipulation, forecast trust.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
The shoe is the ordered stack of cards the table deals from.

**Advanced Explanation:**  
Anything that reveals, burns, inserts, removes, or reorders cards changes the same live shoe used to resolve hands.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Low-Shoe Reshuffle

**Category:**  
Shoe Control / Pressure

**Code Location:**  
`GameViewModel.dealRound(...)`; `drawCard()`; `reshuffleShoe()`

**What It Does:**  
If fewer than 20 cards remain before a round, the shoe is rebuilt and shuffled. If drawing ever empties the shoe, it reshuffles and tries again.

**When Player Encounters It:**  
Late in a shoe or during X-Ray activation with low remaining cards.

**What Decision It Affects:**  
Long-term shoe sculpting, reveal trust, hot/cold shoe value.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
The shoe reshuffles when it gets low.

**Advanced Explanation:**  
Shoe modifications can be wiped or reapplied on reshuffle depending on the effect; Hot/Cold effects matter most around shuffle events.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Passive Shoe Reveal Tiers

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`ShoeRevealConfiguration`; `UpgradeEffectSummary.registerReveal(_:)`; `GameViewModel.activeShoeReveal`

**What It Does:**  
Reveal upgrades show upcoming cards with different precision and destination knowledge: Peek, Read the Shoe, Smudged Lens, Bent Corner, and legacy multi-card reads.

**When Player Encounters It:**  
After acquiring reveal upgrades.

**What Decision It Affects:**  
Side selection, bet sizing, use of shoe control.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Reveal upgrades let you see some cards before betting.

**Advanced Explanation:**  
Not all reveals are equal: exact order and forecast support are much stronger than partial card knowledge.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Deal Forecast And Favorability

**Category:**  
Shoe Control / Betting

**Code Location:**  
`DealForecast.make(from:)`; `ActiveShoeReveal.favorability(from:cardCount:)`; `GameViewModel.dealForecast`

**What It Does:**  
Some reveal configurations produce a forecast with confidence, projected totals, and a recommended bet if enough cards are visible.

**When Player Encounters It:**  
Reveal UI after acquiring forecast-capable reveal effects.

**What Decision It Affects:**  
Bet side, bet size, whether the player has real edge.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
A forecast tells you when the shoe is leaning toward a side.

**Advanced Explanation:**  
Forecast confidence matters: a natural/complete forecast is much stronger than a partial opening read.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Charged X-Ray Reveal

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`ShoeControlActionKind.xRay`; `ShoeRevealConfiguration.xRay`; `.fullXRay`; `GameViewModel.useShoeControl(_:)`; `applyStageStartEffects()`

**What It Does:**  
Charged reveals are manually armed, reveal exact ordered cards for the next hand, spend a charge after the deal, and cap bet size while active.

**When Player Encounters It:**  
After acquiring X-Ray Shoe, Full X-Ray, Inside Man, X-Ray Glasses, Open Index, or similar charged reveal effects.

**What Decision It Affects:**  
Timing, bet sizing, side selection.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
X-Ray gives strong information for one hand, but limits how big you can bet.

**Advanced Explanation:**  
The best X-Ray use is not just "use immediately"; it is timing the read when its cap and forecast still create positive pressure.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Burn Control

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`UpgradeEffect.burnCardEveryHands`; `GameViewModel.shoeControlOptions`; `burnControlCharges(upgrades:)`; `useShoeControl(.burnControl)`; `Shoe.burnTopCard()`

**What It Does:**  
Burn Control grants a manual burn charge every 5 total rounds. Using it removes the next card from the shoe.

**When Player Encounters It:**  
After acquiring Burn Control.

**What Decision It Affects:**  
Whether to discard a bad next card, timing after reveal, stage upgrade triggers.

**Decision Weight:**  
High

**Beginner Explanation:**  
Burn Control lets you throw away the next card when a read says it hurts you.

**Advanced Explanation:**  
Burns are strongest with reveal information; blind burns can just replace one unknown with another.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Soft Shuffle

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`UpgradeEffect.moveTopCardDeeper`; `GameViewModel.useShoeControl(.softShuffle)`; `Shoe.moveTopCardDeeper(positions:)`

**What It Does:**  
Soft Shuffle can be used once per stage to move the next card deeper in the shoe, usually 3 positions.

**When Player Encounters It:**  
After acquiring Soft Shuffle.

**What Decision It Affects:**  
Card order, reveal interpretation, one-stage timing.

**Decision Weight:**  
High

**Beginner Explanation:**  
Soft Shuffle pushes the next card away instead of burning it.

**Advanced Explanation:**  
It is a precise reorder tool, best used when the top card is bad but still might help a later hand.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Immediate Card Injection

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`UpgradeEffect.addExtraNines`; `.addExtraEights`; `.addCards`; `.addRandomCards`; `.addTiePairCards`; `GameViewModel.applyImmediateEffect(_:)`; `Shoe.addRandomCards(...)`

**What It Does:**  
Many upgrades and rewards add cards to the current shoe, then shuffle. This includes extra 8s/9s, aces, random high cards, low cards, and matched pairs.

**When Player Encounters It:**  
Upgrade selection, stage rewards, boss rewards, shuffle effects.

**What Decision It Affects:**  
Build direction and future hand odds.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some upgrades literally add helpful cards to the shoe.

**Advanced Explanation:**  
Card injection changes future distribution, but not necessarily the immediate next hand after the shuffle.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Card Removal

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`UpgradeEffect.removeZeroValueCards`; `.removeCards`; `Shoe.removeRandomZeroValueCards(...)`; `removeRandomFaceCards(...)`; `removeAllFaceCards()`

**What It Does:**  
Some upgrades and rewards remove zero-value cards or face cards from the current shoe.

**When Player Encounters It:**  
Upgrade selection, stage rewards, boss rewards.

**What Decision It Affects:**  
Shoe composition, hand totals, build direction.

**Decision Weight:**  
High

**Beginner Explanation:**  
Removing bad cards changes what the table can deal later.

**Advanced Explanation:**  
Removal effects are distribution sculpting; they pair naturally with reveal and shoe-control builds.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Hot Shoe And Cold Shoe On Shuffle

**Category:**  
Shoe Control / Upgrade

**Code Location:**  
`UpgradeEffect.hotShoe`; `.coldShoe`; `GameViewModel.applyReshuffleEffects()`

**What It Does:**  
Hot Shoe adds extra 8s/9s after each reshuffle. Cold Shoe removes zero-value cards after each reshuffle.

**When Player Encounters It:**  
After reshuffle events, including boss shuffles.

**What Decision It Affects:**  
Value of long stages, boss stages, and shuffle frequency.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some shoe upgrades trigger when the shoe shuffles.

**Advanced Explanation:**  
Automatic Shuffler bosses can make Hot/Cold effects trigger more often, which can be a counterintuitive advantage or chaos source.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Permanent Reveal Count

**Category:**  
Shoe Control / Boss Reward / Upgrade

**Code Location:**  
`RunManager.permanentRevealCount`; `GameViewModel.bestPassiveRevealConfiguration(upgrades:)`; `updateRoundMemory(...)`; `applyBossReward(_:)`

**What It Does:**  
Some effects increase permanent reveal. `revealAfterRound` increments permanent reveal after rounds but clamps it to 2; boss rewards can set much higher counts.

**When Player Encounters It:**  
After reveal-after-round upgrades and boss rewards like Open Ledger.

**What Decision It Affects:**  
Long-term information value.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some rewards make future card reads stick around.

**Advanced Explanation:**  
There is a suspicious inconsistency: after-round reveal is capped at 2, while boss rewards can set 15, but display/configuration normalization may cap visible cards to 5.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Confusing

## Payout Ledger And Upgrade Messages

**Category:**  
Hand Outcome / Modifier

**Code Location:**  
`PayoutLedgerLine`; `RoundPresentationState`; `GameViewModel.payoutCents(...)`; `state.roundPresentation`

**What It Does:**  
Each round builds a ledger of stake, base payout, refunds, bonuses, and upgrade activations. Messages are also counted as upgrade triggers for some stage objectives.

**When Player Encounters It:**  
Round result presentation.

**What Decision It Affects:**  
Understanding why a payout changed and which upgrades fired.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
The payout ledger explains where the money came from.

**Advanced Explanation:**  
Ledger lines are the best source for verifying whether an upgrade actually affected a round.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Flat Win Bonuses

**Category:**  
Modifier / Upgrade / Hand Outcome

**Code Location:**  
`UpgradeEffect.playerWinBonus`; `.bankerWinBonus`; `.chosenBetWinBonus`; `.forecastWinBonus`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Flat bonus effects add cents when a matching win occurs: Player wins, Banker wins, chosen bet wins, or forecasted bet wins.

**When Player Encounters It:**  
After relevant upgrades are acquired and the matching condition occurs.

**What Decision It Affects:**  
Side selection and upgrade choice.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some upgrades add extra cash when the right kind of bet wins.

**Advanced Explanation:**  
Flat bonuses are most valuable when paired with frequent, lower-risk triggers or doubled by boss rewards.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Ante-Scaled Win Bonuses

**Category:**  
Modifier / Upgrade / Economy

**Code Location:**  
`UpgradeEffect.playerAnteWinBonus`; `.bankerAnteWinBonus`; `.chosenBetAnteWinBonus`; `.forecastAnteWinBonus`; `UpgradeEffectSummary`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Many upgrades pay a percentage of current stage ante on matching wins.

**When Player Encounters It:**  
After side, chosen-bet, or forecast bonus upgrades.

**What Decision It Affects:**  
Bet side, stage scaling, build direction.

**Decision Weight:**  
High

**Beginner Explanation:**  
Ante bonuses get larger as the tables get bigger.

**Advanced Explanation:**  
Ante-scaled bonuses can make small bets profitable if the trigger condition is reliable.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Tie Payout Improvements And Tie Streak

**Category:**  
Modifier / Upgrade / Hand Outcome

**Code Location:**  
`UpgradeEffect.improveTiePayout`; `.tiePayoutBonus`; `.firstTieEachStageMultiplier`; `.consecutiveTiePayoutBonus`; `effectiveTiePayoutMultiplier(upgrades:)`

**What It Does:**  
Tie payout starts at 8:1 and can be improved by upgrades, stage rewards, boss rewards, first-Tie multipliers, and consecutive Tie bonuses. Some bosses cap it back to 8:1.

**When Player Encounters It:**  
Tie builds and Tie wins.

**What Decision It Affects:**  
Tie betting, upgrade synergy, boss preparation.

**Decision Weight:**  
High

**Beginner Explanation:**  
Tie is risky, but Tie upgrades can make it pay much harder.

**Advanced Explanation:**  
Tie builds need payout scaling, refund protection, and boss awareness because Tie suppression can erase the plan for a stage.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Profit Multipliers

**Category:**  
Modifier / Upgrade

**Code Location:**  
`UpgradeEffect.profitMultiplier`; `UpgradeEffectSummary.profitMultiplierPercent(for:)`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Profit multipliers increase winning profit globally or for a specific side. Multiple multipliers stack additively above 100%.

**When Player Encounters It:**  
Risk, Player, Banker, Tie, and synergy builds.

**What Decision It Affects:**  
Side selection and bet sizing.

**Decision Weight:**  
High

**Beginner Explanation:**  
Profit multipliers make winning bets pay more.

**Advanced Explanation:**  
Multipliers reward bigger bets only when the player already has enough edge to justify exposure.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Loss Multipliers And Loss Rebates

**Category:**  
Modifier / Upgrade / Pressure

**Code Location:**  
`UpgradeEffect.lossMultiplier`; `.lossRebatePercent`; `GameViewModel.payoutCents(...)`; `ChallengeModeID.highRoller`

**What It Does:**  
Loss multipliers make losing bets cost extra. Loss rebates refund a percentage of losing bets, using the highest percentage rebate available.

**When Player Encounters It:**  
Risk upgrades, High Roller challenge, defensive upgrades.

**What Decision It Affects:**  
Risk tolerance and upgrade traps.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some upgrades make wins bigger but losses worse; others soften losses.

**Advanced Explanation:**  
Risk multipliers can quietly destroy bankroll unless paired with information or strong payout engines.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Damage Control Cooldown

**Category:**  
Modifier / Upgrade / Economy

**Code Location:**  
`UpgradeEffect.lossRebateEveryHands`; `GameState.damageControlHandsSinceUse`; `GameViewModel.payoutCents(...)`; `updateRoundMemory(...)`

**What It Does:**  
Damage Control refunds a percentage of a loss once every few hands, then resets its cooldown.

**When Player Encounters It:**  
After acquiring Damage Control and losing.

**What Decision It Affects:**  
Comeback planning and risk mitigation.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Damage Control can blunt a loss, but not every hand.

**Advanced Explanation:**  
Because it is cooldown-based, it is strongest as a safety layer for occasional larger bets, not as permission to play recklessly.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Safety Net

**Category:**  
Modifier / Upgrade / Economy

**Code Location:**  
`UpgradeEffect.safetyNet`; `GameState.hasUsedSafetyNetThisStage`; `applyPostPayoutStageSafetyNetIfNeeded()`

**What It Does:**  
Once per stage, if bankroll falls below a percentage of the stage-starting bankroll, Safety Net grants cash.

**When Player Encounters It:**  
After a payout leaves bankroll below the threshold.

**What Decision It Affects:**  
Defensive upgrade value, low-bankroll survival.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Safety Net catches you once per stage when your bankroll gets thin.

**Advanced Explanation:**  
Safety Net is a stabilizer, not a plan; it helps preserve runs but does not create edge by itself.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Small-Bet Conservative Bonuses

**Category:**  
Modifier / Upgrade / Archetype

**Code Location:**  
`UpgradeEffect.smallBetWinMultiplier`; `.smallBetStreakBonus`; `GameState.smallBetWinStreak`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Conservative upgrades multiply low-bet wins or pay cash after repeated small-bet wins.

**When Player Encounters It:**  
After Conservative Edge, Small Ball, Low Roller, and related conservative upgrades.

**What Decision It Affects:**  
Bet size, survival pacing, build identity.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some builds reward small, steady wins.

**Advanced Explanation:**  
Conservative builds turn low exposure into compounding value, especially when stage goals are survival-based.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Aggressive Raise And Press Bonuses

**Category:**  
Modifier / Upgrade / Archetype

**Code Location:**  
`UpgradeEffect.pressAfterWinMultiplier`; `.firstLargeBetStageMultiplier`; `.raiseWinBonus`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Aggressive upgrades reward raising after a win, the first large bet each stage, or winning after increasing the previous bet.

**When Player Encounters It:**  
After Press the Advantage, High Roller Spark, Aggressive Bonus, and risk upgrades.

**What Decision It Affects:**  
Bet sequencing, bankroll exposure, build direction.

**Decision Weight:**  
High

**Beginner Explanation:**  
Aggressive builds pay when you press at the right time.

**Advanced Explanation:**  
These effects need edge or bankroll cushion because they explicitly ask the player to increase exposure.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Comeback Win Bonus

**Category:**  
Modifier / Upgrade / Archetype

**Code Location:**  
`UpgradeEffect.comebackWinBonus`; `GameState.consecutiveLosses`; `GameViewModel.payoutCents(...)`; `updateRoundMemory(...)`

**What It Does:**  
After a configured number of consecutive losses, the next win grants bonus cash.

**When Player Encounters It:**  
After Comeback Chip or related comeback effects.

**What Decision It Affects:**  
Recovery decisions and defensive upgrade value.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some upgrades help you recover after a losing streak.

**Advanced Explanation:**  
Comeback effects soften variance, but they should not make the player chase bad bets just to trigger them.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Dealer Exploit And Natural Bonuses

**Category:**  
Modifier / Upgrade / Hand Outcome

**Code Location:**  
`UpgradeEffect.bankerInitialTotalBonus`; `.firstNaturalEachStageBonus`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Dealer Pressure pays if Banker's initial total is within a range. Face Hunter pays once per stage on the first natural.

**When Player Encounters It:**  
After specific dealer-exploit upgrades.

**What Decision It Affects:**  
Upgrade choice and reading ledger outcomes.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some bonuses trigger from special hand details, not just who wins.

**Advanced Explanation:**  
These are supplemental engines; they add value when they happen but are hard to directly control without reveal or shoe sculpting.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Stage Start And Boss Stage Cash

**Category:**  
Modifier / Upgrade / Economy

**Code Location:**  
`UpgradeEffect.stageStartCash`; `.stageStartAnteCash`; `.bossStageCash`; `.bossStageAnteCash`; `applyStageStartEffects()`; `applyBossStageStartEffects()`

**What It Does:**  
Some upgrades grant cash at stage start or boss-stage start. Summary values can scale by ante.

**When Player Encounters It:**  
At stage start or boss stage start after acquiring matching upgrades.

**What Decision It Affects:**  
Upgrade value and boss preparation.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some upgrades pay before the hand starts.

**Advanced Explanation:**  
Stage-start cash is reliable compared to conditional win bonuses, but it does not directly change hand odds.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented But Suspicious

## Card Exit Income And Round Stipends

**Category:**  
Modifier / Upgrade / Economy

**Code Location:**  
`UpgradeEffect.cardExitIncome`; `.roundStipend`; `.roundAnteStipend`; `GameViewModel.payoutCents(...)`

**What It Does:**  
Some upgrades pay passive income every round or per card leaving the shoe.

**When Player Encounters It:**  
After economy/reveal upgrades.

**What Decision It Affects:**  
Build direction, hand pacing, long-stage value.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Some upgrades make money even when the main bet is not the whole story.

**Advanced Explanation:**  
Passive income can make survival stages easier, especially when it reduces reliance on big bets.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Upgrade Rarity, Draft Timing, And Duplicates

**Category:**  
Upgrade

**Code Location:**  
`UpgradeRarity.weightedRandom`; `GameViewModel.upgradeRewardThreshold`; `queueShoeUpgradeRewardIfNeeded()`; `UpgradeCard.randomChoices(...)`; `UpgradeEffect.hasMeaningfulDuplicateValue`

**What It Does:**  
The first upgrade appears after 2 rounds; later upgrades after 3 rounds. Draft choices are weighted 70% common, 25% rare, 5% legendary. Low-value duplicate upgrades are filtered unless needed to fill choices.

**When Player Encounters It:**  
Upgrade draft screens.

**What Decision It Affects:**  
Build direction and expected upgrade availability.

**Decision Weight:**  
High

**Beginner Explanation:**  
Upgrades arrive every few hands, and rarer cards are less common.

**Advanced Explanation:**  
Draft selection is random but constrained by unlocked cards, duplicate value, and guided first-run curation.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Upgrade Unlocking And Default Pool

**Category:**  
Upgrade / Economy

**Code Location:**  
`PlayerProfile.defaultUnlockedUpgradeNames`; `MetaProgressionManager.unlockedUpgradeCards`; `Unlockable.upgradeUnlockables`

**What It Does:**  
New profiles start with a default set of unlocked upgrade names. More upgrades can be unlocked permanently with Chips.

**When Player Encounters It:**  
Upgrade drafts and profile unlock shop.

**What Decision It Affects:**  
Build availability and meta progression.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
You start with a starter upgrade pool and unlock more over time.

**Advanced Explanation:**  
Unlock choices change draft odds and available archetypes, so meta progression should be taught as build-shaping rather than pure power.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Synergy Tag Thresholds

**Category:**  
Synergy / Upgrade

**Code Location:**  
`UpgradeTag`; `SynergyDefinition.allSynergies`; `GameViewModel.activeSynergies`; `activeUpgradeEffects`

**What It Does:**  
Collecting enough upgrades with a tag activates synergy effects. Examples: 3 Tie upgrades improve Tie payout; 5 Reveal upgrades add reveal and chosen-bet ante bonus; 5 Banker upgrades grant Banker ante bonus and No Commission.

**When Player Encounters It:**  
After acquiring multiple upgrades in the same tag family.

**What Decision It Affects:**  
Upgrade choice, build direction, draft discipline.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Several upgrades pointing the same direction become stronger together.

**Advanced Explanation:**  
Synergies are the main reason not to chase every flashy upgrade; focused tags unlock extra effects that random piles do not.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly

## Boss Suppression And Upgrade Disable

**Category:**  
Boss / Pressure / Upgrade

**Code Location:**  
`BossEffect.suppressedTags`; `BossManager.startPendingBoss(...)`; `GameViewModel.effectiveUpgrades`; `disabledBossUpgrades`

**What It Does:**  
Bosses can disable all acquired upgrades matching suppressed tags. Pit Boss and The House can also disable a random number of upgrades.

**When Player Encounters It:**  
Boss stages.

**What Decision It Affects:**  
Build resilience and boss preparation.

**Decision Weight:**  
High

**Beginner Explanation:**  
Bosses can temporarily shut off parts of your build.

**Advanced Explanation:**  
A single-tag build can become fragile when the wrong boss appears, especially in Boss Rush.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Automatic Shuffler And House Shoe Rules

**Category:**  
Boss / Shoe Control / Pressure

**Code Location:**  
`BossEffect.shufflesAfterEveryRound`; `GameViewModel.dealRound(...)`; `shuffleRemainingShoeForBoss()`

**What It Does:**  
Automatic Shuffler and The House shuffle the remaining shoe after every round. Hot/Cold shuffle effects apply after these shuffles.

**When Player Encounters It:**  
Specific boss stages.

**What Decision It Affects:**  
Shoe sculpting, reveal reliability, Hot/Cold upgrade value.

**Decision Weight:**  
High

**Beginner Explanation:**  
Some bosses keep scrambling the shoe.

**Advanced Explanation:**  
Continuous shuffling weakens long-term top-deck planning but can repeatedly trigger shuffle-based modifiers.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Formal Player Archetype System Absence

**Category:**  
Archetype

**Code Location:**  
No dedicated `PlayerArchetype` type found. Strategy identity is currently inferred from `UpgradeTag`, `RunModifierID`, and `SynergyDefinition`.

**What It Does:**  
The code has build tags and run modifiers, but no formal player archetype model with name, starting bonus, weakness, or explicit strategy.

**When Player Encounters It:**  
Indirectly through upgrades, synergies, run modifiers, and UI labels.

**What Decision It Affects:**  
Upgrade choice and build direction.

**Decision Weight:**  
Critical for tutorial planning

**Beginner Explanation:**  
The game has build styles, but not a named character class system yet.

**Advanced Explanation:**  
Tutorial data should not claim fixed archetypes like "Safe Grinder" or "High Roller" unless they are framed as build paths/run modifiers, not formal classes.

**Tutorial Priority:**  
Must Teach

**Status:**  
Designed But Not Implemented

## Build Archetype: Conservative / Low Roller

**Category:**  
Archetype / Upgrade / Betting

**Code Location:**  
`UpgradeTag.conservative`; `RunModifierID.lowRoller`; `Conservative Edge`; `Small Ball`; `Low Roller`; `Discipline Bonus`

**What It Does:**  
This build rewards low bets, repeated small wins, and not raising. Low Roller run modifier starts with a smaller bankroll but increases chip rewards.

**When Player Encounters It:**  
Upgrade drafts and run modifier setup.

**What Decision It Affects:**  
Bet size, risk tolerance, upgrade choice.

**Decision Weight:**  
High

**Beginner Explanation:**  
The cautious path wins by staying alive and making small bets pay.

**Advanced Explanation:**  
Conservative builds are especially strong in survival-stage data because they do not need high exposure to make progress.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Aggressive / High Roller

**Category:**  
Archetype / Upgrade / Betting

**Code Location:**  
`UpgradeTag.aggressive`; `UpgradeTag.risk`; `RunModifierID.highRoller`; `ChallengeModeID.highRoller`; `Press the Advantage`; `High Roller Spark`; `Aggressive Bonus`

**What It Does:**  
This build rewards raising, large bets, and higher-risk payout multipliers. High Roller challenge starts with $5,000 but makes losses 25% worse.

**When Player Encounters It:**  
Challenge setup, run modifier setup, upgrade drafts.

**What Decision It Affects:**  
Bet size, when to press, whether to accept loss penalties.

**Decision Weight:**  
High

**Beginner Explanation:**  
Aggressive builds can pay hard, but they punish bad timing.

**Advanced Explanation:**  
High Roller effects need information or strong payout support; otherwise loss multipliers can erase the starting-bankroll advantage.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Player Advocate

**Category:**  
Archetype / Upgrade / Betting

**Code Location:**  
`UpgradeTag.player`; `playerAdvocateCards`; `SynergyDefinition.player_coalition`

**What It Does:**  
Player-tag upgrades reward Player wins with ante bonuses, profit multipliers, loss rebates, and synergy bonuses.

**When Player Encounters It:**  
Upgrade drafts and Player-focused builds.

**What Decision It Affects:**  
Side selection and upgrade priority.

**Decision Weight:**  
High

**Beginner Explanation:**  
Player builds want Player wins to pay more than normal.

**Advanced Explanation:**  
Player builds become strong when side bonuses stack with reveal forecasts that identify good Player hands.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Banker King

**Category:**  
Archetype / Upgrade / Betting

**Code Location:**  
`UpgradeTag.banker`; `bankerKingCards`; `SynergyDefinition.banker_empire`; `BossEffect.restoresBankerCommission`

**What It Does:**  
Banker-tag upgrades reward Banker wins, remove commission, and build toward Banker Empire synergy.

**When Player Encounters It:**  
Upgrade drafts and Banker-focused builds.

**What Decision It Affects:**  
Side selection, commission management, boss risk.

**Decision Weight:**  
High

**Beginner Explanation:**  
Banker builds make Banker wins pay better and can remove the commission.

**Advanced Explanation:**  
Banker builds should watch for bosses that restore commission or suppress Banker tags.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Tie Hunter

**Category:**  
Archetype / Upgrade / Betting

**Code Location:**  
`UpgradeTag.tie`; `tieHunterCards`; `RunModifierID.tieChaser`; `SynergyDefinition.tie_master`; `BossEffect.tieClamp`

**What It Does:**  
Tie builds improve Tie payouts, add matched pairs, refund previous losses on Tie, and trigger Tie synergies.

**When Player Encounters It:**  
Tie upgrade drafts, run modifier setup, Tie Only challenge.

**What Decision It Affects:**  
Whether to chase Tie, how much to protect bankroll, boss preparation.

**Decision Weight:**  
High

**Beginner Explanation:**  
Tie builds chase rare results for oversized payouts.

**Advanced Explanation:**  
Tie builds are swingy and can be hard-countered by Tie Clamp or The House.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Reveal / Card Counter

**Category:**  
Archetype / Shoe Control / Betting

**Code Location:**  
`UpgradeTag.reveal`; `cardCounterCards`; `ShoeRevealConfiguration`; `SynergyDefinition.counter_master`; `RunModifierID.openingTell`

**What It Does:**  
Reveal builds show upcoming cards, add forecasts, and build toward reveal synergies.

**When Player Encounters It:**  
Reveal upgrades, shoe UI, forecast UI.

**What Decision It Affects:**  
Side selection, bet sizing, shoe-control timing.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Reveal builds turn guessing into informed betting.

**Advanced Explanation:**  
The strongest reveal builds combine forecast, burn/reorder tools, and bankroll discipline because information still has caps and boss counters.

**Tutorial Priority:**  
Must Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Shoe Architect / Loaded Shoe

**Category:**  
Archetype / Shoe Control / Synergy

**Code Location:**  
`UpgradeTag.shoe`; `loadedShoeCards`; `SynergyDefinition.shoe_architect`; card injection/removal effects

**What It Does:**  
Shoe builds add or remove cards from the shoe and can trigger a shuffle-based synergy that adds 8s and 9s.

**When Player Encounters It:**  
Shoe upgrade drafts and reshuffles.

**What Decision It Affects:**  
Long-term odds shaping, upgrade choice.

**Decision Weight:**  
High

**Beginner Explanation:**  
Shoe builds change the cards that can be dealt.

**Advanced Explanation:**  
Shoe sculpting is slower than direct payout bonuses but can compound with reveal, Tie, and side-specific strategies.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Economy Engine

**Category:**  
Archetype / Economy / Synergy

**Code Location:**  
`UpgradeTag.economy`; `economyCards`; `SynergyDefinition.economy_engine`

**What It Does:**  
Economy upgrades add passive income, ante-scaled rewards, loss rebates, and stage-start cash. Five economy upgrades grant a large round ante stipend.

**When Player Encounters It:**  
Upgrade drafts and payout ledgers.

**What Decision It Affects:**  
Survival, low-risk scaling, reward choice.

**Decision Weight:**  
High

**Beginner Explanation:**  
Economy builds make money outside the base bet.

**Advanced Explanation:**  
Economy builds are powerful in survival stages because they reduce the need to win big single hands.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Comeback

**Category:**  
Archetype / Economy / Pressure

**Code Location:**  
`UpgradeTag.comeback`; `Safety Net`; `Damage Control`; `Comeback Chip`; `UpgradeEffectSummary`

**What It Does:**  
Comeback tools refund losses, grant cash when low, or pay after losing streaks.

**When Player Encounters It:**  
Defensive upgrade drafts and low-bankroll situations.

**What Decision It Affects:**  
Whether to stabilize a fragile run.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Comeback upgrades help you survive bad stretches.

**Advanced Explanation:**  
They are best as insurance layered onto a real plan, not the whole build.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Build Archetype: Boss Tech

**Category:**  
Archetype / Boss / Economy

**Code Location:**  
`UpgradeTag.boss`; `bossTechCards`; `SynergyDefinition.boss_slayer`

**What It Does:**  
Boss-tag upgrades prepare for boss stages with reveal, cash, rebates, or boss-stage bonuses. Three Boss upgrades trigger Boss Slayer synergy.

**When Player Encounters It:**  
Upgrade drafts and boss stages.

**What Decision It Affects:**  
Pre-boss preparation and build resilience.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
Boss Tech helps when the casino starts fighting back.

**Advanced Explanation:**  
Boss-tag value depends on how soon a boss is coming and whether the reward offsets suppressed upgrades.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly as a build path, not a formal archetype

## Heat Pressure

**Category:**  
Pressure

**Code Location:**  
`RunManager.heat`; `RunManager.maxHeat`; `RunManager.evaluateStage(bankrollCents:)`; `StageRewardEffect.reduceHeat`

**What It Does:**  
Heat can end the run at max. Current live gain is tied to clearing a stage with negative stage profit. Heat reduction rewards are defined.

**When Player Encounters It:**  
HUD, stage result, reward choices.

**What Decision It Affects:**  
Whether to accept a stage clear at a loss and whether Heat reduction is valuable.

**Decision Weight:**  
High

**Beginner Explanation:**  
The casino can get too hot even if you survive the table.

**Advanced Explanation:**  
Heat is underdeveloped compared with its model surface; it should be taught lightly until more triggers are live.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented But Confusing

## Anti-Stall Round Limits

**Category:**  
Pressure / Core Run

**Code Location:**  
`Stage.roundLimit`; `RunManager.roundsRemaining`; `RunManager.evaluateStage(bankrollCents:)`

**What It Does:**  
Each stage has a hand limit, and the stage resolves when the required hands are played. Future objective types can fail when out of rounds.

**When Player Encounters It:**  
Every stage.

**What Decision It Affects:**  
Pacing, temporary-edge timing, whether to sit on advantages.

**Decision Weight:**  
High

**Beginner Explanation:**  
You only get a limited number of hands at each table.

**Advanced Explanation:**  
Since live stages are survival-based, round limits are currently more of a completion timer than a profit deadline.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly

## Shop Phase Placeholder

**Category:**  
Economy / Shop

**Code Location:**  
`StageFlowState.shop`; `RunManager.enterShop()`; `ShopPhaseView`; `ContentView.continueFromShop()`

**What It Does:**  
The model and view contain a shop phase, but the live `GameViewModel` does not appear to expose `continueFromShop()` or a clear path into `RunManager.enterShop()`.

**When Player Encounters It:**  
Likely not reachable in the current live flow.

**What Decision It Affects:**  
Would affect spending Chips between stages.

**Decision Weight:**  
Low currently, High if connected

**Beginner Explanation:**  
The code has a shop concept, but it does not look fully wired into live play.

**Advanced Explanation:**  
Do not build tutorial commitments around shop flow until routing and state mutation are verified.

**Tutorial Priority:**  
Reference Only

**Status:**  
Designed But Not Implemented

## Generic Modifier Engine

**Category:**  
Modifier / Economy / Pressure / Shoe Control

**Code Location:**  
`ModifierModels.swift`; `ModifierEngine.resolve(...)`; `Modifier.sampleDebugPool`; `RunState.sampleDebugRun(...)`

**What It Does:**  
A data-driven modifier engine exists with triggers, conditions, heat, reveal requests, payout modifiers, refunds, chips, usage limits, and sample modifiers.

**When Player Encounters It:**  
Not in the live `GameViewModel` battle loop.

**What Decision It Affects:**  
Would affect shop builds, trigger timing, Heat, and modifier leveling if connected.

**Decision Weight:**  
Low currently, Critical for future rebuild

**Beginner Explanation:**  
There is a future modifier system in code, but the current live game still uses upgrade effects.

**Advanced Explanation:**  
The engine is testable architecture, not authoritative gameplay until events are emitted from live rounds.

**Tutorial Priority:**  
Reference Only

**Status:**  
Designed But Not Implemented

## Future RunState And Shop Models

**Category:**  
Core Run / Economy / Shop

**Code Location:**  
`RunState.swift`; `ShopModels.swift`; `OpponentModels.swift`

**What It Does:**  
Future battle/shop architecture models phases, objectives, short battles, opponents, shops, consumables, attachments, boss relics, and starting contacts.

**When Player Encounters It:**  
Mostly debug/sample state, not the current live run.

**What Decision It Affects:**  
Would affect run pacing and shop decisions once connected.

**Decision Weight:**  
Low currently

**Beginner Explanation:**  
Some systems are planned in code but not part of the current playable loop.

**Advanced Explanation:**  
Tutorial source of truth should remain `GameViewModel`/`RunManager` until the rebuild layer is activated.

**Tutorial Priority:**  
Reference Only

**Status:**  
Designed But Not Implemented

## Starting Contacts

**Category:**  
Core Run / Economy / Archetype

**Code Location:**  
`StartingContact`; `GameState.startingContact`; `RunPersistenceManager.startingContact(id:)`; `RunStartView`

**What It Does:**  
Starting contacts are modeled. The default Floor Host has no bonus. A sample Inside Dealer starts with X-Ray Shoe and Lucky Cut, but it is not clearly selectable in live setup.

**When Player Encounters It:**  
Run start view, possibly debug/sample data.

**What Decision It Affects:**  
Would affect opening build and starting resources.

**Decision Weight:**  
Low currently, Medium if connected

**Beginner Explanation:**  
Contacts are planned run starters, but the default contact currently does not change the run.

**Advanced Explanation:**  
Do not teach contact strategy until contacts are exposed as real choices.

**Tutorial Priority:**  
Reference Only

**Status:**  
Designed But Not Implemented

## Achievements

**Category:**  
Economy / Meta Progression

**Code Location:**  
`Achievement.allAchievements`; `MetaProgressionManager.evaluateAchievements(context:)`

**What It Does:**  
Achievements grant Chips for revealing cards, acquiring Loaded Shoe, reaching bankroll thresholds, defeating bosses, and clearing Stage 10.

**When Player Encounters It:**  
During run snapshots or run end when criteria are met.

**What Decision It Affects:**  
Long-term goals and unlock pacing.

**Decision Weight:**  
Low

**Beginner Explanation:**  
Achievements pay extra Chips for milestones.

**Advanced Explanation:**  
They are useful progression rewards but should not drive hand-by-hand decisions.

**Tutorial Priority:**  
Optional

**Status:**  
Implemented Clearly

## Existing Onboarding And Glossary

**Category:**  
Core Run / Tutorial

**Code Location:**  
`TutorialModels.swift`; `OnboardingView`; `GlossaryView`; `ContentView.isShowingTutorial`; `MetaProgressionManager.markOnboardingCompleted(skipped:)`

**What It Does:**  
The app currently has a seven-step tutorial overlay and glossary. It can be replayed and skipped, and completion is stored in `PlayerProfile.hasCompletedOnboarding`.

**When Player Encounters It:**  
First-time flow and settings replay.

**What Decision It Affects:**  
Learning path, not core gameplay directly.

**Decision Weight:**  
Medium

**Beginner Explanation:**  
The current app already has a basic tutorial, but not the richer prompt-pack tutorial system.

**Advanced Explanation:**  
Prompt-pack implementation should either migrate or replace this without creating duplicate completion keys.

**Tutorial Priority:**  
Reference Only

**Status:**  
Implemented But Confusing

## Stage Reward Apply Coverage

**Category:**  
Economy / Upgrade

**Code Location:**  
`StageRewardEffect`; `StageReward.allRewards`; `GameViewModel.applyStageReward(_:)`

**What It Does:**  
`StageRewardEffect` defines direct cash, ante-scaled cash, Chips, Heat reduction, upgrade removal/duplication, random upgrades, Tie payout increases, high-card injection, and face-card removal. The live apply switch now covers those effect cases.

**When Player Encounters It:**  
Stage reward selection.

**What Decision It Affects:**  
Reward choice and trust in reward text.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
Stage rewards now have code paths matching their effect types.

**Advanced Explanation:**  
This was discovered as a missing apply-case risk during the audit and repaired before moving to Prompt 2. It still needs Xcode verification.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly, Needs Manual Verification

## Boss Reward Apply Coverage

**Category:**  
Boss / Economy

**Code Location:**  
`BossRewardEffect.gainAnteScaledCash`; `BossReward.Vault Leak`; `GameViewModel.applyBossReward(_:)`

**What It Does:**  
Boss reward data defines Vault Leak as ante-scaled cash plus Chips, and the live boss reward apply switch now handles `gainAnteScaledCash`.

**When Player Encounters It:**  
Boss reward selection.

**What Decision It Affects:**  
Boss reward trust and economy.

**Decision Weight:**  
High

**Beginner Explanation:**  
Vault Leak now pays through the same reward application path as other boss rewards.

**Advanced Explanation:**  
This was discovered as a missing apply-case risk during the audit and repaired before moving to Prompt 2. It still needs Xcode verification.

**Tutorial Priority:**  
Should Teach

**Status:**  
Implemented Clearly, Needs Manual Verification

## GameViewModel Flow Glue

**Category:**  
Core Run

**Code Location:**  
`ContentView`; `GameViewModel`; `RunManager`

**What It Does:**  
`ContentView` needs `GameViewModel` accessors and flow methods for stage preview, stage result, bet cap reasons, run start, battle start, stage result continuation, and shop continuation. Those forwarding methods now exist.

**When Player Encounters It:**  
Run start, stage preview, stage result, and shop overlays.

**What Decision It Affects:**  
Navigation through run flow and bet availability messaging.

**Decision Weight:**  
Critical

**Beginner Explanation:**  
The run-flow screens now have model methods to move the player forward.

**Advanced Explanation:**  
This was discovered as a missing view-model surface during the audit and repaired with narrow forwarding methods. It still needs Xcode verification.

**Tutorial Priority:**  
Reference Only

**Status:**  
Implemented Clearly, Needs Manual Verification

# Critical Mechanics New Players Must Understand First

1. Bankroll is survival, and falling below the stage minimum ends the run.
2. The live stage ladder is currently survival-hand based, not profit-target based.
3. Bet size is capped by stage denominations, stage max, bankroll, and sometimes reveal effects.
4. Player, Banker, and Tie payouts work differently, with Banker commission and Tie pushes.
5. The shoe is a real ordered card stack, and reveal/forecast mechanics read that stack.
6. X-Ray and other strong information effects should change betting, but may cap bet size.
7. Upgrades are build pieces; focused tags activate synergies.
8. Boss stages can suppress or disable parts of a build.
9. Heat is a second fail condition, but its current live behavior is narrower than the models imply.
10. Some reward/shop/modifier systems are modeled but not fully connected.

# Mechanics That Should Appear In Warm-Up Hands

- Bankroll as health.
- Stage survival objective and limited hands.
- Bet size and stage bet caps.
- Player/Banker/Tie base payout and Tie push.
- Reveal/forecast changing bet choice.
- X-Ray bet cap tradeoff.
- Burn Control or Soft Shuffle after a reveal.
- Upgrade synergy vs unrelated reward choice.
- Boss suppression of a focused build.
- Heat from clearing at a loss.
- Small-bet conservative path vs aggressive press path.

# Implemented But Confusing

- Guided first run rigs the opening hand and first upgrade, but this is not the normal game.
- Stage progress code still includes profit target support, but current stages are survival stages.
- Heat exists as a run-ending pressure, but live gain mostly happens on stage clear at a loss.
- Chips appear both as in-run/shop-adjacent state and as permanent profile currency.
- Permanent reveal count can be clamped differently depending on the source of the reveal.
- Build archetypes exist as tags and synergies, not as formal player classes.
- Existing onboarding uses `hasCompletedOnboarding`, while the prompt pack later asks for `hasCompletedIntroTutorial`.

# Implemented But Broken Or Suspicious

- `ShopPhaseView` and `StageFlowState.shop` exist, but a live path into `RunManager.enterShop()` was not found.
- The generic `ModifierEngine` has real resolver code, but live hand resolution does not appear to call it.
- `StageRewardEffect.gainCash` exists but no current `StageReward.allRewards` entry uses it.
- `BossRewardEffect.gainCash` exists but no current `BossReward.allRewards` entry uses it.
- Baccarat banker draw rules are implemented in more than one place; they should be kept in sync or centralized.
- Reward apply coverage and run-flow glue were repaired during this audit pass, but the workspace has no local Swift/Xcode toolchain, so build verification is still pending.

# Designed But Not Implemented

- Full prompt-pack tutorial system: intro splash, mechanics guide, warm-up hands, learn room, quick help, QA report, final report.
- Formal player archetypes with names, starting bonuses, weaknesses, and intended strategies.
- Future `RunState` battle/shop loop.
- Shop offers, modifier purchases, consumables, attachments, and boss relics in the live loop.
- Generic `ModifierEngine` integration into `GameViewModel`.
- Starting contact selection beyond the default/sample model.
- Future hooks: Private Table License and Backroom Ledger.
- Online daily leaderboard service; current daily run record is local.
- Profit-target stage ladder in current live stage data.

# Recommended Tutorial Order

1. Bankroll is health.
2. Stage objective: survive the table and keep enough bankroll for the next stage.
3. Bet sides and base payouts: Player, Banker, Tie, commission, Tie push.
4. Bet size, stage denominations, and bankroll cap.
5. Shoe basics: cards are dealt from a real ordered shoe.
6. Reveal basics: information changes the correct bet.
7. X-Ray tradeoff: strong read, limited charges, bet cap.
8. Upgrade drafts: choose pieces that match a plan.
9. Synergy: tags and focused build direction.
10. Conservative vs aggressive build paths.
11. Tie, Player, Banker, reveal, shoe, economy, and comeback build examples.
12. Boss stages and suppressed upgrades.
13. Heat and stage-clear-at-a-loss pressure.
14. Meta unlocks: Chips, Reputation, challenges, run modifiers.
15. Reference-only systems: shop, generic modifiers, future contacts, future hooks.
