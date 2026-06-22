import SwiftUI

struct RunOverView: View {
    let runManager: RunManager
    let bossManager: BossManager
    let profile: PlayerProfile
    let startingContact: StartingContact
    let activeModifiers: [ModifierInstance]
    let bossRelics: [BossRelic]
    let bankrollCents: Int
    let chipsEarnedThisRun: Int
    let reputationEarnedThisRun: Int
    let onStartNewRun: () -> Void
    @State private var didAppear = false
    @State private var particleTrigger = UUID()

    private var isVictory: Bool {
        runManager.status == .completed
    }

    var body: some View {
        ZStack {
            (isVictory ? CasinoTheme.background : CasinoTheme.warningBackground)
            .ignoresSafeArea()

            if isVictory {
                ParticleBurstView(
                    trigger: particleTrigger,
                    color: CasinoTheme.gold,
                    secondaryColor: CasinoTheme.emerald,
                    count: 74,
                    intensity: 1.45
                )
            }

            GeometryReader { proxy in
                let isCompact = proxy.size.height < 720
                let visibleStats = Array(statItems(isCompact: isCompact).enumerated())

                VStack(spacing: isCompact ? 10 : 15) {
                    CasinoLightsView()
                        .frame(height: isCompact ? 16 : 24)

                    VStack(spacing: isCompact ? 4 : 8) {
                        Text(isVictory ? "Casino Cleared" : "RUN OVER")
                            .font(.system(size: isCompact ? 31 : (isVictory ? 42 : 38), weight: .black, design: .rounded))
                            .foregroundStyle(isVictory ? CasinoTheme.gold : CasinoTheme.red)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.74)
                            .shadow(color: (isVictory ? CasinoTheme.gold : CasinoTheme.red).opacity(0.44), radius: 14)

                        Text(isVictory ? "You beat the final table." : "Bankroll or Heat ended the run.")
                            .font((isCompact ? Font.subheadline : Font.headline).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.70))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    VStack(alignment: .leading, spacing: isCompact ? 5 : 7) {
                        Text(mainBuild)
                            .font(.headline.weight(.black))
                            .foregroundStyle(CasinoTheme.gold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(runExplanation)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.68))
                            .lineLimit(isCompact ? 2 : 3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(isCompact ? 10 : 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .crookedPanel(kind: isVictory ? .reward : .warning, strokeColor: isVictory ? CrookedCasinoTheme.dirtyGold : CrookedCasinoTheme.mutedRed, cornerRadius: 12)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: isCompact ? 7 : 9) {
                        ForEach(visibleStats, id: \.offset) { item in
                            statTile(title: item.element.title, value: item.element.value, isCompact: isCompact)
                        }
                    }
                    .padding(isCompact ? 10 : 14)
                    .crookedPanel(kind: .felt, strokeColor: isVictory ? CrookedCasinoTheme.dirtyGold : CrookedCasinoTheme.mutedRed, cornerRadius: 14)

                    Spacer(minLength: 0)

                    Button(action: onStartNewRun) {
                        Text("Start New Run")
                            .font((isCompact ? Font.headline : Font.title3).weight(.black))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isCompact ? 3 : 5)
                    }
                    .buttonStyle(CrookedCasinoButtonStyle(tone: .gold))
                    .accessibilityLabel("Start New Run")
                }
                .padding(.horizontal, 18)
                .padding(.top, max(proxy.safeAreaInsets.top, CGFloat(isCompact ? 6 : 12)))
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, CGFloat(isCompact ? 8 : 14)))
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .opacity(didAppear ? 1 : 0)
                .scaleEffect(didAppear ? 1 : 0.96)
            }
        }
        .onAppear {
            particleTrigger = UUID()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.76)) {
                didAppear = true
            }
        }
    }

    private func statTile(title: String, value: String, isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
            Text(title)
                .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: isCompact ? 13 : 15, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, isCompact ? 9 : 11)
        .padding(.vertical, isCompact ? 7 : 9)
        .background(
            CrookedStickerShape(cornerRadius: 10)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func statItems(isCompact: Bool) -> [(title: String, value: String)] {
        let required: [(title: String, value: String)] = [
            (title: "Contact", value: startingContact.name),
            (title: "Top Mod", value: BuildArchetypeDetector.highestLevelModifierName(activeModifiers: activeModifiers)),
            (title: "Stage", value: "\(runManager.stageReached)"),
            (title: "Bankroll", value: MoneyFormatter.format(bankrollCents)),
            (title: "Heat", value: "\(runManager.heat)/\(runManager.maxHeat)"),
            (title: "Best Bankroll", value: MoneyFormatter.format(runManager.highestBankrollCents)),
            (title: "Best Profit", value: MoneyFormatter.format(runManager.highestProfitCents)),
            (title: "Rounds", value: "\(runManager.totalRoundsPlayed)"),
            (title: "Bosses", value: "\(bossManager.bossesDefeatedCount)"),
            (title: "Chips Earned", value: "+\(formatNumber(chipsEarnedThisRun))"),
            (title: "Rep Earned", value: "+\(formatNumber(reputationEarnedThisRun))")
        ]

        guard !isCompact else {
            return required
        }

        return required + [
            (title: "Total Chips", value: formatNumber(profile.casinoChips)),
            (title: "Total Rep", value: formatNumber(profile.reputation)),
            (title: "Player Wins", value: "\(runManager.playerWins)"),
            (title: "Banker Wins", value: "\(runManager.bankerWins)"),
            (title: "Tie Results", value: "\(runManager.tieResults)"),
            (title: "Relics", value: "\(bossRelics.count)")
        ]
    }

    private var mainBuild: String {
        "Main Build: \(BuildArchetypeDetector.detect(activeModifiers: activeModifiers))"
    }

    private var runExplanation: String {
        if isVictory {
            return "Your build survived every opponent table and cleared The House."
        }

        if let result = runManager.lastStageResult, !result.lossExplanation.isEmpty {
            return result.lossExplanation
        }

        if runManager.heat >= runManager.maxHeat {
            return "Heat reached the limit. Add Heat control, cleaner reveals, or lower-risk lines next run."
        }

        if bankrollCents < runManager.currentStage.minimumBetCents {
            return "Bankroll fell below the table minimum. The next build needs steadier income or safer bet sizing."
        }

        return "The opponent outscored your table profit. Add payout scaling, pivot options, or stronger information before the next boss."
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
