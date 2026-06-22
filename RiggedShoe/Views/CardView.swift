import SwiftUI

struct CardView: View {
    let card: Card?
    var isFaceDown = false
    var isHighlighted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isFaceDown ? CasinoTheme.feltDark : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isFaceDown ? CasinoTheme.gold : (isHighlighted ? CasinoTheme.gold : Color.black.opacity(0.18)), lineWidth: isHighlighted ? 2 : 1)
                )
                .shadow(color: isHighlighted ? CasinoTheme.gold.opacity(0.40) : Color.black.opacity(0.24), radius: isHighlighted ? 12 : 4, y: 3)

            if isFaceDown {
                VStack(spacing: 4) {
                    Text("RS")
                        .font(.caption2.weight(.black))
                    Text("SHOE")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                }
                .foregroundStyle(CasinoTheme.gold)
            } else if let card {
                VStack(spacing: 2) {
                    Text(card.rank.shortName)
                        .font(.title3.weight(.black))
                    Text(card.suit.symbol)
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(card.suit.isRed ? Color.red : Color.black)
            }
        }
        .aspectRatio(0.68, contentMode: .fit)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isFaceDown)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if isFaceDown {
            return "Face down shoe card"
        }

        guard let card else {
            return "Empty card"
        }

        return "\(card.rank.shortName) \(card.suit.symbol), baccarat value \(card.baccaratValue)"
    }
}

struct BaccaratHandView: View {
    let title: String
    let hand: BaccaratHand

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("Total \(hand.total)")
                    .font(.headline.monospacedDigit().weight(.black))
                    .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.22))
            }

            HStack(spacing: 8) {
                ForEach(hand.cards) { card in
                    CardView(card: card)
                        .frame(width: 52)
                }
            }
        }
        .padding(14)
        .neonPanel(strokeColor: Color.white, opacity: 0.12, cornerRadius: 12)
    }
}
