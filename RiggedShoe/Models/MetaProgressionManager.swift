import Foundation

struct RunConfiguration: Equatable {
    let startingBankrollCents: Int
    let chipRewardMultiplierPercent: Int
    let startingUpgradeNames: [String]
    let activeRunModifierIDs: Set<String>
    let challengeID: ChallengeModeID
    let isDailyRun: Bool
    let dailySeed: UInt64?
    let themeID: CasinoThemeID
    let isGuidedFirstRun: Bool
}

struct ProgressionAward: Equatable {
    var chips: Int = 0
    var reputation: Int = 0
    var achievements: [Achievement] = []

    var isEmpty: Bool {
        chips == 0 && reputation == 0 && achievements.isEmpty
    }

    mutating func add(_ other: ProgressionAward) {
        chips += other.chips
        reputation += other.reputation
        achievements.append(contentsOf: other.achievements)
    }
}

struct AchievementContext {
    var bankrollCents: Int = 0
    var profitCents: Int = 0
    var revealedCards: Int = 0
    var acquiredUpgradeNames: Set<String> = []
    var completedStage10: Bool = false
}

struct MetaProgressionManager {
    private static let storageKey = "riggedShoe.playerProfile.v1"
    private static let corruptStorageKey = "riggedShoe.playerProfile.corruptBackup.v1"

