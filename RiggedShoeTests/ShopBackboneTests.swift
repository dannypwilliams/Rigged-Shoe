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
        XCTAssertGreaterThanOrEqual(Modifier.allContent.count, 120)
        XCTAssertGreaterThanOrEqual(Consumable.allContent.count, 30)
        XCTAssertGreaterThanOrEqual(Attachment.allContent.count, 30)
        XCTAssertGreaterThanOrEqual(StartingContact.allContacts.count, 12)
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

    func testGeneratedShopKeepsFrozenOffersAndCreatesFourOffers() {
        var generator: SeededRandomGenerator? = SeededRandomGenerator(seed: 99)
        let frozenOffer = ShopOffer(
            kind: .modifier,
            contentID: "core.banker-bias",
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

        XCTAssertEqual(shop.offers.count, 4)
        XCTAssertTrue(shop.offers.contains { $0.id == frozenOffer.id && $0.isFrozen })
        XCTAssertTrue(shop.offers.allSatisfy { !$0.contentID.isEmpty })
        XCTAssertTrue(shop.offers.allSatisfy { $0.priceChips >= 0 })
    }

    func testStartingContactsResolveTheirStartingContent() {
        for contact in StartingContact.allContacts {
            for modifierID in contact.startingModifiers {
                XCTAssertNotNil(
                    Modifier.definition(id: modifierID),
                    "\(contact.name) references unknown modifier \(modifierID)"
                )
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
            XCTAssertEqual(preview.tableRuleDetail, stage.tableEvent.summary)
            XCTAssertEqual(preview.secondaryObjectiveTitle, stage.secondaryObjective.title)
            XCTAssertFalse(preview.secondaryObjectiveReward.isEmpty)
        }
    }

    func testBossScheduleAndRelicRewardsAreDeterministic() {
        XCTAssertNil(BossManager.boss(forStageID: 1))
        XCTAssertEqual(BossManager.boss(forStageID: 5)?.name, "Pit Boss")
        XCTAssertEqual(BossManager.boss(forStageID: 8)?.name, "The Inspector")
        XCTAssertEqual(BossManager.boss(forStageID: 10)?.name, "The House")

        let relicRewardIDs = BossReward.allRewards.compactMap { reward -> String? in
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

    func testRunManagerStageClearComparesPlayerAgainstOpponent() {
        var manager = RunManager()
        manager.currentStageRoundsPlayed = manager.currentRoundLimit
        manager.currentStageOpponentProfitCents = manager.currentStage.anteCents * 10

        XCTAssertFalse(
            manager.isStageClear(bankrollCents: manager.stageStartingBankrollCents),
            "A player who only survives should not clear when the opponent score is far ahead."
        )

        let winningBankroll = manager.stageStartingBankrollCents + manager.currentStageOpponentProfitCents
        XCTAssertTrue(
            manager.isStageClear(bankrollCents: winningBankroll),
            "Player should clear after surviving and matching or beating opponent profit."
        )
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
            unlockedRewardNames: Set(BossReward.allRewards.map(\.name)),
            unlockedUpgradeCards: UpgradeCard.allCards
        )
        XCTAssertEqual(bossManager.pendingBossRewardChoices.count, 3)
        XCTAssertTrue(BossReward.allRewards.contains { reward in
            if case .grantBossRelic = reward.effect {
                return true
            }
            return false
        })
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
}
