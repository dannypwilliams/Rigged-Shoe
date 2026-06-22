import Foundation

enum RunModifierID: String, CaseIterable, Codable, Identifiable {
    case highRoller
    case lowRoller
    case openingTell
    case tieChaser

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .highRoller:
            return "High Roller"
        case .lowRoller:
            return "Low Roller"
        case .openingTell:
            return "Opening Tell"
        case .tieChaser:
            return "Tie Chaser"
        }
    }

    var description: String {
        switch self {
        case .highRoller:
            return "Start each run with $5,000."
        case .lowRoller:
            return "Start each run with $500 and earn 50% more Chips from run rewards."
        case .openingTell:
            return "Start each run with Marked Shoe."
        case .tieChaser:
            return "Start each run with Tie Hunter."
        }
    }

    var costChips: Int {
        switch self {
        case .highRoller:
            return 2_000
        case .lowRoller:
            return 1_000
        case .openingTell:
            return 3_000
        case .tieChaser:
            return 5_000
        }
    }

    var costReputation: Int {
        0
    }

    var startingBankrollCents: Int? {
        switch self {
        case .highRoller:
            return 500_000
        case .lowRoller:
            return 50_000
        case .openingTell, .tieChaser:
            return nil
        }
    }

    var chipRewardMultiplierPercent: Int {
        switch self {
        case .lowRoller:
            return 150
        case .highRoller, .openingTell, .tieChaser:
            return 100
        }
    }

    var startingUpgradeNames: [String] {
        switch self {
        case .openingTell:
            return ["Marked Shoe"]
        case .tieChaser:
            return ["Tie Hunter"]
        case .highRoller, .lowRoller:
            return []
        }
    }

    var conflictingIDs: Set<RunModifierID> {
        switch self {
        case .highRoller:
            return [.lowRoller]
        case .lowRoller:
            return [.highRoller]
        case .openingTell, .tieChaser:
            return []
        }
    }
}

enum UnlockableContent: Equatable {
    case upgrade(name: String)
    case stageReward(name: String)
    case bossReward(name: String)
    case runModifier(id: RunModifierID)
    case futureHook(id: String)
}

