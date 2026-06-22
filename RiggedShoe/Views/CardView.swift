import SwiftUI

struct CardView: View {
    let card: Card?
    var isFaceDown = false
    var isHighlighted = false

    var body: some View {
        CrookedPlayingCardView(kind: isFaceDown ? .backRed : .common, isHighlighted: isHighlighted) {
            if isFaceDown {
                VStack(spacing: 4) {
                    CrookedDoodleIconView(icon: .shoe, tint: CrookedCasinoTheme.dirtyGold, size: 20)

                    Text("RS")
                        .font(.caption2.weight(.black))
                    Text("SHOE")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                }
                .foregroundStyle(CrookedCasinoTheme.paperLight)
            } else if let card {
                VStack(spacing: 2) {
                    Text(card.rank.shortName)
                        .font(.title3.weight(.black))
                    Text(card.suit.symbol)
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(card.suit.isRed ? CrookedCasinoTheme.mutedRed : CrookedCasinoTheme.ink)
            } else {
                CrookedDoodleIconView(icon: .spark, tint: CrookedCasinoTheme.smoke, size: 22)
                    .opacity(0.54)
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
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.paper.opacity(0.72), cornerRadius: 12)
    }
}
