import SwiftUI

enum CasinoFloorPage: Int, CaseIterable, Identifiable {
    case game
    case casino
    case lounge
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .game:
            return "Game Room"
        case .casino:
            return "Casino Room"
        case .lounge:
            return "Lounge"
        case .settings:
            return "Settings"
        }
    }

    var subtitle: String {
        switch self {
        case .game:
            return "Play baccarat"
        case .casino:
            return "Build and profile"
        case .lounge:
            return "Themes and collection"
        case .settings:
            return "Controls"
        }
    }

    var shortTitle: String {
        switch self {
        case .game:
            return "Game"
        case .casino:
            return "Build"
        case .lounge:
            return "Lounge"
        case .settings:
            return "Gear"
        }
    }

    var iconName: String {
        switch self {
        case .game:
            return "suit.club.fill"
        case .casino:
            return "sparkles"
        case .lounge:
            return "crown.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .game:
            return CasinoTheme.emerald
        case .casino:
            return CasinoTheme.gold
        case .lounge:
            return CasinoTheme.violet
        case .settings:
            return .white.opacity(0.82)
        }
    }
}

struct CasinoFloorPagerView: View {
    @Binding var selectedPage: CasinoFloorPage
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var settings: SettingsManager
    @ObservedObject var audioManager: AudioManager

    let dealButtonTitle: String
    let dealGuidanceText: String
    let onDealRound: () -> Void
    let onPurchaseUnlockable: (Unlockable) -> Void
    let onToggleRunModifier: (RunModifierID, Bool) -> Void
    let onSelectChallenge: (ChallengeModeID) -> Void
    let onToggleDailyRun: (Bool) -> Void
    let onSelectTheme: (CasinoThemeID) -> Void
    let onReplayTutorial: () -> Void
    let onShowGlossary: () -> Void
    let onShowSupport: () -> Void
    let onResetProfile: () -> Void
    let onShowDebug: (() -> Void)?

