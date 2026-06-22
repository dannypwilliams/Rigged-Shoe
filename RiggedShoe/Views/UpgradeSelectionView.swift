import SwiftUI

struct UpgradeSelectionView: View {
    let choices: [UpgradeCard]
    let onSelect: (UpgradeCard) -> Void

    @State private var appearedIDs: Set<UUID> = []
    @State private var sparkleTrigger = UUID()

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 740

            ZStack {
                CasinoTheme.background
                    .ignoresSafeArea()

                VStack(spacing: isCompact ? 9 : 14) {
                    VStack(spacing: isCompact ? 3 : 6) {
                        Text("Choose an Upgrade")
                            .font(.system(size: isCompact ? 29 : 34, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: CasinoTheme.gold.opacity(0.30), radius: 10)

                        Text("Tap one card. It applies immediately.")
                            .font(.system(size: isCompact ? 12 : 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.64))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: isCompact ? 7 : 9) {
                        ForEach(Array(choices.enumerated()), id: \.element.id) { index, upgrade in
                            Button {
                                onSelect(upgrade)
                            } label: {
                                upgradeCard(upgrade, isCompact: isCompact)
                            }
                            .buttonStyle(JuicyPressButtonStyle())
                            .opacity(appearedIDs.contains(upgrade.id) ? 1 : 0)
                            .offset(y: appearedIDs.contains(upgrade.id) ? 0 : 28)
                            .rotation3DEffect(.degrees(appearedIDs.contains(upgrade.id) ? 0 : -75), axis: (x: 1, y: 0, z: 0))
                            .animation(.spring(response: 0.50, dampingFraction: 0.74).delay(Double(index) * 0.08), value: appearedIDs)
                        }
                    }
                }
                .padding(isCompact ? 12 : 16)
            }
        }
        .onAppear {
            sparkleTrigger = UUID()
            for choice in choices {
                appearedIDs.insert(choice.id)
            }
        }
    }

    private func upgradeCard(_ upgrade: UpgradeCard, isCompact: Bool) -> some View {
        let color = CasinoTheme.rarityColor(upgrade.rarity)

        return ZStack {
            VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
                HStack {
                    Text(upgrade.rarity.displayName)
                        .font(.system(size: isCompact ? 10 : 12, weight: .black, design: .rounded))
                        .foregroundStyle(upgrade.rarity == .legendary ? .black : color)
                        .padding(.horizontal, isCompact ? 8 : 10)
                        .padding(.vertical, isCompact ? 4 : 5)
                        .background(
                            Capsule()
                                .fill(upgrade.rarity == .legendary ? color : color.opacity(0.15))
                        )

                    Spacer()

                    Text("Tap to pick")
                        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                        .textCase(.uppercase)

                    if upgrade.rarity == .legendary {
                        Image(systemName: "sparkles")
                            .foregroundStyle(CasinoTheme.gold)
                    }
                }

                Text(upgrade.name)
                    .font(.system(size: isCompact ? 18 : 21, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(upgrade.description)
                    .font(.system(size: isCompact ? 12 : 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(isCompact ? 3 : 2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Label(activationText(for: upgrade.effect), systemImage: "bolt.fill")
                    .font(.system(size: isCompact ? 8 : 10, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, isCompact ? 7 : 9)
                    .padding(.vertical, isCompact ? 4 : 5)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.12))
                    )

                HStack(spacing: 6) {
                    ForEach(Array(upgrade.tags.prefix(isCompact ? 2 : 3)), id: \.self) { tag in
                        Text(tag.displayName)
                            .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                            .foregroundStyle(color)
                            .textCase(.uppercase)
                            .padding(.horizontal, isCompact ? 7 : 8)
                            .padding(.vertical, isCompact ? 3 : 4)
                            .background(Capsule().fill(color.opacity(0.14)))
                    }
                }
            }
            .padding(isCompact ? 11 : 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(upgrade.rarity == .legendary ? 0.26 : 0.12),
                                Color.white.opacity(0.07),
                                Color.black.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(color.opacity(upgrade.rarity == .legendary ? 0.90 : 0.62), lineWidth: upgrade.rarity == .legendary ? 2 : 1)
            )
            .shadow(color: color.opacity(upgrade.rarity == .legendary ? 0.32 : 0.12), radius: upgrade.rarity == .legendary ? 18 : 8, y: 8)

            if upgrade.rarity == .legendary {
                ParticleBurstView(
                    trigger: sparkleTrigger,
                    color: CasinoTheme.gold,
                    secondaryColor: .white,
                    count: 14,
                    intensity: 0.55
                )
            }
        }
    }

    private func activationText(for effect: UpgradeEffect) -> String {
        let fragments = activationFragments(for: effect)
        guard !fragments.isEmpty else {
            return "Applies immediately"
        }

        let uniqueFragments = fragments.reduce(into: [String]()) { result, fragment in
            if !result.contains(fragment) {
                result.append(fragment)
            }
        }

        if uniqueFragments.count == 1 {
            return uniqueFragments[0]
        }

        return "Triggers: " + uniqueFragments.prefix(2).joined(separator: " + ")
    }

    private func activationFragments(for effect: UpgradeEffect) -> [String] {
        switch effect {
        case .addExtraNines, .addExtraEights, .addCards, .addRandomCards, .addTiePairCards, .removeZeroValueCards, .removeCards:
            return ["Immediately changes the shoe"]
        case .playerWinBonus:
            return ["When Player wins"]
        case .bankerWinBonus, .noCommission:
            return ["When Banker wins"]
        case .chosenBetWinBonus:
            return ["When your chosen bet wins"]
        case .forecastWinBonus:
            return ["When the forecast is right"]
        case .improveTiePayout, .tiePayoutBonus:
            return ["On winning Tie bets"]
        case .shoeReveal(let configuration):
            return configuration.isCharged
                ? ["Tap to activate", "Bet cap while active"]
                : ["Before each hand"]
        case .revealCards:
            return ["Before each hand"]
        case .limitedXRayReveal:
            return ["Tap to activate", "Limited charges"]
        case .revealAfterRound:
            return ["After each round"]
        case .hotShoe, .coldShoe:
            return ["Whenever the shoe shuffles"]
        case .profitMultiplier(let betType, _):
            return [betType.map { "When \($0.displayName) wins" } ?? "On any winning bet"]
        case .lossMultiplier:
            return ["When a bet loses"]
        case .lossRebatePercent:
            return ["After losses"]
        case .roundStipend:
            return ["Every round"]
        case .stageStartCash:
            return ["At stage start"]
        case .cardExitIncome:
            return ["Whenever cards leave the shoe"]
        case .streakBonus(let betType, _):
            return [betType.map { "When \($0.displayName) streaks" } ?? "When win streaks build"]
        case .firstTieEachStageMultiplier:
            return ["First Tie each stage"]
        case .consecutiveTiePayoutBonus:
            return ["On consecutive Ties"]
        case .previousLossRefundOnTie:
            return ["When Tie hits after a loss"]
        case .bossStageCash:
            return ["At boss stage start"]
        case .safetyNet:
            return ["Once per stage when bankroll drops"]
        case .smallBetWinMultiplier:
            return ["When small bets win"]
        case .smallBetStreakBonus:
            return ["After small-bet win streaks"]
        case .pressAfterWinMultiplier:
            return ["After raising following a win"]
        case .lossRebateEveryHands(_, let everyHands):
            return ["Every \(everyHands) hands on loss"]
        case .burnCardEveryHands(let interval):
            return ["Manual burn every \(interval) hands"]
        case .moveTopCardDeeper:
            return ["Manual shoe control once per stage"]
        case .bankerInitialTotalBonus(let minTotal, let maxTotal, _):
            return ["When Banker starts \(minTotal)-\(maxTotal) and you win"]
        case .firstNaturalEachStageBonus:
            return ["First natural each stage"]
        case .comebackWinBonus(let lossCount, _):
            return ["After \(lossCount) losses, next win"]
        case .firstLargeBetStageMultiplier:
            return ["First big bet win each stage"]
        case .steadyBetWinBonus:
            return ["When you win without raising"]
        case .raiseWinBonus:
            return ["When you raise and win"]
        case .combined(let effects):
            return effects.flatMap(activationFragments)
        }
    }
}

struct JuicyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
