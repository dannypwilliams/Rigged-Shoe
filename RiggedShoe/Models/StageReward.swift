import Foundation

enum StageRewardEffect: Equatable {
    case gainCash(cents: Int)
    case removeRandomAcquiredUpgrade
    case duplicateRandomAcquiredUpgrade
    case addRandomUpgrade(rarity: UpgradeRarity)
    case increaseTiePayout(amount: Int)
    case addRandomHighValueCards(count: Int)
    case removeRandomFaceCards(count: Int)
}

struct StageReward: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let effect: StageRewardEffect

    init(id: UUID = UUID(), name: String, description: String, effect: StageRewardEffect) {
        self.id = id
        self.name = name
        self.description = description
        self.effect = effect
    }

    static var allRewards: [StageReward] {
        [
            StageReward(
                name: "Pocket $25",
                description: "Gain $25 immediately.",
                effect: .gainCash(cents: 2_500)
            ),
            StageReward(
                name: "Pocket $40",
                description: "Gain $40 immediately.",
                effect: .gainCash(cents: 4_000)
            ),
            StageReward(
                name: "Pocket $75",
                description: "Gain $75 immediately.",
                effect: .gainCash(cents: 7_500)
            ),
            StageReward(
                name: "Pocket $125",
                description: "Gain $125 immediately.",
                effect: .gainCash(cents: 12_500)
            ),
            StageReward(
                name: "Clean Slate",
                description: "Remove one random acquired upgrade.",
                effect: .removeRandomAcquiredUpgrade
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
            case .gainCash, .increaseTiePayout, .addRandomHighValueCards, .removeRandomFaceCards:
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
