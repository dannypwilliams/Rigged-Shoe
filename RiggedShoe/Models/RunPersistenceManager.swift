import Foundation

struct SavedRunManagerState: Codable, Equatable {
    var startingBankrollCents: Int
    var stageStartingBankrollCents: Int?
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
}

struct RunPersistenceManager {
    private static let storageKey = "riggedShoe.activeRun.v2"
    private static let corruptStorageKey = "riggedShoe.activeRun.corruptBackup.v1"
    private static let currentVersion = 2

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
            bankrollCents: state.bankrollCents,
            selectedBetType: state.selectedBetType,
            selectedBetAmountCents: state.selectedBetAmountCents,
            shoeCards: state.shoe.cards,
            acquiredUpgradeNames: state.acquiredUpgrades.map(\.name),
            pendingUpgradeNames: state.pendingUpgradeChoices.map(\.name),
            pendingStageRewardNames: state.pendingStageRewardChoices.map(\.name),
            roundsSinceLastUpgrade: state.roundsSinceLastUpgrade,
            runManager: SavedRunManagerState(
                startingBankrollCents: state.runManager.startingBankrollCents,
                stageStartingBankrollCents: state.runManager.stageStartingBankrollCents,
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
                status: state.runManager.status.storageValue
            ),
            bossManager: SavedBossManagerState(
                pendingAnnouncementBossID: state.bossManager.pendingAnnouncementBoss?.id,
                activeBossID: state.bossManager.activeBoss?.id,
                lastDefeatedBossID: state.bossManager.lastDefeatedBoss?.id,
                defeatedBossIDs: state.bossManager.defeatedBosses.map(\.id),
                pendingBossRewardNames: state.bossManager.pendingBossRewardChoices.map(\.name)
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
            runStartedAt: state.runStartedAt
        )
    }

    private static func restore(_ snapshot: SavedRunState, configuration: RunConfiguration) -> GameState {
        var state = GameState(configuration: configuration)
        state.bankrollCents = snapshot.bankrollCents
        state.selectedBetType = snapshot.selectedBetType
        state.selectedBetAmountCents = snapshot.selectedBetAmountCents
        state.shoe = Shoe(deckCount: 6, cards: snapshot.shoeCards)
        state.acquiredUpgrades = snapshot.acquiredUpgradeNames.compactMap(upgrade(named:))
        state.pendingUpgradeChoices = snapshot.pendingUpgradeNames.compactMap(upgrade(named:))
        state.pendingStageRewardChoices = snapshot.pendingStageRewardNames.compactMap(stageReward(named:))
        state.roundsSinceLastUpgrade = snapshot.roundsSinceLastUpgrade
        state.runManager = restoreRunManager(snapshot.runManager)
        state.bossManager = restoreBossManager(snapshot.bossManager, acquiredUpgrades: state.acquiredUpgrades)
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
        return state
    }

    private static func restoreRunManager(_ snapshot: SavedRunManagerState) -> RunManager {
        var manager = RunManager(startingBankrollCents: snapshot.startingBankrollCents)
        manager.stageStartingBankrollCents = max(0, snapshot.stageStartingBankrollCents ?? snapshot.startingBankrollCents)
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

    private static func upgrade(named name: String) -> UpgradeCard? {
        UpgradeCard.allCards.first { $0.name == name }?.copyForAcquisition()
    }

    private static func stageReward(named name: String) -> StageReward? {
        StageReward.allRewards.first { $0.name == name }
    }

    private static func bossReward(named name: String) -> BossReward? {
        BossReward.allRewards.first { $0.name == name }
    }

    private static func boss(id: Int?) -> Boss? {
        guard let id else {
            return nil
        }

        return Boss.allBosses.first { $0.id == id }
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
