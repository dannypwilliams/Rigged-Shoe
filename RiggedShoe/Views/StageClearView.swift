import SwiftUI

struct StageClearView: View {
    let runManager: RunManager
    let bankrollCents: Int
    let choices: [StageReward]
    let onSelect: (StageReward) -> Void
    @State private var didAppear = false
    @State private var particleTrigger = UUID()

    private var currentProfitCents: Int {
        runManager.stageProfitCents(bankrollCents: bankrollCents)
    }

    private var clearReasonText: String {
        if let objective = runManager.currentStage.teachingObjective,
           objective.isComplete(in: runManager, bankrollCents: bankrollCents) {
            return "Objective complete: \(objective.title)"
        }

        return "Profit target reached"
    }

    private var nextStage: Stage? {
        let nextIndex = runManager.currentStageIndex + 1
        guard runManager.stages.indices.contains(nextIndex) else {
            return nil
        }

        return runManager.stages[nextIndex]
    }

    var body: some View {
        ZStack {
            CasinoTheme.background
            .ignoresSafeArea()

            ParticleBurstView(
                trigger: particleTrigger,
                color: CasinoTheme.gold,
                secondaryColor: CasinoTheme.emerald,
                count: 38,
                intensity: 1.1
            )

            GeometryReader { proxy in
                let isCompact = proxy.size.height < 780

                VStack(spacing: isCompact ? 10 : 14) {
                    CasinoLightsView()
                        .frame(height: isCompact ? 18 : 24)

                    VStack(spacing: isCompact ? 4 : 7) {
                        Text("Reward Draft")
                            .font(.system(size: isCompact ? 29 : 34, weight: .black, design: .rounded))
                            .foregroundStyle(CasinoTheme.gold)
                            .multilineTextAlignment(.center)
                            .shadow(color: CasinoTheme.gold.opacity(0.40), radius: 12)

                        Text("Stage \(runManager.currentStage.id)")
                            .font((isCompact ? Font.headline : Font.title3).weight(.black))
                            .foregroundStyle(.white)

                        Text(clearReasonText)
                            .font((isCompact ? Font.caption : Font.subheadline).weight(.bold))
                            .foregroundStyle(.white.opacity(0.66))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    HStack(spacing: 8) {
                        stat(title: "Gain", value: MoneyFormatter.signed(currentProfitCents), isCompact: isCompact)
                        stat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents), isCompact: isCompact)
                        stat(title: "Chips", value: "\(runManager.chips)", isCompact: isCompact)
                    }

                    if let nextStage {
                        VStack(spacing: 3) {
                            Text(nextStageGoalText(nextStage))
                                .font(.system(size: isCompact ? 10 : 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.62))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.74)

                            if let unlockText = betUnlockText(for: nextStage) {
                                Text(unlockText)
                                    .font(.system(size: isCompact ? 9 : 10, weight: .black, design: .rounded))
                                    .foregroundStyle(CasinoTheme.gold)
                                    .textCase(.uppercase)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 8)
                    }

                    VStack(spacing: 4) {
                        Text("Reward Earned")
                            .font((isCompact ? Font.subheadline : Font.headline).weight(.black))
                            .foregroundStyle(.white)

                            Text("Choose 1 of 3 rewards, then visit the shop.")
                            .font((isCompact ? Font.caption : Font.subheadline).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.62))
                    }

                    VStack(spacing: isCompact ? 7 : 9) {
                        ForEach(choices) { reward in
                            Button {
                                onSelect(reward)
                            } label: {
                                rewardCard(reward, isCompact: isCompact)
                            }
                            .buttonStyle(JuicyPressButtonStyle())
                        }
                    }
                    .layoutPriority(1)
                }
                .padding(.horizontal, 16)
                .padding(.top, isCompact ? 8 : 14)
                .padding(.bottom, isCompact ? 12 : 18)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .scaleEffect(didAppear ? 1 : 0.96)
                .opacity(didAppear ? 1 : 0)
            }
        }
        .onAppear {
            particleTrigger = UUID()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                didAppear = true
            }
        }
    }

    private func stat(title: String, value: String, isCompact: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: isCompact ? 9 : 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.54))
                .textCase(.uppercase)

            Text(value)
                .font((isCompact ? Font.subheadline : Font.title3).monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 9 : 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func rewardCard(_ reward: StageReward, isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 7) {
            Text("Stage Reward")
                .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.gold)
                .textCase(.uppercase)

            Text(reward.name)
                .font((isCompact ? Font.subheadline : Font.title3).weight(.black))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(reward.description)
                .font((isCompact ? Font.caption2 : Font.subheadline).weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .padding(isCompact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.52), lineWidth: 1)
        )
        .shadow(color: CasinoTheme.gold.opacity(0.12), radius: 10, y: 6)
    }

    private func betUnlockText(for nextStage: Stage) -> String? {
        let currentAmounts = Set(runManager.currentStage.betLimit.allowedBetAmountsCents)
        let newAmounts = nextStage.betLimit.allowedBetAmountsCents
            .filter { !currentAmounts.contains($0) }
            .sorted()

        guard !newAmounts.isEmpty else {
            return nil
        }

        let formattedAmounts = newAmounts.map(MoneyFormatter.format).joined(separator: ", ")
        return newAmounts.count == 1
            ? "New bet unlocked: \(formattedAmounts)"
            : "New bets unlocked: \(formattedAmounts)"
    }

    private func nextStageGoalText(_ stage: Stage) -> String {
        if let objective = stage.teachingObjective {
            if stage.targetProfitCents > 0 {
                return "Next goal: Stage \(stage.id) - \(objective.title), or earn +\(MoneyFormatter.format(stage.targetProfitCents)) from stage start."
            }

            return "Next table: Stage \(stage.id) - \(objective.description)"
        }

        return "Next table: Stage \(stage.id), \(stage.roundLimit) hands against \(stage.opponentName)."
    }
}
