import Foundation

enum BetType: String, CaseIterable, Identifiable, Codable, Hashable {
    case player
    case banker
    case tie

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .player:
            return "Player"
        case .banker:
            return "Banker"
        case .tie:
            return "Tie"
        }
    }

    func totalReturnCents(for betAmountCents: Int) -> Int {
        switch self {
        case .player:
            return betAmountCents + betAmountCents
        case .banker:
            return betAmountCents + (betAmountCents * 95 / 100)
        case .tie:
            return betAmountCents + (betAmountCents * 8)
        }
    }
}
