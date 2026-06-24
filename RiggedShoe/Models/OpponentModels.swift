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

/// Opponent betting personalities used by compact baccarat battles.
///
/// Opponents do not replace the player's tactical betting. They create a
/// visible benchmark that scores from the same resolved baccarat hands, so a
/// stage feels like a short casino duel instead of an arbitrary checklist.
enum OpponentBettingStyle: String, CaseIterable, Codable, Equatable {
    case conservativeBanker
    case playerPivot
    case tieChaser
    case highRoller
    case smallBallGrinder
    case streakBetter
    case counterBetter
    case randomTourist
    case bossStyle
    case houseStyle

    var displayName: String {
        switch self {
        case .conservativeBanker:
            return "Conservative Banker"
        case .playerPivot:
            return "Player Pivot"
        case .tieChaser:
            return "Tie Chaser"
        case .highRoller:
            return "High Roller"
        case .smallBallGrinder:
            return "Small Ball Grinder"
        case .streakBetter:
            return "Streak Better"
        case .counterBetter:
            return "Counter Better"
        case .randomTourist:
            return "Random Tourist"
        case .bossStyle:
            return "Boss Style"
        case .houseStyle:
            return "House Style"
        }
    }

    func preferredBet(
        handIndex: Int,
        previousWinner: BetType?,
        playerBet: BetType,
        actualWinner: BetType
    ) -> BetType {
        switch self {
        case .conservativeBanker:
            return handIndex % 5 == 0 ? .player : .banker
        case .playerPivot:
            return previousWinner == .banker ? .player : .banker
        case .tieChaser:
            return handIndex % 4 == 0 ? .tie : .banker
        case .highRoller:
            return handIndex % 3 == 0 ? actualWinner : .banker
        case .smallBallGrinder:
            return [.banker, .player, .banker, .banker][(handIndex - 1) % 4]
        case .streakBetter:
            return previousWinner ?? .banker
        case .counterBetter:
            switch previousWinner {
            case .player:
                return .banker
            case .banker:
                return .player
            case .tie:
                return .banker
            case nil:
                return .player
            }
        case .randomTourist:
            return BetType.allCases[(handIndex * 7 + actualWinner.rawValue.count) % BetType.allCases.count]
        case .bossStyle:
            return playerBet
        case .houseStyle:
            return actualWinner == .tie ? .banker : actualWinner
        }
    }

    func betMultiplier(handIndex: Int) -> Int {
        switch self {
        case .highRoller:
            return handIndex % 3 == 0 ? 3 : 1
        case .tieChaser:
            return handIndex % 4 == 0 ? 1 : 2
        case .bossStyle:
            return 2
        case .houseStyle:
            return handIndex > 6 ? 3 : 2
        case .smallBallGrinder:
            return 1
        default:
            return handIndex % 5 == 0 ? 2 : 1
        }
    }
}

/// Lightweight variety layer that modifies a stage without creating a new
/// progression mode. Effects are interpreted by `RunManager` and the payout
/// resolver where they materially affect play.
struct TableEvent: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var summary: String
    var rules: [TableRule]
    var rewardBonusChips: Int

    init(
        id: String,
        name: String,
        summary: String,
        rules: [TableRule],
        rewardBonusChips: Int = 0
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.rules = rules
        self.rewardBonusChips = max(0, rewardBonusChips)
    }
}

