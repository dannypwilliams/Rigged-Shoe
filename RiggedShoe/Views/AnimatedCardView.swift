import SwiftUI

struct AnimatedCardView: View {
    let card: Card
    let isWinner: Bool
    let isDimmed: Bool
    let originOffset: CGSize
    var landingRotation: Double = 0
    var onLanded: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasLanded = false
    @State private var isFaceUp = false

    var body: some View {
        ZStack {
            CardView(card: card, isHighlighted: isWinner && isFaceUp)
                .opacity(isFaceUp ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFaceUp ? 0 : -88),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.45
                )

            CardView(card: card, isFaceDown: true)
                .opacity(isFaceUp ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFaceUp ? 88 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.45
                )
        }
        .scaleEffect(hasLanded ? 1.0 : 0.68)
        .rotationEffect(.degrees(hasLanded ? landingRotation : landingRotation - 10))
        .offset(hasLanded ? .zero : originOffset)
        .opacity(isDimmed ? 0.48 : 1.0)
        .shadow(
            color: isWinner && isFaceUp ? CasinoTheme.gold.opacity(0.55) : Color.black.opacity(0.32),
            radius: isWinner && isFaceUp ? 16 : 6,
            y: isWinner && isFaceUp ? 8 : 4
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.rank.shortName) \(card.suit.symbol), baccarat value \(card.baccaratValue)")
        .onAppear {
            runAnimation()
        }
        .onChange(of: card.id) { _, _ in
            runAnimation()
        }
    }

    private func runAnimation() {
        hasLanded = reduceMotion
        isFaceUp = reduceMotion

        if reduceMotion {
            onLanded?()
            return
        }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
            hasLanded = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onLanded?()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.easeInOut(duration: 0.22)) {
                isFaceUp = true
            }
        }
    }
}
