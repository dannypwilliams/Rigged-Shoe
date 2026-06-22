import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var settings = SettingsManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var hapticsManager = HapticsManager()
    @State private var selectedPage: CasinoFloorPage = .game
    @State private var isShowingTutorial = false
    @State private var isShowingGlossary = false
    @State private var isShowingSupport = false
#if DEBUG
    @State private var isShowingDebugMenu = false
#endif
    @State private var isResolvingRoundPresentation = false
    @State private var shakeTrigger: CGFloat = 0

    var body: some View {
        ZStack {
            CasinoTheme.background(for: viewModel.metaProgression.profile.selectedThemeID)
                .ignoresSafeArea()

            CasinoFloorPagerView(
                selectedPage: $selectedPage,
                viewModel: viewModel,
                settings: settings,
                audioManager: audioManager,
                dealButtonTitle: dealButtonTitle,
                dealGuidanceText: dealGuidanceText,
                onDealRound: dealRound,
                onPurchaseUnlockable: purchaseUnlockable,
                onToggleRunModifier: toggleRunModifier,
                onSelectChallenge: selectChallenge,
                onToggleDailyRun: toggleDailyRun,
                onSelectTheme: selectTheme,
                onReplayTutorial: replayTutorial,
                onShowGlossary: showGlossary,
                onShowSupport: showSupport,
                onResetProfile: resetProfile,
                onShowDebug: debugAction
            )
            .tint(CasinoTheme.gold)
            .modifier(ScreenShakeEffect(animatableData: shakeTrigger))

            if !isResolvingRoundPresentation {
                if viewModel.state.runManager.status == .failed || viewModel.state.runManager.status == .completed {
                    RunOverView(
                        runManager: viewModel.state.runManager,
                        bossManager: viewModel.state.bossManager,
                        profile: viewModel.metaProgression.profile,
                        bankrollCents: viewModel.state.bankrollCents,
                        chipsEarnedThisRun: viewModel.state.metaChipsEarnedThisRun,
                        reputationEarnedThisRun: viewModel.state.metaReputationEarnedThisRun,
                        onStartNewRun: startNewRun
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(5)
                } else if let boss = viewModel.state.bossManager.pendingAnnouncementBoss {
                    BossAnnouncementView(
                        boss: boss,
                        onContinue: continueToBoss
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(4)
                } else if let defeatedBoss = viewModel.state.bossManager.lastDefeatedBoss,
                          !viewModel.state.bossManager.pendingBossRewardChoices.isEmpty {
                    BossDefeatedView(
                        boss: defeatedBoss,
                        runManager: viewModel.state.runManager,
                        bankrollCents: viewModel.state.bankrollCents,
                        choices: viewModel.state.bossManager.pendingBossRewardChoices,
                        onSelect: selectBossReward
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(3)
                } else if !viewModel.state.pendingStageRewardChoices.isEmpty {
                    StageClearView(
                        runManager: viewModel.state.runManager,
                        bankrollCents: viewModel.state.bankrollCents,
                        choices: viewModel.state.pendingStageRewardChoices,
                        onSelect: selectStageReward
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(2)
                } else if !viewModel.state.pendingUpgradeChoices.isEmpty {
                    UpgradeSelectionView(
                        choices: viewModel.state.pendingUpgradeChoices,
                        onSelect: selectUpgrade
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(1)
                }
            }

            if isShowingTutorial {
                OnboardingView(
                    onDealGuidedHand: dealRound,
                    onComplete: { skipped in completeTutorial(skipped: skipped) }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(11)
            }

            if isShowingGlossary {
                GlossaryView {
                    isShowingGlossary = false
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(12)
            }

            if isShowingSupport {
                TestFlightSupportView(
                    analyticsLog: viewModel.analytics.debugLogText,
                    onMarkPatchNotesSeen: viewModel.markPatchNotesSeen,
                    onClose: { isShowingSupport = false }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(13)
            }

#if DEBUG
            if isShowingDebugMenu {
                DebugMenuView(
                    analyticsSummary: viewModel.analytics.retentionSummary,
                    onFastForward: viewModel.debugFastForwardThreeRounds,
                    onInstantStageClear: viewModel.debugInstantStageClear,
                    onGrantUpgrade: { name in viewModel.debugGrantUpgrade(named: name) },
                    onGrantLegendary: viewModel.debugGrantLegendary,
                    onSpawnBoss: { boss in viewModel.debugSpawnBoss(boss) },
                    onForceDailySeed: { seed in viewModel.debugForceDailySeed(seed) },
                    onRunPhase3Checks: viewModel.debugRunPhase3Checks,
                    onStressGameRoomLayout: viewModel.debugStressGameRoomLayout,
                    onClose: { isShowingDebugMenu = false }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(14)
            }
#endif
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.pendingUpgradeChoices)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.pendingStageRewardChoices)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.bossManager.pendingAnnouncementBoss)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.bossManager.pendingBossRewardChoices)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.runManager.status)
        .onAppear {
            updateMusicLayer()
        }
        .onChange(of: viewModel.state.latestRound?.id) { _, _ in
            handleRoundFeedback()
        }
        .onChange(of: viewModel.state.bossManager.pendingAnnouncementBoss?.id) { _, newValue in
            guard newValue != nil else {
                return
            }

            audioManager.play(.bossIntro, settings: settings)
            hapticsManager.play(.heavy, settings: settings)
            updateMusicLayer()
        }
        .onChange(of: viewModel.state.bossManager.activeBoss?.id) { _, _ in
            updateMusicLayer()
        }
        .onChange(of: viewModel.state.bossManager.lastDefeatedBoss?.id) { _, newValue in
            guard newValue != nil else {
                return
            }

            audioManager.play(.bossDefeat, settings: settings)
            hapticsManager.play(.heavy, settings: settings)
            shake()
            updateMusicLayer()
        }
        .onChange(of: viewModel.state.pendingStageRewardChoices.isEmpty) { _, isEmpty in
            if !isEmpty {
                audioManager.play(.stageClear, settings: settings)
                hapticsManager.play(.success, settings: settings)
            }
        }
        .onChange(of: viewModel.state.runManager.status) { _, status in
            if status == .completed {
                audioManager.play(.runVictory, settings: settings)
                hapticsManager.play(.success, settings: settings)
                shake(amount: 10)
            } else if status == .failed {
                hapticsManager.play(.failure, settings: settings)
            }

            updateMusicLayer()
        }
        .onChange(of: viewModel.metaProgression.profile.achievedAchievementIDs.count) { _, newValue in
            guard newValue > 0 else {
                return
            }

            audioManager.play(.achievementUnlock, settings: settings)
            hapticsManager.play(.success, settings: settings)
        }
        .onChange(of: settings.musicVolume) { _, _ in updateMusicLayer() }
        .onChange(of: settings.isMusicMuted) { _, _ in updateMusicLayer() }
        .onChange(of: viewModel.metaProgression.profile.selectedThemeID) { _, _ in updateMusicLayer() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                viewModel.recordSessionEnded()
            }
        }
    }

    @ViewBuilder
    private func destination(for room: CasinoRoom) -> some View {
        switch room {
        case .gameRoom:
            GameRoomView(
                viewModel: viewModel,
                selectedPage: $selectedPage,
                dealButtonTitle: dealButtonTitle,
                dealGuidanceText: dealGuidanceText,
                onDealRound: dealRound,
                onBack: leaveRoom
            )
        case .upgradeRoom:
            UpgradeRoomView(
                viewModel: viewModel,
                onBack: leaveRoom,
                onShowGlossary: showGlossary,
                onShowDebug: debugAction
            )
        case .profileOffice:
            ProfileOfficeView(
                viewModel: viewModel,
                onPurchase: purchaseUnlockable,
                onBack: leaveRoom,
                onShowGlossary: showGlossary,
                onShowDebug: debugAction
            )
        case .challengeRoom:
            ChallengeRoomView(
                viewModel: viewModel,
                onToggleRunModifier: toggleRunModifier,
                onSelectChallenge: selectChallenge,
                onToggleDailyRun: toggleDailyRun,
                onBack: leaveRoom,
                onShowGlossary: showGlossary,
                onShowDebug: debugAction
            )
        case .themeLounge:
            ThemeLoungeView(
                viewModel: viewModel,
                onSelectTheme: selectTheme,
                onBack: leaveRoom,
                onShowGlossary: showGlossary,
                onShowDebug: debugAction
            )
        case .collectionVault:
            CollectionVaultView(
                viewModel: viewModel,
                onBack: leaveRoom,
                onShowGlossary: showGlossary,
                onShowDebug: debugAction
            )
        case .settings:
            SettingsRoomView(
                settings: settings,
                audioManager: audioManager,
                analyticsLog: viewModel.analytics.debugLogText,
                onReplayTutorial: replayTutorial,
                onShowGlossary: showGlossary,
                onShowSupport: showSupport,
                onResetProfile: {
                    selectedPage = .game
                    resetProfile()
                },
                onBack: leaveRoom,
                onShowDebug: debugAction
            )
        }
    }

    private var debugAction: (() -> Void)? {
#if DEBUG
        return {
            isShowingDebugMenu = true
            hapticsManager.play(.medium, settings: settings)
        }
#else
        return nil
#endif
    }

    private func enterRoom(_ room: CasinoRoom) {
        hapticsManager.play(.light, settings: settings)
        selectedPage = floorPage(for: room)
    }

    private func leaveRoom() {
        hapticsManager.play(.light, settings: settings)
        selectedPage = .game
    }

    private func floorPage(for room: CasinoRoom) -> CasinoFloorPage {
        switch room {
        case .gameRoom:
            return .game
        case .upgradeRoom, .profileOffice:
            return .casino
        case .challengeRoom, .themeLounge, .collectionVault:
            return .lounge
        case .settings:
            return .settings
        }
    }

    private func showGlossary() {
        isShowingGlossary = true
        hapticsManager.play(.light, settings: settings)
    }

    private func showSupport() {
        isShowingSupport = true
        hapticsManager.play(.light, settings: settings)
    }

    private func purchaseUnlockable(_ unlockable: Unlockable) {
        audioManager.play(.upgradeSelection, settings: settings)
        hapticsManager.play(.medium, settings: settings)
        viewModel.purchaseUnlockable(unlockable)
    }

    private func toggleRunModifier(_ modifier: RunModifierID, isActive: Bool) {
        hapticsManager.play(.light, settings: settings)
        viewModel.setRunModifier(modifier, isActive: isActive)
    }

    private func selectChallenge(_ challengeID: ChallengeModeID) {
        hapticsManager.play(.medium, settings: settings)
        viewModel.setChallenge(challengeID)
    }

    private func toggleDailyRun(_ isEnabled: Bool) {
        hapticsManager.play(.light, settings: settings)
        viewModel.setDailyRunEnabled(isEnabled)
    }

    private func selectTheme(_ themeID: CasinoThemeID) {
        hapticsManager.play(.medium, settings: settings)
        viewModel.setTheme(themeID)
        updateMusicLayer()
    }

    private var dealButtonTitle: String {
        if viewModel.state.runManager.status == .failed || viewModel.state.runManager.status == .completed {
            return "Run Finished"
        }

        if viewModel.state.bossManager.pendingAnnouncementBoss != nil {
            return "Boss Approaching"
        }

        if !viewModel.state.bossManager.pendingBossRewardChoices.isEmpty {
            return "Choose Boss Reward"
        }

        if !viewModel.state.pendingStageRewardChoices.isEmpty {
            return "Choose Stage Reward"
        }

        if !viewModel.state.pendingUpgradeChoices.isEmpty {
            return "Choose Upgrade"
        }

        if !viewModel.state.challengeID.allowsBet(viewModel.state.selectedBetType) {
            return "Bet Not Allowed"
        }

        if !viewModel.isBetAmountUnlocked(viewModel.state.selectedBetAmountCents) {
            return "Bet Locked"
        }

        if viewModel.state.bankrollCents < viewModel.state.selectedBetAmountCents {
            return "Bankroll Too Low"
        }

        return viewModel.canDeal ? "Deal" : "Bankroll Too Low"
    }

    private var dealGuidanceText: String {
        if viewModel.canDeal {
            if let guidedOpeningHandNotice = viewModel.guidedOpeningHandNotice {
                return guidedOpeningHandNotice
            }

            if let cap = viewModel.activeRevealBetCapCents {
                return "\(viewModel.activeShoeReveal?.title ?? "Reveal") active: bet capped at \(MoneyFormatter.format(cap))."
            }

            if viewModel.state.selectedBetAmountCents * 4 > max(1, viewModel.state.bankrollCents) {
                return "High risk: this bet is more than 25% of your bankroll."
            }

            switch viewModel.state.runManager.stageReached {
            case 1:
                return "Recommended: play the $10 hand and protect the $200 safety line."
            case 2:
                return "Recommended: stay controlled. Finish 10 hands without losing more than $60."
            case 3:
                return "Recommended: grow by $15; use $20 or $30 only when the read is strong."
            case 4:
                return "Recommended: chase one upgrade-powered win. Let your best bonus or reveal guide the bet."
            case 5:
                return "First profit gate: use your build. Press $50-$75 only when upgrades or reveals give you an edge."
            default:
                break
            }

            return "Deal plays one baccarat round from the shoe."
        }

        if viewModel.state.runManager.status == .failed || viewModel.state.runManager.status == .completed {
            return "Start a new run from the run summary before dealing again."
        }

        if viewModel.isDealResolutionLocked {
            return "Resolving this hand. The next deal unlocks after the result."
        }

        if viewModel.state.bossManager.pendingAnnouncementBoss != nil {
            return "Continue through the boss warning before the next hand."
        }

        if !viewModel.state.bossManager.pendingBossRewardChoices.isEmpty {
            return "Choose a boss reward to return to the table."
        }

        if !viewModel.state.pendingStageRewardChoices.isEmpty {
            return "Choose a stage reward to return to the table."
        }

        if !viewModel.state.pendingUpgradeChoices.isEmpty {
            return "Choose an upgrade to return to the table."
        }

        if !viewModel.state.challengeID.allowsBet(viewModel.state.selectedBetType) {
            return "\(viewModel.state.challengeID.name) does not allow \(viewModel.state.selectedBetType.displayName) bets."
        }

        if !viewModel.isBetAmountUnlocked(viewModel.state.selectedBetAmountCents) {
            let stage = viewModel.unlockStage(forBetAmountCents: viewModel.state.selectedBetAmountCents)
            return "This bet unlocks at Stage \(stage). Choose a smaller denomination."
        }

        if let cap = viewModel.activeRevealBetCapCents,
           viewModel.state.selectedBetAmountCents > cap {
            return "\(viewModel.activeShoeReveal?.title ?? "Reveal") caps this hand at \(MoneyFormatter.format(cap))."
        }

        if viewModel.state.bankrollCents < viewModel.state.selectedBetAmountCents {
            return "Choose a smaller bet that your bankroll can cover."
        }

        return "Clear the current table state before dealing again."
    }

    private func dealRound() {
        guard viewModel.canDeal else {
            return
        }

        hapticsManager.play(.light, settings: settings)
        viewModel.dealRound()
    }

    private func selectUpgrade(_ upgrade: UpgradeCard) {
        audioManager.play(.upgradeSelection, settings: settings)
        hapticsManager.play(upgrade.rarity == .legendary ? .success : .medium, settings: settings)
        viewModel.selectUpgrade(upgrade)
    }

    private func selectStageReward(_ reward: StageReward) {
        audioManager.play(.chipGain, settings: settings)
        hapticsManager.play(.medium, settings: settings)
        viewModel.selectStageReward(reward)
    }

    private func selectBossReward(_ reward: BossReward) {
        audioManager.play(.upgradeSelection, settings: settings)
        hapticsManager.play(.success, settings: settings)
        viewModel.selectBossReward(reward)
    }

    private func continueToBoss() {
        hapticsManager.play(.heavy, settings: settings)
        viewModel.continueToBoss()
        updateMusicLayer()
    }

    private func startNewRun() {
        hapticsManager.play(.medium, settings: settings)
        selectedPage = .game
        viewModel.startNewRun()
        updateMusicLayer()
    }

    private func resetProfile() {
        hapticsManager.play(.failure, settings: settings)
        selectedPage = .game
        viewModel.resetProfile()
        isShowingTutorial = false
    }

    private func replayTutorial() {
        isShowingTutorial = true
    }

    private func completeTutorial(skipped: Bool) {
        viewModel.completeOnboarding(skipped: skipped)
        isShowingTutorial = false
    }

    private func handleRoundFeedback() {
        guard let result = viewModel.state.latestRound else {
            return
        }

        holdPostRoundScreensUntilResultReveal(for: result)

        if settings.isReduceMotionEnabled {
            if result.netCents > 0 {
                audioManager.play(.chipGain, settings: settings)
            } else if result.netCents < 0 {
                audioManager.play(.chipLoss, settings: settings)
            }
            return
        }

        let cardInterval = 0.18
        let resultRevealDelay = Double(dealCardCount(for: result)) * cardInterval + 0.52

        for index in 0..<dealCardCount(for: result) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * cardInterval) {
                audioManager.play(.cardDeal, settings: settings)
                hapticsManager.play(.light, settings: settings)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + resultRevealDelay) {
            if result.netCents > 0 {
                audioManager.play(viewModel.state.roundPresentation.winTier == .jackpot ? .jackpot : .chipGain, settings: settings)
            } else if result.netCents < 0 {
                audioManager.play(.chipLoss, settings: settings)
            }

            switch viewModel.state.roundPresentation.winTier {
            case .big:
                audioManager.play(.bigWin, settings: settings)
                hapticsManager.play(.medium, settings: settings)
            case .huge:
                audioManager.play(.bigWin, settings: settings)
                hapticsManager.play(.heavy, settings: settings)
                shake()
            case .jackpot:
                audioManager.play(.jackpot, settings: settings)
                hapticsManager.play(.success, settings: settings)
                shake(amount: 12)
            case .loss, .push, .normal:
                break
            }
        }
    }

    private func holdPostRoundScreensUntilResultReveal(for result: RoundResult) {
        guard !settings.isReduceMotionEnabled else {
            isResolvingRoundPresentation = false
            viewModel.completeDealPresentation(for: result.id)
            return
        }

        isResolvingRoundPresentation = true

        let cardInterval = 0.18
        let overlayDelay = Double(dealCardCount(for: result)) * cardInterval + 0.82

        DispatchQueue.main.asyncAfter(deadline: .now() + overlayDelay) {
            guard viewModel.state.latestRound?.id == result.id else {
                return
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                isResolvingRoundPresentation = false
            }

            viewModel.completeDealPresentation(for: result.id)
        }
    }

    private func dealCardCount(for result: RoundResult) -> Int {
        result.playerHand.cards.count + result.bankerHand.cards.count
    }

    private func updateMusicLayer() {
        let layer: MusicLayer

        if viewModel.state.runManager.status == .completed {
            layer = .victory
        } else if let boss = viewModel.state.bossManager.activeBoss ?? viewModel.state.bossManager.pendingAnnouncementBoss {
            layer = boss.id == Boss.house.id ? .finalBoss : .boss
        } else {
            layer = .normalRun
        }

        audioManager.transition(
            to: layer,
            settings: settings,
            themeID: viewModel.metaProgression.profile.selectedThemeID
        )
    }

    private func shake(amount: CGFloat = 8) {
        guard !settings.isReduceMotionEnabled else {
            return
        }

        withAnimation(.linear(duration: 0.42)) {
            shakeTrigger += 1
        }
    }
}

#Preview {
    ContentView()
}