struct Unlockable: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let costChips: Int
    let costReputation: Int
    let content: UnlockableContent

    var categoryName: String {
        switch content {
        case .upgrade:
            return "Upgrade"
        case .stageReward:
            return "Stage Reward"
        case .bossReward:
            return "Boss Reward"
        case .runModifier:
            return "Run Modifier"
        case .futureHook:
            return "Future Hook"
        }
    }

    func isUnlocked(in profile: PlayerProfile) -> Bool {
        switch content {
        case .upgrade(let name):
            return profile.unlockedUpgradeNames.contains(name)
        case .stageReward(let name):
            return profile.unlockedStageRewardNames.contains(name)
        case .bossReward(let name):
            return profile.unlockedBossRewardNames.contains(name)
        case .runModifier(let id):
            return profile.unlockedRunModifierIDs.contains(id.rawValue)
        case .futureHook(let id):
            return profile.unlockedFutureHookIDs.contains(id)
        }
    }

    func canAfford(with profile: PlayerProfile) -> Bool {
        profile.casinoChips >= costChips && profile.reputation >= costReputation
    }

    static var allUnlockables: [Unlockable] {
        upgradeUnlockables + stageRewardUnlockables + bossRewardUnlockables + runModifierUnlockables + futureHookUnlockables
    }

    private static var upgradeUnlockables: [Unlockable] {
        UpgradeCard.allCards.map { card in
            Unlockable(
                id: "upgrade.\(card.name)",
                name: card.name,
                description: card.description,
                costChips: card.rarity.unlockCostChips,
                costReputation: 0,
                content: .upgrade(name: card.name)
            )
        }
    }

    private static var stageRewardUnlockables: [Unlockable] {
        [
            Unlockable(
                id: "stageReward.Pocket125",
                name: "Pocket $125",
                description: "Adds a stronger but still controlled cash reward to stage reward choices.",
                costChips: 1_000,
                costReputation: 0,
                content: .stageReward(name: "Pocket $125")
            ),
            Unlockable(
                id: "stageReward.LegendaryContact",
                name: "Legendary Contact",
                description: "Adds a legendary upgrade reward to stage reward choices.",
                costChips: 2_500,
                costReputation: 1,
                content: .stageReward(name: "Legendary Contact")
            ),
            Unlockable(
                id: "stageReward.TiePressure",
                name: "Tie Pressure",
                description: "Adds a permanent Tie payout stage reward.",
                costChips: 1_500,
                costReputation: 0,
                content: .stageReward(name: "Tie Pressure")
            ),
            Unlockable(
                id: "stageReward.HighCardDrop",
                name: "High Card Drop",
                description: "Adds a shoe-loading stage reward.",
                costChips: 1_000,
                costReputation: 0,
                content: .stageReward(name: "High Card Drop")
            ),
            Unlockable(
                id: "stageReward.FaceSweep",
                name: "Face Sweep",
                description: "Adds a face-card removal stage reward.",
                costChips: 1_000,
                costReputation: 0,
                content: .stageReward(name: "Face Sweep")
            )
        ]
    }

    private static var bossRewardUnlockables: [Unlockable] {
        [
            Unlockable(
                id: "bossReward.OpenLedger",
                name: "Open Ledger",
                description: "Adds permanent 15-card reveal boss rewards.",
                costChips: 3_000,
                costReputation: 1,
                content: .bossReward(name: "Open Ledger")
            ),
            Unlockable(
                id: "bossReward.TieConspiracy",
                name: "Tie Conspiracy",
                description: "Adds 30:1 Tie payout boss rewards.",
                costChips: 5_000,
                costReputation: 2,
                content: .bossReward(name: "Tie Conspiracy")
            ),
            Unlockable(
                id: "bossReward.EchoChamber",
                name: "Echo Chamber",
                description: "Adds a boss reward that duplicates 3 random upgrades.",
                costChips: 2_500,
                costReputation: 0,
                content: .bossReward(name: "Echo Chamber")
            ),
            Unlockable(
                id: "bossReward.LegendaryWire",
                name: "Legendary Wire",
                description: "Adds a boss reward that grants a random legendary upgrade.",
                costChips: 4_000,
                costReputation: 2,
                content: .bossReward(name: "Legendary Wire")
            ),
            Unlockable(
                id: "bossReward.CasinoInsideContact",
                name: "Casino Inside Contact",
                description: "Adds a boss reward that gives future stages +3 rounds.",
                costChips: 6_000,
                costReputation: 3,
                content: .bossReward(name: "Casino Inside Contact")
            )
        ]
    }

    private static var runModifierUnlockables: [Unlockable] {
        RunModifierID.allCases.map { modifier in
            Unlockable(
                id: "runModifier.\(modifier.rawValue)",
                name: modifier.name,
                description: modifier.description,
                costChips: modifier.costChips,
                costReputation: modifier.costReputation,
                content: .runModifier(id: modifier)
            )
        }
    }

    private static var futureHookUnlockables: [Unlockable] {
        [
            Unlockable(
                id: "futureHook.privateTable",
                name: "Private Table License",
                description: "Future content hook for special high-stakes tables.",
                costChips: 7_500,
                costReputation: 5,
                content: .futureHook(id: "privateTable")
            ),
            Unlockable(
                id: "futureHook.backroomLedger",
                name: "Backroom Ledger",
                description: "Future content hook for late-run contract systems.",
                costChips: 10_000,
                costReputation: 8,
                content: .futureHook(id: "backroomLedger")
            )
        ]
    }
}

extension UpgradeRarity {
    var unlockCostChips: Int {
        switch self {
        case .common:
            return 250
        case .rare:
            return 1_000
        case .legendary:
            return 5_000
        }
    }
}
