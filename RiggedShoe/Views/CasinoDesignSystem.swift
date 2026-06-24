import SwiftUI

enum CasinoSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
}

enum CasinoRadius {
    static let tile: CGFloat = 10
    static let panel: CGFloat = 16
    static let screen: CGFloat = 22
}

struct AppScreenScaffold<Content: View>: View {
    var background: AnyShapeStyle = AnyShapeStyle(CrookedCasinoTheme.tableBackground)
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Rectangle()
                .fill(background)
                .ignoresSafeArea()

            content
        }
    }
}

struct CenteredContentColumn<Content: View>: View {
    var maxWidth: CGFloat = 460
    var horizontalPadding: CGFloat = 14
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    content
                        .frame(maxWidth: min(proxy.size.width - horizontalPadding * 2, maxWidth))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height, alignment: .center)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, CasinoSpace.lg)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct CasinoPanel<Content: View>: View {
    var kind: CrookedPanelKind = .felt
    var strokeColor: Color = CasinoTheme.gold
    var cornerRadius: CGFloat = CasinoRadius.panel
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(CasinoSpace.lg)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(kind.fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.20), radius: 10, y: 6)
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var accentColor: Color = CasinoTheme.gold

    var body: some View {
        VStack(spacing: CasinoSpace.xs) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .accessibilityLabel("\(title), \(value)")
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .padding(.horizontal, CasinoSpace.sm)
        .background(
            RoundedRectangle(cornerRadius: CasinoRadius.tile, style: .continuous)
                .fill(Color.white.opacity(0.065))
        )
        .overlay(
            RoundedRectangle(cornerRadius: CasinoRadius.tile, style: .continuous)
                .stroke(accentColor.opacity(0.28), lineWidth: 1)
        )
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(spacing: CasinoSpace.xs) {
            Text(title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.gold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.68))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(CasinoTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(
                    RoundedRectangle(cornerRadius: CasinoRadius.tile, style: .continuous)
                        .fill(CasinoTheme.gold)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

struct CompactTopHUD: View {
    let chips: Int
    let heat: Int
    let maxHeat: Int
    let onGameInfo: () -> Void
    let onBattleLog: () -> Void

    var body: some View {
        HStack(spacing: CasinoSpace.sm) {
            MetricTile(title: "Chips", value: "\(chips)")
            MetricTile(title: "Heat", value: "\(heat)/\(maxHeat) \(HeatBand.band(for: heat, maxHeat: maxHeat).rawValue)", accentColor: CasinoTheme.red)

            Button(action: onGameInfo) {
                Image(systemName: "questionmark.circle.fill")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Game Info")

            Button(action: onBattleLog) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Battle Log")
        }
        .font(.headline.weight(.black))
        .foregroundStyle(.white)
    }
}

struct PersistentBottomNavigation<Tab: Hashable>: View {
    let tabs: [(tab: Tab, title: String, systemImage: String)]
    @Binding var selection: Tab

    var body: some View {
        HStack(spacing: CasinoSpace.xs) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { _, item in
                Button {
                    selection = item.tab
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: item.systemImage)
                        Text(item.title)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .foregroundStyle(selection == item.tab ? CasinoTheme.ink : .white.opacity(0.70))
                    .background(
                        RoundedRectangle(cornerRadius: CasinoRadius.tile, style: .continuous)
                            .fill(selection == item.tab ? CasinoTheme.gold : Color.white.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == item.tab ? [.isButton, .isSelected] : .isButton)
            }
        }
    }
}

struct RunSummaryGrid: View {
    let items: [(title: String, value: String)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CasinoSpace.sm) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                MetricTile(title: item.title, value: item.value)
            }
        }
    }
}

struct ModifierDetailSheet: View {
    let title: String
    let details: [(String, String)]

    var body: some View {
        AppScreenScaffold {
            CenteredContentColumn {
                CasinoPanel {
                    VStack(alignment: .leading, spacing: CasinoSpace.md) {
                        SectionHeader(title: title)
                        ForEach(Array(details.enumerated()), id: \.offset) { _, detail in
                            HStack(alignment: .top) {
                                Text(detail.0)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(.white.opacity(0.58))
                                    .textCase(.uppercase)
                                Spacer(minLength: CasinoSpace.md)
                                Text(detail.1)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }
            }
        }
    }
}
