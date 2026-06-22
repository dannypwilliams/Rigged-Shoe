import Foundation

struct GameState: Equatable {
    var bankrollCents: Int
    var selectedBetType: BetType = .player
    var selectedBetAmountCents: Int = 1_000
    var shoe = Shoe(deckCount: 6)
    var latestRound: RoundResult?
    var history: [RoundResult] = []
    var acquiredUpgrades: [UpgradeCard] = []
    var pendingUpgradeChoices: [UpgradeCard] = []
    var pendingStageRewardChoices: [StageReward] = []
    var roundsSinceLastUpgrade: Int = 0
    var runManager: RunManager
    var bossManager = BossManager()
    var chipRewardMultiplierPercent: Int
    var metaChipsEarnedThisRun: Int = 0
    var metaReputationEarnedThisRun: Int = 0
    var didRecordRunEnd: Bool = false
    var roundPresentation = RoundPresentationState()
    var challengeID: ChallengeModeID
    var isDailyRun: Bool
    var dailySeed: UInt64?
    var seededGenerator: SeededRandomGenerator?
    var themeID: CasinoThemeID
    var playerWinStreak: Int = 0
    var bankerWinStreak: Int = 0
    var tieStreak: Int = 0
    var previousRoundLossCents: Int = 0
    var hasPaidFirstTieThisStage = false
    var hasUsedSafetyNetThisStage = false
    var hasUsedHighRollerSparkThisStage = false
    var hasPaidFaceHunterThisStage = false
    var damageControlHandsSinceUse = 3
    var burnControlUses = 0
    var smallBetWinStreak = 0
    var consecutiveLosses = 0
    var lastRoundDidWin = false
    var lastBetAmountCents = 0
    var hasMovedCardThisStage = false
    var xRayChargesRemainingThisStage = 0
    var isXRayActiveForNextHand = false
    var isGuidedFirstRun: Bool
    var guidedExcitingWinDelivered = false
    var hasOfferedGuidedUpgrade = false
    var runStartedAt = Date()

    init(configuration: RunConfiguration = RunConfiguration(
        startingBankrollCents: RunManager.defaultStartingBankrollCents,
        chipRewardMultiplierPercent: 100,
        startingUpgradeNames: [],
        activeRunModifierIDs: [],
        challengeID: .standard,
        isDailyRun: false,
        dailySeed: nil,
        themeID: .lasVegas,
        isGuidedFirstRun: true
    )) {
        self.bankrollCents = configuration.startingBankrollCents
        self.runManager = RunManager(startingBankrollCents: configuration.startingBankrollCents)
        self.chipRewardMultiplierPercent = configuration.chipRewardMultiplierPercent
        self.challengeID = configuration.challengeID
        self.isDailyRun = configuration.isDailyRun
        self.dailySeed = configuration.dailySeed
        self.seededGenerator = configuration.dailySeed.map(SeededRandomGenerator.init(seed:))
        self.themeID = configuration.themeID
        self.isGuidedFirstRun = configuration.isGuidedFirstRun
        self.acquiredUpgrades = configuration.startingUpgradeNames.compactMap { name in
            UpgradeCard.allCards.first { $0.name == name }?.copyForAcquisition()
        }

        if configuration.challengeID == .tieOnly {
            self.selectedBetType = .tie
        } else if configuration.challengeID == .bankerOnly {
            self.selectedBetType = .banker
        } else if configuration.challengeID == .playerOnly {
            self.selectedBetType = .player
        }

        if configuration.dailySeed != nil {
            var generator = self.seededGenerator
            self.shoe = Shoe(deckCount: 6, seededGenerator: &generator)
            self.seededGenerator = generator
        }
    }
}