    var body: some View {
        TabView(selection: $selectedPage) {
            GameRoomView(
                viewModel: viewModel,
                selectedPage: $selectedPage,
                dealButtonTitle: dealButtonTitle,
                dealGuidanceText: dealGuidanceText,
                onDealRound: onDealRound,
                onBack: {}
            )
            .tag(CasinoFloorPage.game)

            CasinoRoomPage(
                viewModel: viewModel,
                selectedPage: $selectedPage,
                onPurchaseUnlockable: onPurchaseUnlockable,
                onShowGlossary: onShowGlossary,
                onShowDebug: onShowDebug
            )
            .tag(CasinoFloorPage.casino)

            LoungePage(
                viewModel: viewModel,
                selectedPage: $selectedPage,
                onToggleRunModifier: onToggleRunModifier,
                onSelectChallenge: onSelectChallenge,
                onToggleDailyRun: onToggleDailyRun,
                onSelectTheme: onSelectTheme,
                onShowGlossary: onShowGlossary,
                onShowDebug: onShowDebug
            )
            .tag(CasinoFloorPage.lounge)

            SettingsFloorPage(
                settings: settings,
                audioManager: audioManager,
                selectedPage: $selectedPage,
                profile: viewModel.metaProgression.profile,
                analyticsLog: viewModel.analytics.debugLogText,
                onReplayTutorial: onReplayTutorial,
                onShowGlossary: onShowGlossary,
                onShowSupport: onShowSupport,
                onResetProfile: onResetProfile,
                onShowDebug: onShowDebug
            )
            .tag(CasinoFloorPage.settings)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct CasinoCurrencyStrip: View {
    let profile: PlayerProfile
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            currencyPill(title: "Chips", value: floorFormatNumber(profile.casinoChips), color: CasinoTheme.gold)
            currencyPill(title: "Rep", value: floorFormatNumber(profile.reputation), color: CasinoTheme.neonBlue)
        }
    }

    private func currencyPill(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: compact ? 6 : 7, height: compact ? 6 : 7)

            Text(title)
                .font(.system(size: compact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)

            Text(value)
                .font(.system(size: compact ? 10 : 12, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: true, vertical: false)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 7)
        .background(Capsule().fill(Color.black.opacity(0.28)))
        .overlay(Capsule().stroke(color.opacity(0.22), lineWidth: 1))
        .accessibilityLabel("\(title) \(value)")
    }
}

struct RunCurrencyStrip: View {
    let runManager: RunManager
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            resourcePill(title: "Chips", value: "\(runManager.chips)", color: CasinoTheme.gold)
            resourcePill(title: "Heat", value: "\(runManager.heat)/\(runManager.maxHeat)", color: CasinoTheme.red)
        }
    }

    private func resourcePill(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: compact ? 6 : 7, height: compact ? 6 : 7)

            Text(title)
                .font(.system(size: compact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(value)
                .font(.system(size: compact ? 10 : 12, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 7)
        .background(Capsule().fill(Color.black.opacity(0.28)))
        .overlay(Capsule().stroke(color.opacity(0.22), lineWidth: 1))
        .accessibilityLabel("\(title) \(value)")
    }
}

private struct CasinoRoomPage: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selectedPage: CasinoFloorPage
    let onPurchaseUnlockable: (Unlockable) -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?

    private var profile: PlayerProfile { viewModel.metaProgression.profile }

    var body: some View {
        FloorPageScaffold(page: .casino, selectedPage: $selectedPage, profile: profile, onShowGlossary: onShowGlossary, onShowDebug: onShowDebug) {
            VStack(spacing: 9) {
                HStack(spacing: 8) {
                    FloorMetricTile(title: "Run Upgrades", value: "\(viewModel.state.acquiredUpgrades.count)", accentColor: CasinoTheme.gold)
                    FloorMetricTile(title: "Synergies", value: "\(viewModel.activeSynergies.count)", accentColor: CasinoTheme.emerald)
                    FloorMetricTile(title: "Collection", value: "\(viewModel.collectionCompletionPercent)%", accentColor: CasinoTheme.neonBlue)
                }

                FloorPanel(title: "Current Build", subtitle: "Live run advantages") {
                    HStack(spacing: 7) {
                        FloorMetricTile(title: "Reveal", value: "\(viewModel.revealedShoeCards)", accentColor: CasinoTheme.neonBlue)
                        FloorMetricTile(title: "Tie", value: "\(effectiveTiePayout):1", accentColor: CasinoTheme.gold)
                        FloorMetricTile(title: "Disabled", value: "\(viewModel.state.bossManager.disabledUpgradeIDs.count)", accentColor: CasinoTheme.red)
                    }

                    CompactUpgradeList(
                        upgrades: Array(viewModel.state.acquiredUpgrades.prefix(3)),
                        disabledIDs: viewModel.state.bossManager.disabledUpgradeIDs
                    )
                }

                FloorPanel(title: "Profile Office", subtitle: "Permanent progression") {
                    HStack(spacing: 7) {
                        FloorMetricTile(title: "Runs", value: "\(profile.totalRuns)", accentColor: CasinoTheme.emerald)
                        FloorMetricTile(title: "Wins", value: "\(profile.totalWins)", accentColor: CasinoTheme.gold)
                        FloorMetricTile(title: "Bosses", value: "\(profile.bossesDefeated)", accentColor: CasinoTheme.red)
                    }

                    HStack(spacing: 7) {
                        FloorDetailPill(title: "Best Bankroll", value: MoneyFormatter.format(profile.highestBankrollEverCents))
                        FloorDetailPill(title: "Best Profit", value: MoneyFormatter.format(profile.highestProfitEverCents))
                    }
                }

                FloorPanel(title: "Unlock Shop", subtitle: "Next available unlocks") {
                    HStack(spacing: 7) {
                        let locked = viewModel.shopUnlockables.filter { !$0.isUnlocked(in: profile) }
                        ForEach(Array(locked.prefix(2))) { unlockable in
                            CompactUnlockCard(
                                unlockable: unlockable,
                                profile: profile,
                                onPurchase: onPurchaseUnlockable
                            )
                        }

                        if locked.isEmpty {
                            FloorEmptyState(text: "Everything currently available is unlocked.")
                        }
                    }
                }
            }
        }
    }

    private var effectiveTiePayout: Int {
        if viewModel.state.bossManager.capsTiePayoutAtBase {
            return 8
        }

        let effects = viewModel.activeUpgradeEffects
        let runManager = viewModel.state.runManager
        let upgradedTie = effects.tiePayoutMultiplier + effects.tiePayoutBonus + runManager.tiePayoutBonus
        let rewardTie = runManager.tiePayoutOverride ?? 8
        return max(8 + runManager.tiePayoutBonus, upgradedTie, rewardTie)
    }
}

