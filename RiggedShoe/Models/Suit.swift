import Foundation

enum Suit: String, CaseIterable, Codable, Hashable {
    case hearts
    case diamonds
    case clubs
    case spades

    var symbol: String {
        switch self {
        case .hearts:
            return "H"
        case .diamonds:
            return "D"
        case .clubs:
            return "C"
        case .spades:
            return "S"
        }
    }

    var isRed: Bool {
        self == .hearts || self == .diamonds
    }
}
