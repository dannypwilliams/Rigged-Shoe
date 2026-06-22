import Foundation

struct TablePayoutRules: Equatable {
    var bankerCommissionPercent: Int = 5
    var tiePayoutMultiplier: Int = 8

    static let standard = TablePayoutRules()

    func profitCents(for betType: BetType, betAmountCents: Int) -> Int {
        switch betType {
        case .player:
            return betAmountCents
        case .banker:
            return betAmountCents * max(0, 100 - bankerCommissionPercent) / 100
        case .tie:
            return betAmountCents * tiePayoutMultiplier
        }
    }

    func totalReturnCents(for betType: BetType, betAmountCents: Int) -> Int {
        betAmountCents + profitCents(for: betType, betAmountCents: betAmountCents)
    }

    func payoutLabel(for betType: BetType) -> String {
        "Pays \(payoutRatioText(for: betType))"
    }

    func payoutDetail(for betType: BetType) -> String {
        switch betType {
        case .player:
            return "Player pays \(payoutRatioText(for: betType))"
        case .banker:
            if bankerCommissionPercent == 0 {
                return "Banker pays \(payoutRatioText(for: betType))"
            }

            return "Banker pays \(payoutRatioText(for: betType)) after commission"
        case .tie:
            return "Tie pays \(payoutRatioText(for: betType))"
        }
    }

    func preDealText(for betType: BetType, betAmountCents: Int) -> String {
        switch betType {
        case .player:
            return "\(payoutLabel(for: betType)). Tie refunds; Banker win loses \(MoneyFormatter.format(betAmountCents))."
        case .banker:
            return "\(payoutLabel(for: betType)). Tie refunds; Player win loses \(MoneyFormatter.format(betAmountCents))."
        case .tie:
            return "\(payoutLabel(for: betType)). Any non-tie result loses \(MoneyFormatter.format(betAmountCents))."
        }
    }

    private func payoutRatioText(for betType: BetType) -> String {
        switch betType {
        case .player:
            return "1:1"
        case .banker:
            return ratioText(percent: max(0, 100 - bankerCommissionPercent))
        case .tie:
            return "\(tiePayoutMultiplier):1"
        }
    }

    private func ratioText(percent: Int) -> String {
        if percent == 100 {
            return "1:1"
        }

        if percent % 100 == 0 {
            return "\(percent / 100):1"
        }

        return String(format: "%.2f:1", Double(percent) / 100.0)
    }
}

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
        TablePayoutRules.standard.totalReturnCents(for: self, betAmountCents: betAmountCents)
    }
}

extension Stage {
    var tablePayoutRules: TablePayoutRules {
        let tableCommissions = effectiveTableRules.compactMap { rule -> Int? in
            if case .bankerCommission(let percent) = rule {
                return percent
            }

            return nil
        }

        let tieMultipliers = effectiveTableRules.compactMap { rule -> Int? in
            if case .tiePayout(let multiplier) = rule {
                return multiplier
            }

            return nil
        }

        return TablePayoutRules(
            bankerCommissionPercent: tableCommissions.min() ?? TablePayoutRules.standard.bankerCommissionPercent,
            tiePayoutMultiplier: max(TablePayoutRules.standard.tiePayoutMultiplier, tieMultipliers.max() ?? TablePayoutRules.standard.tiePayoutMultiplier)
        )
    }
}
