import Foundation

enum StageObjectiveKind: Equatable {
    case winBets
    case triggerUpgrades
    case winWithReveal
    case surviveHands(minBankrollCents: Int)
    case finishHandsBreakEvenOrBetter
    case finishHandsWithLossLimit(cents: Int)
    case growBankroll(percent: Int)
    case growBankrollBy(cents: Int)
    case winUpgradeInfluencedHands
    case reachBankroll(cents: Int)
}

struct StageObjective: Equatable {
    let kind: StageObjectiveKind
    let target: Int
    let title: String
    let description: String

    func currentValue(in runManager: RunManager, bankrollCents: Int? = nil) -> Int {
        switch kind {
        case .winBets:
            return runManager.currentStageWinningBets
        case .triggerUpgrades:
            return runManager.currentStageUpgradeTriggers
        case .winWithReveal:
            return runManager.currentStageRevealWins
        case .surviveHands:
            return runManager.currentStageRoundsPlayed
        case .finishHandsBreakEvenOrBetter:
            return runManager.currentStageRoundsPlayed
        case .finishHandsWithLossLimit:
            return runManager.currentStageRoundsPlayed
        case .growBankroll(let percent):
            guard runManager.stageStartingBankrollCents > 0, let bankrollCents else {
                return 0
            }

            let growthPercent = runManager.stageProfitCents(bankrollCents: bankrollCents) * 100 / runManager.stageStartingBankrollCents
            return min(max(0, growthPercent), percent)
        case .growBankrollBy(let cents):
            guard let bankrollCents else {
                return 0
            }

            return min(max(0, runManager.stageProfitCents(bankrollCents: bankrollCents)), cents)
        case .winUpgradeInfluencedHands:
            return runManager.currentStageUpgradeInfluencedWins
        case .reachBankroll(let cents):
            return min(bankrollCents ?? 0, cents)
        }
    }

    func isComplete(in runManager: RunManager, bankrollCents: Int) -> Bool {
        switch kind {
        case .finishHandsBreakEvenOrBetter:
            return runManager.currentStageRoundsPlayed >= target
                && runManager.stageProfitCents(bankrollCents: bankrollCents) >= 0
        case .finishHandsWithLossLimit(let cents):
            return runManager.currentStageRoundsPlayed >= target
                && runManager.stageProfitCents(bankrollCents: bankrollCents) >= -cents
        case .growBankroll(let percent):
            guard runManager.stageStartingBankrollCents > 0 else {
                return false
            }

            return runManager.stageProfitCents(bankrollCents: bankrollCents) * 100 >= runManager.stageStartingBankrollCents * percent
        case .growBankrollBy(let cents):
            return runManager.stageProfitCents(bankrollCents: bankrollCents) >= cents
        case .reachBankroll(let cents):
            return bankrollCents >= cents
        default:
            return currentValue(in: runManager, bankrollCents: bankrollCents) >= target
        }
    }

    func isFailed(in runManager: RunManager, bankrollCents: Int) -> Bool {
        switch kind {
        case .surviveHands(let minBankrollCents):
            return bankrollCents < minBankrollCents || runManager.currentStageMinimumBankrollCents < minBankrollCents
        default:
            return false
        }
    }