extension TableEvent {
    static let noCommissionNight = TableEvent(
        id: "no-commission-night",
        name: "No Commission Night",
        summary: "Banker wins pay full 1:1 tonight.",
        rules: [.bankerCommission(percent: 0)]
    )
    static let highMinimums = TableEvent(
        id: "high-minimums",
        name: "High Minimums",
        summary: "The table ante is stricter than usual.",
        rules: [.minBet(cents: 5_000)]
    )
    static let tightSurveillance = TableEvent(
        id: "tight-surveillance",
        name: "Tight Surveillance",
        summary: "Suspicious wins create extra Heat.",
        rules: [.heatGainOnSuspiciousWin(amount: 1)]
    )
    static let tiePromo = TableEvent(
        id: "tie-promo",
        name: "Tie Promo",
        summary: "Tie pays 10:1, but chasing it looks suspicious.",
        rules: [.tiePayout(multiplier: 10), .heatGainOnSuspiciousWin(amount: 1)]
    )
    static let coldTable = TableEvent(
        id: "cold-table",
        name: "Cold Table",
        summary: "The first losing hand gives the casino momentum.",
        rules: [.custom(id: "first-loss-pressure", description: "First stage loss adds 2 Heat and 2x ante opponent pressure.")]
    )
    static let privateTable = TableEvent(
        id: "private-table",
        name: "Private Table",
        summary: "A shorter table with a better reward.",
        rules: [.custom(id: "private-table", description: "Reward draft gains +1 Chip if cleared.")],
        rewardBonusChips: 1
    )
    static let luckyShoe = TableEvent(
        id: "lucky-shoe",
        name: "Lucky Shoe",
        summary: "The first natural win pays extra.",
        rules: [.custom(id: "lucky-shoe", description: "First natural win gains 1x ante.")]
    )
    static let badCut = TableEvent(
        id: "bad-cut",
        name: "Bad Cut",
        summary: "Opening reads are weaker early.",
        rules: [.custom(id: "bad-cut", description: "Reveal confidence is less reliable for the first hand.")]
    )
    static let distractedPit = TableEvent(
        id: "distracted-pit",
        name: "Distracted Pit",
        summary: "The first Heat gain is ignored.",
        rules: [.custom(id: "distracted-pit", description: "First Heat gain can be prevented.")]
    )
    static let richCrowd = TableEvent(
        id: "rich-crowd",
        name: "Rich Crowd",
        summary: "Large winning bets earn Chips.",
        rules: [.custom(id: "rich-crowd", description: "High bet wins grant +1 Chip.")]
    )
    static let touristRush = TableEvent(
        id: "tourist-rush",
        name: "Tourist Rush",
        summary: "Opponent action is less predictable.",
        rules: [.custom(id: "tourist-rush", description: "Opponent leans random.")]
    )
    static let finalHandSpotlight = TableEvent(
        id: "final-hand-spotlight",
        name: "Final Hand Spotlight",
        summary: "Final hand payout effects matter more.",
        rules: [.custom(id: "final-hand-spotlight", description: "Final hand win grants +1 Chip.")]
    )
    static let naturalBonusTable = TableEvent(
        id: "natural-bonus-table",
        name: "Natural Bonus Table",
        summary: "Natural hands create extra visible pressure.",
        rules: [.custom(id: "natural-bonus-table", description: "Natural wins grant a small ante bonus.")]
    )
    static let pairWatch = TableEvent(
        id: "pair-watch",
        name: "Pair Watch",
        summary: "Pairs become more valuable and more suspicious.",
        rules: [.custom(id: "pair-watch", description: "Pair events can add reward value but may add Heat.")]
    )
    static let markerDesk = TableEvent(
        id: "marker-desk",
        name: "Marker Desk",
        summary: "Credit lines are easier to use, but Heat matters more.",
        rules: [.heatGainOnSuspiciousWin(amount: 1), .custom(id: "marker-desk", description: "Loan and comeback effects are highlighted.")]
    )
    static let coolerShift = TableEvent(
        id: "cooler-shift",
        name: "Cooler Shift",
        summary: "Streaks are harder to maintain at this table.",
        rules: [.custom(id: "cooler-shift", description: "Streak builds should pivot or protect the final hand.")]
    )

    static var allEvents: [TableEvent] {
        [
            noCommissionNight,
            highMinimums,
            tightSurveillance,
            tiePromo,
            coldTable,
            privateTable,
            luckyShoe,
            badCut,
            distractedPit,
            richCrowd,
            touristRush,
            finalHandSpotlight,
            naturalBonusTable,
            pairWatch,
            markerDesk,
            coolerShift
        ]
    }

    static func event(forStageID stageID: Int) -> TableEvent {
        let sequence: [TableEvent] = [
            .touristRush,
            .noCommissionNight,
            .tiePromo,
            .highMinimums,
            .tightSurveillance,
            .privateTable,
            .richCrowd,
            .badCut,
            .coldTable,
            .finalHandSpotlight,
            .naturalBonusTable,
            .pairWatch,
            .markerDesk,
            .coolerShift
        ]

        guard stageID > 0 else {
            return .touristRush
        }

        return sequence[(stageID - 1) % sequence.count]
    }
}

enum SecondaryObjectiveKind: String, Codable, Equatable {
    case winWithoutHeat
    case endWithProfit
    case triggerModifiers
    case winTie
    case conservativeBetting
    case useAllBetTypes
    case finishAheadByTwoAnte
    case winFinalHand
    case beatWithoutConsumables
    case recoverFromBehind
}

struct SecondaryObjective: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var summary: String
    var kind: SecondaryObjectiveKind
    var target: Int
    var rewardSummary: String

    init(
        id: String,
        title: String,
        summary: String,
        kind: SecondaryObjectiveKind,
        target: Int = 1,
        rewardSummary: String = "+1 Chip"
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.kind = kind
        self.target = max(1, target)
        self.rewardSummary = rewardSummary
    }
}

