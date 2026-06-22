import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum CrookedCasinoAsset: String, CaseIterable {
    case cardFrameCommon = "card_frame_common_crooked"
    case cardFrameUncommon = "card_frame_uncommon_crooked"
    case cardFrameRare = "card_frame_rare_crooked"
    case cardFrameLegendary = "card_frame_legendary_crooked"
    case cardFrameCursed = "card_frame_cursed_crooked"
    case cardFrameBoss = "card_frame_boss_crooked"
    case cardBackRed = "card_back_red_crooked"

    case dealerShoeIdle = "dealer_shoe_idle"
    case dealerShoePeeking = "dealer_shoe_peeking"
    case dealerShoeLaughing = "dealer_shoe_laughing"
    case dealerShoeAngry = "dealer_shoe_angry"
    case dealerShoeRigged = "dealer_shoe_rigged"
    case dealerShoeBusted = "dealer_shoe_busted"
    case dealerShoeShuffling = "dealer_shoe_shuffling"
    case dealerShoeReward = "dealer_shoe_reward"

    case chip1White = "chip_1_white"
    case chip5Red = "chip_5_red"
    case chip10Blue = "chip_10_blue"
    case chip25Green = "chip_25_green"
    case chip50Black = "chip_50_black"
    case chip100Gold = "chip_100_gold"
    case chipStackSmall = "chip_stack_small"
    case chipStackMedium = "chip_stack_medium"
    case chipStackLarge = "chip_stack_large"
    case chipCostBadge = "chip_cost_badge"
    case chipRewardBadge = "chip_reward_badge"

    case chip1 = "chip_1"
    case chip5 = "chip_5"
    case chip25 = "chip_25"

    case buttonRed = "button_red_wobbly"
    case buttonBlack = "button_black_wobbly"
    case buttonGreen = "button_green_wobbly"
    case buttonGold = "button_gold_wobbly"
    case buttonDisabled = "button_disabled_wobbly"

    case panelPaperTorn = "panel_paper_torn"
    case panelFeltDark = "panel_felt_dark"
    case panelCasinoRed = "panel_casino_red"
    case panelShopPaper = "panel_shop_paper"
    case panelRewardPaper = "panel_reward_paper"
    case panelWarningBlack = "panel_warning_black"
    case panelBossRed = "panel_boss_red"

    case iconEyeTell = "icon_eye_tell"
    case iconLoadedShoe = "icon_loaded_shoe"
    case iconHouseEdge = "icon_house_edge"
    case iconColdStreak = "icon_cold_streak"
}

enum CrookedCasinoTheme {
    static let ink = Color(red: 0.035, green: 0.030, blue: 0.026)
    static let dustyBlack = Color(red: 0.055, green: 0.047, blue: 0.041)
    static let paper = Color(red: 0.92, green: 0.86, blue: 0.72)
    static let paperLight = Color(red: 0.98, green: 0.93, blue: 0.80)
    static let stainedPaper = Color(red: 0.75, green: 0.64, blue: 0.45)
    static let casinoRed = Color(red: 0.58, green: 0.10, blue: 0.085)
    static let mutedRed = Color(red: 0.72, green: 0.14, blue: 0.10)
    static let dirtyGold = Color(red: 0.78, green: 0.57, blue: 0.19)
    static let felt = Color(red: 0.045, green: 0.25, blue: 0.15)
    static let feltDark = Color(red: 0.020, green: 0.115, blue: 0.075)
    static let fadedBlue = Color(red: 0.28, green: 0.55, blue: 0.68)
    static let smoke = Color(red: 0.47, green: 0.43, blue: 0.38)

