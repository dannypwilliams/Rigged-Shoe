import SwiftUI

struct ShoePreviewView: View {
    let cardsRemaining: Int
    let previewCards: [Card]
    let revealedCount: Int
    let shoeImpact: ShoeImpact

    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DealerShoeView(state: shoeImpact == .shuffled ? .shuffling : .peeking, isCompact: true)
                    .frame(width: 48, height: 32)

                Text("Shoe")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .accessibilityHint("The shoe is the live card stack. Revealed cards show upcoming cards.")

                Spacer()

                Text("\(cardsRemaining) cards remaining")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white.opacity(0.70))
                    .contentTransition(.numericText())
            }

            HStack(spacing: 8) {
                if revealedCount > 0 {
                    statusPill("Revealing next \(min(revealedCount, previewCards.count))", color: CasinoTheme.gold)
                }

                if let message = shoeImpact.message {
                    statusPill(message, color: shoeImpact.isPositive ? CasinoTheme.emerald : CasinoTheme.red)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(Array(previewCards.enumerated()), id: \.element.id) { index, card in
                        CardView(card: card, isFaceDown: index >= revealedCount)
                            .frame(width: 34)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }

                    if previewCards.isEmpty {
                        Text("Shoe will reshuffle before the next round.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.58))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: previewCards.map(\.id))
            }
        }
        .padding(14)
        .scaleEffect(pulse ? 1.015 : 1.0)
        .crookedPanel(
            kind: .felt,
            strokeColor: shoeImpact == .none ? CrookedCasinoTheme.dirtyGold : (shoeImpact.isPositive ? CrookedCasinoTheme.felt : CrookedCasinoTheme.mutedRed),
            cornerRadius: 12
        )
        .accessibilityElement(children: .contain)
        .accessibilityHint("Manipulation upgrades add or remove real cards from this shoe.")
        .onChange(of: shoeImpact) { _, newValue in
            guard newValue != .none else {
                return
            }

            withAnimation(.spring(response: 0.24, dampingFraction: 0.55)) {
                pulse = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                withAnimation(.easeOut(duration: 0.20)) {
                    pulse = false
                }
            }
        }
    }

    private func statusPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.black))
            .foregroundStyle(color)
            .textCase(.uppercase)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                CrookedStickerShape(cornerRadius: 10)
                    .fill(color.opacity(0.13))
            )
    }
}