private struct LoungePage: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selectedPage: CasinoFloorPage
    let onToggleRunModifier: (RunModifierID, Bool) -> Void
    let onSelectChallenge: (ChallengeModeID) -> Void
    let onToggleDailyRun: (Bool) -> Void
    let onSelectTheme: (CasinoThemeID) -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?

    private var profile: PlayerProfile { viewModel.metaProgression.profile }

    var body: some View {
        FloorPageScaffold(page: .lounge, selectedPage: $selectedPage, profile: profile, onShowGlossary: onShowGlossary, onShowDebug: onShowDebug) {
            VStack(spacing: 9) {
                FloorPanel(title: "Theme Lounge", subtitle: "Cosmetic casino atmosphere") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 3), spacing: 7) {
                        ForEach(CasinoThemeID.allCases) { theme in
                            CompactThemeButton(
                                theme: theme,
                                isSelected: profile.selectedThemeID == theme,
                                onSelect: onSelectTheme
                            )
                        }
                    }
                }

                FloorPanel(title: "Challenge Room", subtitle: "Optional future-run rules") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 2), spacing: 7) {
                        ForEach(ChallengeModeID.allCases) { challenge in
                            CompactChoiceButton(
                                title: challenge.name,
                                subtitle: challenge == .standard ? "Recommended" : "+\(challenge.chipRewardMultiplierPercent - 100)% Chips",
                                isSelected: profile.selectedChallengeID == challenge,
                                accentColor: challenge == .standard ? CasinoTheme.gold : CasinoTheme.red
                            ) {
                                onSelectChallenge(challenge)
                            }
                        }
                    }

                    HStack(spacing: 7) {
                        FloorToggleCard(title: "Daily", value: profile.isDailyRunEnabled, accentColor: CasinoTheme.neonBlue) {
                            onToggleDailyRun($0)
                        }

                        ForEach(Array(RunModifierID.allCases.prefix(2))) { modifier in
                            CompactRunModifierButton(modifier: modifier, profile: profile, onToggle: onToggleRunModifier)
                        }
                    }
                }

                FloorPanel(title: "Collection Vault", subtitle: "Discovered content and achievements") {
                    HStack(spacing: 7) {
                        FloorMetricTile(title: "Complete", value: "\(viewModel.collectionCompletionPercent)%", accentColor: CasinoTheme.gold)
                        FloorMetricTile(title: "Achievements", value: "\(profile.achievedAchievementIDs.count)", accentColor: CasinoTheme.emerald)
                        FloorMetricTile(title: "Bosses Down", value: "\(profile.bossesDefeatedIDs.count)", accentColor: CasinoTheme.red)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 3), spacing: 7) {
                        ForEach(Array(viewModel.collectionEntries.prefix(6))) { entry in
                            CompactCollectionCard(entry: entry)
                        }
                    }
                }
            }
        }
    }
}