    func progressText(in runManager: RunManager, bankrollCents: Int) -> String {
        switch kind {
        case .surviveHands(let minBankrollCents):
            let survivalText = minBankrollCents <= 1
                ? "bankroll above $0"
                : "bankroll \(MoneyFormatter.format(minBankrollCents))+"
            return "\(min(currentValue(in: runManager, bankrollCents: bankrollCents), target))/\(target) hands, \(survivalText)"
        case .finishHandsBreakEvenOrBetter:
            let result = runManager.stageProfitCents(bankrollCents: bankrollCents) >= 0 ? "even+" : MoneyFormatter.signed(runManager.stageProfitCents(bankrollCents: bankrollCents))
            return "\(min(currentValue(in: runManager, bankrollCents: bankrollCents), target))/\(target) hands, \(result)"
        case .finishHandsWithLossLimit(let cents):
            let currentLoss = max(0, -runManager.stageProfitCents(bankrollCents: bankrollCents))
            return "\(min(currentValue(in: runManager, bankrollCents: bankrollCents), target))/\(target) hands, loss \(MoneyFormatter.format(currentLoss))/\(MoneyFormatter.format(cents))"
        case .growBankroll(let percent):
            return "\(currentValue(in: runManager, bankrollCents: bankrollCents))%/\(percent)%"
        case .growBankrollBy(let cents):
            return "\(MoneyFormatter.format(currentValue(in: runManager, bankrollCents: bankrollCents))) / \(MoneyFormatter.format(cents))"
        case .winUpgradeInfluencedHands:
            return "\(currentValue(in: runManager, bankrollCents: bankrollCents)) / \(target) upgrade or reveal win"
        case .reachBankroll(let cents):
            return "\(MoneyFormatter.format(bankrollCents))/\(MoneyFormatter.format(cents))"
        default:
            return "\(currentValue(in: runManager, bankrollCents: bankrollCents))/\(target)"
        }
    }

    func progress(in runManager: RunManager, bankrollCents: Int) -> Double {
        switch kind {
        case .reachBankroll(let cents):
            return min(1, Double(bankrollCents) / Double(max(1, cents)))
        case .growBankroll(let percent):
            guard percent > 0 else {
                return 1
            }

            return min(1, Double(currentValue(in: runManager, bankrollCents: bankrollCents)) / Double(percent))
        case .finishHandsWithLossLimit:
            return min(1, Double(currentValue(in: runManager, bankrollCents: bankrollCents)) / Double(max(1, target)))
        case .growBankrollBy(let cents):
            return min(1, Double(currentValue(in: runManager, bankrollCents: bankrollCents)) / Double(max(1, cents)))
        default:
            return min(1, Double(currentValue(in: runManager, bankrollCents: bankrollCents)) / Double(max(1, target)))
        }
    }
}

struct BetLimit: Equatable {
    let allowedBetAmountsCents: [Int]

    func allows(_ amountCents: Int) -> Bool {
        allowedBetAmountsCents.contains(amountCents)
    }
}

struct Stage: Identifiable, Equatable {
    let id: Int
    let targetProfitCents: Int
    let roundLimit: Int
    let teachingObjective: StageObjective?
    let betLimit: BetLimit

    init(
        id: Int,
        targetProfitCents: Int,
        roundLimit: Int,
        teachingObjective: StageObjective? = nil,
        betLimit: BetLimit
    ) {
        self.id = id
        self.targetProfitCents = targetProfitCents
        self.roundLimit = roundLimit
        self.teachingObjective = teachingObjective
        self.betLimit = betLimit
    }