extension SecondaryObjective {
    static let noHeat = SecondaryObjective(id: "no-heat", title: "Keep It Cool", summary: "Clear with Heat 3 or less.", kind: .winWithoutHeat)
    static let endProfit = SecondaryObjective(id: "end-profit", title: "Ahead of Schedule", summary: "End the table with positive stage profit.", kind: .endWithProfit)
    static let triggerThree = SecondaryObjective(id: "trigger-three", title: "Engine Online", summary: "Trigger 3 modifier or upgrade effects.", kind: .triggerModifiers, target: 3)
    static let winTie = SecondaryObjective(id: "win-tie", title: "Longshot Hit", summary: "Win at least one Tie bet.", kind: .winTie)
    static let conservative = SecondaryObjective(id: "conservative", title: "Stay Small", summary: "Never bet above 25% bankroll.", kind: .conservativeBetting)
    static let allSides = SecondaryObjective(id: "all-sides", title: "Use the Layout", summary: "Place a winning bet on at least 2 different sides.", kind: .useAllBetTypes, target: 2)
    static let twoAnte = SecondaryObjective(id: "two-ante", title: "Beat the Spread", summary: "Finish ahead by 2x ante.", kind: .finishAheadByTwoAnte)
    static let finalHand = SecondaryObjective(id: "final-hand", title: "Close Strong", summary: "Win the final hand.", kind: .winFinalHand)
    static let noConsumables = SecondaryObjective(id: "no-consumables", title: "No Props", summary: "Beat the opponent without using consumables.", kind: .beatWithoutConsumables)
    static let comeback = SecondaryObjective(id: "comeback", title: "Comeback Table", summary: "Win after falling behind the opponent.", kind: .recoverFromBehind)

    static var allObjectives: [SecondaryObjective] {
        [.noHeat, .endProfit, .triggerThree, .winTie, .conservative, .allSides, .twoAnte, .finalHand, .noConsumables, .comeback]
    }

