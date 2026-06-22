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
            return "\(min(currentValue(in: runManager, bankrollCents: bankrollCents), target))/\(target) hands, stay \(MoneyFormatter.format(minBankrollCents))+"
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
            roundLimit: 10,
            teachingObjective: StageObjective(
                kind: .surviveHands(minBankrollCents: 20_000),
                target: 10,
                title: "Survive the Table",
                description: "Play 10 hands without your bankroll dropping below $200."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [1_000])
        ),
        Stage(
            id: 2,
            targetProfitCents: 0,
            roundLimit: 10,
            teachingObjective: StageObjective(
                kind: .finishHandsWithLossLimit(cents: 6_000),
                target: 10,
                title: "Controlled Risk",
                description: "Finish 10 hands without losing more than $60 from your stage-start bankroll."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000])
        ),
        Stage(
            id: 3,
            targetProfitCents: 0,
            roundLimit: 12,
            teachingObjective: StageObjective(
                kind: .growBankrollBy(cents: 1_500),
                target: 1_500,
                title: "Grow Bankroll by $15",
                description: "Earn $15 from the bankroll you had when Stage 3 began."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000])
        ),
        Stage(
            id: 4,
            targetProfitCents: 6_000,
            roundLimit: 12,
            teachingObjective: StageObjective(
                kind: .winUpgradeInfluencedHands,
                target: 1,
                title: "Upgrade or Reveal Win",
                description: "Win one hand using an upgrade bonus, reveal read, or shoe-control effect."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000])
        ),
        Stage(
            id: 5,
            targetProfitCents: 0,
            roundLimit: 12,
            teachingObjective: StageObjective(
                kind: .growBankrollBy(cents: 12_500),
                target: 12_500,
                title: "Grow Bankroll by $125",
                description: "First profit gate: earn $125 from stage start using your upgrades and bigger unlocked bets."
            ),
            betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500])
        ),
        Stage(id: 6, targetProfitCents: 15_000, roundLimit: 12, betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500, 10_000])),
        Stage(id: 7, targetProfitCents: 25_000, roundLimit: 12, betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500, 10_000, 20_000])),
        Stage(id: 8, targetProfitCents: 45_000, roundLimit: 12, betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500, 10_000, 20_000, 30_000])),
        Stage(id: 9, targetProfitCents: 75_000, roundLimit: 12, betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500, 10_000, 20_000, 30_000, 50_000])),
        Stage(id: 10, targetProfitCents: 125_000, roundLimit: 12, betLimit: BetLimit(allowedBetAmountsCents: [1_000, 2_000, 3_000, 5_000, 7_500, 10_000, 20_000, 30_000, 50_000, 100_000]))
    ]
}
