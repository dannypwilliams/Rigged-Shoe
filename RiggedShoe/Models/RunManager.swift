import Foundation

enum RunStatus: Equatable {
    case active
    case stageCleared
    case failed
    case completed
}

struct RunManager: Equatable {
    static let defaultStartingBankrollCents = 25_000

    let stages: [Stage]
    let startingBankrollCents: Int
    var stageStartingBankrollCents: Int
    var currentStageIndex: Int
    var currentStageRoundsPlayed: Int
    var currentStageWinningBets: Int
    var currentStageUpgradeTriggers: Int
    var currentStageRevealWins: Int
    var currentStageUpgradeInfluencedWins: Int
    var currentStageLosses: Int
    var currentStageMinimumBankrollCents: Int
    var currentStageBiggestWinCents: Int
    var currentStageBiggestLossCents: Int
    var totalRoundsPlayed: Int
    var playerWins: Int
    var bankerWins: Int
    var tieResults: Int
    var highestBankrollCents: Int
    var highestProfitCents: Int
    var tiePayoutBonus: Int
    var tiePayoutOverride: Int?
    var permanentRevealCount: Int
    var playerBonusMultiplier: Int
    var bankerBonusMultiplier: Int
    var futureStageRoundBonus: Int
    var status: RunStatus

    init(stages: [Stage] = Stage.allStages, startingBankrollCents: Int = Self.defaultStartingBankrollCents) {
        self.stages = stages
        self.startingBankrollCents = startingBankrollCents
        self.stageStartingBankrollCents = startingBankrollCents
        self.currentStageIndex = 0
        self.currentStageRoundsPlayed = 0
        self.currentStageWinningBets = 0
        self.currentStageUpgradeTriggers = 0
        self.currentStageRevealWins = 0
        self.currentStageUpgradeInfluencedWins = 0
        self.currentStageLosses = 0
        self.currentStageMinimumBankrollCents = startingBankrollCents
        self.currentStageBiggestWinCents = 0
        self.currentStageBiggestLossCents = 0
        self.totalRoundsPlayed = 0
        self.playerWins = 0
        self.bankerWins = 0
        self.tieResults = 0
        self.highestBankrollCents = startingBankrollCents
        self.highestProfitCents = 0
        self.tiePayoutBonus = 0
        self.tiePayoutOverride = nil
        self.permanentRevealCount = 0
        self.playerBonusMultiplier = 1
        self.bankerBonusMultiplier = 1
        self.futureStageRoundBonus = 0
        self.status = .active
    }

    var currentStage: Stage {
        stages[min(currentStageIndex, stages.count - 1)]
    }

    var stageReached: Int {
        currentStage.id
    }

    var roundsRemaining: Int {
        max(0, currentRoundLimit - currentStageRoundsPlayed)
    }

    var currentRoundLimit: Int {
        currentStage.roundLimit + futureStageRoundBonus
    }

    func currentProfitCents(bankrollCents: Int) -> Int {
        bankrollCents - startingBankrollCents
    }

    func stageProfitCents(bankrollCents: Int) -> Int {
        bankrollCents - stageStartingBankrollCents
    }

    func stageTargetBankrollCents() -> Int {
        if case .reachBankroll(let cents)? = currentStage.teachingObjective?.kind {
            return cents
        }

        if case .growBankrollBy(let cents)? = currentStage.teachingObjective?.kind {
            return stageStartingBankrollCents + cents
        }

        return stageStartingBankrollCents + currentStage.targetProfitCents
    }

    func stageProgress(bankrollCents: Int) -> Double {
        guard currentStage.targetProfitCents > 0 else {
            return 0
        }

        let profit = max(0, stageProfitCents(bankrollCents: bankrollCents))
        return min(1, Double(profit) / Double(currentStage.targetProfitCents))
    }

    func teachingObjectiveProgress(bankrollCents: Int) -> Double {
        guard let objective = currentStage.teachingObjective else {
            return 0
        }

        return objective.progress(in: self, bankrollCents: bankrollCents)
    }

    func combinedStageProgress(bankrollCents: Int) -> Double {
        max(stageProgress(bankrollCents: bankrollCents), teachingObjectiveProgress(bankrollCents: bankrollCents))
    }

    func isStageClear(bankrollCents: Int) -> Bool {
        if currentStage.targetProfitCents > 0,
           stageProfitCents(bankrollCents: bankrollCents) >= currentStage.targetProfitCents {
            return true
        }

        return currentStage.teachingObjective?.isComplete(in: self, bankrollCents: bankrollCents) == true
    }

    func isStageFailed(bankrollCents: Int) -> Bool {
        currentStage.teachingObjective?.isFailed(in: self, bankrollCents: bankrollCents) == true
    }

    mutating func recordRound(
        result: RoundResult,
        bankrollCents: Int,
        didWinBet: Bool,
        upgradeTriggerCount: Int,
        didWinWithReveal: Bool,
        bankrollBeforeRoundCents: Int
    ) {
        totalRoundsPlayed += 1
        currentStageRoundsPlayed += 1
        currentStageUpgradeTriggers += max(0, upgradeTriggerCount)
        currentStageMinimumBankrollCents = min(currentStageMinimumBankrollCents, bankrollCents)
        let netChange = bankrollCents - bankrollBeforeRoundCents
        currentStageBiggestWinCents = max(currentStageBiggestWinCents, netChange)
        currentStageBiggestLossCents = min(currentStageBiggestLossCents, netChange)

        if didWinBet {
            currentStageWinningBets += 1
        }

        if didWinBet && (upgradeTriggerCount > 0 || didWinWithReveal) {
            currentStageUpgradeInfluencedWins += 1
        }

        if !result.isPush && !didWinBet {
            currentStageLosses += 1
        }

        if didWinWithReveal {
            currentStageRevealWins += 1
        }

        switch result.winner {
        case .player:
            playerWins += 1
        case .banker:
            bankerWins += 1
        case .tie:
            tieResults += 1
        }

        updateHighs(bankrollCents: bankrollCents)
    }

    mutating func updateHighs(bankrollCents: Int) {
        highestBankrollCents = max(highestBankrollCents, bankrollCents)
        highestProfitCents = max(highestProfitCents, max(0, currentProfitCents(bankrollCents: bankrollCents)))
    }

    mutating func evaluateStage(bankrollCents: Int) {
        if isStageClear(bankrollCents: bankrollCents) {
            status = .stageCleared
        } else if isStageFailed(bankrollCents: bankrollCents) {
            status = .failed
        } else if roundsRemaining == 0 {
            status = .failed
        } else {
            status = .active
        }
    }

    mutating func advanceAfterStageClear(bankrollCents: Int) {
        guard currentStageIndex + 1 < stages.count else {
            status = .completed
            return
        }

        currentStageIndex += 1
        stageStartingBankrollCents = bankrollCents
        currentStageRoundsPlayed = 0
        currentStageWinningBets = 0
        currentStageUpgradeTriggers = 0
        currentStageRevealWins = 0
        currentStageUpgradeInfluencedWins = 0
        currentStageLosses = 0
        currentStageMinimumBankrollCents = bankrollCents
        currentStageBiggestWinCents = 0
        currentStageBiggestLossCents = 0
        status = .active
    }
}