    static func objective(forStageID stageID: Int) -> SecondaryObjective {
        allObjectives[(max(1, stageID) - 1) % allObjectives.count]
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
    var bettingStyle: OpponentBettingStyle
    var startingBankrollTargetCents: Int
    var heatPressure: Int
    var rules: [TableRule]
    var modifiers: [ModifierInstance]
    var weakness: String
    var flavorText: String
    var rewardTier: String
    var difficultyRating: Int

    init(
        id: String,
        name: String,
        subtitle: String,
        stageNumber: Int,
        ante: Int,
        bettingStyle: OpponentBettingStyle,
        startingBankrollTargetCents: Int,
        heatPressure: Int = 0,
        rules: [TableRule] = [],
        modifiers: [ModifierInstance] = [],
        weakness: String,
        flavorText: String,
        rewardTier: String,
        difficultyRating: Int
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.stageNumber = stageNumber
        self.ante = max(1, ante)
        self.bettingStyle = bettingStyle
        self.startingBankrollTargetCents = startingBankrollTargetCents
        self.heatPressure = max(0, heatPressure)
        self.rules = rules
        self.modifiers = modifiers
        self.weakness = weakness
        self.flavorText = flavorText
        self.rewardTier = rewardTier
        self.difficultyRating = min(max(1, difficultyRating), 10)
    }

    func betAmountCents(for stage: Stage, handIndex: Int) -> Int {
        let base = max(stage.anteCents, startingBankrollTargetCents)
        let amount = base * bettingStyle.betMultiplier(handIndex: handIndex)
        return min(stage.stageMaxBetCents, max(stage.anteCents, amount))
    }

    func profitDeltaCents(
        for result: RoundResult,
        stage: Stage,
        handIndex: Int,
        previousWinner: BetType?,
        playerBet: BetType
    ) -> Int {
        let opponentBet = bettingStyle.preferredBet(
            handIndex: handIndex,
            previousWinner: previousWinner,
            playerBet: playerBet,
            actualWinner: result.winner
        )
        let amount = betAmountCents(for: stage, handIndex: handIndex)

        if result.winner == .tie, opponentBet != .tie {
            return 0
        }

        guard opponentBet == result.winner else {
            return -amount
        }

        switch opponentBet {
        case .player:
            return stage.tablePayoutRules.profitCents(for: .player, betAmountCents: amount)
        case .banker:
            return stage.tablePayoutRules.profitCents(for: .banker, betAmountCents: amount)
        case .tie:
            return stage.tablePayoutRules.profitCents(for: .tie, betAmountCents: amount)
        }
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
    static var allOpponents: [OpponentState] {
        [
            opponent("nervous-tourist", "Nervous Tourist", "Tutorial table", 1, .randomTourist, "No real plan. Small, random pressure.", "A tourist clutching a comp drink and guessing every side.", "Common", 1),
            opponent("weekend-regular", "Weekend Regular", "Banker lean", 2, .conservativeBanker, "Predictable Banker bias.", "A local who knows Banker is usually boring and correct.", "Common", 2, modifierIDs: ["core.banker-bias"]),
            opponent("card-room-grinder", "Card Room Grinder", "Small-ball pressure", 3, .smallBallGrinder, "Outscale them with stronger payout triggers.", "They are not here to get rich. They are here to never leave.", "Improved", 3, modifierIDs: ["bet.small-ball"]),
            opponent("tie-chaser", "Tie Chaser", "Longshot hunter", 4, .tieChaser, "Punish their missed Tie attempts.", "Every push makes them grin like they already won.", "Improved", 4, modifierIDs: ["core.tie-insurance"]),
            opponent("pattern-player", "Pattern Player", "Repeats hot results", 5, .streakBetter, "Break streaks and switch sides.", "They believe the table speaks in runs.", "Boss", 5, modifierIDs: ["bet.hot-hand"]),
            opponent("the-counter", "The Counter", "Bets against the last result", 6, .counterBetter, "Ride stable reads instead of chasing reversals.", "A contrarian who sees every result as a setup.", "Improved", 5, modifierIDs: ["player.reversal-read"]),
            opponent("whale-junior", "The Whale Junior", "Occasional overbets", 7, .highRoller, "Let reckless misses beat them.", "Too much credit, too little patience.", "High", 6, modifierIDs: ["bet.high-roller"]),
            opponent("quiet-regular", "Quiet Regular", "Low Heat grinder", 8, .smallBallGrinder, "They lack burst. Find payout spikes.", "A silent regular who somehow knows every dealer by name.", "Boss", 6, modifierIDs: ["heat.low-profile"]),
            opponent("mechanics-friend", "The Mechanic's Friend", "Shoe-control pressure", 9, .counterBetter, "Use vision or economy when the shoe gets weird.", "They know someone near the discard tray.", "High", 7, modifierIDs: ["core.burn-notice"]),
            opponent("inside-man", "The Inside Man", "Opening information", 10, .houseStyle, "Heat and boss relics counter their information edge.", "They never look surprised by the first four cards.", "Final", 8, modifierIDs: ["core.opening-tell"]),
            opponent("the-cooler", "The Cooler", "Streak breaker", 9, .conservativeBanker, "Diversify tags before they flatten one lane.", "The room gets quiet when they sit down.", "High", 8, modifierIDs: ["heat.surveillance-loop"]),
            opponent("floor-favorite", "The Floor Favorite", "Late Banker engine", 10, .conservativeBanker, "Player pivots and Heat control beat their house edge.", "The casino seems to smile at every Banker card.", "Final", 9, modifierIDs: ["banker.house-favorite", "banker.commission-dodge"]),
            opponent("the-whale", "The Whale", "High-limit pressure", 8, .highRoller, "Let their overbets miss, then punish with controlled caps.", "Every chip stack on the rail seems to belong to them.", "High", 8, modifierIDs: ["bet.high-roller", "debt.credit-line"]),
            opponent("the-insider", "The Insider", "Knows the opening shoe", 9, .houseStyle, "Beat information with Heat control and boss relics.", "They nod before the first card leaves the shoe.", "High", 8, modifierIDs: ["boss.inside-job", "vision.deep-read"]),
            opponent("the-auditor", "The Auditor", "Taxes suspicious value", 9, .counterBetter, "Low-Heat engines and clean wins dodge their pressure.", "They write down every bonus before it pays.", "High", 7, modifierIDs: ["heat.floor-distraction", "sabotage.opponent-tax"]),
            opponent("the-collector", "The Collector", "Chips and debt pressure", 10, .smallBallGrinder, "Build enough burst to avoid being slowly taxed out.", "They never raise their voice. They do not need to.", "Final", 9, modifierIDs: ["debt.debt-collector", "economy.shop-regular"])
        ]
    }

    static func opponent(forStageID stageID: Int) -> OpponentState {
        switch stageID {
        case 1:
            return allOpponents[0]
        case 2:
            return allOpponents[1]
        case 3:
            return allOpponents[2]
        case 4:
            return allOpponents[3]
        case 5:
            return allOpponents[4]
        case 6:
            return allOpponents[5]
        case 7:
            return allOpponents[6]
        case 8:
            return allOpponents[7]
        case 9:
            return allOpponents[10]
        case 10:
            return allOpponents[11]
        default:
            let latePool = Array(allOpponents.suffix(8))
            return latePool[(stageID - 11) % latePool.count]
        }
    }

    static func sample(stageNumber: Int, isBoss: Bool) -> OpponentState {
        opponent(forStageID: stageNumber)
    }

    private static func opponent(
        _ id: String,
        _ name: String,
        _ subtitle: String,
        _ stageNumber: Int,
        _ bettingStyle: OpponentBettingStyle,
        _ weakness: String,
        _ flavorText: String,
        _ rewardTier: String,
        _ difficultyRating: Int,
        modifierIDs: [String] = []
    ) -> OpponentState {
        let liveStage = Stage.allStages.first { $0.id == stageNumber }
        let ante = liveStage?.ante ?? 25
        let anteCents = liveStage?.anteCents ?? 2_500
        return OpponentState(
            id: id,
            name: name,
            subtitle: subtitle,
            stageNumber: stageNumber,
            ante: ante,
            bettingStyle: bettingStyle,
            startingBankrollTargetCents: anteCents,
            heatPressure: max(0, difficultyRating / 2),
            rules: [
                .maxBet(cents: liveStage?.stageMaxBetCents ?? anteCents * 4),
                .heatGainOnSuspiciousWin(amount: max(0, difficultyRating / 4))
            ],
            modifiers: modifierIDs.map { ModifierInstance(modifierID: $0) },
            weakness: weakness,
            flavorText: flavorText,
            rewardTier: rewardTier,
            difficultyRating: difficultyRating
        )
    }
}

extension BossState {
    static func sample(stageNumber: Int) -> BossState {
        let isFinal = stageNumber == 30
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

/// Small deterministic build classifier for run summaries and reward hints.
///
/// This intentionally uses owned modifier tags instead of player-facing upgrade
/// names so future content automatically participates in archetype detection.
struct BuildArchetypeDetector {
    static func detect(activeModifiers: [ModifierInstance]) -> String {
        var counts: [ModifierTag: Int] = [:]

        for instance in activeModifiers {
            guard let modifier = Modifier.definition(id: instance.modifierID) else {
                continue
            }

            let weight = max(1, instance.level)
            for tag in modifier.tags {
                counts[tag, default: 0] += weight
            }
        }

        guard let top = counts.max(by: { $0.value < $1.value })?.key else {
            return "Fresh Table"
        }

        if counts[.banker, default: 0] >= 3 { return "Banker Engine" }
        if counts[.player, default: 0] >= 3 { return "Player Pivot" }
        if counts[.tie, default: 0] >= 3 { return "Tie Hunter" }
        if counts[.shoeVision, default: 0] >= 3 { return "Shoe Vision" }
        if counts[.shoeControl, default: 0] + counts[.cardSculpting, default: 0] >= 3 { return "Shoe Control" }
        if counts[.betControl, default: 0] >= 3 { return "High Roller" }
        if counts[.economy, default: 0] >= 3 { return "Small Ball Economy" }
        if counts[.comeback, default: 0] >= 3 { return "Comeback" }
        if counts[.heat, default: 0] >= 3 { return "Heat Ghost" }
        if counts[.boss, default: 0] >= 2 { return "Boss Killer" }

        switch top {
        case .banker: return "Banker Engine"
        case .player: return "Player Pivot"
        case .tie: return "Tie Hunter"
        case .shoeVision: return "Shoe Vision"
        case .shoeControl, .cardSculpting: return "Shoe Control"
        case .betControl: return "High Roller"
        case .economy: return "Small Ball Economy"
        case .comeback: return "Comeback"
        case .heat: return "Heat Ghost"
        case .boss: return "Boss Killer"
        default: return counts.count >= 3 ? "Hybrid Build" : "\(top.displayName) Build"
        }
    }

    static func highestLevelModifierName(activeModifiers: [ModifierInstance]) -> String {
        activeModifiers
            .sorted { lhs, rhs in
                if lhs.level == rhs.level {
                    return (Modifier.definition(id: lhs.modifierID)?.name ?? lhs.modifierID)
                        < (Modifier.definition(id: rhs.modifierID)?.name ?? rhs.modifierID)
                }
                return lhs.level > rhs.level
            }
            .first
            .flatMap { instance in
                Modifier.definition(id: instance.modifierID).map { "\($0.name) L\(instance.level)" }
            } ?? "None"
    }
}
