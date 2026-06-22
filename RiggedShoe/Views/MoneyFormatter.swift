import Foundation

enum MoneyFormatter {
    static func format(_ cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        let absoluteCents = abs(cents)
        let dollars = absoluteCents / 100
        let remainingCents = absoluteCents % 100
        let dollarText = groupedDollars(dollars)

        if remainingCents == 0 {
            return "\(sign)$\(dollarText)"
        }

        return "\(sign)$\(dollarText).\(String(format: "%02d", remainingCents))"
    }

    static func signed(_ cents: Int) -> String {
        if cents > 0 {
            return "+\(format(cents))"
        }

        return format(cents)
    }

    private static func groupedDollars(_ dollars: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: dollars)) ?? String(dollars)
    }
}
