import Foundation

enum RunStatus: Equatable {
    case active
    case stageCleared
    case failed
    case completed
}

enum StageFlowState: String, Codable, Equatable {
    case runStart
    case stagePreview
    case battle
    case stageResult
    case rewardDraft
    case shop
    case runComplete
    case runFailed
}

struct RunManager: Equatable {
    static let defaultStartingBankrollCents = 25_000

    let stages: [Stage]
    let startingBankrollCents: Int
    var flowState: StageFlowState
    var stageStartingBankrollCents: Int
    var currentStageStartingHeat: Int
    var currentStageStartingChips: Int
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
    var chips: Int
    var heat: Int
    var maxHeat: Int
    var lastStageResult: StageResultData?
    var status: RunStatus

    init(stages: [Stage] = Stage.allStages, startingBankrollCents: Int = Self.defaultStartingBankrollCents) {
        self.stages = stages
        self.startingBankrollCents = startingBankrollCents
        self.flowState = .runStart
        self.stageStartingBankrollCents = startingBankrollCents
        self.currentStageStartingHeat = 0
        self.currentStageStartingChips = 3
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
        self.chips = 3
        self.heat = 0
        self.maxHeat = 10
        self.lastStageResult = nil
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

    var stagePreviewData: StagePreviewData {
        StagePreviewData(stage: currentStage, handCount: currentRoundLimit)
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

    func minimumBetCents() -> Int {
        currentStage.minimumBetCents
    }

    func maximumBetCents(bankrollCents: Int) -> Int {
        min(currentStage.stageMaxBetCents, max(0, bankrollCents / 4))
    }

    func isBetAmountAllowed(_ amountCents: Int, bankrollCents: Int) -> Bool {
        amountCents >= minimumBetCents()
            && amountCents <= maximumBetCents(bankrollCents: bankrollCents)
            && amountCents <= bankrollCents
            && currentStage.betLimit.allows(amountCents)
    }

    func betCapReason(for amountCents: Int, bankrollCents: Int) -> String? {
        if !currentStage.betLimit.allows(amountCents) {
            return "Locked until a later stage."
        }

        if amountCents < minimumBetCents() {
            return "Below the stage ante."
        }

        if amountCents > bankrollCents {
            return "Bankroll too low."
        }

        if amountCents > maximumBetCents(bankrollCents: bankrollCents) {
            return "Stage cap is \(MoneyFormatter.format(maximumBetCents(bankrollCents: bankrollCents)))."
        }

        return nil
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
        guard bankrollCents > 0, heat < maxHeat else {
            return false
        }

        if currentStageRoundsPlayed >= currentRoundLimit {
            return true
        }

        if currentStage.targetProfitCents > 0,
           stageProfitCents(bankrollCents: bankrollCents) >= currentStage.targetProfitCents {
            return true
        }

        return currentStage.teachingObjective?.isComplete(in: self, bankrollCents: bankrollCents) == true
    }

    func isStageFailed(bankrollCents: Int) -> Bool {
        bankrollCents < currentStage.minimumBetCents
            || heat >= maxHeat
            || currentStage.teachingObjective?.isFailed(in: self, bankrollCents: bankrollCents) == true
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
        guard status == .active else {
            return
        }

        if let failureReason = failureReason(bankrollCents: bankrollCents) {
            status = .failed
            flowState = .stageResult
            lastStageResult = makeStageResult(
                didWin: false,
                bankrollCents: bankrollCents,
                heatBeforeResult: heat,
                chipsEarned: 0,
                failureReason: failureReason
            )
        } else if isStageClear(bankrollCents: bankrollCents) {
            let heatBeforeResult = heat
            let stageProfit = stageProfitCents(bankrollCents: bankrollCents)
            let heatDelta = stageProfit < 0 ? (currentStage.isBossStage ? 2 : 1) : 0
            heat = min(maxHeat, heat + heatDelta)

            if heat >= maxHeat {
                status = .failed
                flowState = .stageResult
                lastStageResult = makeStageResult(
                    didWin: false,
                    bankrollCents: bankrollCents,
                    heatBeforeResult: heatBeforeResult,
                    chipsEarned: 0,
                    failureReason: .heatMaxed
                )
                return
            }

            let earnedChips = EconomyRewardCalculation
                .stageClear(stage: currentStage, bankrollCents: bankrollCents)
                .chipsReward
            chips += earnedChips
            status = .stageCleared
            flowState = .stageResult
            lastStageResult = makeStageResult(
                didWin: true,
                bankrollCents: bankrollCents,
                heatBeforeResult: heatBeforeResult,
                chipsEarned: earnedChips,
                failureReason: nil
            )
        } else if roundsRemaining == 0 {
            status = .failed
            flowState = .stageResult
            lastStageResult = makeStageResult(
                didWin: false,
                bankrollCents: bankrollCents,
                heatBeforeResult: heat,
                chipsEarned: 0,
                failureReason: currentStage.isBossStage ? .bossDefeat : .stageCondition
            )
        } else {
            status = .active
            flowState = .battle
        }
    }

    mutating func advanceAfterStageClear(bankrollCents: Int) {
        guard currentStageIndex + 1 < stages.count else {
            status = .completed
            flowState = .runComplete
            return
        }

        currentStageIndex += 1
        stageStartingBankrollCents = bankrollCents
        currentStageStartingHeat = heat
        currentStageStartingChips = chips
        currentStageRoundsPlayed = 0
        currentStageWinningBets = 0
        currentStageUpgradeTriggers = 0
        currentStageRevealWins = 0
        currentStageUpgradeInfluencedWins = 0
        currentStageLosses = 0
        currentStageMinimumBankrollCents = bankrollCents
        currentStageBiggestWinCents = 0
        currentStageBiggestLossCents = 0
        lastStageResult = nil
        status = .active
        flowState = .stagePreview
    }

    mutating func startRunPreview() {
        guard flowState == .runStart else {
            return
        }

        flowState = .stagePreview
    }

    mutating func startStageBattle() {
        guard status == .active else {
            return
        }

        lastStageResult = nil
        flowState = .battle
    }

    mutating func showRewardDraft() {
        guard flowState == .stageResult, status == .stageCleared else {
            return
        }

        if currentStageIndex + 1 >= stages.count {
            status = .completed
            flowState = .runComplete
        } else {
            flowState = .rewardDraft
        }
    }

    mutating func enterShop() {
        guard status == .stageCleared else {
            return
        }

        flowState = .shop
    }

    mutating func failRunAfterResult() {
        guard status == .failed else {
            return
        }

        flowState = .runFailed
    }

    private func failureReason(bankrollCents: Int) -> StageFailureReason? {
        if bankrollCents < currentStage.minimumBetCents {
            return .bankrollBusted
        }

        if heat >= maxHeat {
            return .heatMaxed
        }

        if currentStage.teachingObjective?.isFailed(in: self, bankrollCents: bankrollCents) == true {
            return currentStage.isBossStage ? .bossDefeat : .stageCondition
        }

        return nil
    }

    private func makeStageResult(
        didWin: Bool,
        bankrollCents: Int,
        heatBeforeResult: Int,
        chipsEarned: Int,
        failureReason: StageFailureReason?
    ) -> StageResultData {
        StageResultData(
            stageNumber: currentStage.id,
            didWin: didWin,
            profitCents: stageProfitCents(bankrollCents: bankrollCents),
            bankrollChangeCents: bankrollCents - stageStartingBankrollCents,
            heatChange: heat - heatBeforeResult,
            chipsEarned: chipsEarned,
            failureReason: failureReason
        )
    }
}
