import SwiftUI

struct RunHUDView: View {
    let runManager: RunManager
    let bankrollCents: Int
    let rewardProgressText: String
    let bankrollDeltaCents: Int
    let challengeID: ChallengeModeID
    let isDailyRun: Bool

    private var currentProfitCents: Int {
        runManager.stageProfitCents(bankrollCents: bankrollCents)
    }

    private var teachingObjective: StageObjective? {
        runManager.currentStage.teachingObjective
    }

    private var goalTitle: String {
        teachingObjective?.title ?? "Stage Profit"
    }

    private var goalProgressText: String {
        guard let teachingObjective else {
            return "\(MoneyFormatter.signed(currentProfitCents)) / +\(MoneyFormatter.format(runManager.currentStage.targetProfitCents))"
        }

        let objectiveText = teachingObjective.progressText(in: runManager, bankrollCents: bankrollCents)
        guard runManager.currentStage.targetProfitCents > 0 else {
            return objectiveText
        }

        return "\(objectiveText)  or  \(MoneyFormatter.signed(currentProfitCents)) / +\(MoneyFormatter.format(runManager.currentStage.targetProfitCents))"
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Stage \(runManager.currentStage.id)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: CasinoTheme.gold.opacity(0.18), radius: 8)

                    Text(rewardProgressText)
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(CasinoTheme.gold)

                    Text(isDailyRun ? "\(challengeID.name) Daily Run" : challengeID.name)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                        .textCase(.uppercase)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 8) {
                        CrookedChipView(valueText: "$", size: 30, tone: .gold)

                        AnimatedMoneyText(cents: bankrollCents)
                            .minimumScaleFactor(0.7)
                    }

                    Text("Bankroll")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.56))
                        .textCase(.uppercase)

                    if bankrollDeltaCents != 0 {
                        Text(MoneyFormatter.signed(bankrollDeltaCents))
                            .font(.caption.monospacedDigit().weight(.black))
                            .foregroundStyle(bankrollDeltaCents > 0 ? CasinoTheme.emerald : CasinoTheme.red)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goalTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.58))
                        .textCase(.uppercase)

                    Spacer()

                    Text(goalProgressText)
                        .font(.subheadline.monospacedDigit().weight(.black))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))

                        Capsule()
                            .fill(CasinoTheme.gold)
                            .frame(width: geometry.size.width * runManager.combinedStageProgress(bankrollCents: bankrollCents))
                    }
                }
                .frame(height: 10)

                if let teachingObjective {
                    Text(teachingObjective.description)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.52))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
            }

            HStack {
                stat(title: "Target", value: runManager.currentStage.targetProfitCents > 0 ? MoneyFormatter.format(runManager.currentStage.targetProfitCents) : goalTitle)
                stat(title: "Rounds", value: "\(runManager.roundsRemaining) / \(runManager.currentRoundLimit) left")
                stat(title: "Played", value: "\(runManager.totalRoundsPlayed)")
            }
        }
        .padding(16)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 14)
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.48))
                .textCase(.uppercase)

            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold.opacity(0.60), cornerRadius: 8)
    }
}
