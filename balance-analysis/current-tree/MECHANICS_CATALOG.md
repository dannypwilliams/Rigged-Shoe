# Mechanics Catalog

Generated from the current worktree. The simulator parsed modifier, shop, stage, boss, reward, and legacy upgrade source files, then mirrored the live battle flow that is visible from `GameViewModel.swift`.

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

Observed emitted triggers: `stageStarted`, `betPlaced`, `beforeDeal`, `playerWonBet`, `playerLostBet`, `tieOccurred`, `heatGained`, `shopEntered`, `shopRerolled`, `modifierBought`, `modifierSold`, `modifierLeveled`.

Declared but not observed in the live battle flow: `runStarted`, `handStarted`, `cardRevealed`, `cardDrawn`, `handResolved`, `naturalOccurred`, `pairOccurred`, `bossStarted`, `bossDefeated`, `finalHand`, `runEnded`. Modifiers that depend only on these hooks are classified as dead or redesign candidates unless another path activates them.

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
| banker.backroom-banco | Backroom Banco | epic | playerWonBet | banker, heat | 3 | RiggedShoe/Models/ModifierModels.swift:805 | payout bonus up to 45%; costs 1 Heat | emitted |
| banker.banco-battery | Banco Battery | rare | playerWonBet | banker, streak | 2 | RiggedShoe/Models/ModifierModels.swift:802 | bankroll +100% ante | emitted |
| banker.banco-press | Banco Press | uncommon | playerWonBet | banker, betControl | 2 | RiggedShoe/Models/ModifierModels.swift:808 | bankroll +110% ante | emitted |
| banker.banker-anchor | Banker Anchor | common | playerLostBet | banker, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:804 | refund up to 20% | emitted |
| banker.banker-lock | Banker Lock | legendary | playerWonBet | banker, boss | 5 | RiggedShoe/Models/ModifierModels.swift:807 | payout bonus up to 85%; costs 1 Heat | emitted |
| banker.commission-dodge | Commission Dodge | common | playerWonBet | banker, economy | 1 | RiggedShoe/Models/ModifierModels.swift:800 | payout bonus up to 14% | emitted |
| banker.dealers-nod | Dealer's Nod | uncommon | playerWonBet | banker, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:803 | reveals 1 cards | emitted |
| banker.house-favorite | House Favorite | uncommon | playerWonBet | banker, economy | 1 | RiggedShoe/Models/ModifierModels.swift:801 | bankroll +50% ante; chips +2 | emitted |
| banker.loyal-customer | Loyal Customer | rare | playerWonBet | banker, streak | 3 | RiggedShoe/Models/ModifierModels.swift:806 | bankroll +175% ante | emitted |
| bet.careful-hands | Careful Hands | common | playerLostBet | betControl, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:872 | refund up to 25% | emitted |
| bet.flat-better | Flat Better | common | playerWonBet | betControl | 1 | RiggedShoe/Models/ModifierModels.swift:877 | bankroll +55% ante | emitted |
| bet.high-roller | High Roller | rare | playerWonBet | betControl, heat | 2 | RiggedShoe/Models/ModifierModels.swift:874 | payout bonus up to 50%; costs 1 Heat | emitted |
| bet.insurance-marker | Insurance Marker | uncommon | playerLostBet | betControl, comeback | 2 | RiggedShoe/Models/ModifierModels.swift:875 | refund up to 35% | emitted |
| bet.loss-limit | Loss Limit | rare | playerLostBet | betControl, comeback | 3 | RiggedShoe/Models/ModifierModels.swift:876 | refund up to 30% | emitted |
| bet.overbet-permit | Overbet Permit | epic | beforeBet | betControl, heat | 4 | RiggedShoe/Models/ModifierModels.swift:879 | contentModifier(id: "bet.overbet-permit", name: "Overbet Permit", summary: "Temporarily bends bet caps in your favor.", rarity: .epic, tags: [.betControl, .heat], trigger: .beforeBet, effects: [.adjustBetLimit(minCents: nil, maxCents: nil), .gainHeat(amount: 1)], minShopTier: 4, useLimits: [.perStage(1)]), | not emitted |
| bet.parlay-slip | Parlay Slip | rare | playerWonBet | betControl, economy | 3 | RiggedShoe/Models/ModifierModels.swift:878 | chips +2 | emitted |
| bet.press-edge | Press the Edge | uncommon | playerWonBet | betControl, streak | 2 | RiggedShoe/Models/ModifierModels.swift:873 | payout bonus up to 24% | emitted |
| bet.safe-marker | Safe Marker | uncommon | playerLostBet | betControl, comeback | 2 | RiggedShoe/Models/ModifierModels.swift:880 | refund up to 20% | emitted |
| bet.small-ball | Small Ball | common | playerWonBet | betControl, economy | 1 | RiggedShoe/Models/ModifierModels.swift:871 | bankroll +70% ante | emitted |
| boss.boss-bounty | Boss Bounty | rare | bossDefeated | boss, economy | 3 | RiggedShoe/Models/ModifierModels.swift:957 | bankroll +225% ante; chips +4 | not emitted |
| boss.countermeasure | Countermeasure | uncommon | heatGained | boss, heat | 2 | RiggedShoe/Models/ModifierModels.swift:956 | prevents Heat | emitted |
| boss.final-table-pass | Final Table Pass | rare | bossStarted | boss, heat | 3 | RiggedShoe/Models/ModifierModels.swift:954 | contentModifier(id: "boss.final-table-pass", name: "Final Table Pass", summary: "Boss stages begin with lower Heat.", rarity: .rare, tags: [.boss, .heat], trigger: .bossStarted, effects: [.reduceHeat(amount: 1)], minShopTier: 3), | not emitted |
| boss.house-crack | House Crack | legendary | playerWonBet | boss, betControl, heat | 5 | RiggedShoe/Models/ModifierModels.swift:958 | payout bonus up to 75%; costs 1 Heat | emitted |
| boss.inside-job | Inside Job | epic | bossStarted | boss, shoeVision, opponentSabotage | 4 | RiggedShoe/Models/ModifierModels.swift:955 | reveals 4 cards; costs 1 Heat | not emitted |
| control.burn-notice | Burn Notice | common | beforeDeal | shoeControl | 1 | RiggedShoe/Models/ModifierModels.swift:856 | costs 1 Heat | emitted |
| control.card-delay | Card Delay | rare | beforeDeal | shoeControl | 3 | RiggedShoe/Models/ModifierModels.swift:859 | costs 1 Heat | emitted |
| control.control-burn | Control Burn | epic | beforeDeal | shoeControl, heat | 4 | RiggedShoe/Models/ModifierModels.swift:860 | costs 2 Heat | emitted |
| control.dealer-slip | Dealer Slip | uncommon | beforeDeal | shoeControl | 2 | RiggedShoe/Models/ModifierModels.swift:858 | contentModifier(id: "control.dealer-slip", name: "Dealer Slip", summary: "Move the next card deeper into the shoe.", rarity: .uncommon, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardDeeper(positions: 2)], minShopTier: 2, useLimits: [.perStage(1)]), | emitted |
| control.dealers-thumb | Dealer's Thumb | epic | bossStarted | shoeControl, boss | 4 | RiggedShoe/Models/ModifierModels.swift:865 | contentModifier(id: "control.dealers-thumb", name: "Dealer's Thumb", summary: "Before a boss hand, delay the top card.", rarity: .epic, tags: [.shoeControl, .boss], trigger: .bossStarted, effects: [.moveTopCardDeeper(positions: 3)], minShopTier: 4) | not emitted |
| control.discard-favor | Discard Favor | uncommon | beforeDeal | shoeControl, economy | 2 | RiggedShoe/Models/ModifierModels.swift:861 | bankroll +30% ante; costs 1 Heat | emitted |
| control.hot-cut | Hot Cut | legendary | stageStarted | shoeControl, cardSculpting | 5 | RiggedShoe/Models/ModifierModels.swift:864 | costs 2 Heat | emitted |
| control.shoe-pocket | Shoe Pocket | rare | stageStarted | shoeControl, cardSculpting | 3 | RiggedShoe/Models/ModifierModels.swift:862 | costs 1 Heat | emitted |
| control.slipstream | Slipstream | rare | beforeDeal | shoeControl, shoeVision | 3 | RiggedShoe/Models/ModifierModels.swift:863 | reveals 1 cards | emitted |
| control.soft-cut | Soft Cut | common | beforeDeal | shoeControl | 1 | RiggedShoe/Models/ModifierModels.swift:857 | contentModifier(id: "control.soft-cut", name: "Soft Cut", summary: "Move the top card to the bottom.", rarity: .common, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardToBottom], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| core.banker-bias | Banker Bias | common | playerWonBet | banker, betControl | 1 | RiggedShoe/Models/ModifierModels.swift:590 | payout bonus up to 25%; chips +1 | emitted |
| core.clean-hands | Clean Hands | common | heatGained | heat | 1 | RiggedShoe/Models/ModifierModels.swift:590 | chips +1; prevents Heat | emitted |
| core.lucky-chip | Lucky Chip | common | playerWonBet | economy | 1 | RiggedShoe/Models/ModifierModels.swift:590 | bankroll +50% ante; chips +2 | emitted |
| core.opening-tell | Opening Tell | rare | stageStarted | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:590 | reveals 5 cards | emitted |
| core.player-surge | Player Surge | common | playerWonBet | player, tempo | 1 | RiggedShoe/Models/ModifierModels.swift:590 | bankroll +200% ante; chips +1 | emitted |
| core.tie-insurance | Tie Insurance | common | playerLostBet | tie, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:590 | refund up to 70% | emitted |
| counter.countertrend-plus | Countertrend+ | uncommon | playerWonBet | player, comeback | 2 | RiggedShoe/Models/ModifierModels.swift:945 | bankroll +125% ante | emitted |
| counter.false-read | False Read | common | playerLostBet | comeback, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:944 | refund up to 10%; reveals 1 cards | emitted |
| counter.mirror-punish | Mirror Punish | rare | playerWonBet | comeback, betControl | 3 | RiggedShoe/Models/ModifierModels.swift:946 | bankroll +150% ante; chips +1 | emitted |
| counter.reverse-count | Reverse Count | uncommon | cardDrawn | comeback, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:947 | contentModifier(id: "counter.reverse-count", name: "Reverse Count", summary: "Card draws after losses improve your next read.", rarity: .uncommon, tags: [.comeback, .shoeVision], trigger: .cardDrawn, effects: [.custom(id: "reverse-count", description: "Logged the drawn card for comeback reads.")], minShopTier: 2), | not emitted |
| counter.turnaround-table | Turnaround Table | epic | playerWonBet | comeback, economy | 4 | RiggedShoe/Models/ModifierModels.swift:948 | bankroll +100% ante; chips +2 | emitted |
| debt.credit-line | Credit Line | epic | bossStarted | economy, boss, heat | 4 | RiggedShoe/Models/ModifierModels.swift:967 | bankroll +200% ante | not emitted |
| debt.debt-collector | Debt Collector | rare | shopEntered | economy, heat | 3 | RiggedShoe/Models/ModifierModels.swift:965 | chips +2 | emitted |
| debt.emergency-marker | Emergency Marker | common | stageStarted | economy, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:964 | bankroll +50% ante | emitted |
| debt.last-dollar | Last Dollar | uncommon | playerLostBet | comeback, economy | 2 | RiggedShoe/Models/ModifierModels.swift:966 | chips +1; refund up to 60% | emitted |
| debt.marker-chain | Marker Chain | uncommon | modifierBought | economy | 2 | RiggedShoe/Models/ModifierModels.swift:968 | bankroll +25% ante | emitted |
| economy.boss-bonus | Boss Bonus | rare | bossDefeated | economy, boss | 3 | RiggedShoe/Models/ModifierModels.swift:892 | chips +5 | not emitted |
| economy.chip-stipend | Chip Stipend | epic | stageStarted | economy | 4 | RiggedShoe/Models/ModifierModels.swift:894 | chips +3 | emitted |
| economy.comp-points | Comp Points | common | playerWonBet | economy | 1 | RiggedShoe/Models/ModifierModels.swift:891 | bankroll +80% ante | emitted |
| economy.coupon-book | Coupon Book | uncommon | shopEntered | economy | 2 | RiggedShoe/Models/ModifierModels.swift:893 | contentModifier(id: "economy.coupon-book", name: "Coupon Book", summary: "Shop entries grant a small discount effect.", rarity: .uncommon, tags: [.economy], trigger: .shopEntered, effects: [.addShopDiscount(percent: 10)], minShopTier: 2), | emitted |
| economy.duplicate-finder | Duplicate Finder | rare | modifierBought | economy | 3 | RiggedShoe/Models/ModifierModels.swift:889 | contentModifier(id: "economy.duplicate-finder", name: "Duplicate Finder", summary: "Buying modifiers helps find copies.", rarity: .rare, tags: [.economy], trigger: .modifierBought, effects: [.custom(id: "duplicate-finder", description: "Future shops bias toward owned modifiers.")], minShopTier: 3), | emitted |
| economy.freeze-discount | Freeze Discount | common | shopEntered | economy | 1 | RiggedShoe/Models/ModifierModels.swift:888 | contentModifier(id: "economy.freeze-discount", name: "Freeze Discount", summary: "Shop entry discounts prices by 5%.", rarity: .common, tags: [.economy], trigger: .shopEntered, effects: [.addShopDiscount(percent: 5)], minShopTier: 1), | emitted |
| economy.interest-ledger | Interest Ledger | common | stageStarted | economy | 1 | RiggedShoe/Models/ModifierModels.swift:886 | bankroll +100% ante | emitted |
| economy.sellback | Sellback | uncommon | modifierSold | economy | 2 | RiggedShoe/Models/ModifierModels.swift:890 | chips +1 | emitted |
| economy.shop-regular | Shop Regular | uncommon | shopRerolled | economy | 2 | RiggedShoe/Models/ModifierModels.swift:887 | contentModifier(id: "economy.shop-regular", name: "Shop Regular", summary: "Rerolls become easier to afford.", rarity: .uncommon, tags: [.economy], trigger: .shopRerolled, effects: [.addRerollDiscount(chips: 1)], minShopTier: 2), | emitted |
| final.closer | Closer | common | finalHand | streak, betControl | 1 | RiggedShoe/Models/ModifierModels.swift:984 | bankroll +125% ante | not emitted |
| final.crown-hand | Crown Hand | epic | finalHand | boss, economy | 4 | RiggedShoe/Models/ModifierModels.swift:987 | bankroll +100% ante; chips +3 | not emitted |
| final.house-breaker | House Breaker | legendary | finalHand | boss, betControl, heat | 5 | RiggedShoe/Models/ModifierModels.swift:988 | payout bonus up to 60% | not emitted |
| final.last-look | Last Look | rare | finalHand | shoeVision, streak | 3 | RiggedShoe/Models/ModifierModels.swift:986 | reveals 4 cards | not emitted |
| final.redemption-hand | Redemption Hand | uncommon | finalHand | comeback | 2 | RiggedShoe/Models/ModifierModels.swift:985 | refund up to 55% | not emitted |
| heat.backroom-pass | Backroom Pass | rare | bossStarted | heat, boss | 3 | RiggedShoe/Models/ModifierModels.swift:903 | contentModifier(id: "heat.backroom-pass", name: "Backroom Pass", summary: "Boss tables begin with reduced Heat.", rarity: .rare, tags: [.heat, .boss], trigger: .bossStarted, effects: [.reduceHeat(amount: 2)], minShopTier: 3), | not emitted |
| heat.camera-blindspot | Camera Blindspot | epic | heatGained | heat, boss | 4 | RiggedShoe/Models/ModifierModels.swift:907 | prevents Heat | emitted |
| heat.cool-customer | Cool Customer | legendary | playerWonBet | heat, economy | 5 | RiggedShoe/Models/ModifierModels.swift:908 | chips +1 | emitted |
| heat.floor-distraction | Floor Distraction | uncommon | heatGained | heat, opponentSabotage | 2 | RiggedShoe/Models/ModifierModels.swift:901 | prevents Heat | emitted |
| heat.low-profile | Low Profile | common | stageStarted | heat | 1 | RiggedShoe/Models/ModifierModels.swift:900 | contentModifier(id: "heat.low-profile", name: "Low Profile", summary: "Reduce Heat at stage start.", rarity: .common, tags: [.heat], trigger: .stageStarted, effects: [.reduceHeat(amount: 1)], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| heat.pit-boss-bribe | Pit Boss Bribe | epic | bossStarted | heat, opponentSabotage | 4 | RiggedShoe/Models/ModifierModels.swift:904 | contentModifier(id: "heat.pit-boss-bribe", name: "Pit Boss Bribe", summary: "Spend stealth to suppress opponent pressure.", rarity: .epic, tags: [.heat, .opponentSabotage], trigger: .bossStarted, effects: [.suppressOpponentTags([.boss])], minShopTier: 4), | not emitted |
| heat.quiet-dealer | Quiet Dealer | rare | heatGained | heat, shoeControl | 3 | RiggedShoe/Models/ModifierModels.swift:902 | prevents Heat | emitted |
| heat.soft-footsteps | Soft Footsteps | common | heatGained | heat | 1 | RiggedShoe/Models/ModifierModels.swift:905 | prevents Heat | emitted |
| heat.surveillance-loop | Surveillance Loop | rare | bossStarted | heat, shoeVision | 3 | RiggedShoe/Models/ModifierModels.swift:906 | contentModifier(id: "heat.surveillance-loop", name: "Surveillance Loop", summary: "Reveal suppression hurts less.", rarity: .rare, tags: [.heat, .shoeVision], trigger: .bossStarted, effects: [.custom(id: "surveillance-loop", description: "Boss reveal suppression is logged and softened.")], minShopTier: 3), | not emitted |
| loaded.add-nine | Add Nine | common | stageStarted | cardSculpting, shoeControl | 1 | RiggedShoe/Models/ModifierModels.swift:934 | contentModifier(id: "loaded.add-nine", name: "Add Nine", summary: "Add a 9 to the current shoe at stage start.", rarity: .common, tags: [.cardSculpting, .shoeControl], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 1, useLimits: [.perStage(1)]), | emitted |
| loaded.eight-stack | Eight Stack+ | rare | stageStarted | cardSculpting, shoeControl | 3 | RiggedShoe/Models/ModifierModels.swift:937 | contentModifier(id: "loaded.eight-stack", name: "Eight Stack+", summary: "Add 8s and improve Tie/Banker texture.", rarity: .rare, tags: [.cardSculpting, .shoeControl], trigger: .stageStarted, effects: [.addCards(ranks: [.eight], count: 2)], minShopTier: 3, useLimits: [.perStage(1)]), | emitted |
| loaded.marked-nine | Marked Nine | uncommon | stageStarted | cardSculpting, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:935 | reveals 1 cards; costs 1 Heat | emitted |
| loaded.nine-engine | Nine Engine | legendary | stageStarted | cardSculpting, boss | 5 | RiggedShoe/Models/ModifierModels.swift:938 | reveals 3 cards; costs 2 Heat | emitted |
| loaded.nine-worship | Nine Worship | rare | stageStarted | cardSculpting, natural, economy | 3 | RiggedShoe/Models/ModifierModels.swift:936 | bankroll +50% ante | emitted |
| natural.natural-bonus | Natural Bonus | uncommon | naturalOccurred | natural, economy | 2 | RiggedShoe/Models/ModifierModels.swift:915 | bankroll +110% ante | not emitted |
| natural.natural-comp | Natural Comp | rare | naturalOccurred | natural, economy | 3 | RiggedShoe/Models/ModifierModels.swift:917 | bankroll +75% ante; chips +2 | not emitted |
| natural.natural-read | Natural Read | common | naturalOccurred | natural, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:914 | reveals 1 cards | not emitted |
| natural.perfect-nine | Perfect Nine | legendary | naturalOccurred | natural, boss, cardSculpting | 5 | RiggedShoe/Models/ModifierModels.swift:918 | bankroll +325% ante; costs 1 Heat | not emitted |
| natural.snap-nine | Snap Nine | rare | naturalOccurred | natural, cardSculpting | 3 | RiggedShoe/Models/ModifierModels.swift:916 | contentModifier(id: "natural.snap-nine", name: "Snap Nine", summary: "Natural pressure adds 9s to future shoes.", rarity: .rare, tags: [.natural, .cardSculpting], trigger: .naturalOccurred, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]), | not emitted |
| pair.matchbook | Matchbook | uncommon | pairOccurred | pair, economy | 2 | RiggedShoe/Models/ModifierModels.swift:926 | chips +1 | not emitted |
| pair.pair-hunter | Pair Hunter | common | pairOccurred | pair, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:924 | bankroll +20% ante; reveals 1 cards | not emitted |
| pair.split-pocket | Split Pocket | rare | pairOccurred | pair, cardSculpting | 3 | RiggedShoe/Models/ModifierModels.swift:927 | contentModifier(id: "pair.split-pocket", name: "Split Pocket", summary: "Pairs slip one matching-value plan into the shoe.", rarity: .rare, tags: [.pair, .cardSculpting], trigger: .pairOccurred, effects: [.addCards(ranks: [.eight, .nine], count: 1)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]), | not emitted |
| pair.twin-engine | Twin Engine | epic | pairOccurred | pair, economy, streak | 4 | RiggedShoe/Models/ModifierModels.swift:928 | bankroll +125% ante; chips +3 | not emitted |
| pair.twin-signal | Twin Signal | uncommon | pairOccurred | pair, tie, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:925 | reveals 2 cards | not emitted |
| player.break-pattern | Break the Pattern | epic | playerWonBet | player, boss | 4 | RiggedShoe/Models/ModifierModels.swift:819 | payout bonus up to 55% | emitted |
| player.countertrend | Countertrend | common | playerWonBet | player, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:817 | bankroll +150% ante | emitted |
| player.player-tempo | Player Tempo | uncommon | playerWonBet | player, economy | 2 | RiggedShoe/Models/ModifierModels.swift:822 | bankroll +75% ante; chips +1 | emitted |
| player.punto-insurance | Punto Insurance | common | playerLostBet | player, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:820 | refund up to 45% | emitted |
| player.punto-strike | Punto Strike | rare | playerWonBet | player, tempo | 2 | RiggedShoe/Models/ModifierModels.swift:816 | bankroll +160% ante | emitted |
| player.reversal-read | Reversal Read | uncommon | playerWonBet | player, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:814 | payout bonus up to 32% | emitted |
| player.sharp-turn | Sharp Turn | uncommon | playerWonBet | player, economy | 2 | RiggedShoe/Models/ModifierModels.swift:818 | chips +1 | emitted |
| player.side-step | Side Step | common | playerWonBet | player, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:815 | reveals 1 cards | emitted |
| player.underdog-side | Underdog Side | rare | playerWonBet | player, heat | 3 | RiggedShoe/Models/ModifierModels.swift:821 | payout bonus up to 46%; costs 1 Heat | emitted |
| sabotage.cold-read | Cold Read | epic | bossStarted | opponentSabotage, boss | 4 | RiggedShoe/Models/ModifierModels.swift:976 | contentModifier(id: "sabotage.cold-read", name: "Cold Read", summary: "Boss starts suppress one hostile tag.", rarity: .epic, tags: [.opponentSabotage, .boss], trigger: .bossStarted, effects: [.suppressOpponentTags([.boss])], minShopTier: 4), | not emitted |
| sabotage.house-static | House Static | rare | heatGained | opponentSabotage, heat | 3 | RiggedShoe/Models/ModifierModels.swift:978 | prevents Heat | emitted |
| sabotage.opponent-tax | Opponent Tax | rare | stageStarted | opponentSabotage, economy | 3 | RiggedShoe/Models/ModifierModels.swift:975 | bankroll +40% ante | emitted |
| sabotage.table-chat | Table Chat | common | handStarted | opponentSabotage | 1 | RiggedShoe/Models/ModifierModels.swift:977 | contentModifier(id: "sabotage.table-chat", name: "Table Chat", summary: "Hand starts occasionally distract the table.", rarity: .common, tags: [.opponentSabotage], trigger: .handStarted, effects: [.custom(id: "table-chat", description: "Opponent tell noted in the battle log.")], minShopTier: 1, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]), | not emitted |
| sabotage.tempo-theft | Tempo Theft | uncommon | shopRerolled | opponentSabotage, economy | 2 | RiggedShoe/Models/ModifierModels.swift:974 | contentModifier(id: "sabotage.tempo-theft", name: "Tempo Theft", summary: "Shop rerolls pressure opponents and refund a Chip later.", rarity: .uncommon, tags: [.opponentSabotage, .economy], trigger: .shopRerolled, effects: [.custom(id: "tempo-theft", description: "Next opponent scoring burst is softened.")], minShopTier: 2), | emitted |
| tie.dead-heat | Dead Heat | rare | playerWonBet | tie, economy | 3 | RiggedShoe/Models/ModifierModels.swift:832 | bankroll +325% ante | emitted |
| tie.equalizer | Equalizer | rare | playerWonBet | tie, economy | 2 | RiggedShoe/Models/ModifierModels.swift:829 | bankroll +250% ante; chips +3 | emitted |
| tie.final-hand-tie | Final Hand Tie | epic | finalHand | tie, comeback | 4 | RiggedShoe/Models/ModifierModels.swift:835 | refund up to 50% | not emitted |
| tie.jackpot-discipline | Jackpot Discipline | uncommon | playerLostBet | tie, comeback | 2 | RiggedShoe/Models/ModifierModels.swift:836 | refund up to 60% | emitted |
| tie.longshot-ledger | Longshot Ledger | epic | playerWonBet | tie, betControl | 3 | RiggedShoe/Models/ModifierModels.swift:830 | payout bonus up to 100% | emitted |
| tie.mirror-bet | Mirror Bet | common | playerLostBet | tie, comeback | 1 | RiggedShoe/Models/ModifierModels.swift:833 | refund up to 18% | emitted |
| tie.split-signal | Split Signal | uncommon | tieOccurred | tie, shoeVision | 2 | RiggedShoe/Models/ModifierModels.swift:831 | reveals 2 cards | emitted |
| tie.tie-master | Tie Master | legendary | playerWonBet | tie, economy | 5 | RiggedShoe/Models/ModifierModels.swift:834 | bankroll +200% ante; chips +5 | emitted |
| tie.tie-whisperer | Tie Whisperer | common | playerLostBet | tie, shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:828 | reveals 1 cards | emitted |
| vision.banker-forecast | Banker Forecast | rare | playerWonBet | shoeVision, banker | 3 | RiggedShoe/Models/ModifierModels.swift:848 | bankroll +130% ante | emitted |
| vision.boss-scout | Boss Scout | epic | bossStarted | shoeVision, boss | 4 | RiggedShoe/Models/ModifierModels.swift:850 | reveals 5 cards | not emitted |
| vision.dealer-glance | Dealer Glance | common | stageStarted | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:842 | reveals 1 cards | emitted |
| vision.deep-read | Deep Read | rare | stageStarted | shoeVision | 3 | RiggedShoe/Models/ModifierModels.swift:844 | reveals 4 cards | emitted |
| vision.face-down-count | Face Down Count | common | cardDrawn | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:846 | contentModifier(id: "vision.face-down-count", name: "Face Down Count", summary: "Card draws create compact shoe knowledge.", rarity: .common, tags: [.shoeVision], trigger: .cardDrawn, effects: [.custom(id: "count-card", description: "Logged one drawn card for the counter.")], minShopTier: 1), | not emitted |
| vision.pattern-memory | Pattern Memory | uncommon | playerWonBet | shoeVision, economy | 2 | RiggedShoe/Models/ModifierModels.swift:845 | bankroll +20% ante; reveals 1 cards | emitted |
| vision.soft-peek | Soft Peek | common | stageStarted | shoeVision | 1 | RiggedShoe/Models/ModifierModels.swift:843 | reveals 2 cards | emitted |
| vision.third-card-forecast | Third Card Forecast | epic | stageStarted | shoeVision | 4 | RiggedShoe/Models/ModifierModels.swift:847 | reveals 5 cards | emitted |
| vision.tie-forecast | Tie Forecast | rare | betPlaced | shoeVision, tie | 3 | RiggedShoe/Models/ModifierModels.swift:849 | reveals 3 cards | emitted |

## Legacy Upgrade Cards

Legacy per-hand upgrade drafts are disabled by `shouldOfferLegacyShoeUpgradeDrafts == false`, but stage/boss rewards can still add random legacy upgrades. These remain cataloged because they are implemented and reachable.

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