    static var tableBackground: LinearGradient {
        LinearGradient(
            colors: [
                felt.opacity(0.98),
                feltDark.opacity(0.96),
                dustyBlack.opacity(0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var paperBackground: LinearGradient {
        LinearGradient(
            colors: [
                paperLight,
                paper,
                stainedPaper.opacity(0.76)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func assetExists(_ asset: CrookedCasinoAsset) -> Bool {
#if canImport(UIKit)
        UIImage(named: asset.rawValue) != nil
#else
        false
#endif
    }

    static func accent(for rarity: UpgradeRarity) -> Color {
        CrookedCardFrameKind(rarity: rarity).accent
    }

    static func chipAsset(for value: Int) -> CrookedCasinoAsset {
        switch value {
        case 0...1:
            return .chip1
        case 2...9:
            return .chip5
        case 10...24:
            return .chip10Blue
        case 25...49:
            return .chip25
        case 50...99:
            return .chip50Black
        default:
            return .chip100Gold
        }
    }

    static func icon(for upgrade: UpgradeCard) -> CrookedDoodleIcon {
        if upgrade.tags.contains(.dealerExploit) {
            return .houseEdge
        }

        if upgrade.tags.contains(.shoe) {
            return .shoe
        }

        if upgrade.tags.contains(.reveal) {
            return .eye
        }

        if upgrade.tags.contains(.economy) {
            return .chip
        }

        if upgrade.tags.contains(.tie) {
            return .dice
        }

        if upgrade.tags.contains(.banker) {
            return .crown
        }

        if upgrade.tags.contains(.player) {
            return .hand
        }

        if upgrade.tags.contains(.risk) || upgrade.tags.contains(.aggressive) {
            return .fire
        }

        if upgrade.tags.contains(.comeback) || upgrade.tags.contains(.conservative) {
            return .brokenHeart
        }

        if upgrade.tags.contains(.boss) {
            return .skull
        }

        if upgrade.rarity == .legendary {
            return .crown
        }

        return .spark
    }
}

enum CrookedCardFrameKind: Equatable {
    case common
    case uncommon
    case rare
    case legendary
    case cursed
    case boss
    case backRed

    init(rarity: UpgradeRarity) {
        switch rarity {
        case .common:
            self = .common
        case .rare:
            self = .rare
        case .legendary:
            self = .legendary
        }
    }

    init(modifierRarity: ModifierRarity) {
        switch modifierRarity {
        case .common:
            self = .common
        case .uncommon:
            self = .uncommon
        case .rare, .epic:
            self = .rare
        case .legendary:
            self = .legendary
        case .boss:
            self = .boss
        }
    }

    var asset: CrookedCasinoAsset {
        switch self {
        case .common:
            return .cardFrameCommon
        case .uncommon:
            return .cardFrameUncommon
        case .rare:
            return .cardFrameRare
        case .legendary:
            return .cardFrameLegendary
        case .cursed:
            return .cardFrameCursed
        case .boss:
            return .cardFrameBoss
        case .backRed:
            return .cardBackRed
        }
    }

    var accent: Color {
        switch self {
        case .common:
            return CrookedCasinoTheme.mutedRed
        case .uncommon:
            return CrookedCasinoTheme.felt
        case .rare:
            return CrookedCasinoTheme.dirtyGold
        case .legendary:
            return CrookedCasinoTheme.dirtyGold
        case .cursed:
            return CrookedCasinoTheme.casinoRed
        case .boss:
            return CrookedCasinoTheme.mutedRed
        case .backRed:
            return CrookedCasinoTheme.casinoRed
        }
    }

    var fill: Color {
        switch self {
        case .cursed:
            return Color(red: 0.16, green: 0.12, blue: 0.10)
        case .backRed:
            return CrookedCasinoTheme.casinoRed
        default:
            return CrookedCasinoTheme.paper
        }
    }

    var labelColor: Color {
        switch self {
        case .cursed, .boss, .backRed:
            return CrookedCasinoTheme.paperLight
        default:
            return CrookedCasinoTheme.ink
        }
    }
}

enum DealerShoeState: Equatable {
    case idle
    case peeking
    case laughing
    case angry
    case rigged
    case busted
    case shuffling
    case reward

    var asset: CrookedCasinoAsset {
        switch self {
        case .idle:
            return .dealerShoeIdle
        case .peeking:
            return .dealerShoePeeking
        case .laughing:
            return .dealerShoeLaughing
        case .angry:
            return .dealerShoeAngry
        case .rigged:
            return .dealerShoeRigged
        case .busted:
            return .dealerShoeBusted
        case .shuffling:
            return .dealerShoeShuffling
        case .reward:
            return .dealerShoeReward
        }
    }
}

enum CrookedPanelKind: Equatable {
    case paper
    case felt
    case casinoRed
    case shop
    case reward
    case warning
    case boss

    var asset: CrookedCasinoAsset {
        switch self {
        case .paper:
            return .panelPaperTorn
        case .felt:
            return .panelFeltDark
        case .casinoRed:
            return .panelCasinoRed
        case .shop:
            return .panelShopPaper
        case .reward:
            return .panelRewardPaper
        case .warning:
            return .panelWarningBlack
        case .boss:
            return .panelBossRed
        }
    }

    var fill: AnyShapeStyle {
        switch self {
        case .paper, .shop, .reward:
            return AnyShapeStyle(CrookedCasinoTheme.paperBackground)
        case .felt:
            return AnyShapeStyle(CrookedCasinoTheme.tableBackground)
        case .casinoRed, .boss:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [CrookedCasinoTheme.casinoRed, CrookedCasinoTheme.dustyBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .warning:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [CrookedCasinoTheme.dustyBlack, CrookedCasinoTheme.casinoRed.opacity(0.52)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

enum CrookedDoodleIcon: Equatable {
    case shoe
    case eye
    case chip
    case fire
    case hand
    case dice
    case dealer
    case brokenHeart
    case skull
    case crown
    case houseEdge
    case coldStreak
    case reward
    case shop
    case spark
    case suit(String)

    var asset: CrookedCasinoAsset? {
        switch self {
        case .shoe:
            return .iconLoadedShoe
        case .eye:
            return .iconEyeTell
        case .houseEdge:
            return .iconHouseEdge
        case .coldStreak:
            return .iconColdStreak
        default:
            return nil
        }
    }

    var systemName: String {
        switch self {
        case .shoe:
            return "rectangle.stack.fill"
        case .eye:
            return "eye.fill"
        case .chip:
            return "circle.circle.fill"
        case .fire:
            return "flame.fill"
        case .hand:
            return "hand.raised.fill"
        case .dice:
            return "die.face.5.fill"
        case .dealer:
            return "person.crop.circle.badge.questionmark"
        case .brokenHeart:
            return "heart.slash.fill"
        case .skull:
            return "xmark.seal.fill"
        case .crown:
            return "crown.fill"
        case .houseEdge:
            return "building.columns.fill"
        case .coldStreak:
            return "snowflake"
        case .reward:
            return "gift.fill"
        case .shop:
            return "tag.fill"
        case .spark:
            return "sparkles"
        case .suit:
            return "suit.club.fill"
        }
    }

    var label: String {
        switch self {
        case .suit(let symbol):
            return symbol
        default:
            return ""
        }
    }
}

struct CrookedThemedAsset<Fallback: View>: View {
    let asset: CrookedCasinoAsset
    @ViewBuilder let fallback: () -> Fallback

    var body: some View {
        if CrookedCasinoTheme.assetExists(asset) {
            Image(asset.rawValue)
                .resizable()
                .scaledToFit()
        } else {
            fallback()
        }
    }
}

struct CrookedCasinoCard: View {
    let kind: CrookedCardFrameKind
    let eyebrow: String
    let title: String
    let description: String
    let icon: CrookedDoodleIcon
    var footer: String?
    var tags: [String] = []
    var tapHint: String?
    var isCompact = false

    var body: some View {
        HStack(alignment: .top, spacing: isCompact ? 9 : 12) {
            CrookedDoodleIconView(icon: icon, tint: kind.accent, size: isCompact ? 50 : 62)
                .padding(.top, isCompact ? 2 : 4)

            VStack(alignment: .leading, spacing: isCompact ? 5 : 7) {
                HStack(spacing: 7) {
                    Text(eyebrow)
                        .font(.system(size: isCompact ? 8 : 10, weight: .black, design: .rounded))
                        .foregroundStyle(kind == .legendary ? CrookedCasinoTheme.ink : kind.accent)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .padding(.horizontal, isCompact ? 7 : 9)
                        .padding(.vertical, isCompact ? 3 : 4)
                        .background(
                            CrookedStickerShape(cornerRadius: 7)
                                .fill(kind == .legendary ? kind.accent : kind.accent.opacity(0.16))
                        )

                    Spacer(minLength: 6)

                    if let tapHint {
                        Text(tapHint)
                            .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                            .foregroundStyle(CrookedCasinoTheme.smoke)
                            .textCase(.uppercase)
                            .lineLimit(1)
                    }
                }

                Text(title)
                    .font(.system(size: isCompact ? 16 : 19, weight: .black, design: .rounded))
                    .foregroundStyle(kind.labelColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(description)
                    .font(.system(size: isCompact ? 11 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(kind.labelColor.opacity(0.74))
                    .lineLimit(isCompact ? 2 : 3)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)

                if let footer {
                    Text(footer)
                        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(kind.accent)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(kind.accent.opacity(0.13)))
                }

                if !tags.isEmpty {
                    HStack(spacing: 5) {
                        ForEach(Array(tags.prefix(isCompact ? 2 : 3)), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                                .foregroundStyle(kind.accent)
                                .textCase(.uppercase)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(kind.accent.opacity(0.12)))
                        }
                    }
                }
            }
        }
        .padding(isCompact ? 11 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CrookedCardFrameBackground(kind: kind))
        .overlay(DoodleAccentView(accent: kind.accent, density: isCompact ? .low : .medium).allowsHitTesting(false))
        .shadow(color: kind.accent.opacity(kind == .legendary || kind == .boss ? 0.22 : 0.11), radius: 10, y: 5)
    }
}

struct CrookedPlayingCardView<Content: View>: View {
    let kind: CrookedCardFrameKind
    var isHighlighted = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            CrookedCardFrameBackground(kind: kind)

            DoodleAccentView(accent: kind.accent, density: .low)
                .opacity(kind == .backRed ? 0.55 : 0.35)

            content()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(isHighlighted ? CrookedCasinoTheme.dirtyGold : .clear, lineWidth: isHighlighted ? 3 : 0)
                .padding(2)
        )
        .shadow(color: isHighlighted ? CrookedCasinoTheme.dirtyGold.opacity(0.36) : Color.black.opacity(0.22), radius: isHighlighted ? 12 : 5, y: 4)
    }
}

struct CrookedDoodleIconView: View {
    let icon: CrookedDoodleIcon
    var tint: Color = CrookedCasinoTheme.dirtyGold
    var size: CGFloat = 54

    var body: some View {
        ZStack {
            CrookedStickerShape(cornerRadius: size * 0.28)
                .fill(CrookedCasinoTheme.paperLight)
                .overlay(
                    CrookedStickerShape(cornerRadius: size * 0.28)
                        .stroke(CrookedCasinoTheme.ink, lineWidth: max(2, size * 0.05))
                )
                .rotationEffect(.degrees(-2))

            if let asset = icon.asset, CrookedCasinoTheme.assetExists(asset) {
                Image(asset.rawValue)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.16)
            } else if case .suit(let symbol) = icon {
                Text(symbol)
                    .font(.system(size: size * 0.48, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
            } else if icon == .chip {
                CrookedChipView(valueText: "5", size: size * 0.70, tone: .red)
            } else {
                Image(systemName: icon.systemName)
                    .font(.system(size: size * 0.40, weight: .black))
                    .foregroundStyle(tint)
                    .rotationEffect(.degrees(1.5))
            }

            Path { path in
                path.move(to: CGPoint(x: size * 0.68, y: size * 0.18))
                path.addLine(to: CGPoint(x: size * 0.78, y: size * 0.08))
                path.move(to: CGPoint(x: size * 0.75, y: size * 0.24))
                path.addLine(to: CGPoint(x: size * 0.88, y: size * 0.20))
            }
            .stroke(tint.opacity(0.55), lineWidth: 1.4)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct DealerShoeView: View {
    var state: DealerShoeState = .idle
    var isCompact = false

    var body: some View {
        CrookedThemedAsset(asset: state.asset) {
            DealerShoeFallback(state: state)
        }
        .frame(minWidth: isCompact ? 64 : 88, minHeight: isCompact ? 46 : 64)
        .accessibilityLabel("Cartoon dealer shoe")
    }
}

struct CrookedChipView: View {
    enum Tone: Equatable {
        case white
        case red
        case blue
        case green
        case black
        case gold

        var fill: Color {
            switch self {
            case .white:
                return CrookedCasinoTheme.paperLight
            case .red:
                return CrookedCasinoTheme.mutedRed
            case .blue:
                return CrookedCasinoTheme.fadedBlue
            case .green:
                return CrookedCasinoTheme.felt
            case .black:
                return CrookedCasinoTheme.dustyBlack
            case .gold:
                return CrookedCasinoTheme.dirtyGold
            }
        }
    }

    let valueText: String
    var size: CGFloat = 34
    var tone: Tone = .red

    var body: some View {
        ZStack {
            Circle()
                .fill(tone.fill)
                .scaleEffect(x: 1.04, y: 0.96)
                .rotationEffect(.degrees(-5))
                .overlay(
                    Circle()
                        .stroke(CrookedCasinoTheme.ink, lineWidth: max(2, size * 0.07))
                        .scaleEffect(x: 1.04, y: 0.96)
                )

            ForEach(0..<8, id: \.self) { index in
                UnevenRoundedRectangle(topLeadingRadius: 1, topTrailingRadius: 2, style: .continuous)
                    .fill(CrookedCasinoTheme.paperLight.opacity(tone == .white ? 0.68 : 0.88))
                    .frame(width: size * 0.10, height: size * 0.22)
                    .offset(y: -size * 0.36)
                    .rotationEffect(.degrees(Double(index) * 45 + (index.isMultiple(of: 2) ? -4 : 3)))
            }

            Circle()
                .fill(CrookedCasinoTheme.paperLight.opacity(tone == .white ? 0.70 : 0.30))
                .frame(width: size * 0.48, height: size * 0.48)
                .overlay(Circle().stroke(CrookedCasinoTheme.ink.opacity(0.72), lineWidth: max(1, size * 0.035)))

            Text(valueText)
                .font(.system(size: size * 0.24, weight: .black, design: .rounded))
                .foregroundStyle(tone == .black ? CrookedCasinoTheme.paperLight : CrookedCasinoTheme.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .offset(x: size * -0.018, y: size * -0.018)

            HStack(spacing: size * 0.045) {
                Circle().fill(CrookedCasinoTheme.ink).frame(width: size * 0.028, height: size * 0.028)
                Circle().fill(CrookedCasinoTheme.ink).frame(width: size * 0.028, height: size * 0.028)
            }
            .offset(y: size * 0.18)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct CrookedCasinoButtonStyle: ButtonStyle {
    enum Tone {
        case red
        case black
        case green
        case gold

        var asset: CrookedCasinoAsset {
            switch self {
            case .red:
                return .buttonRed
            case .black:
                return .buttonBlack
            case .green:
                return .buttonGreen
            case .gold:
                return .buttonGold
            }
        }

        var fill: Color {
            switch self {
            case .red:
                return CrookedCasinoTheme.mutedRed
            case .black:
                return CrookedCasinoTheme.dustyBlack
            case .green:
                return CrookedCasinoTheme.felt
            case .gold:
                return CrookedCasinoTheme.dirtyGold
            }
        }

        var foreground: Color {
            switch self {
            case .gold:
                return CrookedCasinoTheme.ink
            default:
                return CrookedCasinoTheme.paperLight
            }
        }
    }

    var tone: Tone = .gold
    @Environment(\.isEnabled) private var isEnabled

    init(tone: Tone = .gold) {
        self.tone = tone
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.black))
            .foregroundStyle(isEnabled ? tone.foreground : CrookedCasinoTheme.paperLight.opacity(0.48))
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(buttonBackground)
            .overlay(DoodleAccentView(accent: tone.foreground.opacity(0.60), density: .low))
            .scaleEffect(x: configuration.isPressed ? 0.97 : 1, y: configuration.isPressed ? 0.92 : 1)
            .rotationEffect(.degrees(configuration.isPressed ? -0.8 : 0))
            .brightness(configuration.isPressed ? 0.04 : 0)
            .animation(.spring(response: 0.20, dampingFraction: 0.66), value: configuration.isPressed)
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if isEnabled, CrookedCasinoTheme.assetExists(tone.asset) {
            Image(tone.asset.rawValue)
                .resizable(capInsets: EdgeInsets(top: 28, leading: 34, bottom: 28, trailing: 34), resizingMode: .stretch)
        } else if !isEnabled, CrookedCasinoTheme.assetExists(.buttonDisabled) {
            Image(CrookedCasinoAsset.buttonDisabled.rawValue)
                .resizable(capInsets: EdgeInsets(top: 28, leading: 34, bottom: 28, trailing: 34), resizingMode: .stretch)
        } else {
            CrookedStickerShape(cornerRadius: 13)
                .fill(isEnabled ? tone.fill : Color.white.opacity(0.08))
                .overlay(
                    CrookedStickerShape(cornerRadius: 13)
                        .stroke(CrookedCasinoTheme.ink, lineWidth: 2.4)
                )
                .shadow(color: Color.black.opacity(0.22), radius: 7, y: 4)
        }
    }
}

struct CrookedPanelModifier: ViewModifier {
    let kind: CrookedPanelKind
    var strokeColor: Color
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(CrookedPanelBackground(kind: kind, cornerRadius: cornerRadius))
            .overlay(
                CrookedStickerShape(cornerRadius: cornerRadius)
                    .stroke(CrookedCasinoTheme.ink.opacity(0.82), lineWidth: 2)
            )
            .overlay(
                CrookedStickerShape(cornerRadius: max(4, cornerRadius - 5))
                    .stroke(strokeColor.opacity(0.36), lineWidth: 1)
                    .padding(4)
            )
            .overlay(DoodleAccentView(accent: strokeColor, density: .low).allowsHitTesting(false))
            .shadow(color: Color.black.opacity(0.24), radius: 10, y: 6)
    }
}

extension View {
    func crookedPanel(kind: CrookedPanelKind = .paper, strokeColor: Color = CrookedCasinoTheme.dirtyGold, cornerRadius: CGFloat = 14) -> some View {
        modifier(CrookedPanelModifier(kind: kind, strokeColor: strokeColor, cornerRadius: cornerRadius))
    }
}

private struct CrookedCardFrameBackground: View {
    let kind: CrookedCardFrameKind

    var body: some View {
        if CrookedCasinoTheme.assetExists(kind.asset) {
            Image(kind.asset.rawValue)
                .resizable(capInsets: EdgeInsets(top: 46, leading: 36, bottom: 46, trailing: 36), resizingMode: .stretch)
        } else {
            CrookedCardFrameFallback(kind: kind)
        }
    }
}

private struct CrookedCardFrameFallback: View {
    let kind: CrookedCardFrameKind

    var body: some View {
        ZStack {
            CrookedStickerShape(cornerRadius: 15)
                .fill(kind.fill)

            CrookedPaperTexture(accent: kind.accent)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            CrookedStickerShape(cornerRadius: 15)
                .stroke(CrookedCasinoTheme.ink, lineWidth: 3)

            CrookedStickerShape(cornerRadius: 11)
                .stroke(kind.accent.opacity(0.72), lineWidth: 1.4)
                .padding(6)
        }
    }
}

private struct CrookedPanelBackground: View {
    let kind: CrookedPanelKind
    let cornerRadius: CGFloat

    var body: some View {
        if CrookedCasinoTheme.assetExists(kind.asset) {
            Image(kind.asset.rawValue)
                .resizable(capInsets: EdgeInsets(top: 44, leading: 44, bottom: 44, trailing: 44), resizingMode: .stretch)
        } else {
            CrookedStickerShape(cornerRadius: cornerRadius)
                .fill(kind.fill)
                .overlay(CrookedPaperTexture(accent: CrookedCasinoTheme.dirtyGold.opacity(0.70)))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

private struct DealerShoeFallback: View {
    let state: DealerShoeState

    private var mouthArc: CGFloat {
        switch state {
        case .angry, .busted:
            return -10
        case .laughing, .reward:
            return 14
        default:
            return 8
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let lineWidth = max(2.2, min(width, height) * 0.055)

            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: width * 0.035, style: .continuous)
                        .fill(CrookedCasinoTheme.casinoRed)
                        .overlay(RoundedRectangle(cornerRadius: width * 0.035).stroke(CrookedCasinoTheme.ink, lineWidth: lineWidth * 0.55))
                        .frame(width: width * 0.30, height: height * 0.52)
                        .rotationEffect(.degrees(-8 + Double(index) * 2.4))
                        .offset(x: width * (-0.16 + CGFloat(index) * 0.055), y: -height * 0.23)
                }

                CrookedStickerShape(cornerRadius: height * 0.18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.50, green: 0.18, blue: 0.10),
                                Color(red: 0.30, green: 0.10, blue: 0.065)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width * 0.78, height: height * 0.58)
                    .offset(x: width * 0.04, y: height * 0.12)
                    .overlay(
                        CrookedStickerShape(cornerRadius: height * 0.18)
                            .stroke(CrookedCasinoTheme.ink, lineWidth: lineWidth)
                            .frame(width: width * 0.78, height: height * 0.58)
                            .offset(x: width * 0.04, y: height * 0.12)
                    )

                RoundedRectangle(cornerRadius: height * 0.08, style: .continuous)
                    .fill(CrookedCasinoTheme.dirtyGold)
                    .overlay(RoundedRectangle(cornerRadius: height * 0.08).stroke(CrookedCasinoTheme.ink, lineWidth: lineWidth * 0.45))
                    .frame(width: width * 0.24, height: height * 0.13)
                    .offset(x: width * 0.12, y: height * 0.19)

                Text("HOUSE")
                    .font(.system(size: max(5, height * 0.055), weight: .black, design: .rounded))
                    .foregroundStyle(CrookedCasinoTheme.ink)
                    .offset(x: width * 0.12, y: height * 0.19)

                HStack(spacing: width * 0.07) {
                    eye(size: height * 0.14, isWide: state == .peeking || state == .rigged)
                    eye(size: height * 0.11, isWide: state == .laughing)
                }
                .offset(x: width * 0.05, y: height * 0.02)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.42, y: height * 0.57))
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.61, y: height * 0.56),
                        control: CGPoint(x: width * 0.52, y: height * (0.56 + mouthArc / 100))
                    )
                }
                .stroke(CrookedCasinoTheme.ink, style: StrokeStyle(lineWidth: lineWidth * 0.72, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.73, y: height * 0.47))
                    path.addQuadCurve(to: CGPoint(x: width * 0.92, y: height * 0.42), control: CGPoint(x: width * 0.82, y: height * 0.36))
                }
                .stroke(CrookedCasinoTheme.paperLight, style: StrokeStyle(lineWidth: lineWidth * 1.8, lineCap: .round))
                .overlay(
                    Path { path in
                        path.move(to: CGPoint(x: width * 0.73, y: height * 0.47))
                        path.addQuadCurve(to: CGPoint(x: width * 0.92, y: height * 0.42), control: CGPoint(x: width * 0.82, y: height * 0.36))
                    }
                    .stroke(CrookedCasinoTheme.ink, style: StrokeStyle(lineWidth: lineWidth * 0.48, lineCap: .round))
                )

                scratchMarks(width: width, height: height, lineWidth: lineWidth)
            }
            .rotationEffect(.degrees(state == .shuffling ? -2.5 : 0.8))
        }
        .aspectRatio(1.45, contentMode: .fit)
    }

    private func eye(size: CGFloat, isWide: Bool) -> some View {
        Ellipse()
            .fill(CrookedCasinoTheme.paperLight)
            .frame(width: isWide ? size * 1.18 : size, height: size * 1.22)
            .overlay(Ellipse().stroke(CrookedCasinoTheme.ink, lineWidth: max(1.2, size * 0.15)))
            .overlay(
                Circle()
                    .fill(CrookedCasinoTheme.ink)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .offset(x: isWide ? size * 0.10 : 0)
            )
    }

    private func scratchMarks(width: CGFloat, height: CGFloat, lineWidth: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: width * 0.24, y: height * 0.54))
            path.addLine(to: CGPoint(x: width * 0.29, y: height * 0.48))
            path.move(to: CGPoint(x: width * 0.31, y: height * 0.68))
            path.addLine(to: CGPoint(x: width * 0.36, y: height * 0.63))
            path.move(to: CGPoint(x: width * 0.67, y: height * 0.34))
            path.addLine(to: CGPoint(x: width * 0.72, y: height * 0.31))
        }
        .stroke(CrookedCasinoTheme.ink.opacity(0.46), lineWidth: max(1, lineWidth * 0.45))
    }
}

struct CrookedStickerShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let wobble = min(rect.width, rect.height) * 0.035
        let radius = min(cornerRadius, min(rect.width, rect.height) * 0.35)

        path.move(to: CGPoint(x: rect.minX + radius + wobble, y: rect.minY + wobble))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY + wobble * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - wobble * 0.3, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX + wobble, y: rect.minY + wobble)
        )
        path.addLine(to: CGPoint(x: rect.maxX - wobble, y: rect.maxY - radius - wobble))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY - wobble * 0.4),
            control: CGPoint(x: rect.maxX - wobble, y: rect.maxY + wobble)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius - wobble, y: rect.maxY - wobble))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + wobble * 0.4, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX - wobble, y: rect.maxY - wobble)
        )
        path.addLine(to: CGPoint(x: rect.minX + wobble, y: rect.minY + radius + wobble))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius + wobble, y: rect.minY + wobble),
            control: CGPoint(x: rect.minX + wobble, y: rect.minY - wobble)
        )

        return path
    }
}

