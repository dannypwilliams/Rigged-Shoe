import Foundation

enum UpgradeTag: String, CaseIterable, Codable, Hashable {
    case player
    case banker
    case tie
    case streak
    case reveal
    case shoe
    case economy
    case risk
    case conservative
    case aggressive
    case comeback
    case dealerExploit
    case boss
    case legendary

    var displayName: String {
        switch self {
        case .dealerExploit:
            return "Dealer Exploit"
        default:
            return rawValue.capitalized
        }
    }
}

struct SeededRandomGenerator: RandomNumberGenerator, Codable, Equatable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}

extension Array {
    func seededShuffled(using generator: inout SeededRandomGenerator) -> [Element] {
        var copy = self

        guard copy.count > 1 else {
            return copy
        }

        for index in copy.indices.dropLast().reversed() {
            let randomIndex = Int(generator.next() % UInt64(index + 1))
            copy.swapAt(index, randomIndex)
        }

        return copy
    }

    func seededRandomElement(using generator: inout SeededRandomGenerator) -> Element? {
        guard !isEmpty else {
            return nil
        }

        return self[Int(generator.next() % UInt64(count))]
    }
}

enum ChallengeModeID: String, CaseIterable, Codable, Identifiable {
    case standard
    case tieOnly
    case bankerOnly
    case playerOnly
    case noReveal
    case highRoller
    case bossRush

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .standard:
            return "Standard"
        case .tieOnly:
            return "Tie Only"
        case .bankerOnly:
            return "Banker Only"
        case .playerOnly:
            return "Player Only"
        case .noReveal:
            return "No Reveal"
        case .highRoller:
            return "High Roller"
        case .bossRush:
            return "Boss Rush"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "The normal casino ladder."
        case .tieOnly:
            return "Only Tie bets are allowed. Extra Chips on completion."
        case .bankerOnly:
            return "Only Banker bets are allowed. Extra Chips on completion."
        case .playerOnly:
            return "Only Player bets are allowed. Extra Chips on completion."
        case .noReveal:
            return "All reveal effects are suppressed. Extra Chips on completion."
        case .highRoller:
            return "Start with $5,000, but losses hurt more. Extra Chips on completion."
        case .bossRush:
            return "Every stage is a boss stage. Big extra Chips on completion."
        }
    }

    var tableRuleSummary: String {
        switch self {
        case .standard:
            return "Allowed bets: Player, Banker, Tie"
        case .tieOnly:
            return "Allowed bets: Tie only"
        case .bankerOnly:
            return "Allowed bets: Banker only"
        case .playerOnly:
            return "Allowed bets: Player only"
        case .noReveal:
            return "Allowed bets: all; reveal effects off"
        case .highRoller:
            return "Allowed bets: all; starts at $5,000"
        case .bossRush:
            return "Allowed bets: all; every stage is a boss"
        }
    }

    var chipRewardMultiplierPercent: Int {
        switch self {
        case .standard:
            return 100
        case .tieOnly, .bankerOnly, .playerOnly:
            return 125
        case .noReveal, .highRoller:
            return 150
        case .bossRush:
            return 200
        }
    }

    var startingBankrollCents: Int? {
        switch self {
        case .highRoller:
            return 500_000
        case .standard, .tieOnly, .bankerOnly, .playerOnly, .noReveal, .bossRush:
            return nil
        }
    }

    func allowsBet(_ betType: BetType) -> Bool {
        switch self {
        case .standard, .noReveal, .highRoller, .bossRush:
            return true
        case .tieOnly:
            return betType == .tie
        case .bankerOnly:
            return betType == .banker
        case .playerOnly:
            return betType == .player
        }
    }
}

struct ChallengeRecord: Codable, Equatable {
    var wins: Int = 0
    var bestProfitCents: Int = 0
    var bestStage: Int = 1
    var totalBonusChipsEarned: Int = 0
}

struct DailyRunRecord: Codable, Equatable {
    var dateKey: String = ""
    var bestProfitCents: Int = 0
    var bestStage: Int = 1
    var completed: Bool = false
}