    static let allStages: [Stage] = [
        Stage(
            id: 1,
            targetProfitCents: 0,
            roundLimit: 5,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 1),
                target: 5,
                title: "Opening Table",
                description: "Survive 5 baccarat hands."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [2_500, 5_000, 7_500, 10_000])
        ),
        Stage(
            id: 2,
            targetProfitCents: 0,
            roundLimit: 6,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 1),
                target: 6,
                title: "Controlled Risk",
                description: "Survive 6 hands with the $50 ante and tighter bet caps."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [5_000, 10_000, 15_000])
        ),
        Stage(
            id: 3,
            targetProfitCents: 0,
            roundLimit: 7,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 1),
                target: 7,
                title: "Read the Shoe",
                description: "Survive 7 hands while your build starts to matter."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [7_500, 15_000, 22_500, 25_000])
        ),
        Stage(
            id: 4,
            targetProfitCents: 0,
            roundLimit: 8,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 1),
                target: 8,
                title: "Build Check",
                description: "Survive 8 hands before the casino sends a boss."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [10_000, 20_000, 30_000, 40_000])
        ),
        Stage(
            id: 5,
            targetProfitCents: 0,
            roundLimit: 8,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 1),
                target: 8,
                title: "Boss Table",
                description: "Survive 8 hands against the first casino boss."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [15_000, 30_000, 45_000, 60_000])
        ),
        Stage(id: 6, targetProfitCents: 0, roundLimit: 8, teachingObjective: StageObjective(kind: .surviveHands(minBankrollCents: 1), target: 8, title: "Deeper Table", description: "Survive 8 hands with a stronger shop-built engine."), betLimit: BetLimit(allowedBetAmountsCents: [20_000, 40_000, 60_000, 80_000])),
        Stage(id: 7, targetProfitCents: 0, roundLimit: 9, teachingObjective: StageObjective(kind: .surviveHands(minBankrollCents: 1), target: 9, title: "Pressure Run", description: "Survive 9 hands before the second boss."), betLimit: BetLimit(allowedBetAmountsCents: [30_000, 60_000, 90_000, 120_000])),
        Stage(id: 8, targetProfitCents: 0, roundLimit: 10, teachingObjective: StageObjective(kind: .surviveHands(minBankrollCents: 1), target: 10, title: "Boss Table II", description: "Survive 10 hands against a major casino countermeasure."), betLimit: BetLimit(allowedBetAmountsCents: [40_000, 80_000, 120_000, 160_000, 175_000])),
        Stage(id: 9, targetProfitCents: 0, roundLimit: 10, teachingObjective: StageObjective(kind: .surviveHands(minBankrollCents: 1), target: 10, title: "Final Prep", description: "Survive 10 hands and tune your bankroll before The House."), betLimit: BetLimit(allowedBetAmountsCents: [60_000, 120_000, 180_000, 240_000, 250_000])),
        Stage(id: 10, targetProfitCents: 0, roundLimit: 12, teachingObjective: StageObjective(kind: .surviveHands(minBankrollCents: 1), target: 12, title: "Final Boss", description: "Survive 12 hands against The House."), betLimit: BetLimit(allowedBetAmountsCents: [80_000, 160_000, 240_000, 320_000, 400_000]))
    ]
}

extension Stage {
    var opponent: OpponentState {
        OpponentState.opponent(forStageID: id)
    }

    var tableEvent: TableEvent {
        TableEvent.event(forStageID: id)
    }

    var secondaryObjective: SecondaryObjective {
        SecondaryObjective.objective(forStageID: id)
    }

    var effectiveTableRules: [TableRule] {
        tableEvent.rules + opponent.rules
    }

    var anteCents: Int {
        switch id {
        case 1: return 2_500
        case 2: return 5_000
        case 3: return 7_500
        case 4: return 10_000
        case 5: return 15_000
        case 6: return 20_000
        case 7: return 30_000
        case 8: return 40_000
        case 9: return 60_000
        case 10: return 80_000
        default: return 2_500
        }
    }

    var ante: Int {
        anteCents / 100
    }

    var minimumBetCents: Int {
        let tableMinimums = effectiveTableRules.compactMap { rule -> Int? in
            if case .minBet(let cents) = rule {
                return cents
            }

            return nil
        }

        return ([anteCents] + tableMinimums).max() ?? anteCents
    }

    var stageMaxBetCents: Int {
        switch id {
        case 1: return 10_000
        case 2: return 15_000
        case 3: return 25_000
        case 4: return 40_000
        case 5: return 60_000
        case 6: return 80_000
        case 7: return 120_000
        case 8: return 175_000
        case 9: return 250_000
        case 10: return 400_000
        default: return 10_000
        }
    }

    var isBossStage: Bool {
        [5, 8, 10].contains(id)
    }

    var opponentName: String {
        opponent.name
    }

    var tableRuleSummary: String {
        if isBossStage {
            return "\(tableEvent.name) + boss pressure"
        }

        return tableEvent.name
    }

