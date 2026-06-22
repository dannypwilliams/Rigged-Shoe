# Mechanics Catalog

Generated from the current worktree. The simulator parses the rebalanced 41-modifier roster, production shop/reward pools, stage, boss, and legacy-upgrade archive source files, then mirrors the live battle flow visible from `GameViewModel.swift`.

## Source Of Truth

- Shoe: `RiggedShoe/Models/Shoe.swift` creates a 6-deck shoe, shuffles with `SeededRandomGenerator` when seeded, reshuffles below 20 remaining cards, and exposes card insertion/removal helpers.
- Baccarat: `GameViewModel.playBaccaratRound` deals Player, Banker, Player, Banker; naturals stand; Player draws on 0-5; Banker follows the implemented third-card table; Player and Banker bets push on Tie.
- Payouts: `BetType.swift` and `GameViewModel.payoutCents`; Player pays 1:1, Banker pays 0.95:1 unless table/boss rules change commission, Tie pays 8:1 unless table/reward rules change it.
- Stages and difficulty: `Stage.swift`, `OpponentModels.swift`, `RunManager.swift`, and `BossManager.swift`.
- Modifiers: `ModifierModels.swift`; runtime resolution is `ModifierEngine.resolve`, but only events emitted by `GameViewModel` can trigger.
- Rewards/shop: `StageReward.swift`, `BossReward.swift`, and `ShopModels.swift`.

## Locally Determined Git Context

- `.git/refs/remotes/origin/HEAD` points at `origin/main`.
- `.git/HEAD` points at `refs/heads/main`.
- No Git executable was available in this Windows shell, so uncommitted worktree diffs could not be classified mechanically. The audit therefore treats every implemented non-core modifier/upgrade as in-scope rather than labeling branch-new mechanics.

## Emitted Modifier Triggers

Declared triggers: `runStarted`, `stageStarted`, `handStarted`, `beforeBet`, `betPlaced`, `beforeDeal`, `cardDrawn`, `cardRevealed`, `naturalOccurred`, `pairOccurred`, `tieOccurred`, `wagerWon`, `wagerLost`, `handResolved`, `heatGained`, `shopEntered`, `shopRerolled`, `modifierBought`, `modifierSold`, `modifierLeveled`, `bossStarted`, `bossDefeated`, `finalHand`, `runEnded`.

Modeled/resolved by this command-line battle flow: `runStarted`, `stageStarted`, `handStarted`, `beforeBet`, `betPlaced`, `beforeDeal`, `cardDrawn`, `naturalOccurred`, `pairOccurred`, `tieOccurred`, `wagerWon`, `wagerLost`, `handResolved`, `heatGained`, `shopEntered`, `shopRerolled`, `modifierBought`, `modifierLeveled`, `bossStarted`, `bossDefeated`, `finalHand`, `runEnded`.

Declared but not modeled by this command-line battle flow: `cardRevealed`, `modifierSold`. Modifiers that depend only on these hooks are classified as dead or redesign candidates unless another path activates them.

## Stages

| Stage | Hands | Ante | Allowed Bets | Opponent | Table Event | Boss | Clear Rule |
|---:|---:|---:|---|---|---|---|---|
| 1 | 5 | $25 | $25, $50, $75, $100 | Nervous Tourist | Tourist Rush | None | Survive hands and beat opponent score with stage tolerance |
| 2 | 6 | $50 | $50, $100, $150 | Weekend Regular | No Commission Night | None | Survive hands and beat opponent score with stage tolerance |
| 3 | 7 | $75 | $75, $150, $225, $250 | Card Room Grinder | Tie Promo | None | Survive hands and beat opponent score with stage tolerance |
| 4 | 8 | $100 | $100, $200, $300, $400 | Tie Chaser | High Minimums | None | Survive hands and beat opponent score with stage tolerance |
| 5 | 8 | $150 | $150, $300, $450, $600 | Pattern Player | Tight Surveillance | Pit Boss | Survive hands and beat opponent score with stage tolerance |
| 6 | 8 | $200 | $200, $400, $600, $800 | The Counter | Private Table | None | Survive hands and beat opponent score with stage tolerance |
| 7 | 9 | $300 | $300, $600, $900, $1,200 | The Whale Junior | Rich Crowd | None | Survive hands and beat opponent score with stage tolerance |
| 8 | 10 | $400 | $400, $800, $1,200, $1,600, $1,750 | Quiet Regular | Bad Cut | The Inspector | Survive hands and beat opponent score with stage tolerance |
| 9 | 10 | $600 | $600, $1,200, $1,800, $2,400, $2,500 | The Cooler | Cold Table | None | Survive hands and beat opponent score with stage tolerance |
| 10 | 12 | $800 | $800, $1,600, $2,400, $3,200, $4,000 | The Floor Favorite | Final Hand Spotlight | The House | Survive hands and beat opponent score with stage tolerance |