private struct SettingsFloorPage: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var audioManager: AudioManager
    @Binding var selectedPage: CasinoFloorPage
    let profile: PlayerProfile
    let analyticsLog: String
    let onReplayTutorial: () -> Void
    let onShowGlossary: () -> Void
    let onShowSupport: () -> Void
    let onResetProfile: () -> Void
    let onShowDebug: (() -> Void)?

    var body: some View {
        FloorPageScaffold(page: .settings, selectedPage: $selectedPage, profile: profile, showsCurrency: false, onShowGlossary: onShowGlossary, onShowDebug: onShowDebug) {
            VStack(spacing: 9) {
                FloorPanel(title: "Audio", subtitle: "Volumes and current music") {
                    CompactSettingSlider(title: "Music", value: $settings.musicVolume, isMuted: $settings.isMusicMuted)
                    CompactSettingSlider(title: "SFX", value: $settings.sfxVolume, isMuted: $settings.isSFXMuted)
                    FloorDetailPill(title: "Layer", value: audioManager.currentMusicLayer.displayName)
                }

                FloorPanel(title: "Feel", subtitle: "Comfort controls") {
                    HStack(spacing: 7) {
                        FloorToggleCard(title: "Haptics", value: settings.isHapticsEnabled, accentColor: CasinoTheme.gold) { settings.isHapticsEnabled = $0 }
                        FloorToggleCard(title: "Reduce Motion", value: settings.isReduceMotionEnabled, accentColor: CasinoTheme.neonBlue) { settings.isReduceMotionEnabled = $0 }
                    }
                }

                FloorPanel(title: "Support", subtitle: BuildInfo.versionText) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 2), spacing: 7) {
                        FloorActionButton(title: "Tutorial", iconName: "questionmark.circle.fill", action: onReplayTutorial)
                        FloorActionButton(title: "Glossary", iconName: "book.closed.fill", action: onShowGlossary)
                        FloorActionButton(title: "Playtest", iconName: "testtube.2", action: onShowSupport)

                        ShareLink(item: analyticsLog.isEmpty ? "No Rigged Shoe analytics events yet." : analyticsLog) {
                            FloorActionLabel(title: "Export Logs", iconName: "square.and.arrow.up.fill", accentColor: CasinoTheme.gold)
                        }
                    }
                }

                HStack(spacing: 7) {
                    FloorActionButton(title: "Restore Defaults", iconName: "arrow.counterclockwise") {
                        settings.restoreDefaults()
                    }

                    Button(role: .destructive, action: onResetProfile) {
                        FloorActionLabel(title: "Reset Profile", iconName: "trash.fill", accentColor: CasinoTheme.red, usesLightText: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct FloorPageScaffold<Content: View>: View {
    let page: CasinoFloorPage
    @Binding var selectedPage: CasinoFloorPage
    let profile: PlayerProfile
    var showsCurrency = true
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?
    let content: Content

    init(
        page: CasinoFloorPage,
        selectedPage: Binding<CasinoFloorPage>,
        profile: PlayerProfile,
        showsCurrency: Bool = true,
        onShowGlossary: @escaping () -> Void,
        onShowDebug: (() -> Void)?,
        @ViewBuilder content: () -> Content
    ) {
        self.page = page
        self._selectedPage = selectedPage
        self.profile = profile
        self.showsCurrency = showsCurrency
        self.onShowGlossary = onShowGlossary
        self.onShowDebug = onShowDebug
        self.content = content()
    }

    var body: some View {
        ZStack {
            CasinoTheme.background(for: profile.selectedThemeID)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                header
                content
                    .frame(maxHeight: .infinity, alignment: .top)
                pageDots
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: page.iconName)
                .font(.headline.weight(.black))
                .foregroundStyle(page.accentColor)
                .frame(width: 34, height: 34)
                .background(Circle().fill(page.accentColor.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(page.title)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)

                Text(page.subtitle)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.54))
                    .textCase(.uppercase)
            }

            Spacer(minLength: 0)

            if showsCurrency {
                CasinoCurrencyStrip(profile: profile, compact: true)
            }

            Button(action: onShowGlossary) {
                Image(systemName: "info.circle.fill")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
            .buttonStyle(.plain)

            if let onShowDebug {
                Button(action: onShowDebug) {
                    Image(systemName: "ladybug.fill")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(CasinoTheme.gold)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(CasinoFloorPage.allCases) { pageOption in
                let isSelected = pageOption == selectedPage

                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                        selectedPage = pageOption
                    }
                } label: {
                    HStack(spacing: isSelected ? 4 : 0) {
                        Image(systemName: pageOption.iconName)
                            .font(.system(size: isSelected ? 9 : 10, weight: .black, design: .rounded))

                        if isSelected {
                            Text(pageOption.shortTitle)
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .textCase(.uppercase)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                    }
                    .foregroundStyle(isSelected ? CasinoTheme.ink : .white.opacity(0.62))
                    .frame(height: 25)
                    .padding(.horizontal, isSelected ? 8 : 7)
                    .background(
                        Capsule()
                            .fill(isSelected ? pageOption.accentColor : Color.white.opacity(0.08))
                    )
                    .overlay(
                        Capsule()
                            .stroke(pageOption.accentColor.opacity(isSelected ? 0.30 : 0.16), lineWidth: 1)
                    )
                    .animation(.spring(response: 0.24, dampingFraction: 0.80), value: selectedPage)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go to \(pageOption.title)")
                .accessibilityHint("Switches casino floor page")
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.black.opacity(0.20)))
    }
}

private struct FloorPanel<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.50))
                    .lineLimit(1)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.black.opacity(0.30)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CasinoTheme.gold.opacity(0.16), lineWidth: 1))
    }
}