    var rewardTier: String {
        if id == 10 {
            return "Victory"
        }

        if isBossStage {
            return "Boss"
        }

        switch ante {
        case 0...75:
            return "Common"
        case 76...300:
            return "Improved"
        default:
            return "High"
        }
    }

    var stageClearChips: Int {
        EconomyRewardCalculation.stageClear(stage: self, bankrollCents: 0).chipsReward + tableEvent.rewardBonusChips
    }
}

struct EconomyRewardCalculation: Equatable {
    let stageNumber: Int
    let anteCents: Int
    let baseCashCents: Int
    let cashRewardCents: Int
    let chipsReward: Int
    let capApplied: Bool
    let reason: String

    static func stageClear(stage: Stage, bankrollCents: Int) -> EconomyRewardCalculation {
        let multiplier = stage.isBossStage ? bossStageClearMultiplierPercent(for: stage.id) : normalStageClearMultiplierPercent(for: stage.id)
        let chips = stage.isBossStage ? bossStageChips(for: stage.id) : normalStageChips(for: stage.id)
        return make(
            stage: stage,
            bankrollCents: bankrollCents,
            multiplierPercent: multiplier,
            chipsReward: chips,
            reason: stage.isBossStage ? "boss stage clear" : "normal stage clear"
        )
    }

    static func stageCashReward(stage: Stage, bankrollCents: Int, multiplierPercent: Int) -> EconomyRewardCalculation {
        make(
            stage: stage,
            bankrollCents: bankrollCents,
            multiplierPercent: multiplierPercent,
            chipsReward: 0,
            reason: "stage reward draft"
        )
    }

    static func bossCashReward(stage: Stage, bankrollCents: Int, multiplierPercent: Int, chipsReward: Int) -> EconomyRewardCalculation {
        make(
            stage: stage,
            bankrollCents: bankrollCents,
            multiplierPercent: multiplierPercent,
            chipsReward: chipsReward,
            reason: "boss reward draft"
        )
    }

    private static func make(
        stage: Stage,
        bankrollCents: Int,
        multiplierPercent: Int,
        chipsReward: Int,
        reason: String
    ) -> EconomyRewardCalculation {
        let baseCash = max(0, stage.anteCents * multiplierPercent / 100)
        let cap = bankrollCents > 0 ? max(0, bankrollCents) : baseCash
        let finalCash = min(baseCash, cap)
        return EconomyRewardCalculation(
            stageNumber: stage.id,
            anteCents: stage.anteCents,
            baseCashCents: baseCash,
            cashRewardCents: finalCash,
            chipsReward: max(0, chipsReward),
            capApplied: finalCash < baseCash,
            reason: reason
        )
    }

    private static func normalStageClearMultiplierPercent(for stageID: Int) -> Int {
        switch stageID {
        case 1...2: return 200
        case 3...4: return 150
        default: return 200
        }
    }

    private static func bossStageClearMultiplierPercent(for stageID: Int) -> Int {
        switch stageID {
        case 5: return 300
        case 8: return 400
        case 10: return 500
        default: return 300
        }
    }

    private static func normalStageChips(for stageID: Int) -> Int {
        switch stageID {
        case 1...3: return 2
        case 4...7: return 3
        default: return 4
        }
    }

    private static func bossStageChips(for stageID: Int) -> Int {
        switch stageID {
        case 5: return 5
        case 8: return 6
        case 10: return 8
        default: return 5
        }
    }
}

enum StageFailureReason: String, Codable, Equatable {
    case bankrollBusted
    case heatMaxed
    case bossDefeat
    case stageCondition

    var displayText: String {
        switch self {
        case .bankrollBusted:
            return "Bankroll cannot cover the table minimum."
        case .heatMaxed:
            return "Heat reached the limit."
        case .bossDefeat:
            return "The boss table shut down the run."
        case .stageCondition:
            return "Stage condition failed."
        }
    }
}

