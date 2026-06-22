import Foundation

enum CollectionEntryKind: String, Equatable {
    case upgrade
    case boss
    case achievement
    case stageReward
    case bossReward
    case runModifier
    case futureHook

    var displayName: String {
        switch self {
        case .upgrade:
            return "Upgrade"
        case .boss:
            return "Boss"
        case .achievement:
            return "Achievement"
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
}

struct CollectionEntry: Identifiable, Equatable {
    let id: String
    let kind: CollectionEntryKind
    let title: String
    let subtitle: String
    let description: String
    let rarity: UpgradeRarity?
    let isUnlocked: Bool
    let isEncountered: Bool
    let isDefeated: Bool

    var stateText: String {
        switch kind {
        case .boss:
            if isDefeated {
                return "Defeated"
            }

            return isEncountered ? "Encountered" : "Unknown"
        case .achievement:
            return isUnlocked ? "Claimed" : "Locked"
        case .upgrade, .stageReward, .bossReward, .runModifier, .futureHook:
            return isUnlocked ? "Unlocked" : "Locked"
        }
    }

    var countsTowardCompletion: Bool {
        switch kind {
        case .boss:
            return isDefeated
        case .achievement, .upgrade, .stageReward, .bossReward, .runModifier, .futureHook:
            return isUnlocked
        }
    }
}
