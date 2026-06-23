import SwiftUI

struct StageClearView: View {
    let runManager: RunManager
    let bankrollCents: Int
    let choices: [StageReward]
    let onSelect: (StageReward) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var didAppear = false
    @State private var particleTrigger = UUID()

    private var currentProfitCents: Int {
        runManager.stageProfitCents(bankrollCents: bankrollCents)
    }

    private var clearReasonText: String {
        "Cleared by staying solvent through \(runManager.currentRoundLimit) hands."
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
            CrookedCasinoTheme.tableBackground
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
                let prioritizesRewardChoices = dynamicTypeSize.isAccessibilitySize

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 10 : 14) {
                        if !prioritizesRewardChoices {
                            CasinoLightsView()
                                .frame(height: isCompact ? 18 : 24)
                        }

                        rewardHeader(isCompact: isCompact, showsReason: !prioritizesRewardChoices)

                        if prioritizesRewardChoices {
                            rewardChoices(isCompact: isCompact)
                            rewardPrompt(isCompact: isCompact)
                            statsRow(isCompact: isCompact)
                            nextStageSummary(isCompact: isCompact)
                        } else {
                            statsRow(isCompact: isCompact)
                            nextStageSummary(isCompact: isCompact)
                            rewardPrompt(isCompact: isCompact)
                            rewardChoices(isCompact: isCompact)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, max(proxy.safeAreaInsets.top, CGFloat(isCompact ? 8 : 14)))
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom, CGFloat(isCompact ? 16 : 22)))
                    .frame(maxWidth: 520)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                    .scaleEffect(didAppear ? 1 : 0.96)
                    .opacity(didAppear ? 1 : 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .onAppear {
            particleTrigger = UUID()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                didAppear = true
            }
        }
    }

    private func rewardHeader(isCompact: Bool, showsReason: Bool) -> some View {
        VStack(spacing: isCompact ? 4 : 7) {
            Text("Take 1 Reward")
                .font(.system(size: isCompact ? 29 : 34, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.gold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.82)
                .shadow(color: CasinoTheme.gold.opacity(0.40), radius: 12)
                .accessibilityAddTraits(.isHeader)

            Text("Stage \(runManager.currentStage.id)")
                .font((isCompact ? Font.headline : Font.title3).weight(.black))
                .foregroundStyle(.white)

            if showsReason {
                Text(clearReasonText)
                    .font((isCompact ? Font.caption : Font.subheadline).weight(.bold))
                    .foregroundStyle(.white.opacity(0.66))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func statsRow(isCompact: Bool) -> some View {
        HStack(spacing: 8) {
            stat(title: "Gain", value: MoneyFormatter.signed(currentProfitCents), isCompact: isCompact)
            stat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents), isCompact: isCompact)
            stat(title: "Chips", value: "\(runManager.chips)", isCompact: isCompact)
        }
    }

    @ViewBuilder
    private func nextStageSummary(isCompact: Bool) -> some View {
        if let nextStage {
            VStack(spacing: 3) {
                Text(nextStageGoalText(nextStage))
                    .font(.system(size: isCompact ? 10 : 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if let unlockText = betUnlockText(for: nextStage) {
                    Text(unlockText)
                        .font(.system(size: isCompact ? 9 : 10, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.gold)
                        .textCase(.uppercase)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private func rewardPrompt(isCompact: Bool) -> some View {
        VStack(spacing: 4) {
            Text("Reward Earned")
                .font((isCompact ? Font.subheadline : Font.headline).weight(.black))
                .foregroundStyle(.white)

            Text("Choose 1 of 3 rewards, then visit the shop.")
                .font((isCompact ? Font.caption : Font.subheadline).weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func rewardChoices(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 7 : 9) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, reward in
                Button {
                    onSelect(reward)
                } label: {
                    rewardCard(reward, isCompact: isCompact)
                }
                .buttonStyle(JuicyPressButtonStyle())
                .accessibilityIdentifier("reward-choice-\(index + 1)")
            }
        }
        .layoutPriority(1)
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
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 10)
    }

    private func rewardCard(_ reward: StageReward, isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(reward.name)
                    .font(.system(size: isCompact ? 17 : 19, weight: .black, design: .rounded))
                    .foregroundStyle(CrookedCasinoTheme.ink)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text(rewardArchetype(reward).rawValue)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(CrookedCasinoTheme.ink)
                    .textCase(.uppercase)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(CrookedStickerShape(cornerRadius: 7).fill(CrookedCasinoTheme.dirtyGold.opacity(0.72)))
            }

            Text(rewardArchetype(reward).fantasyTag)
                .font(.caption.weight(.bold))
                .foregroundStyle(CrookedCasinoTheme.ink.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            rewardLine(title: "Effect", value: reward.description)
            rewardLine(title: "Heat", value: rewardHeatImpact(reward))
        }
        .padding(isCompact ? 12 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            CrookedStickerShape(cornerRadius: 13)
                .fill(CrookedCasinoTheme.paperLight)
                .overlay {
                    CrookedStickerShape(cornerRadius: 13)
                        .stroke(CrookedCasinoTheme.dirtyGold.opacity(0.72), lineWidth: 1.3)
                }
        }
        .overlay(DoodleAccentView(accent: CrookedCasinoTheme.felt, density: .low).allowsHitTesting(false))
        .shadow(color: CrookedCasinoTheme.felt.opacity(0.12), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
    }

    private func rewardLine(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(CrookedCasinoTheme.ink.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 52, alignment: .leading)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CrookedCasinoTheme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func rewardArchetype(_ reward: StageReward) -> VerticalSliceArchetype {
        let tags = RewardDraftState.tags(for: reward)
        if tags.contains(.heat) || tags.contains(.betControl) {
            return .heatGambler
        }

        if tags.contains(.economy) || tags.contains(.comeback) || tags.contains(.consumable) || tags.contains(.attachment) {
            return .compScammer
        }

        return .cardReader
    }

    private func rewardHeatImpact(_ reward: StageReward) -> String {
        if case .heatReduction(let amount)? = reward.rebuildEffect {
            return "-\(amount) Heat"
        }

        if case .reduceHeat(let amount) = reward.effect {
            return "-\(amount) Heat"
        }

        return "+0 Heat"
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

            return "Next table: Stage \(stage.id), \(stage.roundLimit) hands. \(objective.description)"
        }

        return "Next table: Stage \(stage.id), \(stage.roundLimit) hands against \(stage.opponentName)."
    }
}