private struct FloorMetricTile: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.48))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(accentColor.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(accentColor.opacity(0.24), lineWidth: 1))
    }
}

private struct FloorDetailPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.46))
                .textCase(.uppercase)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)))
    }
}

private struct CompactUpgradeList: View {
    let upgrades: [UpgradeCard]
    let disabledIDs: Set<UUID>

    var body: some View {
        VStack(spacing: 6) {
            if upgrades.isEmpty {
                FloorEmptyState(text: "No run upgrades yet. Play hands to earn your first build card.")
            } else {
                ForEach(upgrades) { upgrade in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(CasinoTheme.rarityColor(upgrade.rarity))
                            .frame(width: 7, height: 7)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(upgrade.name)
                                .font(.caption.weight(.black))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(disabledIDs.contains(upgrade.id) ? "Disabled by boss" : upgrade.description)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(disabledIDs.contains(upgrade.id) ? CasinoTheme.red : .white.opacity(0.52))
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(7)
                    .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.06)))
                }
            }
        }
    }
}

private struct CompactUnlockCard: View {
    let unlockable: Unlockable
    let profile: PlayerProfile
    let onPurchase: (Unlockable) -> Void

    var body: some View {
        let canAfford = unlockable.canAfford(with: profile)

        VStack(alignment: .leading, spacing: 6) {
            Text(unlockable.categoryName)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.gold)
                .textCase(.uppercase)

            Text(unlockable.name)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text("\(floorFormatNumber(unlockable.costChips)) Chips")
                .font(.caption2.monospacedDigit().weight(.black))
                .foregroundStyle(canAfford ? .white.opacity(0.72) : CasinoTheme.red)

            Button {
                onPurchase(unlockable)
            } label: {
                Text(canAfford ? "Unlock" : "Need Chips")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(canAfford ? .black : .white.opacity(0.45))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 8).fill(canAfford ? CasinoTheme.gold : Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .disabled(!canAfford)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)))
    }
}

private struct CompactThemeButton: View {
    let theme: CasinoThemeID
    let isSelected: Bool
    let onSelect: (CasinoThemeID) -> Void

