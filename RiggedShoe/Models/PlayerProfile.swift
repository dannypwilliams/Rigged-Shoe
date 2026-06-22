import Foundation

struct PlayerProfile: Codable, Equatable {
    var profileVersion: Int
    var casinoChips: Int
    var reputation: Int

    var totalRuns: Int
    var totalWins: Int
    var totalBaccaratRounds: Int
    var playerWins: Int
    var bankerWins: Int
    var tieResults: Int
    var stagesCleared: Int
    var bossesDefeated: Int
    var totalChipsEarned: Int
    var totalReputationEarned: Int
    var highestBankrollEverCents: Int
    var highestProfitEverCents: Int

    var unlockedUpgradeNames: Set<String>
    var unlockedStageRewardNames: Set<String>
    var unlockedBossRewardNames: Set<String>
    var unlockedRunModifierIDs: Set<String>
    var activeRunModifierIDs: Set<String>
    var unlockedFutureHookIDs: Set<String>
    var achievedAchievementIDs: Set<String>
    var bossesEncounteredIDs: Set<Int>
    var bossesDefeatedIDs: Set<Int>
    var selectedChallengeID: ChallengeModeID
    var isDailyRunEnabled: Bool
    var selectedThemeID: CasinoThemeID
    var challengeRecords: [String: ChallengeRecord]
    var dailyRunRecord: DailyRunRecord
    var leaderboardPlaceholder: LeaderboardPlaceholder?
    var hasCompletedOnboarding: Bool
    var hasSkippedOnboarding: Bool
    var hasCompletedGuidedFirstRun: Bool
    var lastSeenPatchNotesVersion: String?

    init(
        profileVersion: Int = 2,
        casinoChips: Int = 0,
        reputation: Int = 0,
        totalRuns: Int = 0,
        totalWins: Int = 0,
        totalBaccaratRounds: Int = 0,
        playerWins: Int = 0,
        bankerWins: Int = 0,
        tieResults: Int = 0,
        stagesCleared: Int = 0,
        bossesDefeated: Int = 0,
        totalChipsEarned: Int = 0,
        totalReputationEarned: Int = 0,
        highestBankrollEverCents: Int = RunManager.defaultStartingBankrollCents,
        highestProfitEverCents: Int = 0,
        unlockedUpgradeNames: Set<String> = Self.defaultUnlockedUpgradeNames,
        unlockedStageRewardNames: Set<String> = Self.defaultUnlockedStageRewardNames,
        unlockedBossRewardNames: Set<String> = Self.defaultUnlockedBossRewardNames,
        unlockedRunModifierIDs: Set<String> = [],
        activeRunModifierIDs: Set<String> = [],
        unlockedFutureHookIDs: Set<String> = [],
        achievedAchievementIDs: Set<String> = [],
        bossesEncounteredIDs: Set<Int> = [],
        bossesDefeatedIDs: Set<Int> = [],
        selectedChallengeID: ChallengeModeID = .standard,
        isDailyRunEnabled: Bool = false,
        selectedThemeID: CasinoThemeID = .lasVegas,
        challengeRecords: [String: ChallengeRecord] = [:],
        dailyRunRecord: DailyRunRecord = DailyRunRecord(),
        leaderboardPlaceholder: LeaderboardPlaceholder? = nil,
        hasCompletedOnboarding: Bool = false,
        hasSkippedOnboarding: Bool = false,
        hasCompletedGuidedFirstRun: Bool = false,
        lastSeenPatchNotesVersion: String? = nil
    ) {
        self.profileVersion = profileVersion
        self.casinoChips = casinoChips
        self.reputation = reputation
        self.totalRuns = totalRuns
        self.totalWins = totalWins
        self.totalBaccaratRounds = totalBaccaratRounds
        self.playerWins = playerWins
        self.bankerWins = bankerWins
        self.tieResults = tieResults
        self.stagesCleared = stagesCleared
        self.bossesDefeated = bossesDefeated
        self.totalChipsEarned = totalChipsEarned
        self.totalReputationEarned = totalReputationEarned
        self.highestBankrollEverCents = highestBankrollEverCents
        self.highestProfitEverCents = highestProfitEverCents
        self.unlockedUpgradeNames = unlockedUpgradeNames
        self.unlockedStageRewardNames = unlockedStageRewardNames
        self.unlockedBossRewardNames = unlockedBossRewardNames
        self.unlockedRunModifierIDs = unlockedRunModifierIDs
        self.activeRunModifierIDs = activeRunModifierIDs
        self.unlockedFutureHookIDs = unlockedFutureHookIDs
        self.achievedAchievementIDs = achievedAchievementIDs
        self.bossesEncounteredIDs = bossesEncounteredIDs
        self.bossesDefeatedIDs = bossesDefeatedIDs
        self.selectedChallengeID = selectedChallengeID
        self.isDailyRunEnabled = isDailyRunEnabled
        self.selectedThemeID = selectedThemeID
        self.challengeRecords = challengeRecords
        self.dailyRunRecord = dailyRunRecord
        self.leaderboardPlaceholder = leaderboardPlaceholder
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasSkippedOnboarding = hasSkippedOnboarding
        self.hasCompletedGuidedFirstRun = hasCompletedGuidedFirstRun
        self.lastSeenPatchNotesVersion = lastSeenPatchNotesVersion
    }

