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

enum RewardDraftKind: String, Codable, Equatable {
    case normalStage
    case boss
}

enum RewardDraftChoiceType: String, Codable, Equatable {
    case bankroll
    case chips
    case heatRelief
    case modifier
    case consumable
    case attachment
    case bossRelic
    case shoe
    case upgrade

    var displayName: String {
        switch self {
        case .bankroll:
            return "Bankroll"
        case .chips:
            return "Chips"
        case .heatRelief:
            return "Heat Relief"
        case .modifier:
            return "Modifier"
        case .consumable:
            return "Consumable"
        case .attachment:
            return "Attachment"
        case .bossRelic:
            return "Boss Relic"
        case .shoe:
            return "Shoe"
        case .upgrade:
            return "Upgrade"
        }
    }
}

struct RewardDraftChoice: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: RewardDraftChoiceType
    var rarity: ModifierRarity?
    var tags: Set<ModifierTag>
    var fitHint: String

    init(
        id: UUID = UUID(),
        name: String,
        type: RewardDraftChoiceType,
        rarity: ModifierRarity? = nil,
        tags: Set<ModifierTag> = [],
        fitHint: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.rarity = rarity
        self.tags = tags
        self.fitHint = fitHint
    }
}

/// Data model for the quick reward draft between battle and shop.
///
/// The current UI can still render `StageReward` and `BossReward` directly, but
/// this state records the rebuild-facing draft context: stage, boss/normal
/// mode, build tags, reward types, and "why this fits" copy. Future reward UI
/// can bind to this object without changing the battle flow again.
struct RewardDraftState: Identifiable, Codable, Equatable {
    let id: UUID
    var kind: RewardDraftKind
    var stageNumber: Int
    var title: String
    var buildArchetype: String
    var dominantTags: Set<ModifierTag>
    var choices: [RewardDraftChoice]

    init(
        id: UUID = UUID(),
        kind: RewardDraftKind,
        stageNumber: Int,
        title: String,
        buildArchetype: String,
        dominantTags: Set<ModifierTag>,
        choices: [RewardDraftChoice]
    ) {
        self.id = id
        self.kind = kind
        self.stageNumber = stageNumber
        self.title = title
        self.buildArchetype = buildArchetype
        self.dominantTags = dominantTags
        self.choices = choices
    }

    static func stageDraft(
        stage: Stage,
        rewards: [StageReward],
        activeModifiers: [ModifierInstance]
    ) -> RewardDraftState {
        let dominant = dominantTags(from: activeModifiers)
        return RewardDraftState(
            kind: .normalStage,
            stageNumber: stage.id,
            title: "Stage \(stage.id) Reward Draft",
            buildArchetype: BuildArchetypeDetector.detect(activeModifiers: activeModifiers),
            dominantTags: dominant,
            choices: rewards.map { reward in
                RewardDraftChoice(
                    name: reward.name,
                    type: choiceType(for: reward),
                    rarity: rarity(for: reward),
                    tags: tags(for: reward),
                    fitHint: fitHint(tags: tags(for: reward), dominantTags: dominant)
                )
            }
        )
    }

    static func bossDraft(
        stage: Stage,
        rewards: [BossReward],
        activeModifiers: [ModifierInstance]
    ) -> RewardDraftState {
        let dominant = dominantTags(from: activeModifiers)
        return RewardDraftState(
            kind: .boss,
            stageNumber: stage.id,
            title: "Boss Reward Draft",
            buildArchetype: BuildArchetypeDetector.detect(activeModifiers: activeModifiers),
            dominantTags: dominant,
            choices: rewards.map { reward in
                RewardDraftChoice(
                    name: reward.name,
                    type: choiceType(for: reward),
                    rarity: rarity(for: reward),
                    tags: tags(for: reward),
                    fitHint: fitHint(tags: tags(for: reward), dominantTags: dominant)
                )
            }
        )
    }

    static func dominantTags(from activeModifiers: [ModifierInstance]) -> Set<ModifierTag> {
        var counts: [ModifierTag: Int] = [:]
        for instance in activeModifiers {
            guard let modifier = Modifier.definition(id: instance.modifierID) else {
                continue
            }

            for tag in modifier.tags {
                counts[tag, default: 0] += max(1, instance.level)
            }
        }

        return Set(
            counts
                .sorted { lhs, rhs in
                    if lhs.value == rhs.value {
                        return lhs.key.rawValue < rhs.key.rawValue
                    }
                    return lhs.value > rhs.value
                }
                .prefix(3)
                .map(\.key)
        )
    }

