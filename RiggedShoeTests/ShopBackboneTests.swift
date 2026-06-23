import XCTest
@testable import RiggedShoe

final class ShopBackboneTests: XCTestCase {
    private var savedRunData: Data?
    private var testUserDefaultsSuiteName: String!
    private var testUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        savedRunData = UserDefaults.standard.data(forKey: RunPersistenceManager.activeRunStorageKeyForTesting)
        RunPersistenceManager.clear()
        let suiteName = "RiggedShoeTests.\(UUID().uuidString)"
        testUserDefaultsSuiteName = suiteName
        testUserDefaults = UserDefaults(suiteName: suiteName)
        testUserDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        RunPersistenceManager.clear()
        if let savedRunData {
            UserDefaults.standard.set(savedRunData, forKey: RunPersistenceManager.activeRunStorageKeyForTesting)
        }
        if let testUserDefaults {
            testUserDefaults.removePersistentDomain(forName: testUserDefaultsSuiteName)
        }
        testUserDefaultsSuiteName = nil
        testUserDefaults = nil
        self.savedRunData = nil
        super.tearDown()
    }

    private func isolatedMetaProgression() -> MetaProgressionManager {
        MetaProgressionManager(userDefaults: testUserDefaults)
    }

    func testContentCatalogCountsAndIdentityAreStable() {
        XCTAssertGreaterThanOrEqual(Modifier.allContent.count, 100)
        XCTAssertEqual(Modifier.productionContent.count, 41)
        XCTAssertEqual(ActiveModifierCatalog.starterIDs.count, 6)
        XCTAssertEqual(ActiveModifierCatalog.regularIDs.count, 28)
        XCTAssertEqual(ActiveModifierCatalog.capstoneIDs.count, 7)
        XCTAssertEqual(Set(ActiveModifierCatalog.activeIDs).count, 41)
        XCTAssertGreaterThanOrEqual(Consumable.allContent.count, 30)
        XCTAssertGreaterThanOrEqual(Attachment.allContent.count, 30)
        XCTAssertEqual(StartingContact.allContacts.count, 6)
        XCTAssertGreaterThanOrEqual(OpponentState.allOpponents.count, 16)
        XCTAssertGreaterThanOrEqual(Boss.allBosses.count, 6)
        XCTAssertGreaterThanOrEqual(TableEvent.allEvents.count, 16)
        XCTAssertEqual(SecondaryObjective.allObjectives.count, 10)
        XCTAssertGreaterThanOrEqual(BossRelic.allRelics.count, 20)
        XCTAssertGreaterThanOrEqual(
            Unlockable.allUnlockables.filter { unlockable in
                if case .futureHook = unlockable.content {
                    return true
                }
                return false
            }.count,
            10
        )

        XCTAssertEqual(Set(Modifier.allContent.map(\.id)).count, Modifier.allContent.count)
        XCTAssertEqual(Set(Modifier.productionContent.map(\.id)), Set(ActiveModifierCatalog.activeIDs))
        XCTAssertEqual(Set(Consumable.allContent.map(\.id)).count, Consumable.allContent.count)
        XCTAssertEqual(Set(Attachment.allContent.map(\.id)).count, Attachment.allContent.count)
        XCTAssertEqual(Set(StartingContact.allContacts.map(\.id)).count, StartingContact.allContacts.count)
        XCTAssertEqual(Set(OpponentState.allOpponents.map(\.id)).count, OpponentState.allOpponents.count)
        XCTAssertEqual(Set(Boss.allBosses.map(\.id)).count, Boss.allBosses.count)
        XCTAssertEqual(Set(TableEvent.allEvents.map(\.id)).count, TableEvent.allEvents.count)
        XCTAssertEqual(Set(BossRelic.allRelics.map(\.id)).count, BossRelic.allRelics.count)
    }

    func testCoreShopTierCurveMatchesRebuildPlan() {
        XCTAssertEqual(ShopState.tier(for: 1, defeatedBosses: 0), 1)
        XCTAssertEqual(ShopState.tier(for: 2, defeatedBosses: 0), 1)
        XCTAssertEqual(ShopState.tier(for: 3, defeatedBosses: 0), 2)
        XCTAssertEqual(ShopState.tier(for: 4, defeatedBosses: 0), 2)
        XCTAssertEqual(ShopState.tier(for: 5, defeatedBosses: 1), 3)
        XCTAssertEqual(ShopState.tier(for: 8, defeatedBosses: 2), 4)
        XCTAssertEqual(ShopState.tier(for: 9, defeatedBosses: 2), 5)
    }

    func testGeneratedShopKeepsFrozenOffersAndCreatesThreeProductionModifierOffers() {
        var generator: SeededRandomGenerator? = SeededRandomGenerator(seed: 99)
        let frozenOffer = ShopOffer(
            kind: .modifier,
            contentID: "banker.commission-dodge",
            priceChips: 3,
            isFrozen: true
        )

        let shop = ShopState.generated(
            stageID: 3,
            ante: 75,
            defeatedBosses: 0,
            frozenOffers: [frozenOffer],
            ownedModifierIDs: ["core.banker-bias"],
            contactBiasTags: StartingContact.tourist.shopBiasTags,
            seededGenerator: &generator
        )

        XCTAssertEqual(shop.offers.count, 3)
        XCTAssertTrue(shop.offers.contains { $0.id == frozenOffer.id && $0.isFrozen })
        XCTAssertTrue(shop.offers.allSatisfy { !$0.contentID.isEmpty })
        XCTAssertTrue(shop.offers.allSatisfy { $0.priceChips >= 0 })
        XCTAssertTrue(shop.offers.allSatisfy { offer in
            offer.kind != .modifier || ActiveModifierCatalog.acquisitionClass(for: offer.contentID) == .regular
        })
    }

    func testStartingContactsResolveTheirStartingContent() {
        for contact in StartingContact.allContacts {
            for modifierID in contact.startingModifiers {
                XCTAssertNotNil(
                    Modifier.definition(id: modifierID),
                    "\(contact.name) references unknown modifier \(modifierID)"
                )
                XCTAssertEqual(ActiveModifierCatalog.acquisitionClass(for: modifierID), .starter)
            }

            for consumableID in contact.startingConsumables {
                XCTAssertNotNil(
                    Consumable.definition(id: consumableID),
                    "\(contact.name) references unknown consumable \(consumableID)"
                )
            }
        }
    }

    func testStagePreviewUsesOpponentEventAndSecondaryObjective() {
        for stage in Stage.allStages {
            let preview = StagePreviewData(stage: stage, handCount: stage.roundLimit)
            XCTAssertEqual(preview.opponentName, stage.opponent.name)
            XCTAssertFalse(preview.opponentStyle.isEmpty)
            XCTAssertFalse(preview.opponentWeakness.isEmpty)
            XCTAssertEqual(preview.primaryObjectiveTitle, stage.teachingObjective?.title ?? "Beat the Table")
            XCTAssertEqual(preview.primaryObjectiveSummary, stage.teachingObjective?.description ?? "Stay solvent through the table.")
            XCTAssertEqual(preview.maxBetCents, stage.stageMaxBetCents)
            XCTAssertEqual(preview.tableRuleDetail, stage.tableEvent.summary)
            XCTAssertEqual(preview.secondaryObjectiveTitle, stage.secondaryObjective.title)
            XCTAssertFalse(preview.secondaryObjectiveReward.isEmpty)
        }
    }

    func testVerticalSliceStartsWithTwoFixedCapStages() {
        let manager = RunManager()

        XCTAssertEqual(manager.stages.map(\.id), [1, 2])
        XCTAssertEqual(manager.startingBankrollCents, VerticalSliceBalance.startingBankrollCents)
        XCTAssertEqual(manager.chips, VerticalSliceBalance.startingChips)
        XCTAssertEqual(manager.heat, VerticalSliceBalance.startingHeat)
        XCTAssertEqual(manager.currentStage.betLimit.allowedBetAmountsCents, [2_500, 5_000, 7_500])
        XCTAssertEqual(manager.currentStage.stageMaxBetCents, 7_500)
    }

    func testStagePayoutRulesReflectNoCommissionNight() {
        let openingStage = Stage.allStages[0]
        XCTAssertEqual(openingStage.tablePayoutRules.payoutLabel(for: .banker), "Pays 0.95:1")
        XCTAssertEqual(openingStage.tablePayoutRules.profitCents(for: .banker, betAmountCents: 5_000), 4_750)

        let noCommissionStage = Stage.allStages[1]
        XCTAssertEqual(noCommissionStage.tableEvent, .noCommissionNight)
        XCTAssertEqual(noCommissionStage.tablePayoutRules.payoutLabel(for: .banker), "Pays 1:1")
        XCTAssertEqual(noCommissionStage.tablePayoutRules.profitCents(for: .banker, betAmountCents: 5_000), 5_000)
        XCTAssertTrue(noCommissionStage.tablePayoutRules.preDealText(for: .banker, betAmountCents: 5_000).contains("Pays 1:1"))
    }

    func testGuidedShoeSetupReplacesTopCardsWithoutChangingShoeSize() {
        var shoe = Shoe(deckCount: 6)
        let startingCount = shoe.cardsRemaining
        let scriptedCards = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .two),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .spades, rank: .three)
        ]

        shoe.placeCardsOnTop(scriptedCards)

        XCTAssertEqual(startingCount, 312)
        XCTAssertEqual(shoe.cardsRemaining, startingCount)
        XCTAssertEqual(shoe.previewCards(limit: 4).map(\.displayText), scriptedCards.map(\.displayText))
    }

    func testSurvivalObjectiveCopyAvoidsPennyThreshold() {
        let manager = RunManager()
        let text = manager.currentStage.teachingObjective?.progressText(
            in: manager,
            bankrollCents: manager.stageStartingBankrollCents
        ) ?? ""

        XCTAssertFalse(text.contains("$0.01"))
        XCTAssertTrue(text.contains("bankroll above $0"))
    }

    func testEarlyModifierShopMechanicTextNamesActualEffects() {
        XCTAssertTrue(Modifier.definition(id: "core.lucky-chip")?.shopMechanicText.contains("Gain 1 Chips") == true)
        XCTAssertTrue(Modifier.definition(id: "banker.banker-anchor")?.shopMechanicText.contains("Refund 10%") == true)
        XCTAssertTrue(Modifier.definition(id: "player.punto-insurance")?.shopMechanicText.contains("Refund 10%") == true)
        XCTAssertTrue(Modifier.definition(id: "economy.interest-ledger")?.shopMechanicText.contains("Gain 25% of ante") == true)
        XCTAssertTrue(Modifier.definition(id: "bet.high-roller")?.shopMechanicText.contains("Maximum legal wager") == true)
    }

    func testBossScheduleAndRelicRewardsAreDeterministic() {
        XCTAssertNil(BossManager.boss(forStageID: 1))
        XCTAssertEqual(BossManager.boss(forStageID: 5)?.name, "Pit Boss")
        XCTAssertEqual(BossManager.boss(forStageID: 8)?.name, "The Inspector")
        XCTAssertEqual(BossManager.boss(forStageID: 10)?.name, "The House")

        let relicRewardIDs = BossReward.productionRewards.compactMap { reward -> String? in
            if case .grantBossRelic(let id) = reward.effect {
                return id
            }
            return nil
        }
        XCTAssertFalse(relicRewardIDs.isEmpty)
        XCTAssertTrue(relicRewardIDs.allSatisfy { BossRelic.definition(id: $0) != nil })
    }

    func testRebuildBossRulesUseVisiblePressureInsteadOfRandomUpgradeDisable() {
        let pitBoss = BossManager.boss(forStageID: 5)
        XCTAssertEqual(pitBoss?.effect.disabledUpgradeCount, 0)
        XCTAssertEqual(pitBoss?.effect.usesPitBossUpgradeDisable, false)
        XCTAssertTrue(pitBoss?.effect.ruleDescriptions.joined(separator: " ").contains("same side 4 times") == true)

        let inspector = BossManager.boss(forStageID: 8)
        XCTAssertEqual(inspector?.effect.usesPitBossUpgradeDisable, false)
        XCTAssertFalse(inspector?.effect.suppressesReveal ?? true)
        let inspectorRules = inspector?.effect.ruleDescriptions.joined(separator: " ") ?? ""
        XCTAssertTrue(inspectorRules.contains("adds 2 Heat"))
        XCTAssertTrue(inspectorRules.contains("opponent a score boost"))

        let house = BossManager.boss(forStageID: 10)
        XCTAssertEqual(house?.effect.disabledUpgradeCount, 0)
        XCTAssertFalse(house?.effect.suppressesReveal ?? true)
        XCTAssertTrue(house?.effect.shufflesAfterEveryRound ?? false)
        XCTAssertTrue(house?.effect.restoresBankerCommission ?? false)
        XCTAssertTrue(house?.effect.capsTiePayoutAtBase ?? false)
        XCTAssertTrue(house?.effect.ruleDescriptions.joined(separator: " ").contains("adapts") == true)
    }

    func testRewardDraftStateTracksBuildFitAndPivotChoices() {
        var generator: SeededRandomGenerator? = SeededRandomGenerator(seed: 20260622)
        let activeModifiers = [
            ModifierInstance(modifierID: "core.banker-bias", level: 2),
            ModifierInstance(modifierID: "banker.house-favorite")
        ]
        let rewards = StageReward.randomDraftChoices(
            count: 3,
            stage: Stage.allStages[2],
            activeModifiers: activeModifiers,
            acquiredUpgrades: [],
            seededGenerator: &generator
        )
        let draft = RewardDraftState.stageDraft(
            stage: Stage.allStages[2],
            rewards: rewards,
            activeModifiers: activeModifiers
        )

        XCTAssertEqual(rewards.count, 3)
        XCTAssertEqual(draft.choices.count, rewards.count)
        XCTAssertTrue(draft.dominantTags.contains(.banker))
        XCTAssertTrue(draft.choices.contains { $0.fitHint == "Fits your current build" || $0.fitHint == "Off-build pivot" })
        XCTAssertEqual(Set(rewards.map(\.name)).count, rewards.count)
    }

    func testRunManagerStageClearsBySolvencyAfterFixedHands() {
        var manager = RunManager()
        manager.currentStageRoundsPlayed = manager.currentRoundLimit
        manager.currentStageOpponentProfitCents = manager.currentStage.anteCents * 10

        XCTAssertTrue(manager.isStageClear(bankrollCents: manager.currentStage.minimumBetCents))
        XCTAssertFalse(manager.isStageClear(bankrollCents: 0))
    }

    func testLegalBetCapsDoNotUseQuarterBankrollLimit() {
        var manager = RunManager()

        XCTAssertEqual(manager.legalBetAmounts(bankrollCents: 25_000), [2_500, 5_000, 7_500])
        XCTAssertEqual(manager.maximumBetCents(bankrollCents: 25_000), 7_500)

        manager.advanceAfterStageClear(bankrollCents: 25_000)
        XCTAssertEqual(manager.legalBetAmounts(bankrollCents: 25_000), [5_000, 10_000])
        XCTAssertEqual(manager.maximumBetCents(bankrollCents: 25_000), 10_000)
    }

    func testStageResultSummaryUsesSolvencyClearText() {
        var manager = RunManager()
        manager.startRunPreview()
        manager.startStageBattle()
        manager.currentStageRoundsPlayed = manager.currentRoundLimit
        manager.currentStageOpponentProfitCents = 7_500

        let endingBankroll = manager.stageStartingBankrollCents + 10_000
        manager.evaluateStage(bankrollCents: endingBankroll)

        let result = manager.lastStageResult
        XCTAssertEqual(result?.startingBankrollCents, RunManager.defaultStartingBankrollCents)
        XCTAssertEqual(result?.endingBankrollCents, endingBankroll)
        XCTAssertEqual(result?.bankrollChangeCents, 10_000)
        XCTAssertEqual(result?.scoreMarginCents, 2_500)
        XCTAssertEqual(result?.scoreMarginText, "+25.00 pts")
        XCTAssertEqual(result?.title, "Table Cleared")
        XCTAssertEqual(result?.reasonText, "Cleared by staying solvent after 5 hands.")
    }

    @MainActor
    func testContinuingFromShopStartsNextStageWithCleanBattlePresentation() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.dealRound(allowPresentationLockBypass: true)
        XCTAssertNotNil(viewModel.state.latestRound)

        viewModel.debugInstantStageClear()
        viewModel.continueFromStageResult()
        guard let reward = viewModel.state.pendingStageRewardChoices.first(where: { $0.rebuildEffect == nil })
            ?? viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected a reward draft after stage clear")
            return
        }

        viewModel.selectStageReward(reward)
        XCTAssertEqual(viewModel.state.runManager.flowState, .shop)

        viewModel.continueFromShop()
        XCTAssertEqual(viewModel.state.runManager.stageReached, 2)
        XCTAssertEqual(viewModel.state.runManager.flowState, .stagePreview)
        XCTAssertNil(viewModel.state.latestRound)
        XCTAssertTrue(viewModel.state.history.isEmpty)
        XCTAssertTrue(viewModel.state.roundPresentation.triggerFeedback.isEmpty)
        XCTAssertEqual(viewModel.state.selectedBetAmountCents, viewModel.state.runManager.currentStage.minimumBetCents)
    }

    @MainActor
    func testHeatCapCreatesRecoverableStageStateInsteadOfFailure() {
        var manager = RunManager()
        manager.startRunPreview()
        manager.startStageBattle()
        manager.heat = manager.maxHeat
        manager.currentStageRoundsPlayed = manager.currentRoundLimit

        manager.evaluateStage(bankrollCents: manager.stageStartingBankrollCents)

        XCTAssertEqual(manager.status, .stageCleared)
        XCTAssertEqual(manager.flowState, .stageResult)
        XCTAssertNotEqual(manager.lastStageResult?.failureReason, .heatMaxed)
    }

    @MainActor
    func testGuidedFirstHandConsumesScriptedCardsFromSixDeckShoe() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        XCTAssertEqual(viewModel.state.shoe.cardsRemaining, 312)

        viewModel.dealRound(allowPresentationLockBypass: true)

        XCTAssertEqual(viewModel.state.runManager.currentStageRoundsPlayed, 1)
        XCTAssertEqual(viewModel.state.shoe.cardsRemaining, 308)
        XCTAssertEqual(viewModel.state.latestRound?.playerHand.cards.count, 2)
        XCTAssertEqual(viewModel.state.latestRound?.bankerHand.cards.count, 2)
    }

    @MainActor
    func testDuplicateDealCallsAreIgnoredUntilPresentationCompletes() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()

        viewModel.dealRound()
        let firstRoundID = viewModel.state.latestRound?.id
        let roundsAfterFirstDeal = viewModel.state.runManager.currentStageRoundsPlayed
        let shoeCountAfterFirstDeal = viewModel.state.shoe.cardsRemaining

        viewModel.dealRound()

        XCTAssertTrue(viewModel.isDealResolutionLocked)
        XCTAssertEqual(viewModel.state.latestRound?.id, firstRoundID)
        XCTAssertEqual(viewModel.state.runManager.currentStageRoundsPlayed, roundsAfterFirstDeal)
        XCTAssertEqual(viewModel.state.shoe.cardsRemaining, shoeCountAfterFirstDeal)

        viewModel.completeDealPresentation(for: UUID())
        XCTAssertTrue(viewModel.isDealResolutionLocked)

        viewModel.completeDealPresentation(for: firstRoundID)
        XCTAssertFalse(viewModel.isDealResolutionLocked)
    }

    @MainActor
    func testTwoStageRouteCompletesForRepresentativeArchetypeContacts() {
        let contacts: [StartingContact] = [
            .bankerBias,
            .playerSurge,
            .openingTell
        ]

        for contact in contacts {
            RunPersistenceManager.clear()
            var metaProgression = isolatedMetaProgression()
            metaProgression.markGuidedFirstRunCompleted()
            let viewModel = GameViewModel(metaProgression: metaProgression)

            viewModel.selectStartingContact(contact)
            viewModel.continueFromRunStart()
            viewModel.startStageBattle()
            viewModel.debugInstantStageClear()
            XCTAssertEqual(viewModel.state.runManager.status, .stageCleared, contact.name)

            viewModel.continueFromStageResult()
            guard let reward = viewModel.state.pendingStageRewardChoices.first else {
                XCTFail("Expected Stage 1 reward for \(contact.name)")
                continue
            }
            viewModel.selectStageReward(reward)

            if let offer = viewModel.state.shopState.offers.first,
               viewModel.canBuyShopOffer(offer) {
                viewModel.buyShopOffer(offer)
            }

            viewModel.continueFromShop()
            XCTAssertEqual(viewModel.state.runManager.currentStage.id, 2, contact.name)
            XCTAssertEqual(viewModel.state.runManager.flowState, .stagePreview, contact.name)

            viewModel.startStageBattle()
            viewModel.debugInstantStageClear()
            viewModel.continueFromStageResult()

            XCTAssertEqual(viewModel.state.runManager.status, .completed, contact.name)
            XCTAssertEqual(viewModel.state.runManager.flowState, .runComplete, contact.name)
        }
    }

    @MainActor
    func testFinalStageClearCompletesRunWithoutRewardDraft() {
        RunPersistenceManager.clear()
        var metaProgression = isolatedMetaProgression()
        metaProgression.markGuidedFirstRunCompleted()
        let viewModel = GameViewModel(metaProgression: metaProgression)

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()
        viewModel.continueFromStageResult()

        guard let reward = viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected Stage 1 reward")
            return
        }

        viewModel.selectStageReward(reward)
        viewModel.continueFromShop()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()

        XCTAssertEqual(viewModel.state.runManager.currentStage.id, 2)
        XCTAssertEqual(viewModel.state.runManager.flowState, .stageResult)
        XCTAssertTrue(viewModel.state.pendingStageRewardChoices.isEmpty)

        viewModel.continueFromStageResult()

        XCTAssertEqual(viewModel.state.runManager.status, .completed)
        XCTAssertEqual(viewModel.state.runManager.flowState, .runComplete)
        XCTAssertTrue(viewModel.state.pendingStageRewardChoices.isEmpty)
    }

    @MainActor
    func testStageRewardSelectionIsIdempotentAfterFirstAcceptedTap() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()

        guard let reward = viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected Stage 1 reward")
            return
        }

        viewModel.selectStageReward(reward)
        let bankrollAfterFirstSelection = viewModel.state.bankrollCents
        let chipsAfterFirstSelection = viewModel.state.runManager.chips
        let heatAfterFirstSelection = viewModel.state.runManager.heat
        let activeModifiersAfterFirstSelection = viewModel.state.activeModifiers
        let shopOffersAfterFirstSelection = viewModel.state.shopState.offers

        viewModel.selectStageReward(reward)

        XCTAssertEqual(viewModel.state.bankrollCents, bankrollAfterFirstSelection)
        XCTAssertEqual(viewModel.state.runManager.chips, chipsAfterFirstSelection)
        XCTAssertEqual(viewModel.state.runManager.heat, heatAfterFirstSelection)
        XCTAssertEqual(viewModel.state.activeModifiers, activeModifiersAfterFirstSelection)
        XCTAssertEqual(viewModel.state.shopState.offers, shopOffersAfterFirstSelection)
    }

    @MainActor
    func testBelowMinimumBankrollResolvesInsteadOfDeadEndingBattle() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugSetBankrollForTesting(VerticalSliceBalance.stage1MinimumBetCents - 1)

        XCTAssertEqual(viewModel.state.runManager.status, .failed)
        XCTAssertEqual(viewModel.state.runManager.flowState, .stageResult)
        XCTAssertEqual(viewModel.state.runManager.lastStageResult?.failureReason, .bankrollBusted)
        XCTAssertFalse(viewModel.canDeal)
    }

    @MainActor
    func testFullModifierCapacityBlocksNewShopModifierInsteadOfHiddenBenchOverflow() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())
        let ownedIDs = Array(ActiveModifierCatalog.regularIDs.prefix(VerticalSliceBalance.activeModifierSlots))
        guard let offerID = ActiveModifierCatalog.regularIDs.first(where: { !ownedIDs.contains($0) }) else {
            XCTFail("Expected an unowned production modifier")
            return
        }
        let offer = ShopOffer(kind: .modifier, contentID: offerID, priceChips: 1)

        viewModel.debugSetActiveModifiersForTesting(ownedIDs)
        viewModel.debugSetShopStateForTesting(ShopState(ante: 25, offers: [offer]))

        XCTAssertFalse(viewModel.canBuyShopOffer(offer))
        XCTAssertEqual(viewModel.shopOfferBlockedReason(offer), "Modifier slots full")

        let chipsBeforeRejectedPurchase = viewModel.state.runManager.chips
        viewModel.buyShopOffer(offer)

        XCTAssertEqual(viewModel.state.runManager.chips, chipsBeforeRejectedPurchase)
        XCTAssertEqual(viewModel.state.activeModifiers.map(\.modifierID), ownedIDs)
        XCTAssertTrue(viewModel.state.benchModifiers.isEmpty)
        XCTAssertFalse(viewModel.state.shopState.offers[0].isSoldOut)
    }

    @MainActor
    func testRewardSelectionRestoresToShopWithoutReapplyingReward() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()

        guard let reward = viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected Stage 1 reward")
            return
        }

        viewModel.selectStageReward(reward)
        let restored = GameViewModel(metaProgression: isolatedMetaProgression())

        XCTAssertEqual(restored.state.runManager.flowState, .shop)
        XCTAssertTrue(restored.state.pendingStageRewardChoices.isEmpty)
        XCTAssertEqual(restored.state.bankrollCents, viewModel.state.bankrollCents)
        XCTAssertEqual(restored.state.runManager.chips, viewModel.state.runManager.chips)
        XCTAssertEqual(restored.state.activeModifiers, viewModel.state.activeModifiers)
    }

    @MainActor
    func testPresentationStateAndDisabledWagerReasonsAreStableForTrackA() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()

        XCTAssertEqual(viewModel.presentationState, .guidedOpeningLock)
        XCTAssertEqual(viewModel.disabledWagerReason(for: .banker, amountCents: 2_500), .guidedLock)
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 5_000), .guidedLock)

        viewModel.dealRound()
        guard let roundID = viewModel.state.latestRound?.id else {
            XCTFail("Expected guided hand to resolve")
            return
        }
        XCTAssertEqual(viewModel.presentationState, .resolvingHand(roundID: roundID))

        viewModel.completeDealPresentation(for: roundID)
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 2_500))
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 2_499), .stageUnavailable)
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 7_501), .stageUnavailable)
        viewModel.debugSetBankrollForTesting(3_000)
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 5_000), .insufficientBankroll)

        viewModel.debugInstantStageClear()
        XCTAssertEqual(viewModel.presentationState, .finalHandReview(roundID: roundID))
    }

    @MainActor
    func testGuidedDealRapidActivationResolvesOnceAndLeavesShoeAt308() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()

        viewModel.dealRound()
        viewModel.dealRound()
        viewModel.dealRound()

        XCTAssertEqual(viewModel.state.runManager.currentStageRoundsPlayed, 1)
        XCTAssertEqual(viewModel.state.shoe.cardsRemaining, 308)
        XCTAssertTrue(viewModel.isDealResolutionLocked)
    }

    @MainActor
    func testWagerBoundariesAcrossStageOneAndTwoAndNoQuarterBankrollCap() {
        RunPersistenceManager.clear()
        var metaProgression = isolatedMetaProgression()
        metaProgression.markGuidedFirstRunCompleted()
        let viewModel = GameViewModel(metaProgression: metaProgression)

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()

        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 2_499), .stageUnavailable)
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 2_500))
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 5_000))
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 7_500))
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 7_501), .stageUnavailable)

        viewModel.debugInstantStageClear()
        viewModel.continueFromStageResult()
        selectFirstStageReward(in: viewModel)
        viewModel.continueFromShop()
        viewModel.startStageBattle()

        XCTAssertEqual(viewModel.state.runManager.currentStage.id, 2)
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 4_999), .stageUnavailable)
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 5_000))
        XCTAssertNil(viewModel.disabledWagerReason(for: .player, amountCents: 10_000))
        XCTAssertEqual(viewModel.disabledWagerReason(for: .player, amountCents: 10_001), .stageUnavailable)
        XCTAssertEqual(viewModel.state.runManager.maximumBetCents(bankrollCents: 25_000), 10_000)
    }

    @MainActor
    func testBelowMinimumStageOneAndTwoResolveWithoutDeadBattlePhase() {
        RunPersistenceManager.clear()
        let stageOne = GameViewModel(metaProgression: isolatedMetaProgression())
        stageOne.selectStartingContact(.defaultFloorHost)
        stageOne.continueFromRunStart()
        stageOne.startStageBattle()
        stageOne.debugSetBankrollForTesting(VerticalSliceBalance.stage1MinimumBetCents - 1)

        XCTAssertEqual(stageOne.state.runManager.flowState, .stageResult)
        XCTAssertEqual(stageOne.state.runManager.lastStageResult?.failureReason, .bankrollBusted)
        XCTAssertFalse(stageOne.canDeal)

        RunPersistenceManager.clear()
        var metaProgression = isolatedMetaProgression()
        metaProgression.markGuidedFirstRunCompleted()
        let stageTwo = GameViewModel(metaProgression: metaProgression)
        stageTwo.selectStartingContact(.defaultFloorHost)
        stageTwo.continueFromRunStart()
        stageTwo.startStageBattle()
        stageTwo.debugInstantStageClear()
        stageTwo.continueFromStageResult()
        selectFirstStageReward(in: stageTwo)
        stageTwo.continueFromShop()
        stageTwo.startStageBattle()
        stageTwo.debugSetBankrollForTesting(VerticalSliceBalance.stage2MinimumBetCents - 1)

        XCTAssertEqual(stageTwo.state.runManager.currentStage.id, 2)
        XCTAssertEqual(stageTwo.state.runManager.flowState, .stageResult)
        XCTAssertEqual(stageTwo.state.runManager.lastStageResult?.failureReason, .bankrollBusted)
        XCTAssertFalse(stageTwo.canDeal)
    }

    @MainActor
    func testRestoreCheckpointsDoNotDuplicateDurableEffectsOrTransientPresentation() {
        RunPersistenceManager.clear()
        var metaProgression = isolatedMetaProgression()
        metaProgression.markGuidedFirstRunCompleted()
        let viewModel = GameViewModel(metaProgression: metaProgression)

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        let contactRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(contactRestore.state.runManager.flowState, .stagePreview)
        XCTAssertTrue(contactRestore.state.hasAppliedStartingContact)

        viewModel.startStageBattle()
        viewModel.dealRound()
        let settledRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(settledRestore.state.runManager.currentStageRoundsPlayed, 1)
        XCTAssertNil(settledRestore.state.latestRound)
        XCTAssertTrue(settledRestore.state.history.isEmpty)
        XCTAssertEqual(settledRestore.presentationState, .idle)

        viewModel.debugInstantStageClear()
        let resultRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(resultRestore.state.runManager.flowState, .stageResult)
        XCTAssertEqual(resultRestore.state.runManager.status, .stageCleared)
        XCTAssertNil(resultRestore.state.latestRound)

        viewModel.continueFromStageResult()
        let rewardPreRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(rewardPreRestore.state.runManager.flowState, .rewardDraft)
        XCTAssertFalse(rewardPreRestore.state.pendingStageRewardChoices.isEmpty)

        let chipsBeforeReward = viewModel.state.runManager.chips
        selectFirstStageReward(in: viewModel)
        let rewardPostRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(rewardPostRestore.state.runManager.flowState, .shop)
        XCTAssertEqual(rewardPostRestore.state.runManager.chips, viewModel.state.runManager.chips)
        XCTAssertGreaterThanOrEqual(rewardPostRestore.state.runManager.chips, chipsBeforeReward)
        XCTAssertTrue(rewardPostRestore.state.pendingStageRewardChoices.isEmpty)

        if let frozenOffer = viewModel.state.shopState.offers.first {
            viewModel.toggleFreezeShopOffer(frozenOffer)
            let frozenID = frozenOffer.id
            viewModel.rerollShop()
            let shopRerollRestore = GameViewModel(metaProgression: metaProgression)
            XCTAssertEqual(shopRerollRestore.state.runManager.flowState, .shop)
            XCTAssertEqual(shopRerollRestore.state.shopState.rerollsThisStage, viewModel.state.shopState.rerollsThisStage)
            XCTAssertTrue(shopRerollRestore.state.shopState.offers.contains { offer in
                offer.id == frozenID && offer.isFrozen && !offer.isSoldOut
            })
        }

        if let offer = viewModel.state.shopState.offers.first, viewModel.canBuyShopOffer(offer) {
            let chipsBeforePurchase = viewModel.state.runManager.chips
            viewModel.buyShopOffer(offer)
            let shopPurchaseRestore = GameViewModel(metaProgression: metaProgression)
            XCTAssertEqual(shopPurchaseRestore.state.runManager.chips, viewModel.state.runManager.chips)
            XCTAssertLessThanOrEqual(shopPurchaseRestore.state.runManager.chips, chipsBeforePurchase)
            XCTAssertEqual(shopPurchaseRestore.state.shopState.offers.first?.isSoldOut, true)
        }

        viewModel.continueFromShop()
        let stageTwoPreviewRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(stageTwoPreviewRestore.state.runManager.currentStage.id, 2)
        XCTAssertEqual(stageTwoPreviewRestore.state.runManager.flowState, .stagePreview)
        XCTAssertNil(stageTwoPreviewRestore.state.latestRound)

        viewModel.startStageBattle()
        viewModel.dealRound()
        let stageTwoMidRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(stageTwoMidRestore.state.runManager.currentStage.id, 2)
        XCTAssertEqual(stageTwoMidRestore.state.runManager.flowState, .battle)
        XCTAssertEqual(stageTwoMidRestore.state.runManager.currentStageRoundsPlayed, 1)
        XCTAssertNil(stageTwoMidRestore.state.latestRound)

        viewModel.debugSetBankrollForTesting(VerticalSliceBalance.stage2MinimumBetCents - 1)
        let belowMinimumRestore = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(belowMinimumRestore.state.runManager.flowState, .stageResult)
        XCTAssertEqual(belowMinimumRestore.state.runManager.lastStageResult?.failureReason, .bankrollBusted)
    }

    @MainActor
    func testRunCompleteClearsPersistenceAndReplayStartsFresh() {
        RunPersistenceManager.clear()
        var metaProgression = isolatedMetaProgression()
        metaProgression.markGuidedFirstRunCompleted()
        let viewModel = GameViewModel(metaProgression: metaProgression)

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()
        viewModel.continueFromStageResult()
        selectFirstStageReward(in: viewModel)
        viewModel.continueFromShop()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()

        XCTAssertEqual(viewModel.state.runManager.currentStage.id, 2)
        XCTAssertEqual(viewModel.state.runManager.status, .stageCleared)
        XCTAssertTrue(viewModel.state.pendingStageRewardChoices.isEmpty)

        viewModel.continueFromStageResult()
        XCTAssertEqual(viewModel.state.runManager.status, .completed)
        XCTAssertEqual(viewModel.state.runManager.flowState, .runComplete)
        XCTAssertTrue(viewModel.state.pendingStageRewardChoices.isEmpty)

        let restoredAfterCompletion = GameViewModel(metaProgression: metaProgression)
        XCTAssertEqual(restoredAfterCompletion.state.runManager.flowState, .runStart)
        XCTAssertEqual(restoredAfterCompletion.state.runManager.status, .active)
        XCTAssertEqual(restoredAfterCompletion.state.bankrollCents, VerticalSliceBalance.startingBankrollCents)
        XCTAssertEqual(restoredAfterCompletion.state.runManager.chips, VerticalSliceBalance.startingChips)
        XCTAssertEqual(restoredAfterCompletion.state.runManager.heat, VerticalSliceBalance.startingHeat)
        XCTAssertEqual(restoredAfterCompletion.state.activeModifierSlotLimit, VerticalSliceBalance.activeModifierSlots)

        viewModel.startNewRun()
        XCTAssertEqual(viewModel.state.runManager.flowState, .runStart)
        XCTAssertEqual(viewModel.state.bankrollCents, VerticalSliceBalance.startingBankrollCents)
        XCTAssertEqual(viewModel.state.runManager.chips, VerticalSliceBalance.startingChips)
        XCTAssertEqual(viewModel.state.runManager.heat, VerticalSliceBalance.startingHeat)
        XCTAssertTrue(viewModel.state.pendingStageRewardChoices.isEmpty)
    }

    @MainActor
    func testRewardRestoreAndRapidDoubleSelectApplyOnce() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.debugInstantStageClear()
        viewModel.continueFromStageResult()

        guard let reward = viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected reward")
            return
        }

        viewModel.selectStageReward(reward)
        let bankrollAfterReward = viewModel.state.bankrollCents
        let chipsAfterReward = viewModel.state.runManager.chips
        let activeModifiersAfterReward = viewModel.state.activeModifiers

        viewModel.selectStageReward(reward)
        let restored = GameViewModel(metaProgression: isolatedMetaProgression())
        restored.selectStageReward(reward)

        XCTAssertEqual(restored.state.bankrollCents, bankrollAfterReward)
        XCTAssertEqual(restored.state.runManager.chips, chipsAfterReward)
        XCTAssertEqual(restored.state.activeModifiers, activeModifiersAfterReward)
        XCTAssertEqual(restored.state.runManager.flowState, .shop)
    }

    @MainActor
    func testStructuredLoggerCapturesFocusedStateEvents() {
        RunPersistenceManager.clear()
        let logger = SpyRiggedShoeLogger()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression(), logger: logger)

        viewModel.selectStartingContact(.defaultFloorHost)
        viewModel.continueFromRunStart()
        viewModel.startStageBattle()
        viewModel.selectBetAmount(5_000)
        viewModel.selectBetAmount(4_999)
        viewModel.dealRound()

        let events = logger.records.map(\.event)
        XCTAssertTrue(events.contains(.runStarted))
        XCTAssertTrue(events.contains(.runSaved))
        XCTAssertTrue(events.contains(.contactSelected))
        XCTAssertTrue(events.contains(.stageEntered))
        XCTAssertTrue(events.contains(.wagerRejected))
        XCTAssertTrue(events.contains(.handStarted))
        XCTAssertTrue(events.contains(.handResolved))
        XCTAssertTrue(logger.records.allSatisfy { $0.runID == viewModel.state.runID })
        XCTAssertFalse(logger.records.contains { $0.fields.keys.contains("deck") || $0.fields.keys.contains("shoeCards") })
    }

    func testStageRewardShopAndBossLoopCanAdvanceEndToEnd() {
        var manager = RunManager()
        XCTAssertEqual(manager.flowState, .runStart)

        manager.startRunPreview()
        XCTAssertEqual(manager.flowState, .stagePreview)
        XCTAssertEqual(manager.stagePreviewData.opponentName, Stage.allStages[0].opponent.name)

        manager.startStageBattle()
        XCTAssertEqual(manager.flowState, .battle)

        manager.currentStageRoundsPlayed = manager.currentRoundLimit
        manager.currentStageOpponentProfitCents = 0
        let clearBankroll = manager.stageStartingBankrollCents + manager.currentStage.anteCents
        manager.evaluateStage(bankrollCents: clearBankroll)
        XCTAssertEqual(manager.status, .stageCleared)
        XCTAssertEqual(manager.flowState, .stageResult)
        XCTAssertEqual(manager.lastStageResult?.didWin, true)
        XCTAssertEqual(manager.lastStageResult?.opponentName, Stage.allStages[0].opponent.name)

        manager.showRewardDraft()
        XCTAssertEqual(manager.flowState, .rewardDraft)

        manager.enterShop()
        XCTAssertEqual(manager.flowState, .shop)

        manager.advanceAfterStageClear(bankrollCents: clearBankroll)
        XCTAssertEqual(manager.currentStage.id, 2)
        XCTAssertEqual(manager.flowState, .stagePreview)

        XCTAssertEqual(BossManager.boss(forStageID: 5)?.name, "Pit Boss")
        var bossManager = BossManager()
        bossManager.activeBoss = .pitBoss
        bossManager.defeatActiveBoss(
            acquiredUpgrades: [],
            unlockedRewardNames: Set(BossReward.productionRewards.map(\.name)),
            unlockedUpgradeCards: UpgradeCard.allCards
        )
        XCTAssertEqual(bossManager.pendingBossRewardChoices.count, 3)
        XCTAssertTrue(BossReward.productionRewards.contains { reward in
            if case .grantBossRelic = reward.effect {
                return true
            }
            return false
        })
        XCTAssertTrue(bossManager.pendingBossRewardChoices.allSatisfy { !$0.isLegacyUpgradeReward && !$0.isRetiredForRebalance })
    }

    func testProductionRewardPoolsExcludeLegacyUpgradeRewards() {
        XCTAssertTrue(StageReward.productionRewards.allSatisfy { !$0.isLegacyUpgradeReward && !$0.isRetiredForRebalance })
        XCTAssertTrue(BossReward.productionRewards.allSatisfy { !$0.isLegacyUpgradeReward && !$0.isRetiredForRebalance })
    }

    func testModifierEngineDebugSuitePasses() {
        let results = ModifierEngineDebugTests.runAll()
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(
            results.allSatisfy { $0.contains("OK") },
            "Modifier engine debug failures: \(results.joined(separator: " | "))"
        )
    }

    @MainActor
    func testEveryStartingContactCanStartARunAndApplyIdentity() {
        for contact in StartingContact.allContacts {
            RunPersistenceManager.clear()
            let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())

            XCTAssertEqual(viewModel.state.runManager.flowState, .runStart)
            viewModel.selectStartingContact(contact)
            viewModel.continueFromRunStart()

            XCTAssertEqual(viewModel.state.startingContact.id, contact.id)
            XCTAssertTrue(viewModel.state.hasAppliedStartingContact)
            XCTAssertEqual(viewModel.state.runManager.flowState, .stagePreview)

            for modifierID in contact.startingModifiers.prefix(viewModel.state.activeModifierSlotLimit) {
                XCTAssertTrue(
                    viewModel.state.activeModifiers.contains { $0.modifierID == modifierID },
                    "\(contact.name) did not start with \(modifierID)"
                )
            }

            for consumableID in contact.startingConsumables.prefix(viewModel.state.consumableSlotLimit) {
                XCTAssertTrue(
                    viewModel.state.consumables.contains { $0.id == consumableID },
                    "\(contact.name) did not start with \(consumableID)"
                )
            }

            let expectedBankroll = max(
                5_000,
                RunManager.defaultStartingBankrollCents + contact.bankrollAdjustmentCents
            )
            XCTAssertGreaterThanOrEqual(viewModel.state.bankrollCents, expectedBankroll)
            XCTAssertEqual(viewModel.state.runManager.startingBankrollCents, expectedBankroll)
            XCTAssertGreaterThanOrEqual(viewModel.state.runManager.chips, max(0, 3 + contact.chipsAdjustment))
            XCTAssertGreaterThanOrEqual(viewModel.state.runManager.heat, min(10, max(0, contact.heatAdjustment)))
            XCTAssertLessThanOrEqual(viewModel.state.runManager.heat, viewModel.state.runManager.maxHeat)
        }
    }

    @MainActor
    func testDebugPhase3ChecksIncludeShopFlowActions() {
        RunPersistenceManager.clear()
        let viewModel = GameViewModel(metaProgression: isolatedMetaProgression())
        let summary = viewModel.debugRunPhase3Checks()

        XCTAssertEqual(summary, "Phase 3 checks passed: 14/14")
    }

    @MainActor
    private func selectFirstStageReward(in viewModel: GameViewModel, file: StaticString = #filePath, line: UInt = #line) {
        guard let reward = viewModel.state.pendingStageRewardChoices.first else {
            XCTFail("Expected a pending stage reward", file: file, line: line)
            return
        }

        viewModel.selectStageReward(reward)
    }
}

private final class SpyRiggedShoeLogger: RiggedShoeLogging {
    private(set) var records: [RiggedShoeLogRecord] = []

    func log(_ record: RiggedShoeLogRecord) {
        records.append(record)
    }
}
