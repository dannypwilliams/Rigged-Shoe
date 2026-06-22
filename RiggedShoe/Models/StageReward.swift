import Foundation

enum StageRewardEffect: Codable, Equatable {
    case gainCash(cents: Int)
    case gainAnteScaledCash(multiplierPercent: Int)
    case gainChips(amount: Int)
    case reduceHeat(amount: Int)
    case removeRandomAcquiredUpgrade
    case duplicateRandomAcquiredUpgrade
    case addRandomUpgrade(rarity: UpgradeRarity)
    case increaseTiePayout(amount: Int)
    case addRandomHighValueCards(count: Int)
    case removeRandomFaceCards(count: Int)
}

/// How a reward is expected to be presented in the rebuilt battle/shop loop.
///
/// Existing gameplay still uses `legacyStageClear`. Future stages can mark
/// whether a reward belongs to normal battle clears, boss clears, or shop
/// bonuses without changing the reward screen view model again.
enum StageRewardRole: String, Codable, Equatable {
    case legacyStageClear
    case battleClear
    case bossClear
    case shopBonus
    case heatRelief
}

/// Data-driven payloads for the rebuilt reward layer.
///
/// The current app continues to use `StageRewardEffect`. This optional payload
/// is a bridge toward the Super Auto Pets-style reward/shop phase where rewards
/// may grant Chips, Heat relief, modifiers, consumables, attachments, or relics.
enum RebuildStageRewardEffect: Codable, Equatable {
    case bankroll(cents: Int)
    case chips(amount: Int)
    case heatReduction(amount: Int)
    case modifierDraft(rarity: ModifierRarity?)
    case consumableDraft
    case attachmentDraft
    case bossRelicDraft
    case shopDiscount(percent: Int)
}

struct StageReward: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let effect: StageRewardEffect
    let role: StageRewardRole
    let rebuildEffect: RebuildStageRewardEffect?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        effect: StageRewardEffect,
        role: StageRewardRole = .legacyStageClear,
        rebuildEffect: RebuildStageRewardEffect? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.effect = effect
        self.role = role
        self.rebuildEffect = rebuildEffect
    }

    static var allRewards: [StageReward] {
        [
            StageReward(
                name: "Ante Kickback",
                description: "Gain bankroll equal to 1x this stage's ante, capped by current bankroll.",
                effect: .gainAnteScaledCash(multiplierPercent: 100)
            ),
            StageReward(
                name: "Table Comp",
                description: "Gain bankroll equal to 1.5x this stage's ante, capped by current bankroll.",
                effect: .gainAnteScaledCash(multiplierPercent: 150)
            ),
            StageReward(
                name: "Chip Runner",
                description: "Gain 2 Chips for the next shop.",
                effect: .gainChips(amount: 2)
            ),
            StageReward(
                name: "High Table Cut",
                description: "Gain bankroll equal to 2x this stage's ante, capped by current bankroll.",
                effect: .gainAnteScaledCash(multiplierPercent: 200)
            ),
            StageReward(
                name: "Cool Down",
                description: "Reduce Heat by 2.",
                effect: .reduceHeat(amount: 2)
            ),
            StageReward(
                name: "Double Down",
                description: "Duplicate one random acquired upgrade.",
                effect: .duplicateRandomAcquiredUpgrade
            ),
            StageReward(
                name: "Rare Contact",
                description: "Add one random rare shoe upgrade.",
                effect: .addRandomUpgrade(rarity: .rare)
            ),
            StageReward(
                name: "Legendary Contact",
                description: "Add one random legendary shoe upgrade.",
                effect: .addRandomUpgrade(rarity: .legendary)
            ),
            StageReward(
                name: "Tie Pressure",
                description: "Increase Tie payout by +2.",
                effect: .increaseTiePayout(amount: 2)
            ),
            StageReward(
                name: "High Card Drop",
                description: "Add 8 random 8s and 9s to the shoe.",
                effect: .addRandomHighValueCards(count: 8)
            ),
            StageReward(
                name: "Face Sweep",
                description: "Remove 8 random J, Q, or K cards.",
                effect: .removeRandomFaceCards(count: 8)
            )
        ]
    }

    static func randomChoices(
        count: Int = 3,
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String> = Set(allRewards.map(\.name)),
        unlockedUpgradeCards: [UpgradeCard] = UpgradeCard.allCards
    ) -> [StageReward] {
        var generator: SeededRandomGenerator?
        return randomChoices(
            count: count,
            acquiredUpgrades: acquiredUpgrades,
            unlockedRewardNames: unlockedRewardNames,
            unlockedUpgradeCards: unlockedUpgradeCards,
            seededGenerator: &generator
        )
    }

    static func randomChoices(
        count: Int = 3,
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String> = Set(allRewards.map(\.name)),
        unlockedUpgradeCards: [UpgradeCard] = UpgradeCard.allCards,
        seededGenerator: inout SeededRandomGenerator?
    ) -> [StageReward] {
        let viableRewards = allRewards.filter { reward in
            guard unlockedRewardNames.contains(reward.name) else {
                return false
            }

            switch reward.effect {
            case .removeRandomAcquiredUpgrade, .duplicateRandomAcquiredUpgrade:
                return !acquiredUpgrades.isEmpty
            case .addRandomUpgrade(let rarity):
                return unlockedUpgradeCards.contains { $0.rarity == rarity }
            case .gainCash, .gainAnteScaledCash, .gainChips, .reduceHeat, .increaseTiePayout, .addRandomHighValueCards, .removeRandomFaceCards:
                return true
            }
        }

        if var generator = seededGenerator {
            let rewards = viableRewards.seededShuffled(using: &generator)
            seededGenerator = generator
            return Array(rewards.prefix(count))
        }

        return Array(viableRewards.shuffled().prefix(count))
    }
}
