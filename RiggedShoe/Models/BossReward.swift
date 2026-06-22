import Foundation

enum BossRewardEffect: Equatable {
    case doublePlayerBonuses
    case doubleBankerBonuses
    case addRandomHighValueCards(count: Int)
    case revealCardsPermanently(count: Int)
    case setTiePayout(multiplier: Int)
    case gainCash(cents: Int)
    case gainAnteScaledCash(multiplierPercent: Int, chips: Int)
    case duplicateRandomUpgrades(count: Int)
    case removeAllFaceCards
    case addRandomLegendaryUpgrade
    case casinoInsideContact(extraRounds: Int)
    case grantBossRelic(id: String)
}

struct BossReward: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let effect: BossRewardEffect

    init(id: UUID = UUID(), name: String, description: String, effect: BossRewardEffect) {
        self.id = id
        self.name = name
        self.description = description
        self.effect = effect
    }

    static var allRewards: [BossReward] {
        [
            BossReward(
                name: "Player Consortium",
                description: "Double all Player Bonus values.",
                effect: .doublePlayerBonuses
            ),
            BossReward(
                name: "Banker Consortium",
                description: "Double all Banker Bonus values.",
                effect: .doubleBankerBonuses
            ),
            BossReward(
                name: "High Roller Shoe",
                description: "Add 20 random 8s and 9s to the shoe.",
                effect: .addRandomHighValueCards(count: 20)
            ),
            BossReward(
                name: "Open Ledger",
                description: "Reveal 15 cards permanently.",
                effect: .revealCardsPermanently(count: 15)
            ),
            BossReward(
                name: "Tie Conspiracy",
                description: "Tie payout becomes 30:1.",
                effect: .setTiePayout(multiplier: 30)
            ),
            BossReward(
                name: "Vault Leak",
                description: "Gain up to 5x the boss ante and 6 Chips, capped by your current bankroll.",
                effect: .gainAnteScaledCash(multiplierPercent: 500, chips: 6)
            ),
            BossReward(
                name: "Echo Chamber",
                description: "Duplicate 3 random acquired upgrades.",
                effect: .duplicateRandomUpgrades(count: 3)
            ),
            BossReward(
                name: "Face Card Blackout",
                description: "Remove all J, Q, and K cards from the current shoe.",
                effect: .removeAllFaceCards
            ),
            BossReward(
                name: "Legendary Wire",
                description: "Gain one random legendary upgrade.",
                effect: .addRandomLegendaryUpgrade
            ),
            BossReward(
                name: "Pit Boss Nod",
                description: "Gain the Pit Boss Nod relic: once per stage, ignore a repeated-side Heat penalty.",
                effect: .grantBossRelic(id: "relic.pit-boss-nod")
            ),
            BossReward(
                name: "Vault Key",
                description: "Gain the Vault Key relic: boss clears grant extra Chips.",
                effect: .grantBossRelic(id: "relic.vault-key")
            ),
            BossReward(
                name: "Private Room",
                description: "Gain the Private Room relic: private table rewards are richer.",
                effect: .grantBossRelic(id: "relic.private-room")
            ),
            BossReward(
                name: "Surveillance Loop",
                description: "Gain the Surveillance Loop relic: soften the first reveal suppression each stage.",
                effect: .grantBossRelic(id: "relic.surveillance-loop")
            ),
            BossReward(
                name: "Casino Inside Contact",
                description: "Every future stage starts with +3 rounds remaining.",
                effect: .casinoInsideContact(extraRounds: 3)
            )
        ]
    }

    static func randomChoices(
        count: Int = 3,
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String> = Set(allRewards.map(\.name)),
        unlockedUpgradeCards: [UpgradeCard] = UpgradeCard.allCards
    ) -> [BossReward] {
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
    ) -> [BossReward] {
        let viableRewards = allRewards.filter { reward in
            guard unlockedRewardNames.contains(reward.name) else {
                return false
            }

            switch reward.effect {
            case .duplicateRandomUpgrades:
                return !acquiredUpgrades.isEmpty
            case .addRandomLegendaryUpgrade:
                return unlockedUpgradeCards.contains { $0.rarity == .legendary }
            case .doublePlayerBonuses,
                 .doubleBankerBonuses,
                 .addRandomHighValueCards,
                 .revealCardsPermanently,
                 .setTiePayout,
                 .gainCash,
                 .gainAnteScaledCash,
                 .removeAllFaceCards,
                 .casinoInsideContact,
                 .grantBossRelic:
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