struct StagePreviewData: Equatable {
    let stageNumber: Int
    let opponentName: String
    let opponentSubtitle: String
    let opponentStyle: String
    let opponentWeakness: String
    let opponentFlavorText: String
    let opponentDifficulty: Int
    let primaryObjectiveTitle: String
    let primaryObjectiveSummary: String
    let ante: Int
    let handCount: Int
    let tableRule: String
    let tableRuleDetail: String
    let secondaryObjectiveTitle: String
    let secondaryObjectiveSummary: String
    let secondaryObjectiveReward: String
    let rewardTier: String
    let isBossStage: Bool
    let bossWarning: String?

    init(stage: Stage, handCount: Int) {
        let opponent = stage.opponent
        let event = stage.tableEvent
        let secondary = stage.secondaryObjective
        self.stageNumber = stage.id
        self.opponentName = opponent.name
        self.opponentSubtitle = opponent.subtitle
        self.opponentStyle = opponent.bettingStyle.displayName
        self.opponentWeakness = opponent.weakness
        self.opponentFlavorText = opponent.flavorText
        self.opponentDifficulty = opponent.difficultyRating
        self.primaryObjectiveTitle = stage.teachingObjective?.title ?? "Beat the Table"
        self.primaryObjectiveSummary = stage.teachingObjective?.description ?? "End the stage ahead of the table."
        self.ante = stage.ante
        self.handCount = handCount
        self.tableRule = stage.tableRuleSummary
        self.tableRuleDetail = event.summary
        self.secondaryObjectiveTitle = secondary.title
        self.secondaryObjectiveSummary = secondary.summary
        self.secondaryObjectiveReward = secondary.rewardSummary
        self.rewardTier = opponent.rewardTier
        self.isBossStage = stage.isBossStage
        self.bossWarning = stage.isBossStage ? "\(opponent.name) adds a boss rule on top of \(event.name)." : nil
    }
}

struct StageResultData: Codable, Equatable {
    let stageNumber: Int
    let didWin: Bool
    let startingBankrollCents: Int
    let endingBankrollCents: Int
    let profitCents: Int
    let opponentName: String
    let opponentProfitCents: Int
    let bankrollChangeCents: Int
    let objectiveDescription: String
    let objectiveProgressText: String
    let scoreMarginCents: Int
    let heatChange: Int
    let chipsEarned: Int
    let failureReason: StageFailureReason?
    let tableEventName: String
    let secondaryObjectiveTitle: String
    let secondaryObjectiveCompleted: Bool
    let secondaryObjectiveReward: String
    let lossExplanation: String
    let buildArchetype: String
    let triggeredModifierSummaries: [String]

    var title: String {
        didWin ? "Stage Cleared" : "Stage Failed"
    }

    var reasonText: String {
        if didWin {
            return "Opponent defeated: \(opponentName). Score margin \(scoreMarginText)."
        }

        return lossExplanation.isEmpty ? (failureReason?.displayText ?? "Opponent outscored your table profit.") : lossExplanation
    }

    var scoreMarginText: String {
        let sign = scoreMarginCents > 0 ? "+" : ""
        let whole = abs(scoreMarginCents) / 100
        let cents = abs(scoreMarginCents) % 100
        return "\(sign)\(scoreMarginCents < 0 ? "-" : "")\(whole).\(String(format: "%02d", cents)) pts"
    }