struct LeaderboardPlaceholder: Codable, Equatable {
    var dailySeed: UInt64
    var dateKey: String
    var localScoreCents: Int
}

enum CasinoThemeID: String, CaseIterable, Codable, Identifiable {
    case lasVegas
    case macau
    case monteCarlo
    case underground
    case cyber
    case goldRoom

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .lasVegas:
            return "Las Vegas"
        case .macau:
            return "Macau"
        case .monteCarlo:
            return "Monte Carlo"
        case .underground:
            return "Underground Casino"
        case .cyber:
            return "Cyber Casino"
        case .goldRoom:
            return "Gold Room"
        }
    }
}

struct SynergyDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let requiredTag: UpgradeTag
    let requiredCount: Int
    let effects: [UpgradeEffect]

    func isActive(for upgrades: [UpgradeCard]) -> Bool {
        upgrades.filter { $0.tags.contains(requiredTag) }.count >= requiredCount
    }

    static let allSynergies: [SynergyDefinition] = [
        SynergyDefinition(
            id: "tie_master",
            name: "Tie Master",
            description: "3 Tie upgrades: Tie payout gains +3.",
            requiredTag: .tie,
            requiredCount: 3,
            effects: [.tiePayoutBonus(amount: 3)]
        ),
        SynergyDefinition(
            id: "counter_master",
            name: "Counter Master",
            description: "5 Reveal upgrades: reveal +5 cards and gain $25 when your chosen bet wins.",
            requiredTag: .reveal,
            requiredCount: 5,
            effects: [.revealCards(count: 5), .chosenBetWinBonus(cents: 2_500)]
        ),
        SynergyDefinition(
            id: "banker_empire",
            name: "Banker Empire",
            description: "5 Banker upgrades: Banker wins gain +$75 and ignore commission.",
            requiredTag: .banker,
            requiredCount: 5,
            effects: [.bankerWinBonus(cents: 7_500), .noCommission]
        ),
        SynergyDefinition(
            id: "player_coalition",
            name: "Player Coalition",
            description: "5 Player upgrades: Player wins gain +$75 and +25% profit.",
            requiredTag: .player,
            requiredCount: 5,
            effects: [.playerWinBonus(cents: 7_500), .profitMultiplier(betType: .player, percent: 125)]
        ),
        SynergyDefinition(
            id: "shoe_architect",
            name: "Shoe Architect",
            description: "5 Shoe upgrades: every shuffle adds 3 extra 8s and 3 extra 9s.",
            requiredTag: .shoe,
            requiredCount: 5,
            effects: [.hotShoe(extraEights: 3, extraNines: 3)]
        ),
        SynergyDefinition(
            id: "risk_royalty",
            name: "Risk Royalty",
            description: "5 Risk upgrades: wins pay +50% profit, but losses cost 25% extra.",
            requiredTag: .risk,
            requiredCount: 5,
            effects: [.profitMultiplier(betType: nil, percent: 150), .lossMultiplier(percent: 125)]
        ),
        SynergyDefinition(
            id: "economy_engine",
            name: "Economy Engine",
            description: "5 Economy upgrades: gain $50 after every round.",
            requiredTag: .economy,
            requiredCount: 5,
            effects: [.roundStipend(cents: 5_000)]
        ),
        SynergyDefinition(
            id: "boss_slayer",
            name: "Boss Slayer",
            description: "3 Boss upgrades: gain $1,000 when a boss stage begins.",
            requiredTag: .boss,
            requiredCount: 3,
            effects: [.bossStageCash(cents: 100_000)]
        ),
        SynergyDefinition(
            id: "legendary_constellation",
            name: "Legendary Constellation",
            description: "3 Legendary upgrades: reveal +5 and all wins pay +25% profit.",
            requiredTag: .legendary,
            requiredCount: 3,
            effects: [.revealCards(count: 5), .profitMultiplier(betType: nil, percent: 125)]
        )
    ]
}
