import SwiftUI

struct RoundResultView: View {
    let result: RoundResult
    let presentation: RoundPresentationState

    @State private var visibleDealCount = 0
    @State private var showResult = false
    @State private var resultScale: CGFloat = 0.92

    private var resultColor: Color {
        if result.isPush {
            return CasinoTheme.gold
        }

        return result.didWin ? CasinoTheme.emerald : CasinoTheme.red
    }

    private var dealSteps: [DealStep] {
        var steps: [DealStep] = []

        if result.playerHand.cards.indices.contains(0) {
            steps.append(DealStep(card: result.playerHand.cards[0], owner: .player))
        }

        if result.bankerHand.cards.indices.contains(0) {
            steps.append(DealStep(card: result.bankerHand.cards[0], owner: .banker))
        }

        if result.playerHand.cards.indices.contains(1) {
            steps.append(DealStep(card: result.playerHand.cards[1], owner: .player))
        }

        if result.bankerHand.cards.indices.contains(1) {
            steps.append(DealStep(card: result.bankerHand.cards[1], owner: .banker))
        }

        if result.playerHand.cards.indices.contains(2) {
            steps.append(DealStep(card: result.playerHand.cards[2], owner: .player))
        }

        if result.bankerHand.cards.indices.contains(2) {
            steps.append(DealStep(card: result.bankerHand.cards[2], owner: .banker))
        }

        return steps
    }

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                VStack(spacing: 12) {
                    shoeSource

                    animatedHand(
                        title: "Player",
                        total: result.playerHand.total,
                        cards: visibleCards(for: .player)
                    )

                    animatedHand(
                        title: "Banker",
                        total: result.bankerHand.total,
                        cards: visibleCards(for: .banker)
                    )
                }

                if presentation.winTier.usesParticles && showResult {
                    ParticleBurstView(
                        trigger: presentation.sequenceID,
                        color: presentation.winTier == .jackpot ? CasinoTheme.gold : CasinoTheme.emerald,
                        secondaryColor: CasinoTheme.gold,
                        count: presentation.winTier == .jackpot ? 54 : 32,
                        intensity: presentation.winTier == .jackpot ? 1.35 : 1.0
                    )
                }
            }

            if showResult {
                resultBanner
                    .scaleEffect(resultScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.62)) {
                            resultScale = 1
                        }
                    }

                HStack(spacing: 12) {
                    stat(title: "Bet", value: "\(result.betType.displayName) \(MoneyFormatter.format(result.betAmountCents))")
                    stat(title: "Payout", value: MoneyFormatter.format(result.payoutCents))
                    stat(title: "Net", value: MoneyFormatter.signed(result.netCents))
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear(perform: startDealAnimation)
        .onChange(of: result.id) { _, _ in
            startDealAnimation()
        }
    }

    private var shoeSource: some View {
        HStack(spacing: 10) {
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(CasinoTheme.feltDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(CasinoTheme.gold.opacity(0.55), lineWidth: 1)
                        )
                        .frame(width: 34, height: 48)
                        .offset(x: CGFloat(index) * 4, y: CGFloat(index) * -2)
                }
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dealing from shoe")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.gold)
                    .textCase(.uppercase)

                Text(showResult ? "Result locked" : "Cards in motion")
                    .font(.caption2.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.52))
            }

            Spacer()
        }
        .padding(12)
        .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.18, cornerRadius: 12)
    }

    private var resultBanner: some View {
        VStack(spacing: 5) {
            Text(presentation.winTier.title)
                .font(.system(size: presentation.winTier == .jackpot ? 34 : 28, weight: .black, design: .rounded))
                .foregroundStyle(resultColor)
                .shadow(color: resultColor.opacity(0.38), radius: 10)

            Text(result.winnerText)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            Text(result.betOutcomeText)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white.opacity(0.74))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(resultColor.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(resultColor.opacity(0.78), lineWidth: 1)
        )
    }

    private func animatedHand(title: String, total: Int, cards: [Card]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text(showResult ? "Total \(total)" : "Total --")
                    .font(.headline.monospacedDigit().weight(.black))
                    .foregroundStyle(showResult ? CasinoTheme.gold : .white.opacity(0.38))
            }

            HStack(spacing: 8) {
                ForEach(cards) { card in
                    CardView(card: card, isHighlighted: showResult && result.winner.displayName == title)
                        .frame(width: 52)
                        .transition(
                            .asymmetric(
                                insertion: .opacity
                                    .combined(with: .offset(x: 120, y: -74))
                                    .combined(with: .scale(scale: 0.72)),
                                removal: .opacity
                            )
                        )
                }

                ForEach(0..<max(0, 3 - cards.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .frame(width: 52)
                        .aspectRatio(0.68, contentMode: .fit)
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.76), value: cards.count)
        }
        .padding(14)
        .neonPanel(strokeColor: title == "Player" ? CasinoTheme.neonBlue : CasinoTheme.red, opacity: 0.20, cornerRadius: 12)
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
                .textCase(.uppercase)

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .neonPanel(strokeColor: Color.white, opacity: 0.10, cornerRadius: 10)
    }

    private func visibleCards(for owner: DealOwner) -> [Card] {
        Array(dealSteps.prefix(visibleDealCount).filter { $0.owner == owner }.map(\.card))
    }

    private func startDealAnimation() {
        visibleDealCount = 0
        showResult = false
        resultScale = 0.92

        for index in dealSteps.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.16) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                    visibleDealCount = index + 1
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(dealSteps.count) * 0.16 + 0.20) {
            withAnimation(.easeOut(duration: 0.22)) {
                showResult = true
            }
        }
    }

    private enum DealOwner {
        case player
        case banker
    }

    private struct DealStep: Identifiable {
        let id = UUID()
        let card: Card
        let owner: DealOwner
    }
}