    static let defaultUnlockedUpgradeNames: Set<String> = [
        "Safety Net",
        "Conservative Edge",
        "Small Ball",
        "Press the Advantage",
        "Damage Control",
        "X-Ray Shoe",
        "Opening Tell",
        "Burn Control",
        "Soft Shuffle",
        "Dealer Pressure",
        "Face Hunter",
        "Low Roller",
        "Comeback Chip",
        "Nine Syndicate",
        "Eight Stack",
        "Face Card Purge",
        "Player Bonus",
        "Banker Bonus",
        "Safer Ties"
    ]

    static let defaultUnlockedStageRewardNames: Set<String> = [
        "Pocket $25",
        "Pocket $40",
        "Pocket $75",
        "Clean Slate",
        "Double Down",
        "Rare Contact"
    ]

    static let defaultUnlockedBossRewardNames: Set<String> = [
        "Player Consortium",
        "Banker Consortium",
        "High Roller Shoe",
        "Vault Leak",
        "Face Card Blackout"
    ]
}

extension PlayerProfile {
    enum CodingKeys: String, CodingKey {
        case profileVersion
        case casinoChips
        case reputation
        case totalRuns
        case totalWins
        case totalBaccaratRounds
        case playerWins
        case bankerWins
        case tieResults
        case stagesCleared
        case bossesDefeated
        case totalChipsEarned
        case totalReputationEarned
        case highestBankrollEverCents
        case highestProfitEverCents
        case unlockedUpgradeNames
        case unlockedStageRewardNames
        case unlockedBossRewardNames
        case unlockedRunModifierIDs
        case activeRunModifierIDs
        case unlockedFutureHookIDs
        case achievedAchievementIDs
        case bossesEncounteredIDs
        case bossesDefeatedIDs
        case selectedChallengeID
        case isDailyRunEnabled
        case selectedThemeID
        case challengeRecords
        case dailyRunRecord
        case leaderboardPlaceholder
        case hasCompletedOnboarding
        case hasSkippedOnboarding
        case hasCompletedGuidedFirstRun
        case lastSeenPatchNotesVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            profileVersion: try container.decodeIfPresent(Int.self, forKey: .profileVersion) ?? 1,
            casinoChips: try container.decodeIfPresent(Int.self, forKey: .casinoChips) ?? 0,
            reputation: try container.decodeIfPresent(Int.self, forKey: .reputation) ?? 0,
            totalRuns: try container.decodeIfPresent(Int.self, forKey: .totalRuns) ?? 0,
            totalWins: try container.decodeIfPresent(Int.self, forKey: .totalWins) ?? 0,
            totalBaccaratRounds: try container.decodeIfPresent(Int.self, forKey: .totalBaccaratRounds) ?? 0,
            playerWins: try container.decodeIfPresent(Int.self, forKey: .playerWins) ?? 0,
            bankerWins: try container.decodeIfPresent(Int.self, forKey: .bankerWins) ?? 0,
            tieResults: try container.decodeIfPresent(Int.self, forKey: .tieResults) ?? 0,
            stagesCleared: try container.decodeIfPresent(Int.self, forKey: .stagesCleared) ?? 0,
            bossesDefeated: try container.decodeIfPresent(Int.self, forKey: .bossesDefeated) ?? 0,
            totalChipsEarned: try container.decodeIfPresent(Int.self, forKey: .totalChipsEarned) ?? 0,
            totalReputationEarned: try container.decodeIfPresent(Int.self, forKey: .totalReputationEarned) ?? 0,
            highestBankrollEverCents: try container.decodeIfPresent(Int.self, forKey: .highestBankrollEverCents) ?? RunManager.defaultStartingBankrollCents,
            highestProfitEverCents: try container.decodeIfPresent(Int.self, forKey: .highestProfitEverCents) ?? 0,
            unlockedUpgradeNames: try container.decodeIfPresent(Set<String>.self, forKey: .unlockedUpgradeNames) ?? Self.defaultUnlockedUpgradeNames,
            unlockedStageRewardNames: try container.decodeIfPresent(Set<String>.self, forKey: .unlockedStageRewardNames) ?? Self.defaultUnlockedStageRewardNames,
            unlockedBossRewardNames: try container.decodeIfPresent(Set<String>.self, forKey: .unlockedBossRewardNames) ?? Self.defaultUnlockedBossRewardNames,
            unlockedRunModifierIDs: try container.decodeIfPresent(Set<String>.self, forKey: .unlockedRunModifierIDs) ?? [],
            activeRunModifierIDs: try container.decodeIfPresent(Set<String>.self, forKey: .activeRunModifierIDs) ?? [],
            unlockedFutureHookIDs: try container.decodeIfPresent(Set<String>.self, forKey: .unlockedFutureHookIDs) ?? [],
            achievedAchievementIDs: try container.decodeIfPresent(Set<String>.self, forKey: .achievedAchievementIDs) ?? [],
            bossesEncounteredIDs: try container.decodeIfPresent(Set<Int>.self, forKey: .bossesEncounteredIDs) ?? [],
            bossesDefeatedIDs: try container.decodeIfPresent(Set<Int>.self, forKey: .bossesDefeatedIDs) ?? [],
            selectedChallengeID: try container.decodeIfPresent(ChallengeModeID.self, forKey: .selectedChallengeID) ?? .standard,
            isDailyRunEnabled: try container.decodeIfPresent(Bool.self, forKey: .isDailyRunEnabled) ?? false,
            selectedThemeID: try container.decodeIfPresent(CasinoThemeID.self, forKey: .selectedThemeID) ?? .lasVegas,
            challengeRecords: try container.decodeIfPresent([String: ChallengeRecord].self, forKey: .challengeRecords) ?? [:],
            dailyRunRecord: try container.decodeIfPresent(DailyRunRecord.self, forKey: .dailyRunRecord) ?? DailyRunRecord(),
            leaderboardPlaceholder: try container.decodeIfPresent(LeaderboardPlaceholder.self, forKey: .leaderboardPlaceholder),
            hasCompletedOnboarding: try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false,
            hasSkippedOnboarding: try container.decodeIfPresent(Bool.self, forKey: .hasSkippedOnboarding) ?? false,
            hasCompletedGuidedFirstRun: try container.decodeIfPresent(Bool.self, forKey: .hasCompletedGuidedFirstRun) ?? false,
            lastSeenPatchNotesVersion: try container.decodeIfPresent(String.self, forKey: .lastSeenPatchNotesVersion)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(profileVersion, forKey: .profileVersion)
        try container.encode(casinoChips, forKey: .casinoChips)
        try container.encode(reputation, forKey: .reputation)
        try container.encode(totalRuns, forKey: .totalRuns)
        try container.encode(totalWins, forKey: .totalWins)
        try container.encode(totalBaccaratRounds, forKey: .totalBaccaratRounds)
        try container.encode(playerWins, forKey: .playerWins)
        try container.encode(bankerWins, forKey: .bankerWins)
        try container.encode(tieResults, forKey: .tieResults)
        try container.encode(stagesCleared, forKey: .stagesCleared)
        try container.encode(bossesDefeated, forKey: .bossesDefeated)
        try container.encode(totalChipsEarned, forKey: .totalChipsEarned)
        try container.encode(totalReputationEarned, forKey: .totalReputationEarned)
        try container.encode(highestBankrollEverCents, forKey: .highestBankrollEverCents)
        try container.encode(highestProfitEverCents, forKey: .highestProfitEverCents)
        try container.encode(unlockedUpgradeNames, forKey: .unlockedUpgradeNames)
        try container.encode(unlockedStageRewardNames, forKey: .unlockedStageRewardNames)
        try container.encode(unlockedBossRewardNames, forKey: .unlockedBossRewardNames)
        try container.encode(unlockedRunModifierIDs, forKey: .unlockedRunModifierIDs)
        try container.encode(activeRunModifierIDs, forKey: .activeRunModifierIDs)
        try container.encode(unlockedFutureHookIDs, forKey: .unlockedFutureHookIDs)
        try container.encode(achievedAchievementIDs, forKey: .achievedAchievementIDs)
        try container.encode(bossesEncounteredIDs, forKey: .bossesEncounteredIDs)
        try container.encode(bossesDefeatedIDs, forKey: .bossesDefeatedIDs)
        try container.encode(selectedChallengeID, forKey: .selectedChallengeID)
        try container.encode(isDailyRunEnabled, forKey: .isDailyRunEnabled)
        try container.encode(selectedThemeID, forKey: .selectedThemeID)
        try container.encode(challengeRecords, forKey: .challengeRecords)
        try container.encode(dailyRunRecord, forKey: .dailyRunRecord)
        try container.encodeIfPresent(leaderboardPlaceholder, forKey: .leaderboardPlaceholder)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(hasSkippedOnboarding, forKey: .hasSkippedOnboarding)
        try container.encode(hasCompletedGuidedFirstRun, forKey: .hasCompletedGuidedFirstRun)
        try container.encodeIfPresent(lastSeenPatchNotesVersion, forKey: .lastSeenPatchNotesVersion)
    }
}
