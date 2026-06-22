import Foundation

/// A table rule is a data object that can be applied by a stage, opponent,
/// boss, modifier, relic, or challenge. It should be interpreted by the future
/// battle engine, not by SwiftUI views.
enum TableRule: Codable, Equatable, Hashable {
    case minBet(cents: Int)
    case maxBet(cents: Int)
    case allowedBets(Set<BetType>)
    case bankerCommission(percent: Int)
    case tiePayout(multiplier: Int)
    case heatGainOnLoss(amount: Int)
    case heatGainOnSuspiciousWin(amount: Int)
    case forcedShuffleAfterHand
    case revealSuppressed
    case modifierTagsSuppressed(Set<ModifierTag>)
    case custom(id: String, description: String)

    var id: String {
        switch self {
        case .minBet(let cents):
            return "minBet.\(cents)"
        case .maxBet(let cents):
            return "maxBet.\(cents)"
        case .allowedBets(let bets):
            return "allowedBets.\(bets.map(\.rawValue).sorted().joined(separator: "."))"
        case .bankerCommission(let percent):
            return "bankerCommission.\(percent)"
        case .tiePayout(let multiplier):
            return "tiePayout.\(multiplier)"
        case .heatGainOnLoss(let amount):
            return "heatLoss.\(amount)"
        case .heatGainOnSuspiciousWin(let amount):
            return "heatSuspiciousWin.\(amount)"
        case .forcedShuffleAfterHand:
            return "forcedShuffleAfterHand"
        case .revealSuppressed:
            return "revealSuppressed"
        case .modifierTagsSuppressed(let tags):
            return "suppressed.\(tags.map(\.rawValue).sorted().joined(separator: "."))"
        case .custom(let id, _):
            return "custom.\(id)"
        }
    }

    var description: String {
        switch self {
        case .minBet(let cents):
            return "Minimum bet \(MoneyFormatter.format(cents))"
        case .maxBet(let cents):
            return "Maximum bet \(MoneyFormatter.format(cents))"
        case .allowedBets(let bets):
            return "Allowed bets: \(bets.map(\.displayName).sorted().joined(separator: ", "))"
        case .bankerCommission(let percent):
            return "Banker commission \(percent)%"
        case .tiePayout(let multiplier):
            return "Tie pays \(multiplier):1"
        case .heatGainOnLoss(let amount):
            return "Lose +\(amount) Heat"
        case .heatGainOnSuspiciousWin(let amount):
            return "Suspicious win +\(amount) Heat"
        case .forcedShuffleAfterHand:
            return "Shoe shuffles after each hand"
        case .revealSuppressed:
            return "Reveal effects disabled"
        case .modifierTagsSuppressed(let tags):
            return "Disabled tags: \(tags.map(\.displayName).sorted().joined(separator: ", "))"
        case .custom(_, let description):
            return description
        }
    }
}

/// The casino opponent for a short battle.
///
/// Opponents are not baccarat players. They define pressure, table rules, and
/// modifier resistance for a short stage.
struct OpponentState: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var subtitle: String
    var stageNumber: Int
    var ante: Int
    var startingBankrollTargetCents: Int
    var heatPressure: Int
    var rules: [TableRule]
    var modifiers: [ModifierInstance]

    init(
        id: String,
        name: String,
        subtitle: String,
        stageNumber: Int,
        ante: Int,
        startingBankrollTargetCents: Int,
        heatPressure: Int = 0,
        rules: [TableRule] = [],
        modifiers: [ModifierInstance] = []
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.stageNumber = stageNumber
        self.ante = max(1, ante)
        self.startingBankrollTargetCents = startingBankrollTargetCents
        self.heatPressure = max(0, heatPressure)
        self.rules = rules
        self.modifiers = modifiers
    }
}

/// Runtime state for a boss battle in the rebuilt structure.
///
/// This can bridge to the existing `Boss` model through `sourceBossID`, while
/// still allowing future bosses to be fully data-driven through table rules and
/// suppressed modifier tags.
struct BossState: Identifiable, Codable, Equatable {
    let id: String
    var sourceBossID: Int?
    var name: String
    var description: String
    var iconName: String
    var difficulty: BossDifficulty
    var rules: [TableRule]
    var suppressedModifierTags: Set<ModifierTag>
    var disabledModifierInstanceIDs: Set<UUID>
    var rewardPreview: [BossRelic]
    var isDefeated: Bool

    init(
        id: String,
        sourceBossID: Int? = nil,
        name: String,
        description: String,
        iconName: String,
        difficulty: BossDifficulty,
        rules: [TableRule] = [],
        suppressedModifierTags: Set<ModifierTag> = [],
        disabledModifierInstanceIDs: Set<UUID> = [],
        rewardPreview: [BossRelic] = [],
        isDefeated: Bool = false
    ) {
        self.id = id
        self.sourceBossID = sourceBossID
        self.name = name
        self.description = description
        self.iconName = iconName
        self.difficulty = difficulty
        self.rules = rules
        self.suppressedModifierTags = suppressedModifierTags
        self.disabledModifierInstanceIDs = disabledModifierInstanceIDs
        self.rewardPreview = rewardPreview
        self.isDefeated = isDefeated
    }
}

extension OpponentState {
    static func sample(stageNumber: Int, isBoss: Bool) -> OpponentState {
        let liveStage = Stage.allStages.first { $0.id == stageNumber }
        let ante = liveStage?.ante ?? 25
        let anteCents = liveStage?.anteCents ?? 2_500
        return OpponentState(
            id: isBoss ? "boss-table-\(stageNumber)" : "floor-table-\(stageNumber)",
            name: isBoss ? "Casino Enforcer" : "Floor Dealer",
            subtitle: isBoss ? "Boss table" : "Standard table",
            stageNumber: stageNumber,
            ante: ante,
            startingBankrollTargetCents: anteCents,
            heatPressure: isBoss ? ante + 1 : ante,
            rules: [
                .maxBet(cents: liveStage?.stageMaxBetCents ?? anteCents * 4),
                .heatGainOnSuspiciousWin(amount: ante)
            ]
        )
    }
}

extension BossState {
    static func sample(stageNumber: Int) -> BossState {
        let isFinal = stageNumber == 10
        return BossState(
            id: isFinal ? "the-house-rebuild" : "surveillance-rebuild-\(stageNumber)",
            sourceBossID: isFinal ? 4 : 1,
            name: isFinal ? "The House" : "Surveillance",
            description: isFinal ? "The final table stacks every casino countermeasure." : "Casino cameras punish shoe vision builds.",
            iconName: isFinal ? "building.columns.fill" : "video.fill",
            difficulty: isFinal ? .majorBoss : .miniBoss,
            rules: isFinal ? [
                .revealSuppressed,
                .forcedShuffleAfterHand,
                .modifierTagsSuppressed([.shoeVision, .tie])
            ] : [
                .revealSuppressed,
                .modifierTagsSuppressed([.shoeVision])
            ],
            suppressedModifierTags: isFinal ? [.shoeVision, .tie] : [.shoeVision],
            rewardPreview: [.sampleEyeInTheSky]
        )
    }
}
