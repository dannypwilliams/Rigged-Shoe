import Foundation

struct SavedRunManagerState: Codable, Equatable {
    var startingBankrollCents: Int
    var flowState: String?
    var stageStartingBankrollCents: Int?
    var currentStageStartingHeat: Int?
    var currentStageStartingChips: Int?
    var currentStageIndex: Int
    var currentStageRoundsPlayed: Int
    var currentStageWinningBets: Int?
    var currentStageUpgradeTriggers: Int?
    var currentStageRevealWins: Int?
    var currentStageUpgradeInfluencedWins: Int?
    var currentStageLosses: Int?
    var currentStageMinimumBankrollCents: Int?
    var currentStageBiggestWinCents: Int?
    var currentStageBiggestLossCents: Int?
    var currentStageOpponentProfitCents: Int?
    var currentStageWinningBetTypes: [BetType]?
    var currentStageLastWinner: BetType?
    var currentStageFinalHandWon: Bool?
    var currentStageFellBehindOpponent: Bool?
    var currentStageStayedUnderQuarterBankroll: Bool?
    var currentStageConsumablesUsed: Int?
    var totalRoundsPlayed: Int
    var playerWins: Int
    var bankerWins: Int
    var tieResults: Int
    var highestBankrollCents: Int
    var highestProfitCents: Int
    var tiePayoutBonus: Int
    var tiePayoutOverride: Int?
    var permanentRevealCount: Int
    var playerBonusMultiplier: Int
    var bankerBonusMultiplier: Int
    var futureStageRoundBonus: Int
    var chips: Int?
    var heat: Int?
    var maxHeat: Int?
    var lastStageResult: StageResultData?
    var status: String
}

struct SavedBossManagerState: Codable, Equatable {
    var pendingAnnouncementBossID: Int?
    var activeBossID: Int?
    var lastDefeatedBossID: Int?
    var defeatedBossIDs: [Int]
    var pendingBossRewardNames: [String]
}

struct SavedRunState: Codable, Equatable {
    var version: Int
    var savedAt: Date
    var runID: UUID?
    var bankrollCents: Int
    var selectedBetType: BetType
    var selectedBetAmountCents: Int
    var shoeCards: [Card]
    var acquiredUpgradeNames: [String]
    var pendingUpgradeNames: [String]
    var pendingStageRewardNames: [String]
    var roundsSinceLastUpgrade: Int
    var runManager: SavedRunManagerState
    var bossManager: SavedBossManagerState
    var chipRewardMultiplierPercent: Int
    var metaChipsEarnedThisRun: Int
    var metaReputationEarnedThisRun: Int
    var didRecordRunEnd: Bool
    var challengeID: ChallengeModeID
    var isDailyRun: Bool
    var dailySeed: UInt64?
    var seededGenerator: SeededRandomGenerator?
    var themeID: CasinoThemeID
    var playerWinStreak: Int
    var bankerWinStreak: Int
    var tieStreak: Int
    var previousRoundLossCents: Int
    var hasPaidFirstTieThisStage: Bool
    var hasUsedSafetyNetThisStage: Bool?
    var hasUsedHighRollerSparkThisStage: Bool?
    var hasPaidFaceHunterThisStage: Bool?
    var damageControlHandsSinceUse: Int?
    var burnControlUses: Int?
    var smallBetWinStreak: Int?
    var consecutiveLosses: Int?
    var lastRoundDidWin: Bool?
    var lastBetAmountCents: Int?
    var hasMovedCardThisStage: Bool?
    var xRayChargesRemainingThisStage: Int?
    var isXRayActiveForNextHand: Bool?
    var isGuidedFirstRun: Bool
    var guidedExcitingWinDelivered: Bool
    var hasOfferedGuidedUpgrade: Bool
    var runStartedAt: Date
    var startingContactID: String?
    var hasAppliedStartingContact: Bool?
    var shopState: ShopState?
    var activeModifiers: [ModifierInstance]?
    var benchModifiers: [ModifierInstance]?
    var consumableIDs: [String]?
    var attachmentIDs: [String]?
    var bossRelicIDs: [String]?
}

