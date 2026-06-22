import Foundation

enum Rank: Int, CaseIterable, Codable, Hashable {
    case ace = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13

    var shortName: String {
        switch self {
        case .ace:
            return "A"
        case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten:
            return String(rawValue)
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        }
    }

    var baccaratValue: Int {
        switch self {
        case .ace:
            return 1
        case .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return rawValue
        case .ten, .jack, .queen, .king:
            return 0
        }
    }
}
