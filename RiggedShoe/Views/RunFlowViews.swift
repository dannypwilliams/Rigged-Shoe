import SwiftUI

struct RunStartView: View {
    let contact: StartingContact
    let bankrollCents: Int
    let chips: Int
    let heat: Int
    let maxHeat: Int
    let onContinue: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: CasinoTheme.gold) {
            VStack(spacing: 18) {
                Text("New Run")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.gold)

                VStack(spacing: 8) {
                    Text("Starting Contact")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.58))
                        .textCase(.uppercase)

                    Text(contact.name)
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)

                    Text(contact.summary)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.28)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Chips", value: "\(chips)")
                    RunFlowStat(title: "Heat", value: "\(heat)/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: "Preview Stage 1", action: onContinue)
            }
        }
    }
}

struct StagePreviewView: View {
    let preview: StagePreviewData
    let bankrollCents: Int
    let chips: Int
    let heat: Int
    let maxHeat: Int
    let onEnterBattle: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: preview.isBossStage ? CasinoTheme.red : CasinoTheme.emerald) {
            VStack(spacing: 16) {
                Text(preview.isBossStage ? "Boss Table" : "Stage Preview")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(preview.isBossStage ? CasinoTheme.red : CasinoTheme.gold)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stage \(preview.stageNumber)")
                                .font(.title2.weight(.black))
                                .foregroundStyle(.white)

                            Text(preview.opponentName)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Spacer()

                        Text("ANTE \(preview.ante)")
                            .font(.caption.weight(.black))
                            .foregroundStyle(CasinoTheme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(CasinoTheme.gold))
                    }

                    RunFlowDetailRow(title: "Battle Length", value: "\(preview.handCount) hands")
                    RunFlowDetailRow(title: "Table Rule", value: preview.tableRule)
                    RunFlowDetailRow(title: "Reward Tier", value: preview.rewardTier)

                    if let bossWarning = preview.bossWarning {
                        Text(bossWarning)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(CasinoTheme.red)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(CasinoTheme.red.opacity(0.14))
                            )
                    }
                }
                .padding(16)
                .neonPanel(strokeColor: preview.isBossStage ? CasinoTheme.red : CasinoTheme.gold, opacity: 0.30)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Chips", value: "\(chips)")
                    RunFlowStat(title: "Heat", value: "\(heat)/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: preview.isBossStage ? "Face the Boss" : "Enter Battle", action: onEnterBattle)
            }
        }
    }
}

struct StageResultView: View {
    let result: StageResultData
    let bankrollCents: Int
    let heat: Int
    let maxHeat: Int
    let onContinue: () -> Void

    var body: some View {
        let accent = result.didWin ? CasinoTheme.emerald : CasinoTheme.red

        RunFlowOverlay(accentColor: accent) {
            VStack(spacing: 16) {
                Text(result.title)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(result.didWin ? CasinoTheme.gold : CasinoTheme.red)

                Text("Stage \(result.stageNumber)")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white.opacity(0.72))

                VStack(spacing: 9) {
                    RunFlowDetailRow(title: "Battle Result", value: result.reasonText)
                    RunFlowDetailRow(title: "Profit / Loss", value: MoneyFormatter.signed(result.profitCents))
                    RunFlowDetailRow(title: "Bankroll Change", value: MoneyFormatter.signed(result.bankrollChangeCents))
                    RunFlowDetailRow(title: "Heat Change", value: signedNumber(result.heatChange))
                    RunFlowDetailRow(title: "Chips Earned", value: "+\(result.chipsEarned)")
                }
                .padding(16)
                .neonPanel(strokeColor: accent, opacity: 0.30)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Heat", value: "\(heat)/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: result.didWin ? "Draft Reward" : "Run Summary", action: onContinue)
            }
        }
    }

    private func signedNumber(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }
}

struct ShopPhaseView: View {
    let runManager: RunManager
    let bankrollCents: Int
    let onContinue: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: CasinoTheme.gold) {
            VStack(spacing: 16) {
                Text("Shop Phase")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.gold)

                Text("Spend window between battles. Full buying, selling, rerolls, and attachments land in the next content pass.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                VStack(spacing: 9) {
                    RunFlowDetailRow(title: "Run Chips", value: "\(runManager.chips)")
                    RunFlowDetailRow(title: "Current Heat", value: "\(runManager.heat)/\(runManager.maxHeat)")
                    RunFlowDetailRow(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowDetailRow(title: "Next", value: nextStageText)
                }
                .padding(16)
                .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.28)

                PrimaryRunFlowButton(title: nextStageButtonTitle, action: onContinue)
            }
        }
    }

    private var nextStageText: String {
        let nextIndex = runManager.currentStageIndex + 1
        guard runManager.stages.indices.contains(nextIndex) else {
            return "Run complete"
        }

        let stage = runManager.stages[nextIndex]
        return "Stage \(stage.id): \(stage.opponentName)"
    }

    private var nextStageButtonTitle: String {
        runManager.currentStageIndex + 1 >= runManager.stages.count ? "Finish Run" : "Next Stage"
    }
}

private struct RunFlowOverlay<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content
    @State private var didAppear = false

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            GeometryReader { proxy in
                VStack {
                    Spacer(minLength: 0)

                    content
                        .padding(18)
                        .frame(maxWidth: min(proxy.size.width - 28, 460))
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.black.opacity(0.64))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(accentColor.opacity(0.52), lineWidth: 1)
                        )
                        .shadow(color: accentColor.opacity(0.22), radius: 22, y: 12)
                        .scaleEffect(didAppear ? 1 : 0.96)
                        .opacity(didAppear ? 1 : 0)

                    Spacer(minLength: 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .padding(.horizontal, 14)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                didAppear = true
            }
        }
    }
}

private struct RunFlowStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.56))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}

private struct RunFlowDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.58))
                .textCase(.uppercase)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
    }
}

private struct PrimaryRunFlowButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(CasinoTheme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(CasinoTheme.gold)
                )
        }
        .buttonStyle(JuicyPressButtonStyle())
    }
}
