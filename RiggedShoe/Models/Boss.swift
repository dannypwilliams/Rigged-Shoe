import Foundation

enum BossDifficulty: String, Codable {
    case miniBoss
    case majorBoss

    var displayName: String {
        switch self {
        case .miniBoss:
            return "Mini Boss"
        case .majorBoss:
            return "Major Boss"
        }
    }
}

enum BossEffect: Equatable {
    case surveillance
    case automaticShuffler
    case pitBoss(disabledUpgradeCount: Int)
    case tagSuppression(tags: Set<UpgradeTag>, label: String)
    case tieClamp
    case house

    var suppressesReveal: Bool {
        switch self {
        case .surveillance, .house:
            return true
        case .tagSuppression(let tags, _):
            return tags.contains(.reveal)
        case .automaticShuffler, .pitBoss, .tieClamp:
            return false
        }
    }

    var shufflesAfterEveryRound: Bool {
        switch self {
        case .automaticShuffler, .house:
            return true
        case .surveillance, .pitBoss, .tagSuppression, .tieClamp:
            return false
        }
    }

    var usesPitBossUpgradeDisable: Bool {
        switch self {
        case .pitBoss, .house:
            return true
        case .surveillance, .automaticShuffler, .tagSuppression, .tieClamp:
            return false
        }
    }

    var disabledUpgradeCount: Int {
        switch self {
        case .pitBoss(let count):
            return count
        case .house:
            return 3
        case .surveillance, .automaticShuffler, .tagSuppression, .tieClamp:
            return 0
        }
    }

    var suppressedTags: Set<UpgradeTag> {
        switch self {
        case .surveillance:
            return [.reveal]
        case .tagSuppression(let tags, _):
            return tags
        case .tieClamp:
            return [.tie]
        case .house:
            return [.reveal, .tie]
        case .automaticShuffler, .pitBoss:
            return []
        }
    }

    var restoresBankerCommission: Bool {
        switch self {
        case .house:
            return true
        case .surveillance, .automaticShuffler, .pitBoss, .tagSuppression, .tieClamp:
            return false
        }
    }

    var capsTiePayoutAtBase: Bool {
        switch self {
        case .house, .tieClamp:
            return true
        case .surveillance, .automaticShuffler, .pitBoss, .tagSuppression:
            return false
        }
    }

    var ruleDescriptions: [String] {
        switch self {
        case .surveillance:
            return ["All Reveal upgrades are suppressed this stage."]
        case .automaticShuffler:
            return ["The remaining shoe shuffles after every round.", "Hot Shoe and Cold Shoe trigger after each shuffle."]
        case .pitBoss(let count):
            return ["\(count) acquired upgrades are disabled this stage."]
        case .tagSuppression(let tags, let label):
            return ["\(label) upgrades are disabled this stage.", "Suppressed tags: \(tags.map(\.displayName).sorted().joined(separator: ", "))."]
        case .tieClamp:
            return ["Tie upgrades are disabled.", "Tie payout is capped at 8:1 this stage."]
        case .house:
            return [
                "Reveal and Tie upgrades are suppressed.",
                "The remaining shoe shuffles after every round.",
                "3 acquired upgrades are disabled.",
                "Banker commission is restored.",
                "Tie payout is capped at 8:1."
            ]
        }
    }
}

struct Boss: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let iconName: String
    let difficulty: BossDifficulty
    let effect: BossEffect

    var effectText: String {
        effect.ruleDescriptions.joined(separator: "\n")
    }

    static let surveillance = Boss(
        id: 1,
        name: "Surveillance",
        description: "Casino cameras have noticed unusual play.",
        iconName: "video.fill",
        difficulty: .miniBoss,
        effect: .surveillance
    )

    static let automaticShuffler = Boss(
        id: 2,
        name: "Automatic Shuffler",
        description: "The casino installs continuous shuffling machines.",
        iconName: "shuffle",
        difficulty: .miniBoss,
        effect: .automaticShuffler
    )

    static let pitBoss = Boss(
        id: 3,
        name: "Pit Boss",
        description: "Management targets your strongest advantages.",
        iconName: "person.crop.circle.badge.exclamationmark",
        difficulty: .majorBoss,
        effect: .pitBoss(disabledUpgradeCount: 3)
    )

    static let house = Boss(
        id: 4,
        name: "The House",
        description: "The casino fights back with every trick available.",
        iconName: "building.columns.fill",
        difficulty: .majorBoss,
        effect: .house
    )

    static let nullLens = Boss(
        id: 5,
        name: "Null Lens",
        description: "A counter-surveillance crew blanks every marked card feed.",
        iconName: "eye.slash.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.reveal], label: "Reveal")
    )

    static let tieTaxAuditor = Boss(
        id: 6,
        name: "Tie Tax Auditor",
        description: "The casino audits every suspicious push and tie payout.",
        iconName: "equal.circle.fill",
        difficulty: .majorBoss,
        effect: .tieClamp
    )

    static let compController = Boss(
        id: 7,
        name: "Comp Controller",
        description: "The VIP desk shuts down your freebies and side income.",
        iconName: "creditcard.trianglebadge.exclamationmark.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.economy], label: "Economy")
    )

    static let streakBreaker = Boss(
        id: 8,
        name: "Streak Breaker",
        description: "The floor manager interrupts every hot run.",
        iconName: "bolt.slash.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.streak], label: "Streak")
    )

    static let shoeInspector = Boss(
        id: 9,
        name: "Shoe Inspector",
        description: "The casino weighs the shoe and hunts loaded-card patterns.",
        iconName: "rectangle.stack.badge.minus.fill",
        difficulty: .majorBoss,
        effect: .tagSuppression(tags: [.shoe], label: "Shoe manipulation")
    )

    static let riskManager = Boss(
        id: 10,
        name: "Risk Manager",
        description: "The casino clamps down on reckless high-limit action.",
        iconName: "exclamationmark.triangle.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.risk], label: "Risk")
    )

    static let bankerBlacklist = Boss(
        id: 11,
        name: "Banker Blacklist",
        description: "The table blocks your Banker-side advantages.",
        iconName: "building.columns.circle.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.banker], label: "Banker")
    )

    static let playerLockout = Boss(
        id: 12,
        name: "Player Lockout",
        description: "The pit watches every Player-side angle.",
        iconName: "person.crop.circle.badge.xmark.fill",
        difficulty: .miniBoss,
        effect: .tagSuppression(tags: [.player], label: "Player")
    )

    static let omenDealer = Boss(
        id: 13,
        name: "Omen Dealer",
        description: "A superstitious dealer punishes Tie and Streak builds together.",
        iconName: "moon.stars.fill",
        difficulty: .majorBoss,
        effect: .tagSuppression(tags: [.tie, .streak], label: "Tie and Streak")
    )

    static var allBosses: [Boss] {
        [
            surveillance,
            automaticShuffler,
            pitBoss,
            house,
            nullLens,
            tieTaxAuditor,
            compController,
            streakBreaker,
            shoeInspector,
            riskManager,
            bankerBlacklist,
            playerLockout,
            omenDealer
        ]
    }

    static var randomBossPool: [Boss] {
        allBosses.filter { $0.id != house.id }
    }
}
