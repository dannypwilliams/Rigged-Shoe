import Foundation

struct BaccaratHand: Equatable {
    private(set) var cards: [Card]

    init(cards: [Card] = []) {
        self.cards = cards
    }

    var total: Int {
        cards.reduce(0) { $0 + $1.baccaratValue } % 10
    }

    var isNatural: Bool {
        cards.count == 2 && (total == 8 || total == 9)
    }

    mutating func add(_ card: Card) {
        cards.append(card)
    }
}
