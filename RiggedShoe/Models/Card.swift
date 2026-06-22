import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let suit: Suit
    let rank: Rank

    init(suit: Suit, rank: Rank, id: UUID = UUID()) {
        self.id = id
        self.suit = suit
        self.rank = rank
    }

    var baccaratValue: Int {
        rank.baccaratValue
    }

    var displayText: String {
        "\(rank.shortName)\(suit.symbol)"
    }
}
