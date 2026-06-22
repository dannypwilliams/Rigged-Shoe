import SwiftUI

enum CasinoTheme {
    static let ink = Color(red: 0.015, green: 0.018, blue: 0.020)
    static let felt = Color(red: 0.00, green: 0.20, blue: 0.11)
    static let feltDark = Color(red: 0.01, green: 0.07, blue: 0.045)
    static let gold = Color(red: 0.97, green: 0.75, blue: 0.22)
    static let red = Color(red: 0.96, green: 0.16, blue: 0.18)
    static let emerald = Color(red: 0.18, green: 0.88, blue: 0.46)
    static let neonBlue = Color(red: 0.18, green: 0.62, blue: 1.00)
    static let violet = Color(red: 0.67, green: 0.36, blue: 1.00)
    static let panel = Color.black.opacity(0.34)
    static let panelBright = Color.white.opacity(0.085)

    static var background: LinearGradient {
        background(for: .lasVegas)
    }

    static func background(for themeID: CasinoThemeID) -> LinearGradient {
        let colors: [Color]

        switch themeID {
        case .lasVegas:
            colors = [
                Color(red: 0.015, green: 0.018, blue: 0.020),
                Color(red: 0.00, green: 0.13, blue: 0.08),
                Color(red: 0.10, green: 0.015, blue: 0.025),
                Color(red: 0.015, green: 0.018, blue: 0.020)
            ]
        case .macau:
            colors = [
                Color(red: 0.04, green: 0.00, blue: 0.01),
                Color(red: 0.20, green: 0.02, blue: 0.03),
                Color(red: 0.72, green: 0.42, blue: 0.06).opacity(0.62),
                Color.black
            ]
        case .monteCarlo:
            colors = [
                Color(red: 0.00, green: 0.03, blue: 0.07),
                Color(red: 0.02, green: 0.16, blue: 0.20),
                Color(red: 0.22, green: 0.05, blue: 0.12),
                Color.black
            ]
        case .underground:
            colors = [
                Color.black,
                Color(red: 0.06, green: 0.06, blue: 0.065),
                Color(red: 0.14, green: 0.02, blue: 0.025),
                Color.black
            ]
        case .cyber:
            colors = [
                Color(red: 0.00, green: 0.01, blue: 0.035),
                Color(red: 0.03, green: 0.00, blue: 0.12),
                Color(red: 0.00, green: 0.16, blue: 0.16),
                Color.black
            ]
        case .goldRoom:
            colors = [
                Color(red: 0.03, green: 0.02, blue: 0.00),
                Color(red: 0.20, green: 0.13, blue: 0.02),
                Color(red: 0.44, green: 0.25, blue: 0.03),
                Color.black
            ]
        }

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warningBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.98),
                Color(red: 0.22, green: 0.01, blue: 0.02).opacity(0.98),
                Color.black.opacity(0.98)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func rarityColor(_ rarity: UpgradeRarity) -> Color {
        switch rarity {
        case .common:
            return Color(red: 0.86, green: 0.90, blue: 0.84)
        case .rare:
            return neonBlue
        case .legendary:
            return gold
        }
    }
}

struct NeonPanel: ViewModifier {
    var strokeColor: Color = CasinoTheme.gold
    var opacity: Double = 0.28
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CasinoTheme.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor.opacity(opacity), lineWidth: 1)
            )
            .shadow(color: strokeColor.opacity(0.10), radius: 16, y: 8)
    }
}

extension View {
    func neonPanel(strokeColor: Color = CasinoTheme.gold, opacity: Double = 0.28, cornerRadius: CGFloat = 14) -> some View {
        modifier(NeonPanel(strokeColor: strokeColor, opacity: opacity, cornerRadius: cornerRadius))
    }
}