    static func tags(for reward: StageReward) -> Set<ModifierTag> {
        if let rebuildEffect = reward.rebuildEffect {
            switch rebuildEffect {
            case .bankroll, .chips, .shopDiscount:
                return [.economy]
            case .heatReduction:
                return [.heat]
            case .modifierDraft:
                return [.economy, .betControl]
            case .consumableDraft:
                return [.consumable]
            case .attachmentDraft:
                return [.attachment]
            case .bossRelicDraft:
                return [.boss]
            }
        }

        switch reward.effect {
        case .gainCash, .gainAnteScaledCash, .gainChips:
            return [.economy]
        case .reduceHeat:
            return [.heat]
        case .addRandomUpgrade:
            return [.economy, .betControl]
        case .increaseTiePayout:
            return [.tie]
        case .addRandomHighValueCards, .removeRandomFaceCards:
            return [.shoeControl, .cardSculpting]
        case .removeRandomAcquiredUpgrade, .duplicateRandomAcquiredUpgrade:
            return [.economy]
        }
    }

    static func tags(for reward: BossReward) -> Set<ModifierTag> {
        switch reward.effect {
        case .doublePlayerBonuses:
            return [.player]
        case .doubleBankerBonuses:
            return [.banker]
        case .addRandomHighValueCards, .removeAllFaceCards:
            return [.shoeControl, .cardSculpting]
        case .revealCardsPermanently:
            return [.shoeVision]
        case .setTiePayout:
            return [.tie]
        case .gainCash, .gainAnteScaledCash:
            return [.economy]
        case .duplicateRandomUpgrades, .addRandomLegendaryUpgrade:
            return [.economy, .boss]
        case .casinoInsideContact, .grantBossRelic:
            return [.boss]
        }
    }

    private static func choiceType(for reward: StageReward) -> RewardDraftChoiceType {
        if let rebuildEffect = reward.rebuildEffect {
            switch rebuildEffect {
            case .bankroll:
                return .bankroll
            case .chips, .shopDiscount:
                return .chips
            case .heatReduction:
                return .heatRelief
            case .modifierDraft:
                return .modifier
            case .consumableDraft:
                return .consumable
            case .attachmentDraft:
                return .attachment
            case .bossRelicDraft:
                return .bossRelic
            }
        }

        switch reward.effect {
        case .gainCash, .gainAnteScaledCash:
            return .bankroll
        case .gainChips:
            return .chips
        case .reduceHeat:
            return .heatRelief
        case .addRandomUpgrade, .duplicateRandomAcquiredUpgrade, .removeRandomAcquiredUpgrade, .increaseTiePayout:
            return .upgrade
        case .addRandomHighValueCards, .removeRandomFaceCards:
            return .shoe
        }
    }

    private static func choiceType(for reward: BossReward) -> RewardDraftChoiceType {
        switch reward.effect {
        case .gainCash, .gainAnteScaledCash:
            return .bankroll
        case .grantBossRelic:
            return .bossRelic
        case .addRandomHighValueCards, .removeAllFaceCards:
            return .shoe
        default:
            return .upgrade
        }
    }

    private static func rarity(for reward: StageReward) -> ModifierRarity? {
        if case .addRandomUpgrade(let rarity) = reward.effect {
            switch rarity {
            case .common: return .common
            case .rare: return .rare
            case .legendary: return .legendary
            }
        }

        if case .modifierDraft(let rarity) = reward.rebuildEffect {
            return rarity
        }

        return nil
    }

    private static func rarity(for reward: BossReward) -> ModifierRarity? {
        switch reward.effect {
        case .addRandomLegendaryUpgrade, .grantBossRelic:
            return .legendary
        case .gainAnteScaledCash, .casinoInsideContact:
            return .rare
        default:
            return nil
        }
    }

