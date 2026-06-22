import Foundation

enum WinTier: String, Equatable {
    case loss
    case push
    case normal
    case big
    case huge
    case jackpot

    var title: String {
        switch self {
        case .loss:
            return "Loss"
        case .push:
            return "Push"
        case .normal:
            return "Win"
        case .big:
            return "Big Win"
        case .huge:
            return "Huge Win"
        case .jackpot:
            return "Jackpot"
        }
    }

    var usesParticles: Bool {
        switch self {
        case .big, .huge, .jackpot:
            return true
        case .loss, .push, .normal:
            return false
        }
    }

    var usesShake: Bool {
        switch self {
        case .huge, .jackpot:
            return true
        case .loss, .push, .normal, .big:
            return false
        }
    }
}

enum ShoeImpact: Equatable {
    case none
    case injectedCards(Int)
    case removedCards(Int)
    case shuffled
    case reordered

    var message: String? {
        switch self {
        case .none:
            return nil
        case .injectedCards(let count):
            return "+\(count) cards injected"
        case .removedCards(let count):
            return "-\(count) cards purged"
        case .shuffled:
            return "Shoe shuffled"
        case .reordered:
            return "Shoe reordered"
        }
    }

    var isPositive: Bool {
        switch self {
        case .injectedCards:
            return true
        case .none, .removedCards, .shuffled, .reordered:
            return false
        }
    }
}

struct RoundPresentationState: Equatable {
    var bankrollDeltaCents: Int = 0
    var winTier: WinTier = .normal
    var shoeImpact: ShoeImpact = .none
    var upgradeMessages: [String] = []
    var payoutLedgerLines: [PayoutLedgerLine] = []
    var sequenceID: UUID = UUID()

    var payoutLedgerSummary: String {
        guard !payoutLedgerLines.isEmpty else {
            return ""
        }

        let total = payoutLedgerLines.reduce(0) { $0 + $1.amountCents }
        let namedAdjustments = payoutLedgerLines
            .filter { !$0.isStructural }
            .prefix(2)
            .map { "\($0.title) \(MoneyFormatter.signed($0.amountCents))" }

        if namedAdjustments.isEmpty {
            return "Ledger total \(MoneyFormatter.signed(total))"
        }

        return "Ledger \(MoneyFormatter.signed(total)): \(namedAdjustments.joined(separator: " · "))"
    }
}

struct PayoutLedgerLine: Identifiable, Equatable {
    let title: String
    let detail: String
    let amountCents: Int
    var isStructural = false

    var id: String {
        "\(title)-\(detail)-\(amountCents)"
    }

    var displayText: String {
        "\(title): \(MoneyFormatter.signed(amountCents))"
    }
}

enum SFXEvent {
    case cardDeal
    case chipGain
    case chipLoss
    case upgradeSelection
    case bossIntro
    case bossDefeat
    case stageClear
    case bigWin
    case jackpot
    case achievementUnlock
    case runVictory
}

enum MusicLayer: String, Equatable {
    case normalRun
    case boss
    case finalBoss
    case victory
    case muted

    var displayName: String {
        switch self {
        case .normalRun:
            return "Normal Run"
        case .boss:
            return "Boss"
        case .finalBoss:
            return "Final Boss"
        case .victory:
            return "Victory"
        case .muted:
            return "Muted"
        }
    }
}

enum HapticEvent {
    case light
    case medium
    case heavy
    case success
    case failure
}