    private let userDefaults: UserDefaults
    private(set) var profile: PlayerProfile

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.profile = Self.loadProfile(from: userDefaults)
        normalizeProfile()
    }

    var unlockedUpgradeCards: [UpgradeCard] {
        UpgradeCard.allCards.filter { profile.unlockedUpgradeNames.contains($0.name) }
    }

    var collectionEntries: [CollectionEntry] {
        upgradeCollectionEntries
            + bossCollectionEntries
            + achievementCollectionEntries
            + rewardCollectionEntries
            + runModifierCollectionEntries
            + futureHookCollectionEntries
    }

    var collectionCompletionPercent: Int {
        let entries = collectionEntries
        guard !entries.isEmpty else {
            return 100
        }

        let completed = entries.filter(\.countsTowardCompletion).count
        return Int((Double(completed) / Double(entries.count) * 100).rounded())
    }

    func isRunModifierActive(_ modifier: RunModifierID) -> Bool {
        profile.activeRunModifierIDs.contains(modifier.rawValue)
    }

    func runConfiguration() -> RunConfiguration {
        let activeModifiers = profile.activeRunModifierIDs
            .compactMap(RunModifierID.init(rawValue:))
            .filter { profile.unlockedRunModifierIDs.contains($0.rawValue) }
        let challengeID = profile.selectedChallengeID
        let dailySeed = profile.isDailyRunEnabled ? Self.dailySeed() : nil

        let modifierStartingBankroll = activeModifiers
            .compactMap(\.startingBankrollCents)
            .first
        let startingBankroll = challengeID.startingBankrollCents
            ?? modifierStartingBankroll
            ?? RunManager.defaultStartingBankrollCents

        let chipMultiplier = activeModifiers
            .map(\.chipRewardMultiplierPercent)
            .max() ?? 100
        let challengeMultiplier = challengeID.chipRewardMultiplierPercent

        let startingUpgradeNames = activeModifiers.flatMap(\.startingUpgradeNames)

        return RunConfiguration(
            startingBankrollCents: startingBankroll,
            chipRewardMultiplierPercent: max(chipMultiplier, challengeMultiplier),
            startingUpgradeNames: startingUpgradeNames,
            activeRunModifierIDs: Set(activeModifiers.map(\.rawValue)),
            challengeID: challengeID,
            isDailyRun: profile.isDailyRunEnabled,
            dailySeed: dailySeed,
            themeID: profile.selectedThemeID,
            isGuidedFirstRun: !profile.hasCompletedGuidedFirstRun
        )
    }

    @discardableResult
    mutating func purchase(_ unlockable: Unlockable) -> Bool {
        guard !unlockable.isUnlocked(in: profile), unlockable.canAfford(with: profile) else {
            return false
        }

        profile.casinoChips -= unlockable.costChips
        profile.reputation -= unlockable.costReputation

        switch unlockable.content {
        case .upgrade(let name):
            profile.unlockedUpgradeNames.insert(name)
        case .stageReward(let name):
            profile.unlockedStageRewardNames.insert(name)
        case .bossReward(let name):
            profile.unlockedBossRewardNames.insert(name)
        case .runModifier(let id):
            profile.unlockedRunModifierIDs.insert(id.rawValue)
        case .futureHook(let id):
            profile.unlockedFutureHookIDs.insert(id)
        }

        save()
        return true
    }

    mutating func resetProfile() {
        profile = PlayerProfile()
        save()
    }

    mutating func setRunModifier(_ modifier: RunModifierID, isActive: Bool) {
        guard profile.unlockedRunModifierIDs.contains(modifier.rawValue) else {
            return
        }

        if isActive {
            for conflictingID in modifier.conflictingIDs {
                profile.activeRunModifierIDs.remove(conflictingID.rawValue)
            }

            profile.activeRunModifierIDs.insert(modifier.rawValue)
        } else {
            profile.activeRunModifierIDs.remove(modifier.rawValue)
        }

        save()
    }

    mutating func setChallenge(_ challengeID: ChallengeModeID) {
        profile.selectedChallengeID = challengeID
        save()
    }

    mutating func setDailyRunEnabled(_ isEnabled: Bool) {
        profile.isDailyRunEnabled = isEnabled
        save()
    }

    mutating func setTheme(_ themeID: CasinoThemeID) {
        profile.selectedThemeID = themeID
        save()
    }

    mutating func markOnboardingCompleted(skipped: Bool = false) {
        profile.hasCompletedOnboarding = true
        profile.hasSkippedOnboarding = skipped
        save()
    }

    mutating func markGuidedFirstRunCompleted() {
        profile.hasCompletedGuidedFirstRun = true
        save()
    }

    mutating func markPatchNotesSeen() {
        profile.lastSeenPatchNotesVersion = BuildInfo.versionText
        save()
    }

    mutating func recordRound(
        result: RoundResult,
        bankrollCents: Int,
        profitCents: Int,
        revealedCards: Int,
        acquiredUpgrades: [UpgradeCard]
    ) -> ProgressionAward {
        profile.totalBaccaratRounds += 1

        switch result.winner {
        case .player:
            profile.playerWins += 1
        case .banker:
            profile.bankerWins += 1
        case .tie:
            profile.tieResults += 1
        }

        return recordRunSnapshot(
            bankrollCents: bankrollCents,
            profitCents: profitCents,
            revealedCards: revealedCards,
            acquiredUpgrades: acquiredUpgrades
        )
    }

    mutating func recordRunSnapshot(
        bankrollCents: Int,
        profitCents: Int,
        revealedCards: Int,
        acquiredUpgrades: [UpgradeCard],
        completedStage10: Bool = false
    ) -> ProgressionAward {
        profile.highestBankrollEverCents = max(profile.highestBankrollEverCents, bankrollCents)
        profile.highestProfitEverCents = max(profile.highestProfitEverCents, max(0, profitCents))

        let award = evaluateAchievements(
            context: AchievementContext(
                bankrollCents: bankrollCents,
                profitCents: profitCents,
                revealedCards: revealedCards,
                acquiredUpgradeNames: Set(acquiredUpgrades.map(\.name)),
                completedStage10: completedStage10
            )
        )
        save()
        return award
    }

    mutating func recordStageCleared(stageID: Int, chipMultiplierPercent: Int) -> ProgressionAward {
        profile.stagesCleared += 1

        var award = grantCurrency(chips: 100, reputation: 0, chipMultiplierPercent: chipMultiplierPercent)
        award.add(evaluateAchievements(context: AchievementContext()))
        save()
        return award
    }

    mutating func recordBossEncountered(_ boss: Boss) {
        profile.bossesEncounteredIDs.insert(boss.id)
        save()
    }

    mutating func recordBossDefeated(_ boss: Boss, chipMultiplierPercent: Int) -> ProgressionAward {
        profile.bossesDefeated += 1
        profile.bossesDefeatedIDs.insert(boss.id)

        var award = grantCurrency(
            chips: 500,
            reputation: reputationAward(forBoss: boss),
            chipMultiplierPercent: chipMultiplierPercent
        )
        award.add(evaluateAchievements(context: AchievementContext()))
        save()
        return award
    }

    mutating func recordRunEnded(
        didWin: Bool,
        bankrollCents: Int,
        profitCents: Int,
        revealedCards: Int,
        acquiredUpgrades: [UpgradeCard],
        chipMultiplierPercent: Int,
        challengeID: ChallengeModeID,
        stageReached: Int,
        isDailyRun: Bool,
        dailySeed: UInt64?
    ) -> ProgressionAward {
        profile.totalRuns += 1

        var award = ProgressionAward()

        if didWin {
            profile.totalWins += 1
            award.add(grantCurrency(chips: 6_000, reputation: 5, chipMultiplierPercent: chipMultiplierPercent))
        }

        award.add(recordChallengeRun(
            challengeID: challengeID,
            didWin: didWin,
            profitCents: profitCents,
            stageReached: stageReached,
            chipMultiplierPercent: chipMultiplierPercent
        ))

        if isDailyRun, let dailySeed {
            recordDailyRun(seed: dailySeed, didWin: didWin, profitCents: profitCents, stageReached: stageReached)
        }

        award.add(
            recordRunSnapshot(
                bankrollCents: bankrollCents,
                profitCents: profitCents,
                revealedCards: revealedCards,
                acquiredUpgrades: acquiredUpgrades,
                completedStage10: didWin
            )
        )

        save()
        return award
    }

    private mutating func grantCurrency(chips: Int, reputation: Int, chipMultiplierPercent: Int) -> ProgressionAward {
        let adjustedChips = chips * chipMultiplierPercent / 100

        profile.casinoChips += adjustedChips
        profile.reputation += reputation
        profile.totalChipsEarned += adjustedChips
        profile.totalReputationEarned += reputation

        return ProgressionAward(chips: adjustedChips, reputation: reputation)
    }

    private mutating func evaluateAchievements(context: AchievementContext) -> ProgressionAward {
        var award = ProgressionAward()

        for achievement in Achievement.allAchievements where !profile.achievedAchievementIDs.contains(achievement.id) {
            let isUnlocked: Bool

            switch achievement.id {
            case "card_counter":
                isUnlocked = context.revealedCards >= 10
            case "loaded_shoe":
                isUnlocked = context.acquiredUpgradeNames.contains("Loaded Shoe")
            case "big_winner":
                isUnlocked = max(context.bankrollCents, profile.highestBankrollEverCents) >= 10_000_000
            case "millionaire":
                isUnlocked = max(context.bankrollCents, profile.highestBankrollEverCents) >= 100_000_000
            case "boss_hunter":
                isUnlocked = profile.bossesDefeated >= 10
            case "casino_legend":
                isUnlocked = context.completedStage10 || profile.totalWins > 0
            default:
                isUnlocked = false
            }

            guard isUnlocked else {
                continue
            }

            profile.achievedAchievementIDs.insert(achievement.id)
            profile.casinoChips += achievement.chipReward
            profile.totalChipsEarned += achievement.chipReward
            award.chips += achievement.chipReward
            award.achievements.append(achievement)
        }

        return award
    }

    private func reputationAward(forBoss boss: Boss) -> Int {
        switch boss.id {
        case Boss.surveillance.id:
            return 1
        case Boss.automaticShuffler.id:
            return 2
        case Boss.pitBoss.id:
            return 3
        case Boss.house.id:
            return 5
        default:
            return boss.difficulty == .majorBoss ? 3 : 1
        }
    }

    private mutating func recordChallengeRun(
        challengeID: ChallengeModeID,
        didWin: Bool,
        profitCents: Int,
        stageReached: Int,
        chipMultiplierPercent: Int
    ) -> ProgressionAward {
        guard challengeID != .standard else {
            return ProgressionAward()
        }

        var record = profile.challengeRecords[challengeID.rawValue] ?? ChallengeRecord()
        record.bestProfitCents = max(record.bestProfitCents, max(0, profitCents))
        record.bestStage = max(record.bestStage, stageReached)

        var award = ProgressionAward()

        if didWin {
            record.wins += 1
            let bonusChips = challengeID == .bossRush ? 2_500 : 1_000
            award = grantCurrency(chips: bonusChips, reputation: 0, chipMultiplierPercent: chipMultiplierPercent)
            record.totalBonusChipsEarned += award.chips
        }

        profile.challengeRecords[challengeID.rawValue] = record
        return award
    }

    private mutating func recordDailyRun(seed: UInt64, didWin: Bool, profitCents: Int, stageReached: Int) {
        let dateKey = Self.dailyDateKey()
        var record = profile.dailyRunRecord.dateKey == dateKey ? profile.dailyRunRecord : DailyRunRecord(dateKey: dateKey)

        record.bestProfitCents = max(record.bestProfitCents, max(0, profitCents))
        record.bestStage = max(record.bestStage, stageReached)
        record.completed = record.completed || didWin

        profile.dailyRunRecord = record
        profile.leaderboardPlaceholder = LeaderboardPlaceholder(
            dailySeed: seed,
            dateKey: dateKey,
            localScoreCents: record.bestProfitCents
        )
    }

    private static func dailyDateKey() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let year = components.year ?? 2026
        let month = components.month ?? 1
        let day = components.day ?? 1

        return String(format: "%04d%02d%02d", year, month, day)
    }

    private static func dailySeed() -> UInt64 {
        UInt64(dailyDateKey()) ?? 2_026_061_800
    }

    private mutating func normalizeProfile() {
        profile.profileVersion = max(profile.profileVersion, 2)
        profile.unlockedUpgradeNames.formUnion(PlayerProfile.defaultUnlockedUpgradeNames)
        profile.unlockedStageRewardNames.formUnion(PlayerProfile.defaultUnlockedStageRewardNames)
        profile.unlockedBossRewardNames.formUnion(PlayerProfile.defaultUnlockedBossRewardNames)
        profile.activeRunModifierIDs = profile.activeRunModifierIDs.filter { profile.unlockedRunModifierIDs.contains($0) }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profile) else {
            return
        }

        userDefaults.set(data, forKey: Self.storageKey)
    }

    private static func loadProfile(from userDefaults: UserDefaults) -> PlayerProfile {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return PlayerProfile()
        }

        guard let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            userDefaults.set(data, forKey: corruptStorageKey)
            userDefaults.removeObject(forKey: storageKey)
            return PlayerProfile()
        }

        return profile
    }

    private var upgradeCollectionEntries: [CollectionEntry] {
        UpgradeCard.allCards.map { card in
            CollectionEntry(
                id: "collection.upgrade.\(card.name)",
                kind: .upgrade,
                title: card.name,
                subtitle: card.rarity.displayName,
                description: card.description,
                rarity: card.rarity,
                isUnlocked: profile.unlockedUpgradeNames.contains(card.name),
                isEncountered: profile.unlockedUpgradeNames.contains(card.name),
                isDefeated: false
            )
        }
    }

    private var bossCollectionEntries: [CollectionEntry] {
        Boss.allBosses.map { boss in
            let encountered = profile.bossesEncounteredIDs.contains(boss.id)

            return CollectionEntry(
                id: "collection.boss.\(boss.id)",
                kind: .boss,
                title: encountered ? boss.name : "Unknown Boss",
                subtitle: boss.difficulty.displayName,
                description: encountered ? boss.description : "Reach a boss stage to reveal this casino threat.",
                rarity: nil,
                isUnlocked: encountered,
                isEncountered: encountered,
                isDefeated: profile.bossesDefeatedIDs.contains(boss.id)
            )
        }
    }

    private var achievementCollectionEntries: [CollectionEntry] {
        Achievement.allAchievements.map { achievement in
            let achieved = profile.achievedAchievementIDs.contains(achievement.id)

            return CollectionEntry(
                id: "collection.achievement.\(achievement.id)",
                kind: .achievement,
                title: achievement.name,
                subtitle: "\(achievement.chipReward) Chips",
                description: achievement.description,
                rarity: nil,
                isUnlocked: achieved,
                isEncountered: achieved,
                isDefeated: false
            )
        }
    }

    private var rewardCollectionEntries: [CollectionEntry] {
        let stageRewards = StageReward.allRewards.map { reward in
            CollectionEntry(
                id: "collection.stageReward.\(reward.name)",
                kind: .stageReward,
                title: reward.name,
                subtitle: "Stage Reward",
                description: reward.description,
                rarity: nil,
                isUnlocked: profile.unlockedStageRewardNames.contains(reward.name),
                isEncountered: profile.unlockedStageRewardNames.contains(reward.name),
                isDefeated: false
            )
        }

        let bossRewards = BossReward.allRewards.map { reward in
            CollectionEntry(
                id: "collection.bossReward.\(reward.name)",
                kind: .bossReward,
                title: reward.name,
                subtitle: "Boss Reward",
                description: reward.description,
                rarity: nil,
                isUnlocked: profile.unlockedBossRewardNames.contains(reward.name),
                isEncountered: profile.unlockedBossRewardNames.contains(reward.name),
                isDefeated: false
            )
        }

        return stageRewards + bossRewards
    }

    private var runModifierCollectionEntries: [CollectionEntry] {
        RunModifierID.allCases.map { modifier in
            CollectionEntry(
                id: "collection.runModifier.\(modifier.rawValue)",
                kind: .runModifier,
                title: modifier.name,
                subtitle: profile.activeRunModifierIDs.contains(modifier.rawValue) ? "Active" : "Run Modifier",
                description: modifier.description,
                rarity: nil,
                isUnlocked: profile.unlockedRunModifierIDs.contains(modifier.rawValue),
                isEncountered: profile.unlockedRunModifierIDs.contains(modifier.rawValue),
                isDefeated: false
            )
        }
    }

    private var futureHookCollectionEntries: [CollectionEntry] {
        Unlockable.allUnlockables.compactMap { unlockable in
            guard case .futureHook(let id) = unlockable.content else {
                return nil
            }

            return CollectionEntry(
                id: "collection.futureHook.\(id)",
                kind: .futureHook,
                title: unlockable.name,
                subtitle: "Future Hook",
                description: unlockable.description,
                rarity: nil,
                isUnlocked: profile.unlockedFutureHookIDs.contains(id),
                isEncountered: profile.unlockedFutureHookIDs.contains(id),
                isDefeated: false
            )
        }
    }
}