## Modifiers

| ID | Name | Rarity | Trigger | Tags | Tier | Source | Behavior / Formula | Trigger Status |
|---|---|---|---|---|---:|---|---|---|
| banker.banco-press | Banco Press | uncommon | wagerWon | banker, betControl | 2 | RiggedShoe/Models/ModifierModels.swift:818 | payout bonus up to 20%; bankroll +110% ante | emitted |
| banker.banker-anchor | Banker Anchor | common | wagerLost | banker, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:814 | refund up to 20% | emitted |
| banker.banker-lock | Banker Lock | legendary | wagerWon | banker, boss | 5 | RiggedShoe/Models/ModifierModels.swift:817 | payout bonus up to 85%; costs 1 Heat | emitted |
| banker.commission-dodge | Commission Dodge | common | wagerWon | banker, economy | 1 | RiggedShoe/Models/ModifierModels.swift:810 | payout bonus up to 14% | emitted |
| banker.dealers-nod | Dealer's Nod | uncommon | wagerWon | banker, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:813 | reveals 1 cards | emitted |
| bet.high-roller | High Roller | rare | wagerWon | betControl, heat | 2 | RiggedShoe/Models/ModifierModels.swift:884 | payout bonus up to 50%; costs 1 Heat | emitted |
| bet.press-edge | Press the Edge | uncommon | wagerWon | betControl, streak | 2 | RiggedShoe/Models/ModifierModels.swift:883 | payout bonus up to 24% | emitted |
| boss.boss-bounty | Boss Bounty | rare | bossDefeated | boss, economy | 5 | RiggedShoe/Models/ModifierModels.swift:967 | bankroll +100% ante; chips +3 | emitted |
| boss.house-crack | House Crack | legendary | wagerWon | boss, betControl, heat | 5 | RiggedShoe/Models/ModifierModels.swift:968 | payout bonus up to 50%; costs 2 Heat | emitted |
| control.hot-cut | Hot Cut | legendary | stageStarted | shoeControl, cardSculpting | 5 | RiggedShoe/Models/ModifierModels.swift:874 | costs 2 Heat | emitted |
| control.slipstream | Slipstream | rare | beforeDeal | shoeControl, shoeVision | 3 | RiggedShoe/Models/ModifierModels.swift:873 | reveals 1 cards | emitted |
| control.soft-cut | Soft Cut | common | beforeDeal | shoeControl | 1 | RiggedShoe/Models/ModifierModels.swift:867 | contentModifier(id: "control.soft-cut", name: "Soft Cut", summary: "Move the top card to the bottom.", rarity: .common, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardToBottom], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| core.banker-bias | Banker Bias | common | wagerWon | banker, betControl | 1 | RiggedShoe/Models/ModifierModels.swift:590 | payout bonus up to 5% | emitted |
| core.clean-hands | Clean Hands | common | heatGained | heat | 1 | RiggedShoe/Models/ModifierModels.swift:590 | chips +1 | emitted |
| core.lucky-chip | Lucky Chip | common | wagerWon | economy | 1 | RiggedShoe/Models/ModifierModels.swift:590 | chips +1 | emitted |
| core.opening-tell | Opening Tell | common | stageStarted | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:590 | reveals 2 cards | emitted |
| core.player-surge | Player Surge | common | wagerWon | player, tempo | 1 | RiggedShoe/Models/ModifierModels.swift:590 | payout bonus up to 20%; chips +1 | emitted |
| core.tie-insurance | Tie Insurance | common | wagerLost | tie, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:590 | refund up to 40% | emitted |
| debt.emergency-marker | Emergency Marker | common | stageStarted | economy, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:974 | bankroll +50% ante | emitted |
| debt.last-dollar | Last Dollar | uncommon | wagerLost | comeback, economy | 2 | RiggedShoe/Models/ModifierModels.swift:976 | chips +1; refund up to 60% | emitted |
| economy.comp-points | Comp Points | common | wagerWon | economy | 1 | RiggedShoe/Models/ModifierModels.swift:901 | bankroll +80% ante | emitted |
| economy.interest-ledger | Interest Ledger | common | stageStarted | economy | 1 | RiggedShoe/Models/ModifierModels.swift:896 | bankroll +100% ante | emitted |
| heat.low-profile | Low Profile | common | stageStarted | heat | 1 | RiggedShoe/Models/ModifierModels.swift:910 | contentModifier(id: "heat.low-profile", name: "Low Profile", summary: "Reduce Heat at stage start.", rarity: .common, tags: [.heat], trigger: .stageStarted, effects: [.reduceHeat(amount: 1)], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| heat.soft-footsteps | Soft Footsteps | common | heatGained | heat | 1 | RiggedShoe/Models/ModifierModels.swift:915 | prevents Heat | emitted |
| loaded.add-nine | Add Nine | common | stageStarted | cardSculpting, shoeControl | 1 | RiggedShoe/Models/ModifierModels.swift:944 | contentModifier(id: "loaded.add-nine", name: "Add Nine", summary: "Add a 9 to the current shoe at stage start.", rarity: .common, tags: [.cardSculpting, .shoeControl], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| loaded.marked-nine | Marked Nine | uncommon | stageStarted | cardSculpting, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:945 | reveals 1 cards; costs 1 Heat | emitted |
| player.break-pattern | Break the Pattern | epic | wagerWon | player, boss | 5 | RiggedShoe/Models/ModifierModels.swift:829 | payout bonus up to 55% | emitted |
| player.player-tempo | Player Tempo | uncommon | wagerWon | player, economy | 2 | RiggedShoe/Models/ModifierModels.swift:832 | bankroll +75% ante; chips +1 | emitted |
| player.punto-insurance | Punto Insurance | common | wagerLost | player, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:830 | refund up to 45% | emitted |
| player.reversal-read | Reversal Read | uncommon | wagerWon | player, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:824 | payout bonus up to 32% | emitted |
| player.side-step | Side Step | common | wagerWon | player, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:825 | reveals 1 cards | emitted |
| tie.equalizer | Equalizer | rare | wagerWon | tie, economy | 2 | RiggedShoe/Models/ModifierModels.swift:839 | bankroll +250% ante; chips +3 | emitted |
| tie.mirror-bet | Mirror Bet | common | wagerLost | tie, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:843 | refund up to 18% | emitted |
| tie.split-signal | Split Signal | uncommon | tieOccurred | tie, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:841 | reveals 2 cards | emitted |
| tie.tie-master | Tie Master | legendary | wagerWon | tie, economy | 5 | RiggedShoe/Models/ModifierModels.swift:844 | bankroll +200% ante; chips +5 | emitted |
| tie.tie-whisperer | Tie Whisperer | common | wagerLost | tie, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:838 | reveals 1 cards | emitted |
| vision.deep-read | Deep Read | rare | stageStarted | shoeVision | 3 | RiggedShoe/Models/ModifierModels.swift:854 | reveals 4 cards | emitted |
| vision.pattern-memory | Pattern Memory | uncommon | wagerWon | shoeVision, economy | 2 | RiggedShoe/Models/ModifierModels.swift:855 | bankroll +20% ante; reveals 1 cards | emitted |
| vision.soft-peek | Soft Peek | common | stageStarted | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:853 | reveals 2 cards | emitted |
| vision.third-card-forecast | Third Card Forecast | epic | stageStarted | shoeVision | 5 | RiggedShoe/Models/ModifierModels.swift:857 | reveals 5 cards | emitted |
| vision.tie-forecast | Tie Forecast | rare | betPlaced | shoeVision, tie | 3 | RiggedShoe/Models/ModifierModels.swift:859 | reveals 3 cards | emitted |

## Legacy Upgrade Cards

Legacy per-hand upgrade drafts are disabled and stage/boss production rewards no longer grant legacy upgrades. Legacy cards remain cataloged as archived compatibility data.

| Name | Rarity | Tags | Source | Effect |
|---|---|---|---|---|
| Accounting Trick | rare | economy | RiggedShoe/Models/UpgradeCard.swift:467 | .chosenBetAnteWinBonus(percentOfAnte: 100) |
| Ace Factory | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:390 | .addCards(rank: .ace, count: 12) |
| Aggressive Bonus | common | aggressive, risk | RiggedShoe/Models/UpgradeCard.swift:336 | .raiseWinBonus(minRaiseCents: 2_500, cents: 1_500) |
| All-In | legendary | risk | RiggedShoe/Models/UpgradeCard.swift:445 | .combined([.profitMultiplier(betType: nil, percent: 250), .lossMultiplier(percent: 200)]) |
| Back Room Deal | rare | banker | RiggedShoe/Models/UpgradeCard.swift:416 | .noCommission |
| Balanced Shoe | rare | tie, shoe | RiggedShoe/Models/UpgradeCard.swift:362 | .addTiePairCards(pairs: 10) |
| Banker Bonus | common | banker | RiggedShoe/Models/UpgradeCard.swift:338 | .combined([.profitMultiplier(betType: .banker, percent: 110), .bankerAnteWinBonus(percentOfAnte: 25)]) |
| Banker Dynasty | legendary | banker, streak | RiggedShoe/Models/UpgradeCard.swift:412 | .streakBonus(betType: .banker, centsPerWin: 7_500) |
| Banker Monopoly | legendary | banker | RiggedShoe/Models/UpgradeCard.swift:419 | .profitMultiplier(betType: .banker, percent: 150) |
| Banker Rush | rare | banker, streak | RiggedShoe/Models/UpgradeCard.swift:411 | .streakBonus(betType: .banker, centsPerWin: 2_500) |
| Banker Streak | common | banker | RiggedShoe/Models/UpgradeCard.swift:413 | .bankerAnteWinBonus(percentOfAnte: 35) |
| Banker's Aura | rare | banker, shoe | RiggedShoe/Models/UpgradeCard.swift:417 | .combined([.addExtraNines(count: 8), .bankerAnteWinBonus(percentOfAnte: 35)]) |
| Bent Corner | common | reveal, shoe | RiggedShoe/Models/UpgradeCard.swift:325 | .shoeReveal(.bentCorner) |
| Black Card | legendary | economy | RiggedShoe/Models/UpgradeCard.swift:499 | .roundAnteStipend(percentOfAnte: 100) |
| Blue King | legendary | player, economy | RiggedShoe/Models/UpgradeCard.swift:512 | .playerAnteWinBonus(percentOfAnte: 400) |
| Blue Table | rare | player | RiggedShoe/Models/UpgradeCard.swift:431 | .profitMultiplier(betType: .player, percent: 125) |
| Boss Blackmail | legendary | boss, risk | RiggedShoe/Models/UpgradeCard.swift:506 | .bossStageAnteCash(multiplierPercent: 500) |
| Boss Ledger | rare | boss, economy | RiggedShoe/Models/UpgradeCard.swift:481 | .chosenBetAnteWinBonus(percentOfAnte: 100) |
| Boss Scout | rare | boss, reveal | RiggedShoe/Models/UpgradeCard.swift:477 | .combined([.revealCards(count: 4), .bossStageAnteCash(multiplierPercent: 200)]) |
| Burn Control | common | shoe, reveal | RiggedShoe/Models/UpgradeCard.swift:328 | .burnCardEveryHands(interval: 5) |
| Burn Notice | rare | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:377 | .cardExitIncome(centsPerCard: 100) |
| Camera Loop | rare | boss, reveal | RiggedShoe/Models/UpgradeCard.swift:479 | .revealCards(count: 6) |
| Cashback Card | common | economy | RiggedShoe/Models/UpgradeCard.swift:465 | .lossRebatePercent(percent: 20) |
| Casino Coupon | common | economy | RiggedShoe/Models/UpgradeCard.swift:468 | .stageStartAnteCash(multiplierPercent: 75) |
| Casino Credit | rare | economy | RiggedShoe/Models/UpgradeCard.swift:463 | .stageStartAnteCash(multiplierPercent: 150) |
| Casino Inside Contact+ | legendary | boss, economy | RiggedShoe/Models/UpgradeCard.swift:505 | .bossStageAnteCash(multiplierPercent: 400) |
| Chip Runner | rare | economy, shoe | RiggedShoe/Models/UpgradeCard.swift:466 | .cardExitIncome(centsPerCard: 200) |
| Cold Shoe | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:345 | .coldShoe(removeZeroValueCards: 8) |
| Comeback Chip | common | comeback, economy | RiggedShoe/Models/UpgradeCard.swift:334 | .comebackWinBonus(lossCount: 2, cents: 2_000) |
| Commission Ghost | legendary | banker, economy | RiggedShoe/Models/UpgradeCard.swift:420 | .combined([.noCommission, .bankerAnteWinBonus(percentOfAnte: 200)]) |
| Commission Refund | rare | banker, economy | RiggedShoe/Models/UpgradeCard.swift:410 | .combined([.bankerAnteWinBonus(percentOfAnte: 50), .noCommission]) |
| Comped Drinks | common | economy | RiggedShoe/Models/UpgradeCard.swift:464 | .roundAnteStipend(percentOfAnte: 15) |
| Conservative Edge | common | economy, conservative | RiggedShoe/Models/UpgradeCard.swift:318 | .smallBetWinMultiplier(maxBetCents: 10_000, percent: 150) |
| Crown of Ties | legendary | tie, streak | RiggedShoe/Models/UpgradeCard.swift:508 | .consecutiveTiePayoutBonus(amount: 5) |
| Damage Control | common | comeback, economy | RiggedShoe/Models/UpgradeCard.swift:321 | .lossRebateEveryHands(percent: 50, everyHands: 3) |
| Danger Money | common | risk, economy | RiggedShoe/Models/UpgradeCard.swift:449 | .chosenBetAnteWinBonus(percentOfAnte: 50) |
| Dead Heat Dividend | rare | tie, economy | RiggedShoe/Models/UpgradeCard.swift:361 | .chosenBetAnteWinBonus(percentOfAnte: 150) |
| Dealer Pressure | common | dealerExploit, economy | RiggedShoe/Models/UpgradeCard.swift:330 | .bankerInitialTotalBonus(minTotal: 4, maxTotal: 6, cents: 1_000) |
| Dealer Tell | common | reveal | RiggedShoe/Models/UpgradeCard.swift:373 | .revealAfterRound(count: 1) |
| Dealer's Friend | rare | banker, economy | RiggedShoe/Models/UpgradeCard.swift:415 | .bankerAnteWinBonus(percentOfAnte: 75) |
| Dealer's Soul | legendary | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:503 | .cardExitIncome(centsPerCard: 1_500) |
| Debt Knife | rare | risk, economy | RiggedShoe/Models/UpgradeCard.swift:451 | .combined([.lossMultiplier(percent: 150), .chosenBetAnteWinBonus(percentOfAnte: 150)]) |
| Deep Read | rare | reveal | RiggedShoe/Models/UpgradeCard.swift:341 | .shoeReveal(.smudgedLens) |
| Discipline Bonus | common | conservative, economy | RiggedShoe/Models/UpgradeCard.swift:335 | .steadyBetWinBonus(cents: 500) |
| Double Down | rare | risk | RiggedShoe/Models/UpgradeCard.swift:443 | .combined([.profitMultiplier(betType: nil, percent: 150), .lossMultiplier(percent: 125)]) |
| Dynasty Engine | legendary | streak | RiggedShoe/Models/UpgradeCard.swift:496 | .streakBonus(betType: nil, centsPerWin: 15_000) |
| Eight Flood | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:401 | .addExtraEights(count: 24) |
| Eight Stack | common | shoe | RiggedShoe/Models/UpgradeCard.swift:315 | .addExtraEights(count: 4) |
| Emerald Engine | legendary | economy | RiggedShoe/Models/UpgradeCard.swift:515 | .roundAnteStipend(percentOfAnte: 200) |
| Emergency Marker | common | boss, risk | RiggedShoe/Models/UpgradeCard.swift:480 | .lossRebatePercent(percent: 25) |
| Endless Read | legendary | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:520 | .combined([.revealCards(count: 999), .cardExitIncome(centsPerCard: 500)]) |
| Equals Sign | common | tie, economy | RiggedShoe/Models/UpgradeCard.swift:366 | .roundAnteStipend(percentOfAnte: 20) |
| Face Card Purge | common | shoe | RiggedShoe/Models/UpgradeCard.swift:316 | .removeZeroValueCards(count: 8) |
| Face Card Purge+ | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:396 | .removeZeroValueCards(count: 18) |
| Face Hunter | common | dealerExploit, economy | RiggedShoe/Models/UpgradeCard.swift:331 | .firstNaturalEachStageBonus(cents: 2_500) |
| Final Table | legendary | risk | RiggedShoe/Models/UpgradeCard.swift:507 | .profitMultiplier(betType: nil, percent: 200) |
| Full Surveillance | legendary | reveal, boss | RiggedShoe/Models/UpgradeCard.swift:516 | .revealCards(count: 50) |
| Full X-Ray | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:346 | .shoeReveal(.fullXRay) |
| Future Ledger | rare | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:380 | .combined([.shoeReveal(.smudgedLens), .chosenBetAnteWinBonus(percentOfAnte: 50)]) |
| Gambler's Rush | rare | risk, streak | RiggedShoe/Models/UpgradeCard.swift:446 | .streakBonus(betType: nil, centsPerWin: 5_000) |
| Ghost Commission | legendary | banker | RiggedShoe/Models/UpgradeCard.swift:500 | .combined([.noCommission, .profitMultiplier(betType: .banker, percent: 150)]) |
| Glass Cannon | rare | risk | RiggedShoe/Models/UpgradeCard.swift:447 | .combined([.profitMultiplier(betType: nil, percent: 175), .lossMultiplier(percent: 150)]) |
| God Shoe | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:510 | .hotShoe(extraEights: 12, extraNines: 12) |
| Golden Nines | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:400 | .addExtraNines(count: 24) |
| Golden Parachute | legendary | economy, risk | RiggedShoe/Models/UpgradeCard.swift:492 | .lossRebatePercent(percent: 75) |
| High Limit Permit | rare | risk, economy | RiggedShoe/Models/UpgradeCard.swift:448 | .stageStartAnteCash(multiplierPercent: 150) |
| High Roller Spark | common | aggressive, risk | RiggedShoe/Models/UpgradeCard.swift:333 | .firstLargeBetStageMultiplier(minBetCents: 20_000, percent: 120) |
| Hot Shoe | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:344 | .hotShoe(extraEights: 2, extraNines: 2) |
| Hot Table | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:394 | .hotShoe(extraEights: 8, extraNines: 0) |
| House Collapse | legendary | banker, economy | RiggedShoe/Models/UpgradeCard.swift:490 | .combined([.noCommission, .bankerAnteWinBonus(percentOfAnte: 300)]) |
| House Favorite | common | banker | RiggedShoe/Models/UpgradeCard.swift:409 | .profitMultiplier(betType: .banker, percent: 115) |
| House Ledger | common | banker, economy | RiggedShoe/Models/UpgradeCard.swift:418 | .roundAnteStipend(percentOfAnte: 20) |
| Impossible Ledger | legendary | economy | RiggedShoe/Models/UpgradeCard.swift:519 | .stageStartAnteCash(multiplierPercent: 600) |
| Infinite Credit | legendary | economy | RiggedShoe/Models/UpgradeCard.swift:470 | .stageStartAnteCash(multiplierPercent: 500) |
| Inside Man | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:347 | .shoeReveal(.fullXRay) |
| Known Shoe | rare | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:375 | .combined([.stageStartAnteCash(multiplierPercent: 100), .shoeReveal(.readTheShoe)]) |
| Last Chance | rare | risk, economy | RiggedShoe/Models/UpgradeCard.swift:444 | .lossRebatePercent(percent: 30) |
| Lens Cleaner | common | reveal, risk | RiggedShoe/Models/UpgradeCard.swift:382 | .combined([.shoeReveal(.bentCorner), .lossRebatePercent(percent: 10)]) |
| Loaded Cut Card | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:403 | .hotShoe(extraEights: 6, extraNines: 6) |
| Loaded Shoe | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:349 | .addExtraNines(count: 12) |
| Loaded Vault | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:497 | .addRandomCards(ranks: [.eight, .nine], count: 40) |
| Low Card Mill | common | shoe | RiggedShoe/Models/UpgradeCard.swift:395 | .addRandomCards(ranks: [.ace, .two, .three], count: 12) |
| Low Roller | common | conservative, streak | RiggedShoe/Models/UpgradeCard.swift:332 | .smallBetStreakBonus(maxBetCents: 10_000, requiredWins: 2, cents: 1_000) |
| Lucky Chips | common | economy | RiggedShoe/Models/UpgradeCard.swift:462 | .chosenBetAnteWinBonus(percentOfAnte: 40) |
| Lucky Cut | common | player, risk | RiggedShoe/Models/UpgradeCard.swift:434 | .lossRebatePercent(percent: 15) |
| Lucky Player | common | player | RiggedShoe/Models/UpgradeCard.swift:428 | .playerAnteWinBonus(percentOfAnte: 35) |
| Lucky Push | rare | tie, economy | RiggedShoe/Models/UpgradeCard.swift:358 | .previousLossRefundOnTie(percent: 100) |
| Marked Burn Cards | rare | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:381 | .cardExitIncome(centsPerCard: 200) |
| Marked Shoe | rare | reveal | RiggedShoe/Models/UpgradeCard.swift:340 | .shoeReveal(.readTheShoe) |
| Master Counter | legendary | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:489 | .cardExitIncome(centsPerCard: 1_000) |
| Mathematician | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:504 | .revealCards(count: 30) |
| Money Launderer | legendary | economy, shoe | RiggedShoe/Models/UpgradeCard.swift:471 | .cardExitIncome(centsPerCard: 500) |
| Negative Space | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:511 | .removeZeroValueCards(count: 80) |
| Neon Oracle | legendary | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:493 | .combined([.revealCards(count: 25), .chosenBetAnteWinBonus(percentOfAnte: 300)]) |
| Nine Syndicate | common | shoe | RiggedShoe/Models/UpgradeCard.swift:314 | .addExtraNines(count: 4) |
| Nine Syndicate+ | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:389 | .addExtraNines(count: 10) |
| No Commission | rare | banker | RiggedShoe/Models/UpgradeCard.swift:342 | .noCommission |
| No Guts | common | risk | RiggedShoe/Models/UpgradeCard.swift:452 | .profitMultiplier(betType: nil, percent: 140) |
| No More House Edge | legendary | banker, player, economy | RiggedShoe/Models/UpgradeCard.swift:518 | .combined([.noCommission, .lossRebatePercent(percent: 50), .chosenBetAnteWinBonus(percentOfAnte: 300)]) |
| Open Index | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:379 | .shoeReveal(.fullXRay) |
| Opening Tell | common | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:327 | .combined([.shoeReveal(.readTheShoe), .forecastAnteWinBonus(percentOfAnte: 25)]) |
| Pair Injection | rare | shoe, tie | RiggedShoe/Models/UpgradeCard.swift:399 | .addTiePairCards(pairs: 12) |
| Pattern Reader | rare | reveal, economy | RiggedShoe/Models/UpgradeCard.swift:374 | .forecastAnteWinBonus(percentOfAnte: 150) |
| Peek | common | reveal, shoe | RiggedShoe/Models/UpgradeCard.swift:322 | .shoeReveal(.peek) |
| Peeker's Edge | common | reveal | RiggedShoe/Models/UpgradeCard.swift:378 | .shoeReveal(.peek) |
| People's Champion | legendary | player, economy | RiggedShoe/Models/UpgradeCard.swift:437 | .playerAnteWinBonus(percentOfAnte: 200) |
| Perfect Information | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:488 | .revealCards(count: 999) |
| Phoenix Marker | legendary | tie, economy | RiggedShoe/Models/UpgradeCard.swift:509 | .previousLossRefundOnTie(percent: 200) |
| Pit Bribe | rare | boss, economy | RiggedShoe/Models/UpgradeCard.swift:478 | .bossStageAnteCash(multiplierPercent: 300) |
| Player Bonus | common | player | RiggedShoe/Models/UpgradeCard.swift:337 | .combined([.profitMultiplier(betType: .player, percent: 110), .playerAnteWinBonus(percentOfAnte: 25)]) |
| Player Coalition | rare | player | RiggedShoe/Models/UpgradeCard.swift:433 | .playerAnteWinBonus(percentOfAnte: 100) |
| Player Coup | legendary | player | RiggedShoe/Models/UpgradeCard.swift:436 | .profitMultiplier(betType: .player, percent: 150) |
| Player Dynasty | legendary | player, streak | RiggedShoe/Models/UpgradeCard.swift:427 | .streakBonus(betType: .player, centsPerWin: 7_500) |
| Player Momentum | rare | player | RiggedShoe/Models/UpgradeCard.swift:429 | .profitMultiplier(betType: .player, percent: 120) |
| Player Revolution | legendary | player | RiggedShoe/Models/UpgradeCard.swift:501 | .profitMultiplier(betType: .player, percent: 175) |
| Player Rush | rare | player, streak | RiggedShoe/Models/UpgradeCard.swift:426 | .streakBonus(betType: .player, centsPerWin: 2_500) |
| Press the Advantage | common | aggressive, risk, streak | RiggedShoe/Models/UpgradeCard.swift:320 | .pressAfterWinMultiplier(percent: 115) |
| Private Marker | rare | economy | RiggedShoe/Models/UpgradeCard.swift:469 | .roundAnteStipend(percentOfAnte: 50) |
| Push Prophet | common | tie, reveal | RiggedShoe/Models/UpgradeCard.swift:365 | .combined([.revealCards(count: 2), .chosenBetAnteWinBonus(percentOfAnte: 25)]) |
| Read the Shoe | common | reveal, shoe | RiggedShoe/Models/UpgradeCard.swift:323 | .shoeReveal(.readTheShoe) |
| Rebel Shoe | rare | player, shoe | RiggedShoe/Models/UpgradeCard.swift:432 | .combined([.addCards(rank: .ace, count: 10), .playerAnteWinBonus(percentOfAnte: 35)]) |
| Red King | legendary | banker, economy | RiggedShoe/Models/UpgradeCard.swift:513 | .bankerAnteWinBonus(percentOfAnte: 400) |
| Red Room Invite | legendary | economy, risk | RiggedShoe/Models/UpgradeCard.swift:502 | .stageStartAnteCash(multiplierPercent: 400) |
| Redline Bet | common | risk | RiggedShoe/Models/UpgradeCard.swift:450 | .profitMultiplier(betType: nil, percent: 130) |
| Rigged Shuffle | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:393 | .combined([.hotShoe(extraEights: 5, extraNines: 5), .coldShoe(removeZeroValueCards: 5)]) |
| Rigged Tie | legendary | tie | RiggedShoe/Models/UpgradeCard.swift:348 | .improveTiePayout(multiplier: 25) |
| Risk Crown | legendary | risk | RiggedShoe/Models/UpgradeCard.swift:514 | .combined([.profitMultiplier(betType: nil, percent: 500), .lossMultiplier(percent: 300)]) |
| Royal Flush | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:491 | .removeCards(ranks: [.jack, .queen, .king], count: 60) |
| Royal Flush Out | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:398 | .removeCards(ranks: [.jack, .queen, .king], count: 24) |
| Royal Tie | legendary | tie | RiggedShoe/Models/UpgradeCard.swift:359 | .tiePayoutBonus(amount: 5) |
| Safer Ties | common | tie | RiggedShoe/Models/UpgradeCard.swift:339 | .improveTiePayout(multiplier: 10) |
| Safety Net | common | economy, conservative, comeback | RiggedShoe/Models/UpgradeCard.swift:317 | .safetyNet(thresholdPercent: 80, cents: 1_000) |
| Security Badge | rare | boss, economy | RiggedShoe/Models/UpgradeCard.swift:482 | .stageStartAnteCash(multiplierPercent: 200) |
| Shoe Surgeon | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:402 | .removeZeroValueCards(count: 32) |
| Small Ball | common | streak, conservative, economy | RiggedShoe/Models/UpgradeCard.swift:319 | .smallBetStreakBonus(maxBetCents: 10_000, requiredWins: 3, cents: 2_500) |
| Smudged Lens | common | reveal, shoe | RiggedShoe/Models/UpgradeCard.swift:324 | .shoeReveal(.smudgedLens) |
| Soft Shuffle | common | shoe, reveal | RiggedShoe/Models/UpgradeCard.swift:329 | .moveTopCardDeeper(positions: 3) |
| Split Decision | common | tie, economy | RiggedShoe/Models/UpgradeCard.swift:360 | .chosenBetAnteWinBonus(percentOfAnte: 50) |
| Stacked Shoe | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:392 | .hotShoe(extraEights: 4, extraNines: 4) |
| Surveillance Map | rare | reveal | RiggedShoe/Models/UpgradeCard.swift:376 | .shoeReveal(.smudgedLens) |
| Table Breaker | legendary | risk | RiggedShoe/Models/UpgradeCard.swift:454 | .combined([.profitMultiplier(betType: nil, percent: 300), .lossMultiplier(percent: 200)]) |
| Table Hero | common | player, economy | RiggedShoe/Models/UpgradeCard.swift:435 | .roundAnteStipend(percentOfAnte: 20) |
| Table Whisperer | rare | reveal | RiggedShoe/Models/UpgradeCard.swift:383 | .shoeReveal(.readTheShoe) |
| Tax Loophole | rare | economy | RiggedShoe/Models/UpgradeCard.swift:461 | .lossRebatePercent(percent: 25) |
| The Loaded Contract | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:517 | .addExtraNines(count: 60) |
| The Whale | legendary | risk | RiggedShoe/Models/UpgradeCard.swift:498 | .combined([.profitMultiplier(betType: nil, percent: 300), .lossMultiplier(percent: 175)]) |
| Three-Way Trap | rare | tie | RiggedShoe/Models/UpgradeCard.swift:364 | .improveTiePayout(multiplier: 15) |
| Tie Fever | rare | tie, streak | RiggedShoe/Models/UpgradeCard.swift:357 | .consecutiveTiePayoutBonus(amount: 2) |
| Tie Hunter | rare | tie | RiggedShoe/Models/UpgradeCard.swift:343 | .improveTiePayout(multiplier: 15) |
| Tie Insurance | common | tie, economy | RiggedShoe/Models/UpgradeCard.swift:363 | .lossRebatePercent(percent: 10) |
| Tie Magnet | rare | tie, shoe | RiggedShoe/Models/UpgradeCard.swift:355 | .addTiePairCards(pairs: 6) |
| Tie Singularity | legendary | tie | RiggedShoe/Models/UpgradeCard.swift:494 | .improveTiePayout(multiplier: 35) |
| Twin Outcome | rare | tie | RiggedShoe/Models/UpgradeCard.swift:356 | .firstTieEachStageMultiplier(multiplier: 2) |
| Twin Suns | legendary | tie, shoe | RiggedShoe/Models/UpgradeCard.swift:495 | .addTiePairCards(pairs: 25) |
| Underdog Edge | rare | player, economy | RiggedShoe/Models/UpgradeCard.swift:430 | .playerAnteWinBonus(percentOfAnte: 75) |
| Velvet Rope | rare | banker | RiggedShoe/Models/UpgradeCard.swift:414 | .profitMultiplier(betType: .banker, percent: 125) |
| VIP Lounge | common | economy | RiggedShoe/Models/UpgradeCard.swift:460 | .roundAnteStipend(percentOfAnte: 25) |
| Weighted Deck | rare | shoe | RiggedShoe/Models/UpgradeCard.swift:391 | .addRandomCards(ranks: [.ace, .eight, .nine], count: 16) |
| Whale Signal | legendary | risk, economy | RiggedShoe/Models/UpgradeCard.swift:453 | .stageStartAnteCash(multiplierPercent: 400) |
| X-Ray Glasses | legendary | reveal | RiggedShoe/Models/UpgradeCard.swift:372 | .shoeReveal(.fullXRay) |
| X-Ray Shoe | rare | reveal, shoe | RiggedShoe/Models/UpgradeCard.swift:326 | .shoeReveal(.xRay) |
| Zero Drain | legendary | shoe | RiggedShoe/Models/UpgradeCard.swift:397 | .removeZeroValueCards(count: 24) |