private struct CrookedPaperTexture: View {
    var accent: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<9, id: \.self) { index in
                    Circle()
                        .fill(index.isMultiple(of: 3) ? accent.opacity(0.07) : CrookedCasinoTheme.ink.opacity(0.035))
                        .frame(width: dotSize(index, in: proxy.size), height: dotSize(index, in: proxy.size))
                        .position(texturePoint(index, in: proxy.size))
                }

                ForEach(0..<4, id: \.self) { index in
                    Path { path in
                        let start = texturePoint(index + 5, in: proxy.size)
                        path.move(to: start)
                        path.addLine(to: CGPoint(x: start.x + proxy.size.width * 0.06, y: start.y + (index.isMultiple(of: 2) ? 5 : -4)))
                    }
                    .stroke(CrookedCasinoTheme.ink.opacity(0.075), lineWidth: 1)
                }
            }
        }
    }

    private func texturePoint(_ index: Int, in size: CGSize) -> CGPoint {
        let xFractions: [CGFloat] = [0.10, 0.24, 0.39, 0.56, 0.72, 0.88, 0.18, 0.64, 0.80]
        let yFractions: [CGFloat] = [0.16, 0.72, 0.28, 0.84, 0.18, 0.62, 0.46, 0.42, 0.88]
        let x = xFractions[index % xFractions.count] * size.width
        let y = yFractions[index % yFractions.count] * size.height
        return CGPoint(x: x, y: y)
    }

    private func dotSize(_ index: Int, in size: CGSize) -> CGFloat {
        max(2, min(size.width, size.height) * ([0.018, 0.025, 0.012, 0.032][index % 4]))
    }
}