struct RunPersistenceManager {
    private static let storageKey = "riggedShoe.activeRun.v2"
    private static let corruptStorageKey = "riggedShoe.activeRun.corruptBackup.v1"
    private static let currentVersion = 7

    #if DEBUG
    static var activeRunStorageKeyForTesting: String {
        storageKey
    }
    #endif

    static func save(_ state: GameState) {
        guard state.runManager.status != .completed else {
            clear()
            return
        }

        guard let data = try? JSONEncoder().encode(snapshot(from: state)) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    static func restore(configuration: RunConfiguration) -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }

        guard let snapshot = try? JSONDecoder().decode(SavedRunState.self, from: data),
              snapshot.version <= currentVersion else {
            UserDefaults.standard.set(data, forKey: corruptStorageKey)
            UserDefaults.standard.removeObject(forKey: storageKey)
            return nil
        }

        return restore(snapshot, configuration: configuration)
    }

    private static func snapshot(from state: GameState) -> SavedRunState {
        SavedRunState(
            version: currentVersion,
            savedAt: Date(),
            runID: state.runID,
            bankrollCents: state.bankrollCents,
            selectedBetType: state.selectedBetType,
            selectedBetAmountCents: state.selectedBetAmountCents,
            shoeCards: state.shoe.cards,
            acquiredUpgradeNames: [],
            pendingUpgradeNames: [],
            pendingStageRewardNames: state.pendingStageRewardChoices
                .filter { !$0.isRetiredForRebalance }
                .map(\.name),
            roundsSinceLastUpgrade: state.roundsSinceLastUpgrade,
            runManager: SavedRunManagerState(
                startingBankrollCents: state.runManager.startingBankrollCents,
                flowState: state.runManager.flowState.rawValue,
                stageStartingBankrollCents: state.runManager.stageStartingBankrollCents,
                currentStageStartingHeat: state.runManager.currentStageStartingHeat,
                currentStageStartingChips: state.runManager.currentStageStartingChips,
                currentStageIndex: state.runManager.currentStageIndex,
                currentStageRoundsPlayed: state.runManager.currentStageRoundsPlayed,
                currentStageWinningBets: state.runManager.currentStageWinningBets,
                currentStageUpgradeTriggers: state.runManager.currentStageUpgradeTriggers,
                currentStageRevealWins: state.runManager.currentStageRevealWins,
                currentStageUpgradeInfluencedWins: state.runManager.currentStageUpgradeInfluencedWins,
                currentStageLosses: state.runManager.currentStageLosses,
                currentStageMinimumBankrollCents: state.runManager.currentStageMinimumBankrollCents,
                currentStageBiggestWinCents: state.runManager.currentStageBiggestWinCents,
                currentStageBiggestLossCents: state.runManager.currentStageBiggestLossCents,
                currentStageOpponentProfitCents: state.runManager.currentStageOpponentProfitCents,
                currentStageWinningBetTypes: Array(state.runManager.currentStageWinningBetTypes),
                currentStageLastWinner: state.runManager.currentStageLastWinner,
                currentStageFinalHandWon: state.runManager.currentStageFinalHandWon,
                currentStageFellBehindOpponent: state.runManager.currentStageFellBehindOpponent,
                currentStageStayedUnderQuarterBankroll: state.runManager.currentStageStayedUnderQuarterBankroll,
                currentStageConsumablesUsed: state.runManager.currentStageConsumablesUsed,
                totalRoundsPlayed: state.runManager.totalRoundsPlayed,
                playerWins: state.runManager.playerWins,
                bankerWins: state.runManager.bankerWins,
                tieResults: state.runManager.tieResults,
                highestBankrollCents: state.runManager.highestBankrollCents,
                highestProfitCents: state.runManager.highestProfitCents,
                tiePayoutBonus: state.runManager.tiePayoutBonus,
                tiePayoutOverride: state.runManager.tiePayoutOverride,
                permanentRevealCount: state.runManager.permanentRevealCount,
                playerBonusMultiplier: state.runManager.playerBonusMultiplier,
                bankerBonusMultiplier: state.runManager.bankerBonusMultiplier,
                futureStageRoundBonus: state.runManager.futureStageRoundBonus,
                chips: state.runManager.chips,
                heat: state.runManager.heat,
                maxHeat: state.runManager.maxHeat,
                lastStageResult: state.runManager.lastStageResult,
                status: state.runManager.status.storageValue
            ),
            bossManager: SavedBossManagerState(
                pendingAnnouncementBossID: state.bossManager.pendingAnnouncementBoss?.id,
                activeBossID: state.bossManager.activeBoss?.id,
                lastDefeatedBossID: state.bossManager.lastDefeatedBoss?.id,
                defeatedBossIDs: state.bossManager.defeatedBosses.map(\.id),
                pendingBossRewardNames: state.bossManager.pendingBossRewardChoices
                    .filter { !$0.isRetiredForRebalance }
                    .map(\.name)
            ),
            chipRewardMultiplierPercent: state.chipRewardMultiplierPercent,
            metaChipsEarnedThisRun: state.metaChipsEarnedThisRun,
            metaReputationEarnedThisRun: state.metaReputationEarnedThisRun,
            didRecordRunEnd: state.didRecordRunEnd,
            challengeID: state.challengeID,
            isDailyRun: state.isDailyRun,
            dailySeed: state.dailySeed,
            seededGenerator: state.seededGenerator,
            themeID: state.themeID,
            playerWinStreak: state.playerWinStreak,
            bankerWinStreak: state.bankerWinStreak,
            tieStreak: state.tieStreak,
            previousRoundLossCents: state.previousRoundLossCents,
            hasPaidFirstTieThisStage: state.hasPaidFirstTieThisStage,
            hasUsedSafetyNetThisStage: state.hasUsedSafetyNetThisStage,
            hasUsedHighRollerSparkThisStage: state.hasUsedHighRollerSparkThisStage,
            hasPaidFaceHunterThisStage: state.hasPaidFaceHunterThisStage,
            damageControlHandsSinceUse: state.damageControlHandsSinceUse,
            burnControlUses: state.burnControlUses,
            smallBetWinStreak: state.smallBetWinStreak,
            consecutiveLosses: state.consecutiveLosses,
            lastRoundDidWin: state.lastRoundDidWin,
            lastBetAmountCents: state.lastBetAmountCents,
            hasMovedCardThisStage: state.hasMovedCardThisStage,
            xRayChargesRemainingThisStage: state.xRayChargesRemainingThisStage,
            isXRayActiveForNextHand: state.isXRayActiveForNextHand,
            isGuidedFirstRun: state.isGuidedFirstRun,
            guidedExcitingWinDelivered: state.guidedExcitingWinDelivered,
            hasOfferedGuidedUpgrade: state.hasOfferedGuidedUpgrade,
            runStartedAt: state.runStartedAt,
            startingContactID: state.startingContact.id,
            hasAppliedStartingContact: state.hasAppliedStartingContact,
            shopState: state.shopState,
            activeModifiers: state.activeModifiers,
            benchModifiers: state.benchModifiers,
            consumableIDs: state.consumables.map(\.id),
            attachmentIDs: state.attachments.map(\.id),
            bossRelicIDs: state.bossRelics.map(\.id)
        )
    }

    private static func restore(_ snapshot: SavedRunState, configuration: RunConfiguration) -> GameState {
        var state = GameState(configuration: configuration)
        let legacyChipCompensation = legacyUpgradeChipCompensation(for: snapshot.acquiredUpgradeNames + snapshot.pendingUpgradeNames)
        state.runID = snapshot.runID ?? UUID()
        state.bankrollCents = snapshot.bankrollCents
        state.selectedBetType = snapshot.selectedBetType
        state.selectedBetAmountCents = snapshot.selectedBetAmountCents
        state.shoe = Shoe(deckCount: 6, cards: snapshot.shoeCards)
        state.acquiredUpgrades = []
        state.pendingUpgradeChoices = []
        state.pendingStageRewardChoices = snapshot.pendingStageRewardNames.compactMap(stageReward(named:))
        state.roundsSinceLastUpgrade = snapshot.roundsSinceLastUpgrade
        state.runManager = restoreRunManager(snapshot.runManager)
        state.runManager.chips += legacyChipCompensation
        state.bossManager = restoreBossManager(snapshot.bossManager, acquiredUpgrades: [])
        state.chipRewardMultiplierPercent = snapshot.chipRewardMultiplierPercent
        state.metaChipsEarnedThisRun = snapshot.metaChipsEarnedThisRun
        state.metaReputationEarnedThisRun = snapshot.metaReputationEarnedThisRun
        state.didRecordRunEnd = snapshot.didRecordRunEnd
        state.challengeID = snapshot.challengeID
        state.isDailyRun = snapshot.isDailyRun
        state.dailySeed = snapshot.dailySeed
        state.seededGenerator = snapshot.seededGenerator
        state.themeID = snapshot.themeID
        state.playerWinStreak = snapshot.playerWinStreak
        state.bankerWinStreak = snapshot.bankerWinStreak
        state.tieStreak = snapshot.tieStreak
        state.previousRoundLossCents = snapshot.previousRoundLossCents
        state.hasPaidFirstTieThisStage = snapshot.hasPaidFirstTieThisStage
        state.hasUsedSafetyNetThisStage = snapshot.hasUsedSafetyNetThisStage ?? false
        state.hasUsedHighRollerSparkThisStage = snapshot.hasUsedHighRollerSparkThisStage ?? false
        state.hasPaidFaceHunterThisStage = snapshot.hasPaidFaceHunterThisStage ?? false
        state.damageControlHandsSinceUse = max(0, snapshot.damageControlHandsSinceUse ?? 3)
        state.burnControlUses = max(0, snapshot.burnControlUses ?? 0)
        state.smallBetWinStreak = max(0, snapshot.smallBetWinStreak ?? 0)
        state.consecutiveLosses = max(0, snapshot.consecutiveLosses ?? 0)
        state.lastRoundDidWin = snapshot.lastRoundDidWin ?? false
        state.lastBetAmountCents = max(0, snapshot.lastBetAmountCents ?? 0)
        state.hasMovedCardThisStage = snapshot.hasMovedCardThisStage ?? false
        state.xRayChargesRemainingThisStage = max(0, snapshot.xRayChargesRemainingThisStage ?? 0)
        state.isXRayActiveForNextHand = false
        state.isGuidedFirstRun = snapshot.isGuidedFirstRun
        state.guidedExcitingWinDelivered = snapshot.guidedExcitingWinDelivered
        state.hasOfferedGuidedUpgrade = snapshot.hasOfferedGuidedUpgrade
        state.runStartedAt = snapshot.runStartedAt
        state.startingContact = startingContact(id: snapshot.startingContactID)
        state.hasAppliedStartingContact = snapshot.hasAppliedStartingContact ?? false
        state.shopState = sanitizeShopState(snapshot.shopState ?? ShopState())
        state.activeModifiers = sanitizeModifierInstances(snapshot.activeModifiers ?? [])
        state.benchModifiers = sanitizeModifierInstances(snapshot.benchModifiers ?? [])
        state.consumables = (snapshot.consumableIDs ?? []).compactMap(Consumable.definition(id:))
        state.attachments = (snapshot.attachmentIDs ?? []).compactMap(Attachment.definition(id:))
        state.bossRelics = (snapshot.bossRelicIDs ?? []).compactMap(bossRelic(id:))
        if !state.pendingStageRewardChoices.isEmpty {
            state.rewardDraftState = RewardDraftState.stageDraft(
                stage: state.runManager.currentStage,
                rewards: state.pendingStageRewardChoices,
                activeModifiers: state.activeModifiers
            )
        } else if !state.bossManager.pendingBossRewardChoices.isEmpty {
            state.rewardDraftState = RewardDraftState.bossDraft(
                stage: state.runManager.currentStage,
                rewards: state.bossManager.pendingBossRewardChoices,
                activeModifiers: state.activeModifiers
            )
        }
        return state
    }

    private static func restoreRunManager(_ snapshot: SavedRunManagerState) -> RunManager {
        var manager = RunManager(startingBankrollCents: snapshot.startingBankrollCents)
        manager.flowState = StageFlowState(rawValue: snapshot.flowState ?? "") ?? restoredFlowState(status: snapshot.status)
        manager.stageStartingBankrollCents = max(0, snapshot.stageStartingBankrollCents ?? snapshot.startingBankrollCents)
        manager.currentStageStartingHeat = max(0, snapshot.currentStageStartingHeat ?? 0)
        manager.currentStageStartingChips = max(0, snapshot.currentStageStartingChips ?? 3)
        manager.currentStageIndex = min(max(0, snapshot.currentStageIndex), max(0, manager.stages.count - 1))
        manager.currentStageRoundsPlayed = max(0, snapshot.currentStageRoundsPlayed)
        manager.currentStageWinningBets = max(0, snapshot.currentStageWinningBets ?? 0)
        manager.currentStageUpgradeTriggers = max(0, snapshot.currentStageUpgradeTriggers ?? 0)
        manager.currentStageRevealWins = max(0, snapshot.currentStageRevealWins ?? 0)
        manager.currentStageUpgradeInfluencedWins = max(0, snapshot.currentStageUpgradeInfluencedWins ?? 0)
        manager.currentStageLosses = max(0, snapshot.currentStageLosses ?? 0)
        manager.currentStageMinimumBankrollCents = max(0, snapshot.currentStageMinimumBankrollCents ?? manager.stageStartingBankrollCents)
        manager.currentStageBiggestWinCents = max(0, snapshot.currentStageBiggestWinCents ?? 0)
        manager.currentStageBiggestLossCents = min(0, snapshot.currentStageBiggestLossCents ?? 0)
        manager.currentStageOpponentProfitCents = snapshot.currentStageOpponentProfitCents ?? 0
        manager.currentStageWinningBetTypes = Set(snapshot.currentStageWinningBetTypes ?? [])
        manager.currentStageLastWinner = snapshot.currentStageLastWinner
        manager.currentStageFinalHandWon = snapshot.currentStageFinalHandWon ?? false
        manager.currentStageFellBehindOpponent = snapshot.currentStageFellBehindOpponent ?? false
        manager.currentStageStayedUnderQuarterBankroll = snapshot.currentStageStayedUnderQuarterBankroll ?? true
        manager.currentStageConsumablesUsed = max(0, snapshot.currentStageConsumablesUsed ?? 0)
        manager.totalRoundsPlayed = max(0, snapshot.totalRoundsPlayed)
        manager.playerWins = max(0, snapshot.playerWins)
        manager.bankerWins = max(0, snapshot.bankerWins)
        manager.tieResults = max(0, snapshot.tieResults)
        manager.highestBankrollCents = max(snapshot.startingBankrollCents, snapshot.highestBankrollCents)
        manager.highestProfitCents = max(0, snapshot.highestProfitCents)
        manager.tiePayoutBonus = max(0, snapshot.tiePayoutBonus)
        manager.tiePayoutOverride = snapshot.tiePayoutOverride
        manager.permanentRevealCount = max(0, snapshot.permanentRevealCount)
        manager.playerBonusMultiplier = max(1, snapshot.playerBonusMultiplier)
        manager.bankerBonusMultiplier = max(1, snapshot.bankerBonusMultiplier)
        manager.futureStageRoundBonus = max(0, snapshot.futureStageRoundBonus)
        manager.chips = max(0, snapshot.chips ?? 3)
        manager.heat = max(0, snapshot.heat ?? 0)
        manager.maxHeat = max(1, snapshot.maxHeat ?? 10)
        manager.lastStageResult = snapshot.lastStageResult
        manager.status = RunStatus(storageValue: snapshot.status)
        return manager
    }

    private static func restoreBossManager(_ snapshot: SavedBossManagerState, acquiredUpgrades: [UpgradeCard]) -> BossManager {
        var manager = BossManager()
        manager.pendingAnnouncementBoss = boss(id: snapshot.pendingAnnouncementBossID)
        manager.activeBoss = boss(id: snapshot.activeBossID)
        manager.lastDefeatedBoss = boss(id: snapshot.lastDefeatedBossID)
        manager.defeatedBosses = snapshot.defeatedBossIDs.compactMap(boss(id:))
        manager.pendingBossRewardChoices = snapshot.pendingBossRewardNames.compactMap(bossReward(named:))

        if let activeBoss = manager.activeBoss {
            manager.disabledUpgradeIDs = Set(
                acquiredUpgrades
                    .filter { !$0.tags.isDisjoint(with: activeBoss.effect.suppressedTags) }
                    .map(\.id)
            )
        }

        return manager
    }

    private static func stageReward(named name: String) -> StageReward? {
        StageReward.productionRewards.first { $0.name == name }
    }

    private static func bossReward(named name: String) -> BossReward? {
        BossReward.productionRewards.first { $0.name == name }
    }

    private static func legacyUpgradeChipCompensation(for names: [String]) -> Int {
        names.reduce(0) { total, name in
            guard let upgrade = UpgradeCard.allCards.first(where: { $0.name == name }) else {
                return total
            }

            switch upgrade.rarity {
            case .common:
                return total + 1
            case .rare:
                return total + 3
            case .legendary:
                return total + 5
            }
        }
    }

    private static func sanitizeModifierInstances(_ instances: [ModifierInstance]) -> [ModifierInstance] {
        instances.compactMap { instance in
            guard ActiveModifierCatalog.isProductionAvailable(instance.modifierID),
                  let definition = Modifier.definition(id: instance.modifierID) else {
                return nil
            }

            var sanitized = instance
            sanitized.level = min(max(1, sanitized.level), definition.maxLevel)
            return sanitized
        }
    }

    private static func sanitizeShopState(_ shopState: ShopState) -> ShopState {
        var sanitized = shopState
        sanitized.offers = shopState.offers.filter(ActiveModifierCatalog.productionShopOfferAllowed)
        if sanitized.offers.count > ActiveModifierCatalog.normalShopOfferCount {
            sanitized.offers = Array(sanitized.offers.prefix(ActiveModifierCatalog.normalShopOfferCount))
        }
        return sanitized
    }

    private static func bossRelic(id: String) -> BossRelic? {
        BossRelic.definition(id: id)
    }

    private static func boss(id: Int?) -> Boss? {
        guard let id else {
            return nil
        }

        return Boss.allBosses.first { $0.id == id }
    }

    private static func startingContact(id: String?) -> StartingContact {
        guard let id else {
            return .defaultFloorHost
        }

        return StartingContact.definition(id: id) ?? .defaultFloorHost
    }

    private static func restoredFlowState(status: String) -> StageFlowState {
        switch RunStatus(storageValue: status) {
        case .failed:
            return .runFailed
        case .completed:
            return .runComplete
        case .stageCleared:
            return .stageResult
        case .active:
            return .stagePreview
        }
    }
}

private extension RunStatus {
    var storageValue: String {
        switch self {
        case .active:
            return "active"
        case .stageCleared:
            return "stageCleared"
        case .failed:
            return "failed"
        case .completed:
            return "completed"
        }
    }

    init(storageValue: String) {
        switch storageValue {
        case "stageCleared":
            self = .stageCleared
        case "failed":
            self = .failed
        case "completed":
            self = .completed
        default:
            self = .active
        }
    }
}
