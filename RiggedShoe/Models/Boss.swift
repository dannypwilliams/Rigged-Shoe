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
    case inspector
    case tagSuppression(tags: Set<UpgradeTag>, label: String)
    case tieClamp
    case house

    var suppressesReveal: Bool {
        switch self {
        case .surveillance:
            return true
        case .tagSuppression(let tags, _):
            return tags.contains(.reveal)
        case .automaticShuffler, .pitBoss, .inspector, .tieClamp, .house:
            return false
        }
    }

    var shufflesAfterEveryRound: Bool {
        switch self {
        case .automaticShuffler, .house:
            return true
        case .surveillance, .pitBoss, .inspector, .tagSuppression, .tieClamp:
            return false
        }
    }

    var usesPitBossUpgradeDisable: Bool {
        switch self {
        case .surveillance, .automaticShuffler, .pitBoss, .inspector, .tagSuppression, .tieClamp, .house:
            return false
        }
    }

    var disabledUpgradeCount: Int {
        switch self {
        case .pitBoss(let count):
            return count
        case .surveillance, .automaticShuffler, .inspector, .tagSuppression, .tieClamp, .house:
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
        case .automaticShuffler, .pitBoss, .inspector, .house:
            return []
        }
    }

    var restoresBankerCommission: Bool {
        switch self {
        case .house:
            return true
        case .surveillance, .automaticShuffler, .pitBoss, .inspector, .tagSuppression, .tieClamp:
            return false
        }
    }

    var capsTiePayoutAtBase: Bool {
        switch self {
        case .house, .tieClamp:
            return true
        case .surveillance, .automaticShuffler, .pitBoss, .inspector, .tagSuppression:
            return false
        }
    }

    var ruleDescriptions: [String] {
        switch self {
        case .surveillance:
            return ["All Reveal upgrades are suppressed this stage."]
        case .automaticShuffler:
            return ["The remaining shoe shuffles after every round.", "Hot Shoe and Cold Shoe trigger after each shuffle."]
        case .pitBoss:
            return [
                "Betting the same side 4 times in a row adds 1 Heat.",
                "Repeated-side betting gives the opponent a small score boost."
            ]
        case .inspector:
            return [
                "Reveal and shoe-control effects are reduced by 1 card or flagged once.",
                "The first reveal or shoe-control action this stage adds 2 Heat.",
                "Flagged shoe manipulation gives the opponent a score boost."
            ]
        case .tagSuppression(let tags, let label):
            return ["\(label) upgrades are disabled this stage.", "Suppressed tags: \(tags.map(\.displayName).sorted().joined(separator: ", "))."]
        case .tieClamp:
            return ["Tie upgrades are disabled.", "Tie payout is capped at 8:1 this stage."]
        case .house:
            return [
                "Repeating a bet side draws Pit Boss Heat.",
                "Reveal and shoe-control tools draw Inspector Heat once.",
                "The remaining shoe shuffles after every round.",
                "Banker commission is restored.",
                "Tie payout is capped at 8:1.",
                "The House adapts once to your dominant modifier tag."
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
        description: "Management watches obvious betting patterns.",
        iconName: "person.crop.circle.badge.exclamationmark",
        difficulty: .majorBoss,
        effect: .pitBoss(disabledUpgradeCount: 0)
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
        name: "The Inspector",
        description: "The casino audits every reveal, burn, and suspicious shoe touch.",
        iconName: "rectangle.stack.badge.minus.fill",
        difficulty: .majorBoss,
        effect: .inspector
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

    static let whale = Boss(
        id: 14,
        name: "The Whale",
        description: "A high-limit regular pressures reckless bankroll spikes.",
        iconName: "dollarsign.circle.fill",
        difficulty: .majorBoss,
        effect: .tagSuppression(tags: [.risk], label: "High Roller")
    )

    static let insider = Boss(
        id: 15,
        name: "The Insider",
        description: "Someone else knows the shoe before you do.",
        iconName: "person.text.rectangle.fill",
        difficulty: .majorBoss,
        effect: .inspector
    )

    static let auditor = Boss(
        id: 16,
        name: "The Auditor",
        description: "Every free dollar and comped chip gets scrutinized.",
        iconName: "doc.text.magnifyingglass",
        difficulty: .majorBoss,
        effect: .tagSuppression(tags: [.economy], label: "Economy")
    )

    static let collector = Boss(
        id: 17,
        name: "The Collector",
        description: "Debt, Heat, and unpaid favors come due.",
        iconName: "tray.full.fill",
        difficulty: .majorBoss,
        effect: .tagSuppression(tags: [.comeback, .economy], label: "Debt and Comeback")
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
            omenDealer,
            whale,
            insider,
            auditor,
            collector
        ]
    }

    static var randomBossPool: [Boss] {
        allBosses.filter { $0.id != house.id }
    }
}
