import Foundation

struct BossManager: Equatable {
    var pendingAnnouncementBoss: Boss?
    var activeBoss: Boss?
    var lastDefeatedBoss: Boss?
    var defeatedBosses: [Boss]
    var disabledUpgradeIDs: Set<UUID>
    var pendingBossRewardChoices: [BossReward]

    init() {
        self.pendingAnnouncementBoss = nil
        self.activeBoss = nil
        self.lastDefeatedBoss = nil
        self.defeatedBosses = []
        self.disabledUpgradeIDs = []
        self.pendingBossRewardChoices = []
    }

    var bossesDefeatedCount: Int {
        defeatedBosses.count
    }

    var suppressesReveal: Bool {
        activeBoss?.effect.suppressesReveal ?? false
    }

    var shufflesAfterEveryRound: Bool {
        activeBoss?.effect.shufflesAfterEveryRound ?? false
    }

    var restoresBankerCommission: Bool {
        activeBoss?.effect.restoresBankerCommission ?? false
    }

    var capsTiePayoutAtBase: Bool {
        activeBoss?.effect.capsTiePayoutAtBase ?? false
    }

    mutating func prepareBossIfNeeded(
        for stageID: Int,
        challengeID: ChallengeModeID,
        seededGenerator: inout SeededRandomGenerator?
    ) {
        guard pendingAnnouncementBoss == nil, activeBoss == nil else {
            return
        }

        pendingAnnouncementBoss = Self.boss(
            forStageID: stageID,
            challengeID: challengeID,
            seededGenerator: &seededGenerator
        )
    }

    mutating func startPendingBoss(acquiredUpgrades: [UpgradeCard], seededGenerator: inout SeededRandomGenerator?) {
        guard let boss = pendingAnnouncementBoss else {
            return
        }

        pendingAnnouncementBoss = nil
        activeBoss = boss
        lastDefeatedBoss = nil
        disabledUpgradeIDs = []

        let tagDisabledIDs = acquiredUpgrades
            .filter { !$0.tags.isDisjoint(with: boss.effect.suppressedTags) }
            .map(\.id)

        disabledUpgradeIDs.formUnion(tagDisabledIDs)

        guard boss.effect.usesPitBossUpgradeDisable else {
            return
        }

        let shuffledUpgrades: [UpgradeCard]

        if var generator = seededGenerator {
            shuffledUpgrades = acquiredUpgrades.seededShuffled(using: &generator)
            seededGenerator = generator
        } else {
            shuffledUpgrades = acquiredUpgrades.shuffled()
        }

        disabledUpgradeIDs.formUnion(
            shuffledUpgrades
                .prefix(boss.effect.disabledUpgradeCount)
                .map(\.id)
        )
    }

    mutating func defeatActiveBoss(
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String>,
        unlockedUpgradeCards: [UpgradeCard]
    ) {
        var generator: SeededRandomGenerator?
        defeatActiveBoss(
            acquiredUpgrades: acquiredUpgrades,
            unlockedRewardNames: unlockedRewardNames,
            unlockedUpgradeCards: unlockedUpgradeCards,
            seededGenerator: &generator
        )
    }

    mutating func defeatActiveBoss(
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String>,
        unlockedUpgradeCards: [UpgradeCard],
        seededGenerator: inout SeededRandomGenerator?
    ) {
        guard let boss = activeBoss else {
            return
        }

        activeBoss = nil
        lastDefeatedBoss = boss
        defeatedBosses.append(boss)
        disabledUpgradeIDs = []
        pendingBossRewardChoices = BossReward.randomChoices(
            count: 3,
            acquiredUpgrades: acquiredUpgrades,
            unlockedRewardNames: unlockedRewardNames,
            unlockedUpgradeCards: unlockedUpgradeCards,
            seededGenerator: &seededGenerator
        )
    }

    mutating func clearBossRewardChoices() {
        pendingBossRewardChoices = []
        lastDefeatedBoss = nil
    }

    static func boss(
        forStageID stageID: Int,
        challengeID: ChallengeModeID = .standard
    ) -> Boss? {
        var generator: SeededRandomGenerator?
        return boss(forStageID: stageID, challengeID: challengeID, seededGenerator: &generator)
    }

    static func boss(
        forStageID stageID: Int,
        challengeID: ChallengeModeID = .standard,
        seededGenerator: inout SeededRandomGenerator?
    ) -> Boss? {
        if stageID == 10 {
            return .house
        }

        guard challengeID == .bossRush || [5, 8].contains(stageID) else {
            return nil
        }

        let pool = Boss.randomBossPool

        if var generator = seededGenerator {
            let boss = pool.seededRandomElement(using: &generator)
            seededGenerator = generator
            return boss
        }

        return pool.randomElement()
    }
}