    private static func fitHint(tags: Set<ModifierTag>, dominantTags: Set<ModifierTag>) -> String {
        guard !tags.isEmpty else {
            return "Pivot option"
        }

        if !tags.isDisjoint(with: dominantTags) {
            return "Fits your current build"
        }

        return "Off-build pivot"
    }
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
                name: "Modifier Voucher",
                description: "Draft a shop-tier modifier that leans toward your current build.",
                effect: .gainChips(amount: 0),
                role: .battleClear,
                rebuildEffect: .modifierDraft(rarity: nil)
            ),
            StageReward(
                name: "Rare Modifier Voucher",
                description: "Draft a rare modifier if one is available at this point in the run.",
                effect: .gainChips(amount: 0),
                role: .battleClear,
                rebuildEffect: .modifierDraft(rarity: .rare)
            ),
            StageReward(
                name: "Consumable Case",
                description: "Gain a stage-appropriate consumable for the next table.",
                effect: .gainChips(amount: 0),
                role: .battleClear,
                rebuildEffect: .consumableDraft
            ),
            StageReward(
                name: "Attachment Case",
                description: "Apply a compatible attachment to one active modifier.",
                effect: .gainChips(amount: 0),
                role: .battleClear,
                rebuildEffect: .attachmentDraft
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

    static func randomDraftChoices(
        count: Int = 3,
        stage: Stage,
        activeModifiers: [ModifierInstance],
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String> = Set(allRewards.map(\.name)),
        unlockedUpgradeCards: [UpgradeCard] = UpgradeCard.allCards,
        seededGenerator: inout SeededRandomGenerator?
    ) -> [StageReward] {
        let viableRewards = viableRewards(
            acquiredUpgrades: acquiredUpgrades,
            unlockedRewardNames: unlockedRewardNames,
            unlockedUpgradeCards: unlockedUpgradeCards
        )
        guard !viableRewards.isEmpty else {
            return []
        }

        let dominantTags = RewardDraftState.dominantTags(from: activeModifiers)
        let tier = ShopState.tier(for: stage.id)
        var weighted: [StageReward] = []

        for reward in viableRewards {
            let tags = RewardDraftState.tags(for: reward)
            var weight = 1

            if !tags.isDisjoint(with: dominantTags) {
                weight += 2
            }

            if case .modifierDraft(let rarity) = reward.rebuildEffect {
                if rarity == .rare && tier < 2 {
                    weight = 0
                } else {
                    weight += 1
                }
            }

            if case .attachmentDraft = reward.rebuildEffect, activeModifiers.isEmpty {
                weight = 0
            }

            if weight > 0 {
                weighted.append(contentsOf: Array(repeating: reward, count: weight))
            }
        }

        let pool = weighted.isEmpty ? viableRewards : weighted
        let selected = uniqueRandomSelection(
            from: pool,
            count: count,
            fallback: viableRewards,
            seededGenerator: &seededGenerator
        )

        return ensurePivotOption(
            selected,
            from: viableRewards,
            dominantTags: dominantTags,
            seededGenerator: &seededGenerator
        )
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
        let viableRewards = viableRewards(
            acquiredUpgrades: acquiredUpgrades,
            unlockedRewardNames: unlockedRewardNames,
            unlockedUpgradeCards: unlockedUpgradeCards
        )

        if var generator = seededGenerator {
            let rewards = viableRewards.seededShuffled(using: &generator)
            seededGenerator = generator
            return Array(rewards.prefix(count))
        }

        return Array(viableRewards.shuffled().prefix(count))
    }

    private static func viableRewards(
        acquiredUpgrades: [UpgradeCard],
        unlockedRewardNames: Set<String>,
        unlockedUpgradeCards: [UpgradeCard]
    ) -> [StageReward] {
        allRewards.filter { reward in
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
    }

    private static func uniqueRandomSelection(
        from pool: [StageReward],
        count: Int,
        fallback: [StageReward],
        seededGenerator: inout SeededRandomGenerator?
    ) -> [StageReward] {
        var selected: [StageReward] = []
        let shuffled: [StageReward]

        if var generator = seededGenerator {
            shuffled = pool.seededShuffled(using: &generator)
            seededGenerator = generator
        } else {
            shuffled = pool.shuffled()
        }

        for reward in shuffled where !selected.contains(where: { $0.name == reward.name }) {
            selected.append(reward)
            if selected.count == count {
                return selected
            }
        }

        for reward in fallback where !selected.contains(where: { $0.name == reward.name }) {
            selected.append(reward)
            if selected.count == count {
                return selected
            }
        }

        return selected
    }

    private static func ensurePivotOption(
        _ selected: [StageReward],
        from viableRewards: [StageReward],
        dominantTags: Set<ModifierTag>,
        seededGenerator: inout SeededRandomGenerator?
    ) -> [StageReward] {
        guard selected.count >= 3, !dominantTags.isEmpty else {
            return selected
        }

        let hasPivot = selected.contains { RewardDraftState.tags(for: $0).isDisjoint(with: dominantTags) }
        guard !hasPivot else {
            return selected
        }

        let pivotPool = viableRewards.filter { RewardDraftState.tags(for: $0).isDisjoint(with: dominantTags) }
        guard let pivot = seededRandomElement(from: pivotPool, seededGenerator: &seededGenerator) else {
            return selected
        }

        var copy = selected
        copy[copy.count - 1] = pivot
        return copy
    }

    private static func seededRandomElement(
        from rewards: [StageReward],
        seededGenerator: inout SeededRandomGenerator?
    ) -> StageReward? {
        guard !rewards.isEmpty else {
            return nil
        }

        if var generator = seededGenerator {
            let reward = rewards.seededRandomElement(using: &generator)
            seededGenerator = generator
            return reward
        }

        return rewards.randomElement()
    }
}