struct DoodleAccentView: View {
    enum Density {
        case low
        case medium

        var count: Int {
            switch self {
            case .low:
                return 4
            case .medium:
                return 7
            }
        }
    }

    var accent: Color
    var density: Density = .medium

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<density.count, id: \.self) { index in
                doodle(index: index, in: proxy.size)
                    .position(doodlePoint(index, in: proxy.size))
                    .rotationEffect(.degrees(Double(index % 5) * 9 - 14))
                    .opacity(0.50)
            }
        }
    }

    @ViewBuilder
    private func doodle(index: Int, in size: CGSize) -> some View {
        let markSize = max(5, min(size.width, size.height) * 0.055)

        switch index % 4 {
        case 0:
            Image(systemName: "suit.club.fill")
                .font(.system(size: markSize, weight: .black))
                .foregroundStyle(accent.opacity(0.34))
        case 1:
            Text("*")
                .font(.system(size: markSize * 1.2, weight: .black, design: .rounded))
                .foregroundStyle(CrookedCasinoTheme.mutedRed.opacity(0.42))
        case 2:
            Path { path in
                path.move(to: CGPoint(x: 0, y: markSize * 0.45))
                path.addLine(to: CGPoint(x: markSize, y: 0))
                path.move(to: CGPoint(x: markSize * 0.18, y: markSize))
                path.addLine(to: CGPoint(x: markSize * 0.78, y: markSize * 0.20))
            }
            .stroke(CrookedCasinoTheme.ink.opacity(0.24), lineWidth: 1.2)
            .frame(width: markSize, height: markSize)
        default:
            Circle()
                .stroke(CrookedCasinoTheme.ink.opacity(0.22), lineWidth: 1.2)
                .frame(width: markSize * 0.7, height: markSize * 0.52)
        }
    }

    private func doodlePoint(_ index: Int, in size: CGSize) -> CGPoint {
        let xFractions: [CGFloat] = [0.08, 0.88, 0.18, 0.78, 0.45, 0.92, 0.11]
        let yFractions: [CGFloat] = [0.20, 0.18, 0.83, 0.75, 0.10, 0.52, 0.55]
        return CGPoint(
            x: xFractions[index % xFractions.count] * size.width,
            y: yFractions[index % yFractions.count] * size.height
        )
    }
}