    var body: some View {
        Button {
            onSelect(theme)
        } label: {
            Text(theme.name)
                .font(.caption2.weight(.black))
                .foregroundStyle(isSelected ? .black : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 9).fill(isSelected ? CasinoTheme.gold : Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(CasinoTheme.gold.opacity(isSelected ? 0 : 0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct CompactChoiceButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(isSelected ? .black : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Text(subtitle)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? .black.opacity(0.60) : accentColor.opacity(0.80))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 9).fill(isSelected ? accentColor : Color.white.opacity(0.07)))
        }
        .buttonStyle(.plain)
    }
}

private struct FloorToggleCard: View {
    let title: String
    let value: Bool
    let accentColor: Color
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!value)
        } label: {
            HStack {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer()
                Text(value ? "On" : "Off")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(value ? .black : .white.opacity(0.48))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(value ? accentColor : Color.white.opacity(0.09)))
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.06)))
        }
        .buttonStyle(.plain)
    }
}

private struct CompactRunModifierButton: View {
    let modifier: RunModifierID
    let profile: PlayerProfile
    let onToggle: (RunModifierID, Bool) -> Void

    var body: some View {
        let isUnlocked = profile.unlockedRunModifierIDs.contains(modifier.rawValue)
        let isActive = profile.activeRunModifierIDs.contains(modifier.rawValue)

        Button {
            guard isUnlocked else { return }
            onToggle(modifier, !isActive)
        } label: {
            HStack(spacing: 6) {
                Text(modifier.name)
                    .font(.caption2.weight(.black))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.34))
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
                Spacer()
                Text(isActive ? "On" : isUnlocked ? "Off" : "Lock")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(isActive ? .black : .white.opacity(0.48))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(isActive ? CasinoTheme.gold : Color.white.opacity(0.09)))
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.06)))
        }
        .buttonStyle(.plain)
    }
}

private struct CompactCollectionCard: View {
    let entry: CollectionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Image(systemName: isRevealed ? "checkmark.seal.fill" : "lock.fill")
                .font(.subheadline.weight(.black))
                .foregroundStyle(accentColor)

            Text(isRevealed ? entry.title : "Locked")
                .font(.caption2.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(entry.stateText)
                .font(.system(size: 7, weight: .black, design: .rounded))
                .foregroundStyle(accentColor)
                .textCase(.uppercase)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(isRevealed ? 0.07 : 0.035)))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(accentColor.opacity(isRevealed ? 0.34 : 0.14), lineWidth: 1))
    }

    private var isRevealed: Bool {
        entry.isUnlocked || entry.isEncountered || entry.isDefeated
    }

    private var accentColor: Color {
        if let rarity = entry.rarity {
            return CasinoTheme.rarityColor(rarity)
        }

        return isRevealed ? CasinoTheme.gold : .white.opacity(0.42)
    }
}

private struct CompactSettingSlider: View {
    let title: String
    @Binding var value: Double
    @Binding var isMuted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    isMuted.toggle()
                } label: {
                    Text(isMuted ? "Muted" : "On")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(isMuted ? .white.opacity(0.50) : .black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(isMuted ? Color.white.opacity(0.09) : CasinoTheme.gold))
                }
                .buttonStyle(.plain)
            }

            Slider(value: $value, in: 0...1)
                .tint(CasinoTheme.gold)
                .disabled(isMuted)
        }
    }
}

private struct FloorActionButton: View {
    let title: String
    let iconName: String
    var accentColor: Color = CasinoTheme.gold
    var usesLightText = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FloorActionLabel(title: title, iconName: iconName, accentColor: accentColor, usesLightText: usesLightText)
        }
        .buttonStyle(.plain)
    }
}

private struct FloorActionLabel: View {
    let title: String
    let iconName: String
    let accentColor: Color
    var usesLightText = false

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
            Text(title)
            Spacer(minLength: 0)
        }
        .font(.caption.weight(.black))
        .foregroundStyle(usesLightText ? .white : .black)
        .lineLimit(1)
        .minimumScaleFactor(0.68)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(accentColor))
    }
}

private struct FloorEmptyState: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.56))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.06)))
    }
}

private func floorFormatNumber(_ value: Int) -> String {
    NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
}