    init(
        stageNumber: Int,
        didWin: Bool,
        startingBankrollCents: Int,
        endingBankrollCents: Int,
        profitCents: Int,
        opponentName: String,
        opponentProfitCents: Int,
        bankrollChangeCents: Int,
        objectiveDescription: String,
        objectiveProgressText: String,
        scoreMarginCents: Int,
        heatChange: Int,
        chipsEarned: Int,
        failureReason: StageFailureReason?,
        tableEventName: String,
        secondaryObjectiveTitle: String,
        secondaryObjectiveCompleted: Bool,
        secondaryObjectiveReward: String,
        lossExplanation: String,
        buildArchetype: String,
        triggeredModifierSummaries: [String] = []
    ) {
        self.stageNumber = stageNumber
        self.didWin = didWin
        self.startingBankrollCents = startingBankrollCents
        self.endingBankrollCents = endingBankrollCents
        self.profitCents = profitCents
        self.opponentName = opponentName
        self.opponentProfitCents = opponentProfitCents
        self.bankrollChangeCents = bankrollChangeCents
        self.objectiveDescription = objectiveDescription
        self.objectiveProgressText = objectiveProgressText
        self.scoreMarginCents = scoreMarginCents
        self.heatChange = heatChange
        self.chipsEarned = chipsEarned
        self.failureReason = failureReason
        self.tableEventName = tableEventName
        self.secondaryObjectiveTitle = secondaryObjectiveTitle
        self.secondaryObjectiveCompleted = secondaryObjectiveCompleted
        self.secondaryObjectiveReward = secondaryObjectiveReward
        self.lossExplanation = lossExplanation
        self.buildArchetype = buildArchetype
        self.triggeredModifierSummaries = triggeredModifierSummaries
    }

    enum CodingKeys: String, CodingKey {
        case stageNumber
        case didWin
        case startingBankrollCents
        case endingBankrollCents
        case profitCents
        case opponentName
        case opponentProfitCents
        case bankrollChangeCents
        case objectiveDescription
        case objectiveProgressText
        case scoreMarginCents
        case heatChange
        case chipsEarned
        case failureReason
        case tableEventName
        case secondaryObjectiveTitle
        case secondaryObjectiveCompleted
        case secondaryObjectiveReward
        case lossExplanation
        case buildArchetype
        case triggeredModifierSummaries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stageNumber = try container.decode(Int.self, forKey: .stageNumber)
        didWin = try container.decode(Bool.self, forKey: .didWin)
        startingBankrollCents = try container.decodeIfPresent(Int.self, forKey: .startingBankrollCents) ?? 0
        endingBankrollCents = try container.decodeIfPresent(Int.self, forKey: .endingBankrollCents) ?? 0
        profitCents = try container.decode(Int.self, forKey: .profitCents)
        opponentName = try container.decodeIfPresent(String.self, forKey: .opponentName) ?? "Opponent"
        opponentProfitCents = try container.decodeIfPresent(Int.self, forKey: .opponentProfitCents) ?? 0
        bankrollChangeCents = try container.decode(Int.self, forKey: .bankrollChangeCents)
        objectiveDescription = try container.decodeIfPresent(String.self, forKey: .objectiveDescription) ?? "Clear the stage objective."
        objectiveProgressText = try container.decodeIfPresent(String.self, forKey: .objectiveProgressText) ?? ""
        scoreMarginCents = try container.decodeIfPresent(Int.self, forKey: .scoreMarginCents) ?? (profitCents - opponentProfitCents)
        heatChange = try container.decode(Int.self, forKey: .heatChange)
        chipsEarned = try container.decode(Int.self, forKey: .chipsEarned)
        failureReason = try container.decodeIfPresent(StageFailureReason.self, forKey: .failureReason)
        tableEventName = try container.decodeIfPresent(String.self, forKey: .tableEventName) ?? "Standard Table"
        secondaryObjectiveTitle = try container.decodeIfPresent(String.self, forKey: .secondaryObjectiveTitle) ?? "Optional Objective"
        secondaryObjectiveCompleted = try container.decodeIfPresent(Bool.self, forKey: .secondaryObjectiveCompleted) ?? false
        secondaryObjectiveReward = try container.decodeIfPresent(String.self, forKey: .secondaryObjectiveReward) ?? "+1 Chip"
        lossExplanation = try container.decodeIfPresent(String.self, forKey: .lossExplanation) ?? ""
        buildArchetype = try container.decodeIfPresent(String.self, forKey: .buildArchetype) ?? "Hybrid Build"
        triggeredModifierSummaries = try container.decodeIfPresent([String].self, forKey: .triggeredModifierSummaries) ?? []
    }
}
