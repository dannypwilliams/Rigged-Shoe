import SwiftUI

enum CasinoRoom: String, CaseIterable, Identifiable, Hashable {
    case gameRoom
    case upgradeRoom
    case profileOffice
    case challengeRoom
    case themeLounge
    case collectionVault
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .gameRoom:
            return "Game Room"
        case .upgradeRoom:
            return "Upgrade Room"
        case .profileOffice:
            return "Profile Office"
        case .challengeRoom:
            return "Challenge Room"
        case .themeLounge:
            return "Theme Lounge"
        case .collectionVault:
            return "Collection Vault"
        case .settings:
            return "Settings"
        }
    }

    var description: String {
        switch self {
        case .gameRoom:
            return "Play baccarat rounds: choose a bet, then Deal."
        case .upgradeRoom:
            return "Understand your active upgrades, archetypes, and synergies."
        case .profileOffice:
            return "See permanent progress, currencies, stats, and unlocks."
        case .challengeRoom:
            return "Optional harder runs, daily seed, boss rush, and modifiers."
        case .themeLounge:
            return "Cosmetic casino looks and music flavor."
        case .collectionVault:
            return "Browse unlocked, locked, discovered, and defeated content."
        case .settings:
            return "Audio, haptics, accessibility, help, and reset."
        }
    }

    var purposeLabel: String {
        switch self {
        case .gameRoom:
            return "Play"
        case .upgradeRoom:
            return "Build"
        case .profileOffice:
            return "Progress"
        case .challengeRoom:
            return "Optional"
        case .themeLounge:
            return "Cosmetic"
        case .collectionVault:
            return "Collect"
        case .settings:
            return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .gameRoom:
            return "suit.club.fill"
        case .upgradeRoom:
            return "sparkles"
        case .profileOffice:
            return "person.crop.rectangle.stack.fill"
        case .challengeRoom:
            return "flag.checkered"
        case .themeLounge:
            return "paintpalette.fill"
        case .collectionVault:
            return "lock.rectangle.stack.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .gameRoom:
            return CasinoTheme.emerald
        case .upgradeRoom:
            return CasinoTheme.gold
        case .profileOffice:
            return CasinoTheme.neonBlue
        case .challengeRoom:
            return CasinoTheme.red
        case .themeLounge:
            return CasinoTheme.violet
        case .collectionVault:
            return Color(red: 0.92, green: 0.62, blue: 0.18)
        case .settings:
            return Color.white.opacity(0.82)
        }
    }
}

struct CasinoLobbyView: View {
    @ObservedObject var viewModel: GameViewModel
    let onSelectRoom: (CasinoRoom) -> Void
    let onShowGlossary: () -> Void
    let onShowSupport: () -> Void
    let onShowDebug: (() -> Void)?

    private var profile: PlayerProfile {
        viewModel.metaProgression.profile
    }

    private var isFirstTimePlayer: Bool {
        profile.totalBaccaratRounds == 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                lobbyHeader
                if isFirstTimePlayer {
                    firstTimePrompt
                }
                runStatusPanel
                roomGrid
                footer
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var lobbyHeader: some View {
        VStack(spacing: 12) {
            CasinoLightsView()

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rigged Shoe")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: CasinoTheme.gold.opacity(0.38), radius: 12)

                    Text(isFirstTimePlayer ? "Start at the table" : "Casino floor")
                        .font(.caption.weight(.black))
                        .foregroundStyle(CasinoTheme.gold.opacity(0.80))
                        .textCase(.uppercase)

                    Text(isFirstTimePlayer ? "Play one round first. The other rooms make more sense after you see the shoe deal." : "Choose a room, tune your build, then step back to the table.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer()

                HStack(spacing: 8) {
                    lobbyIconButton(systemImage: "info.circle.fill", action: onShowGlossary)
                    lobbyIconButton(systemImage: "testtube.2", action: onShowSupport)

                    if let onShowDebug {
                        lobbyIconButton(systemImage: "ladybug.fill", action: onShowDebug)
                    }
                }
            }
        }
    }

    private var firstTimePrompt: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.right.circle.fill")
                .font(.title2.weight(.black))
                .foregroundStyle(CasinoTheme.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text("First time here?")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Text("Enter the Game Room, pick Player, Banker, or Tie, then tap Deal. You can explore upgrades and collections after a hand or two.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CasinoTheme.gold.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.45), lineWidth: 1)
        )
    }

    private var runStatusPanel: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Current Run")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)

                    Text(viewModel.rewardProgressText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CasinoTheme.gold.opacity(0.72))
                }

                Spacer()

                Text(viewModel.state.challengeID.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(CasinoTheme.gold))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                CasinoMetricCard(title: "Bankroll", value: MoneyFormatter.format(viewModel.state.bankrollCents), accentColor: CasinoTheme.gold)
                CasinoMetricCard(title: "Stage", value: "\(viewModel.state.runManager.stageReached)", accentColor: CasinoTheme.emerald)
                CasinoMetricCard(title: "Objective", value: lobbyObjectiveValue, accentColor: CasinoTheme.neonBlue)
                CasinoMetricCard(title: "Target", value: lobbyTargetValue, accentColor: CasinoTheme.red)
            }
        }
        .padding(16)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 16)
    }

    private var lobbyObjectiveValue: String {
        let runManager = viewModel.state.runManager
        guard let objective = runManager.currentStage.teachingObjective else {
            return MoneyFormatter.signed(runManager.stageProfitCents(bankrollCents: viewModel.state.bankrollCents))
        }

        return objective.progressText(in: runManager, bankrollCents: viewModel.state.bankrollCents)
    }

    private var lobbyTargetValue: String {
        let stage = viewModel.state.runManager.currentStage
        if stage.targetProfitCents > 0 {
            return "+\(MoneyFormatter.format(stage.targetProfitCents))"
        }

        return stage.teachingObjective?.title ?? "Clear"
    }

    private var roomGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(CasinoRoom.allCases) { room in
                Button {
                    onSelectRoom(room)
                } label: {
                    LobbyRoomCard(room: room, isHighlighted: isFirstTimePlayer && room == .gameRoom)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footer: some View {
        HStack {
            CasinoMetricCard(title: "Chips", value: formatNumber(profile.casinoChips), accentColor: CasinoTheme.gold)
            CasinoMetricCard(title: "Reputation", value: formatNumber(profile.reputation), accentColor: CasinoTheme.neonBlue)
        }
    }

    private func lobbyIconButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Color.white.opacity(0.10)))
                .overlay(Circle().stroke(CasinoTheme.gold.opacity(0.24), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct GameRoomView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selectedPage: CasinoFloorPage
    let dealButtonTitle: String
    let dealGuidanceText: String
    let onDealRound: () -> Void
    let onBack: () -> Void

    @State private var displayedBankrollCents = RunManager.defaultStartingBankrollCents
    @State private var displayedBankrollDeltaCents = 0
    @State private var visibleDealStepCount = 0
    @State private var isResultRevealed = false
    @State private var isAnimatingDeal = false
    @State private var lastPresentedRoundID: UUID?
    @State private var helpTopic: UXHelpTopic?
    @State private var isShowingBattleLog = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            GameTableBackground()

            GeometryReader { proxy in
                let isCompact = proxy.size.height < 780

                VStack(spacing: 0) {
                    gameRoomTopBar(isCompact: isCompact)

                    VStack(spacing: isCompact ? 5 : 8) {
                        BaccaratTableSurface(
                            result: viewModel.state.latestRound,
                            cardsRemaining: viewModel.state.shoe.cardsRemaining,
                            previewCards: viewModel.state.shoe.previewCards(limit: viewModel.shoePreviewLimit),
                            shoeVisibility: viewModel.shoeVisibilityState,
                            isRevealSuppressed: viewModel.state.bossManager.suppressesReveal,
                            shoeImpact: viewModel.state.roundPresentation.shoeImpact,
                            visibleDealStepCount: visibleDealStepCount,
                            isResultRevealed: isResultRevealed,
                            isCompact: isCompact,
                            onShowHelp: { helpTopic = $0 }
                        )
                        .padding(.horizontal, 10)
                        .layoutPriority(3)

                        if !viewModel.shoeControlOptions.isEmpty {
                            ShoeControlStrip(
                                options: viewModel.shoeControlOptions,
                                isDisabled: isAnimatingDeal,
                                isCompact: isCompact,
                                onUse: viewModel.useShoeControl
                            )
                            .padding(.horizontal, 10)
                            .transition(.opacity)
                            .layoutPriority(1)
                        }

                        if !currentStageBattleLogEntries.isEmpty || !viewModel.state.roundPresentation.triggerFeedback.isEmpty {
                            BattleTriggerFeedView(
                                feedback: viewModel.state.roundPresentation.triggerFeedback,
                                latestEntries: Array(currentStageBattleLogEntries.prefix(isCompact ? 2 : 3)),
                                triggerID: viewModel.state.roundPresentation.sequenceID,
                                isCompact: isCompact,
                                onOpenLog: { isShowingBattleLog = true }
                            )
                            .padding(.horizontal, 10)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .layoutPriority(1)
                        }

                        if !isCompact && (viewModel.state.latestRound != nil || isAnimatingDeal) {
                            CurrentResultStrip(
                                result: viewModel.state.latestRound,
                                presentation: viewModel.state.roundPresentation,
                                payoutRules: viewModel.currentPayoutRules,
                                selectedBetType: viewModel.state.selectedBetType,
                                selectedBetAmountCents: viewModel.state.selectedBetAmountCents,
                                isResultRevealed: isResultRevealed,
                                isAnimatingDeal: isAnimatingDeal,
                                isCompact: isCompact
                            )
                            .padding(.horizontal, 10)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                            .layoutPriority(1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, isCompact ? 4 : 6)
                    .padding(.bottom, isCompact ? 4 : 8)
                    .layoutPriority(1)

                    GameRoomBetDock(
                        selectedBetType: viewModel.state.selectedBetType,
                        selectedBetAmountCents: viewModel.state.selectedBetAmountCents,
                        bankrollCents: displayedBankrollCents,
                        betAmountsCents: visibleBetAmounts,
                        allowedBetTypes: allowedBetTypes,
                        payoutRules: viewModel.currentPayoutRules,
                        dealButtonTitle: isAnimatingDeal || viewModel.isDealResolutionLocked ? "Reviewing hand..." : dealButtonTitle,
                        dealGuidanceText: isAnimatingDeal || viewModel.isDealResolutionLocked ? "Reviewing hand result. Next action appears after the hand settles." : dealGuidanceText,
                        rewardProgressText: dockStatusText,
                        canDeal: viewModel.canDeal && !isAnimatingDeal,
                        isReviewingHand: isAnimatingDeal || viewModel.isDealResolutionLocked,
                        isGuidedOpeningHandLocked: viewModel.isGuidedOpeningHandLocked,
                        revealBetCapCents: viewModel.activeRevealBetCapCents,
                        isCompact: isCompact,
                        currentStage: viewModel.state.runManager.stageReached,
                        unlockStageForBetAmount: viewModel.unlockStage(forBetAmountCents:),
                        isBetAmountPlayable: viewModel.isBetAmountPlayable,
                        onSelectBetType: viewModel.selectBetType,
                        onSelectBetAmount: viewModel.selectBetAmount,
                        onDeal: onDealRound,
                        onShowHelp: { helpTopic = $0 }
                    )
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom, CGFloat(isCompact ? 6 : 8)))
                    .background(Color.black.opacity(0.34).ignoresSafeArea(edges: .bottom))
                    .layoutPriority(3)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $helpTopic) { topic in
            ContextHelpSheet(topic: topic)
        }
        .sheet(isPresented: $isShowingBattleLog) {
            BattleLogSheet(
                entries: viewModel.state.battleLog,
                debugEvents: viewModel.state.debugGameEventLog
            )
        }
        .onAppear {
            synchronizePresentationToCurrentRound()
        }
        .onChange(of: viewModel.state.latestRound?.id) { _, newValue in
            guard newValue != nil else {
                synchronizePresentationToCurrentRound()
                return
            }

            startDealPresentation()
        }
        .onChange(of: viewModel.state.bankrollCents) { _, newValue in
            guard !isAnimatingDeal else {
                return
            }

            withAnimation(.easeOut(duration: 0.24)) {
                displayedBankrollCents = newValue
                displayedBankrollDeltaCents = viewModel.state.roundPresentation.bankrollDeltaCents
            }
        }
    }

    private var visibleBetAmounts: [Int] {
        let currentStage = viewModel.state.runManager.stageReached
        let currentStageAmounts = viewModel.state.runManager.currentStage.betLimit.allowedBetAmountsCents.sorted()
        let nextLockedAmount = viewModel.betAmountsCents.first {
            !currentStageAmounts.contains($0)
                && viewModel.unlockStage(forBetAmountCents: $0) > currentStage
        }

        if let nextLockedAmount {
            return currentStageAmounts + [nextLockedAmount]
        }

        return currentStageAmounts
    }

    private var currentStageBattleLogEntries: [BattleLogEntry] {
        viewModel.state.battleLog.filter { $0.stageNumber == viewModel.state.runManager.stageReached }
    }

    private var dockStatusText: String {
        if isAnimatingDeal && !isResultRevealed {
            return "Dealing from the shoe"
        }

        if isResultRevealed, let result = viewModel.state.latestRound {
            let outcome = "\(result.winnerText) \(MoneyFormatter.signed(result.netCents))"
            if !viewModel.state.roundPresentation.payoutLedgerSummary.isEmpty {
                return "\(outcome) · \(viewModel.state.roundPresentation.payoutLedgerSummary)"
            }

            if let message = viewModel.state.roundPresentation.upgradeMessages.first {
                return "\(outcome) · \(message)"
            }

            return outcome
        }

        if let guidedOpeningHandNotice = viewModel.guidedOpeningHandNotice {
            return guidedOpeningHandNotice
        }

        return viewModel.rewardProgressText
    }

    private var allowedBetTypes: Set<BetType> {
        if viewModel.isGuidedOpeningHandLocked {
            return [.player]
        }

        return Set(BetType.allCases.filter { viewModel.state.challengeID.allowsBet($0) })
    }

    private func gameRoomTopBar(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 4 : 6) {
            HStack(spacing: 10) {
                RunCurrencyStrip(runManager: viewModel.state.runManager, compact: true)

                Spacer(minLength: 0)

                Button {
                    helpTopic = .gameInfo
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.gold)
                        .frame(width: 25, height: 25)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                        .overlay(Circle().stroke(CasinoTheme.gold.opacity(0.20), lineWidth: 1))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("game-info-button")
                .accessibilityLabel("Game Info")
                .accessibilityHint("Shows rules, payouts, commission, and shoe help")

                Button {
                    isShowingBattleLog = true
                } label: {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.emerald)
                        .frame(width: 25, height: 25)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                        .overlay(Circle().stroke(CasinoTheme.emerald.opacity(0.24), lineWidth: 1))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Battle Log")
                .accessibilityHint("Shows hand history, payouts, modifier triggers, Heat, and Chips")

                CompactRoomRail(selectedPage: $selectedPage)
            }

            CompactGameStatusBar(
                runManager: viewModel.state.runManager,
                bankrollCents: displayedBankrollCents,
                deltaCents: displayedBankrollDeltaCents
            )
        }
        .padding(.horizontal, 12)
        .padding(.top, isCompact ? 3 : 6)
    }

    private func synchronizePresentationToCurrentRound() {
        displayedBankrollCents = viewModel.state.bankrollCents
        displayedBankrollDeltaCents = viewModel.state.roundPresentation.bankrollDeltaCents
        isAnimatingDeal = false

        if let result = viewModel.state.latestRound {
            lastPresentedRoundID = result.id
            visibleDealStepCount = baccaratDealSteps(for: result).count
            isResultRevealed = true
        } else {
            lastPresentedRoundID = nil
            visibleDealStepCount = 0
            isResultRevealed = false
        }
    }

    private func startDealPresentation() {
        guard let result = viewModel.state.latestRound,
              result.id != lastPresentedRoundID else {
            return
        }

        let steps = baccaratDealSteps(for: result)
        lastPresentedRoundID = result.id
        displayedBankrollDeltaCents = 0

        if reduceMotion {
            visibleDealStepCount = steps.count
            isResultRevealed = true
            displayedBankrollCents = viewModel.state.bankrollCents
            displayedBankrollDeltaCents = viewModel.state.roundPresentation.bankrollDeltaCents
            isAnimatingDeal = false
            return
        }

        isAnimatingDeal = true
        isResultRevealed = false
        visibleDealStepCount = 0

        for index in steps.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.18) {
                guard lastPresentedRoundID == result.id else {
                    return
                }

                withAnimation(.easeOut(duration: 0.12)) {
                    visibleDealStepCount = index + 1
                }
            }
        }

        let revealDelay = Double(steps.count) * 0.18 + 0.52
        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
            guard lastPresentedRoundID == result.id else {
                return
            }

            withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                isResultRevealed = true
                displayedBankrollCents = viewModel.state.bankrollCents
                displayedBankrollDeltaCents = viewModel.state.roundPresentation.bankrollDeltaCents
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay + 0.30) {
            guard lastPresentedRoundID == result.id else {
                return
            }

            isAnimatingDeal = false
        }
    }
}

private struct CompactRoomRail: View {
    @Binding var selectedPage: CasinoFloorPage

    var body: some View {
        HStack(spacing: 6) {
            ForEach(CasinoFloorPage.allCases) { page in
                let isSelected = page == selectedPage

                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                        selectedPage = page
                    }
                } label: {
                    HStack(spacing: isSelected ? 4 : 0) {
                        Image(systemName: page.iconName)
                            .font(.system(size: isSelected ? 9 : 10, weight: .black, design: .rounded))

                        if isSelected {
                            Text(page.shortTitle)
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
                            .fill(isSelected ? page.accentColor : Color.white.opacity(0.08))
                    )
                    .overlay(
                        Capsule()
                            .stroke(page.accentColor.opacity(isSelected ? 0.30 : 0.16), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go to \(page.title)")
                .accessibilityHint("Switches casino floor page")
            }
        }
    }
}

private enum BaccaratDealOwner: String, Equatable {
    case player
    case banker
}

private enum UXHelpTopic: String, Identifiable {
    case gameInfo
    case baccarat
    case shoe
    case reveal
    case bossEffects
    case tiePayout
    case bankerCommission
    case stageTarget
    case challenges
    case permanentProgress

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .gameInfo:
            return "Game Info"
        case .baccarat:
            return "Baccarat Basics"
        case .shoe:
            return "Dealer Shoe"
        case .reveal:
            return "Reveal Effects"
        case .bossEffects:
            return "Boss Effects"
        case .tiePayout:
            return "Tie Payout"
        case .bankerCommission:
            return "Banker Commission"
        case .stageTarget:
            return "Stage Objectives"
        case .challenges:
            return "Optional Challenges"
        case .permanentProgress:
            return "Permanent Progress"
        }
    }

    var summary: String {
        switch self {
        case .gameInfo:
            return "Release route, table rules, payouts, Chips, Heat, and the opening lock."
        case .baccarat:
            return "Player and Banker are the two baccarat hands. You bet which hand wins, or bet Tie."
        case .shoe:
            return "The shoe is the live stack of cards. Rigged Shoe is about changing what is inside it."
        case .reveal:
            return "Reveal upgrades show controlled shoe information inside the Rigged Shoe window."
        case .bossEffects:
            return "Bosses are temporary casino rules that attack your build for one stage."
        case .tiePayout:
            return "Tie is rare but pays more. It starts at 8:1 and upgrades can raise it."
        case .bankerCommission:
            return "Banker wins usually pay 0.95:1 because the Banker hand has a small built-in edge."
        case .stageTarget:
            return "Early stages can clear through teaching objectives or profit. Later stages lean harder on money pressure."
        case .challenges:
            return "Challenges are optional. Standard is the normal mode and is best for learning."
        case .permanentProgress:
            return "Profile rewards unlock more future options, but you can learn the table without touching them."
        }
    }

    var bullets: [String] {
        switch self {
        case .gameInfo:
            return [
                "Stay solvent until the hand count ends.",
                "Stage 1 lasts 5 hands.",
                "Stage 2 lasts 6 hands.",
                "Stage 1 wagers are $25, $50, and $75.",
                "Stage 2 wagers are $50 and $100.",
                "The guided first hand locks Player $25.",
                "All legal bets unlock after it.",
                "Tie results push Player/Banker for $0.",
                "Tie bets pay 8:1.",
                "Banker normally pays 0.95:1.",
                "Stage 2 No Commission Night pays 1:1.",
                "Chips buy shop offers or rerolls.",
                "Heat changes only from visible rules."
            ]
        case .baccarat:
            return [
                "Cards total to the ones digit only. A 17 counts as 7.",
                "Closest hand to 9 wins.",
                "The game draws extra cards automatically using baccarat rules."
            ]
        case .shoe:
            return [
                "Cards are dealt from the shoe at the top of the table.",
                "Adding or removing cards changes future odds.",
                "The card count shows how many cards remain before a reshuffle."
            ]
        case .reveal:
            return [
                "Peek and Read the Shoe give small hints without solving the hand.",
                "X-Ray and Full X-Ray are charged reads with bet caps while active.",
                "Obscured cards such as ?? are intentional uncertainty, not a broken card.",
                "Some bosses temporarily lock reveal information."
            ]
        case .bossEffects:
            return [
                "Bosses appear on scheduled stages.",
                "Their rules only last during that boss stage.",
                "Defeat the stage target to restore your build."
            ]
        case .tiePayout:
            return [
                "Tie bets lose when Player or Banker wins.",
                "A Tie result pushes Player and Banker bets.",
                "Tie upgrades use the best payout unlocked, not every payout added together."
            ]
        case .bankerCommission:
            return [
                "Banker bets are strong, so normal Banker wins pay 95 percent profit.",
                "No Commission removes that tax unless a boss restores it.",
                "The final boss can force commission back on."
            ]
        case .stageTarget:
            return [
                "Early stages use learning objectives, not only profit targets.",
                "Stage profit is current bankroll minus the bankroll you had when this stage began.",
                "Rounds remaining count down after each completed hand.",
                "If rounds hit zero before an objective or target is complete, the run ends."
            ]
        case .challenges:
            return [
                "Leave Standard selected while learning.",
                "Challenge restrictions apply to future runs.",
                "Harder challenges can award more permanent Chips."
            ]
        case .permanentProgress:
            return [
                "Chips and Reputation survive between runs.",
                "Unlocks add more options to future runs.",
                "None of this is required to play a baccarat hand."
            ]
        }
    }
}

private struct ContextHelpButton: View {
    let title: String
    let topic: UXHelpTopic
    let onTap: (UXHelpTopic) -> Void

    var body: some View {
        Button {
            onTap(topic)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "questionmark.circle.fill")
                Text(title)
            }
            .font(.caption2.weight(.black))
            .foregroundStyle(CasinoTheme.gold)
            .textCase(.uppercase)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Capsule().fill(CasinoTheme.gold.opacity(0.12)))
            .overlay(Capsule().stroke(CasinoTheme.gold.opacity(0.24), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ContextHelpSheet: View {
    let topic: UXHelpTopic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(topic.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                                .frame(minHeight: 31, alignment: .center)

                            Text(topic.summary)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.66))
                                .lineLimit(4)
                                .minimumScaleFactor(0.82)
                                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.10)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("game-info-close-button")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(topic.bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 9) {
                                Circle()
                                    .fill(CasinoTheme.gold)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                Text(bullet)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.72))
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.82)
                                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, minHeight: 34, alignment: .topLeading)
                        }
                    }
                    .padding(14)
                    .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.18, cornerRadius: 14)

                    Spacer(minLength: 12)
                }
                .padding(20)
            }
            .accessibilityIdentifier("game-info-sheet")
        }
        .presentationDetents([.medium, .large])
    }
}

private struct BaccaratDealStep: Identifiable, Equatable {
    let owner: BaccaratDealOwner
    let card: Card
    let sequenceIndex: Int

    var id: String {
        "\(owner.rawValue)-\(sequenceIndex)-\(card.id.uuidString)"
    }
}

private func baccaratDealSteps(for result: RoundResult?) -> [BaccaratDealStep] {
    guard let result else {
        return []
    }

    var steps: [BaccaratDealStep] = []

    func append(owner: BaccaratDealOwner, cardIndex: Int) {
        let cards = owner == .player ? result.playerHand.cards : result.bankerHand.cards
        guard cards.indices.contains(cardIndex) else {
            return
        }

        steps.append(
            BaccaratDealStep(
                owner: owner,
                card: cards[cardIndex],
                sequenceIndex: steps.count
            )
        )
    }

    append(owner: .player, cardIndex: 0)
    append(owner: .banker, cardIndex: 0)
    append(owner: .player, cardIndex: 1)
    append(owner: .banker, cardIndex: 1)
    append(owner: .player, cardIndex: 2)
    append(owner: .banker, cardIndex: 2)

    return steps
}

private struct GameTableBackground: View {
    var body: some View {
        ZStack {
            CrookedCasinoTheme.tableBackground
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.34)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            DoodleAccentView(accent: CrookedCasinoTheme.dirtyGold.opacity(0.55), density: .medium)
                .ignoresSafeArea()
                .opacity(0.30)
        }
    }
}

private struct CompactGameStatusBar: View {
    let runManager: RunManager
    let bankrollCents: Int
    let deltaCents: Int

    private var objectiveText: String {
        if let objective = runManager.currentStage.teachingObjective {
            return "Objective: \(objective.progressText(in: runManager, bankrollCents: bankrollCents))"
        }

        return "Objective: \(MoneyFormatter.signed(runManager.stageProfitCents(bankrollCents: bankrollCents))) / +\(MoneyFormatter.format(runManager.currentStage.targetProfitCents))"
    }

    private var handText: String {
        let nextHand = min(runManager.currentStageRoundsPlayed + 1, runManager.currentRoundLimit)
        return "Stage \(runManager.stageReached) - Hand \(max(1, nextHand)) of \(runManager.currentRoundLimit)"
    }

    private var deltaText: String {
        deltaCents == 0 ? "" : MoneyFormatter.signed(deltaCents)
    }

    private var deltaColor: Color {
        if deltaCents > 0 {
            return CasinoTheme.emerald
        }

        if deltaCents < 0 {
            return CasinoTheme.red
        }

        return .white.opacity(0.45)
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 6) {
                Text(handText)
                    .foregroundStyle(CasinoTheme.gold)

                Text("·")
                    .foregroundStyle(.white.opacity(0.28))

                Text(MoneyFormatter.format(bankrollCents))
                    .foregroundStyle(.white)

                Text("·")
                    .foregroundStyle(.white.opacity(0.28))

                Text("\(runManager.roundsRemaining) left")
                    .foregroundStyle(.white.opacity(0.70))

                Spacer(minLength: 4)

                if !deltaText.isEmpty {
                    Text(deltaText)
                        .foregroundStyle(deltaColor)
                }
            }
            .font(.system(size: 12, weight: .black, design: .rounded).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.72)

            HStack(spacing: 8) {
                Text(objectiveText)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Spacer(minLength: 0)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(CasinoTheme.gold)
                        .frame(width: geometry.size.width * CGFloat(runManager.combinedStageProgress(bankrollCents: bankrollCents)))
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.16), lineWidth: 1)
        )
    }
}

private struct CompactStageTableHUD: View {
    let runManager: RunManager
    let bankrollCents: Int

    private var profitCents: Int {
        runManager.stageProfitCents(bankrollCents: bankrollCents)
    }

    private var teachingObjective: StageObjective? {
        runManager.currentStage.teachingObjective
    }

    private var compactGoalTitle: String {
        teachingObjective?.title ?? "Stage Profit"
    }

    private var compactGoalValue: String {
        guard let teachingObjective else {
            return "\(MoneyFormatter.signed(profitCents)) / +\(MoneyFormatter.format(runManager.currentStage.targetProfitCents))"
        }

        return teachingObjective.progressText(in: runManager, bankrollCents: bankrollCents)
    }

    private var compactProfitAlternativeText: String {
        guard runManager.currentStage.targetProfitCents > 0 else {
            return ""
        }

        return "+\(MoneyFormatter.format(runManager.currentStage.targetProfitCents)) profit"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Stage \(runManager.stageReached)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.gold)
                    .textCase(.uppercase)

                Text("\(runManager.roundsRemaining) rounds left")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.68))
            }

            HStack(spacing: 5) {
                Text(compactGoalTitle)
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white.opacity(0.44))
                    .textCase(.uppercase)

                Text(compactGoalValue)
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(.white)

                if teachingObjective != nil && runManager.currentStage.targetProfitCents > 0 {
                    Text("or")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(CasinoTheme.gold.opacity(0.72))
                        .textCase(.uppercase)

                    Text(compactProfitAlternativeText)
                        .font(.caption2.monospacedDigit().weight(.black))
                        .foregroundStyle(.white.opacity(0.70))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }
            .lineLimit(1)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.13))

                    Capsule()
                        .fill(CasinoTheme.gold)
                        .frame(width: geometry.size.width * CGFloat(runManager.combinedStageProgress(bankrollCents: bankrollCents)))
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.32))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.20), lineWidth: 1)
        )
    }
}

private struct BankrollPill: View {
    let bankrollCents: Int
    let deltaCents: Int

    private var deltaColor: Color {
        if deltaCents > 0 {
            return CasinoTheme.emerald
        }

        if deltaCents < 0 {
            return CasinoTheme.red
        }

        return .white.opacity(0.48)
    }

    var body: some View {
        HStack(spacing: 8) {
            CrookedChipView(valueText: "$", size: 34, tone: .gold)

            VStack(alignment: .trailing, spacing: 3) {
                Text("Bankroll")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.46))
                    .textCase(.uppercase)

                Text(MoneyFormatter.format(bankrollCents))
                    .font(.headline.monospacedDigit().weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                Text(deltaCents == 0 ? "No change" : MoneyFormatter.signed(deltaCents))
                    .font(.caption2.monospacedDigit().weight(.black))
                    .foregroundStyle(deltaColor)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .crookedPanel(kind: .felt, strokeColor: deltaColor.opacity(0.74), cornerRadius: 12)
    }
}

private struct BaccaratTableSurface: View {
    let result: RoundResult?
    let cardsRemaining: Int
    let previewCards: [Card]
    let shoeVisibility: ShoeVisibilityState
    let isRevealSuppressed: Bool
    let shoeImpact: ShoeImpact
    let visibleDealStepCount: Int
    let isResultRevealed: Bool
    var isCompact = false
    let onShowHelp: (UXHelpTopic) -> Void

    private var dealSteps: [BaccaratDealStep] {
        baccaratDealSteps(for: result)
    }

    private var visibleSteps: ArraySlice<BaccaratDealStep> {
        dealSteps.prefix(visibleDealStepCount)
    }

    var body: some View {
        VStack(spacing: isCompact ? 7 : 10) {
            ShoeView(
                cardsRemaining: cardsRemaining,
                previewCards: previewCards,
                visibility: shoeVisibility,
                isRevealSuppressed: isRevealSuppressed,
                shoeImpact: shoeImpact,
                dealTrigger: result?.id,
                dealCardCount: dealCardCount,
                isCompact: isCompact
            )

            Text(tableStateText)
                .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(1)

            ZStack {
                HStack(alignment: .top, spacing: isCompact ? 8 : 12) {
                    TableHandZone(
                        title: "Player",
                        accentColor: CasinoTheme.neonBlue,
                        cards: visibleCards(for: .player),
                        total: isResultRevealed ? result?.playerHand.total : nil,
                        isWinner: isResultRevealed && isWinningHand(.player),
                        isDimmed: isResultRevealed && isDimmedHand(.player),
                        dealOriginOffset: CGSize(width: 64, height: -168),
                        isCompact: isCompact
                    )

                    TableHandZone(
                        title: "Banker",
                        accentColor: CasinoTheme.red,
                        cards: visibleCards(for: .banker),
                        total: isResultRevealed ? result?.bankerHand.total : nil,
                        isWinner: isResultRevealed && isWinningHand(.banker),
                        isDimmed: isResultRevealed && isDimmedHand(.banker),
                        dealOriginOffset: CGSize(width: -64, height: -168),
                        isCompact: isCompact
                    )
                }

                if isResultRevealed, let naturalText {
                    NaturalCalloutView(text: naturalText)
                        .offset(y: -48)
                        .transition(.scale(scale: 0.84).combined(with: .opacity))
                }

                if isResultRevealed,
                   let result,
                   result.winner == .tie {
                    TieCalloutView(
                        isBetHit: result.betType == .tie,
                        trigger: result.id
                    )
                    .offset(y: 16)
                    .transition(.scale(scale: 0.78).combined(with: .opacity))
                }
            }
        }
        .padding(isCompact ? 10 : 14)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: isCompact ? 22 : 28)
    }

    private var dealCardCount: Int {
        dealSteps.count
    }

    private var tableStateText: String {
        if visibleDealStepCount > 0 && !isResultRevealed {
            return "Current hand dealing"
        }

        if isResultRevealed && result != nil {
            return "Last hand result"
        }

        return "Next hand"
    }

    private func visibleCards(for owner: BaccaratDealOwner) -> [Card] {
        visibleSteps
            .filter { $0.owner == owner }
            .map(\.card)
    }

    private func isWinningHand(_ owner: BaccaratDealOwner) -> Bool {
        guard let winner = result?.winner else {
            return false
        }

        if winner == .tie {
            return true
        }

        return (owner == .player && winner == .player) || (owner == .banker && winner == .banker)
    }

    private func isDimmedHand(_ owner: BaccaratDealOwner) -> Bool {
        guard let winner = result?.winner,
              winner != .tie else {
            return false
        }

        return (owner == .player && winner == .banker) || (owner == .banker && winner == .player)
    }

    private var naturalText: String? {
        guard let result,
              result.playerHand.isNatural || result.bankerHand.isNatural else {
            return nil
        }

        if result.playerHand.isNatural && result.bankerHand.isNatural {
            return "Double Natural"
        }

        return result.playerHand.isNatural ? "Player Natural" : "Banker Natural"
    }
}

private struct DealerShoeTableView: View {
    let cardsRemaining: Int
    let previewCards: [Card]
    let revealedCount: Int
    let shoeImpact: ShoeImpact

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black.opacity(0.42))
                        .frame(height: 96)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(CasinoTheme.gold.opacity(0.48), lineWidth: 2)
                        )

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CasinoTheme.feltDark)
                        .frame(width: 164, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(CasinoTheme.gold.opacity(0.38), lineWidth: 1)
                        )
                        .offset(x: 44, y: -4)

                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(red: 0.07, green: 0.05, blue: 0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(CasinoTheme.gold.opacity(0.44), lineWidth: 1)
                            )
                            .frame(width: 54, height: 72)
                            .offset(x: CGFloat(index) * 9 - 46, y: CGFloat(index) * -2 + 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .scaleEffect(pulse ? 1.018 : 1.0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Shoe")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)

                    Text("\(cardsRemaining)")
                        .font(.title2.monospacedDigit().weight(.black))
                        .foregroundStyle(CasinoTheme.gold)

                    Text("cards left")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.50))
                        .textCase(.uppercase)
                }
                .frame(width: 76, alignment: .trailing)
            }

            HStack(spacing: 7) {
                ForEach(Array(previewCards.prefix(8).enumerated()), id: \.element.id) { index, card in
                    CardView(card: card, isFaceDown: index >= revealedCount)
                        .frame(width: 29)
                }

                if previewCards.isEmpty {
                    Text("Shuffle before next round")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.54))
                }
            }

            HStack(spacing: 8) {
                if revealedCount > 0 {
                    tablePill("Reveal \(min(revealedCount, previewCards.count))", color: CasinoTheme.gold)
                }

                if let message = shoeImpact.message {
                    tablePill(message, color: shoeImpact.isPositive ? CasinoTheme.emerald : CasinoTheme.red)
                }
            }
        }
        .onChange(of: shoeImpact) { _, newValue in
            guard newValue != .none else {
                return
            }

            withAnimation(.spring(response: 0.24, dampingFraction: 0.55)) {
                pulse = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                withAnimation(.easeOut(duration: 0.20)) {
                    pulse = false
                }
            }
        }
    }

    private func tablePill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .textCase(.uppercase)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.13)))
    }
}

private struct TableHandZone: View {
    let title: String
    let accentColor: Color
    let cards: [Card]
    let total: Int?
    let isWinner: Bool
    let isDimmed: Bool
    let dealOriginOffset: CGSize
    var isCompact = false

    var body: some View {
        VStack(spacing: isCompact ? 7 : 10) {
            HStack {
                Text(title)
                    .font(.system(size: isCompact ? 12 : 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(height: isCompact ? 17 : 22, alignment: .center)
                    .accessibilityHidden(true)

                Spacer()

                Text(total.map { "\($0)" } ?? "--")
                    .font(.system(size: isCompact ? 13 : 20, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(total == nil ? .white.opacity(0.32) : CasinoTheme.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: isCompact ? 30 : 36, height: isCompact ? 30 : 36)
                    .background(Circle().fill(Color.black.opacity(0.24)))
                    .accessibilityHidden(true)
            }

            HStack(spacing: isCompact ? -16 : -12) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    AnimatedCardView(
                        card: card,
                        isWinner: isWinner,
                        isDimmed: isDimmed,
                        originOffset: dealOriginOffset,
                        landingRotation: Double(index - 1) * 3.4
                    )
                    .frame(width: isCompact ? 48 : 60)
                }

                ForEach(0..<max(0, 3 - cards.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .frame(width: isCompact ? 44 : 58)
                        .aspectRatio(0.68, contentMode: .fit)
                }
            }
            .frame(maxWidth: .infinity, minHeight: isCompact ? 70 : 92, alignment: .center)
        }
        .padding(isCompact ? 9 : 12)
        .crookedPanel(kind: .felt, strokeColor: (isWinner ? CrookedCasinoTheme.dirtyGold : accentColor), cornerRadius: isCompact ? 14 : 18)
        .shadow(color: isWinner ? CasinoTheme.gold.opacity(0.22) : .clear, radius: isWinner ? 16 : 0)
        .opacity(isDimmed ? 0.72 : 1.0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts = ["\(title) hand"]
        if let total {
            parts.append("total \(total)")
        } else {
            parts.append("no total yet")
        }
        if cards.isEmpty {
            parts.append("no cards dealt")
        } else {
            parts.append(cards.map { "\($0.rank.shortName) \($0.suit.symbol)" }.joined(separator: ", "))
        }
        if isWinner {
            parts.append("winner")
        }
        return parts.joined(separator: ", ")
    }
}

private struct NaturalCalloutView: View {
    let text: String

    @State private var pulse = false

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(.black)
            .textCase(.uppercase)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(Capsule().fill(CasinoTheme.gold))
            .overlay(Capsule().stroke(.white.opacity(0.38), lineWidth: 1))
            .shadow(color: CasinoTheme.gold.opacity(pulse ? 0.72 : 0.36), radius: pulse ? 18 : 10)
            .scaleEffect(pulse ? 1.04 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.44).repeatCount(2, autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

private struct TieCalloutView: View {
    let isBetHit: Bool
    let trigger: UUID

    @State private var pop = false

    var body: some View {
        ZStack {
            if isBetHit {
                ParticleBurstView(
                    trigger: trigger,
                    color: CasinoTheme.gold,
                    secondaryColor: CasinoTheme.red,
                    count: 34,
                    intensity: 0.92
                )
            }

            VStack(spacing: 2) {
                Text(isBetHit ? "Tie Hit" : "Tie")
                    .font(.system(size: isBetHit ? 28 : 23, weight: .black, design: .rounded))
                    .foregroundStyle(isBetHit ? .black : CasinoTheme.gold)
                    .textCase(.uppercase)

                if isBetHit {
                    Text("Rare payout")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.black.opacity(0.66))
                        .textCase(.uppercase)
                }
            }
            .padding(.horizontal, isBetHit ? 22 : 17)
            .padding(.vertical, isBetHit ? 12 : 9)
            .background(
                Capsule()
                    .fill(isBetHit ? CasinoTheme.gold : Color.black.opacity(0.78))
            )
            .overlay(
                Capsule()
                    .stroke(isBetHit ? .white.opacity(0.45) : CasinoTheme.gold.opacity(0.62), lineWidth: 1)
            )
            .shadow(color: CasinoTheme.gold.opacity(isBetHit ? 0.70 : 0.38), radius: isBetHit ? 22 : 12)
            .scaleEffect(pop ? 1.0 : 0.72)
        }
        .onAppear {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.62)) {
                pop = true
            }
        }
    }
}

private struct BattleTriggerFeedView: View {
    let feedback: [ModifierTriggerFeedback]
    let latestEntries: [BattleLogEntry]
    let triggerID: UUID
    var isCompact = false
    let onOpenLog: () -> Void

    @State private var pulse = false

    private var visibleFeedback: [ModifierTriggerFeedback] {
        Array(feedback.prefix(isCompact ? 2 : 4))
    }

    var body: some View {
        HStack(spacing: 7) {
            Button(action: onOpenLog) {
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.rectangle.fill")
                    Text("Log")
                }
                .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.gold)
                .padding(.horizontal, 8)
                .frame(height: isCompact ? 26 : 30)
                .background(Capsule().fill(Color.black.opacity(0.36)))
                .overlay(Capsule().stroke(CasinoTheme.gold.opacity(0.24), lineWidth: 1))
            }
            .buttonStyle(.plain)

            if !visibleFeedback.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(visibleFeedback) { item in
                            ModifierTriggerPill(feedback: item, isCompact: isCompact)
                                .scaleEffect(pulse ? 1.0 : 0.96)
                                .opacity(pulse ? 1.0 : 0.76)
                        }
                    }
                    .padding(.vertical, 1)
                }
            } else {
                HStack(spacing: 6) {
                    ForEach(latestEntries) { entry in
                        RecentBattleLogChip(entry: entry, isCompact: isCompact)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: isCompact ? 30 : 36)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.24))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            animatePulse()
        }
        .onChange(of: triggerID) { _, _ in
            animatePulse()
        }
    }

    private func animatePulse() {
        pulse = false
        withAnimation(.spring(response: 0.26, dampingFraction: 0.62)) {
            pulse = true
        }
    }
}

private struct ModifierTriggerPill: View {
    let feedback: ModifierTriggerFeedback
    var isCompact = false

    private var color: Color {
        switch feedback.kind {
        case .boss, .heat:
            return CasinoTheme.red
        case .chips, .payout, .modifier:
            return CasinoTheme.gold
        case .reveal, .shoe:
            return CasinoTheme.neonBlue
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: feedback.kind.iconName)
                .font(.system(size: isCompact ? 8 : 9, weight: .black))

            Text(feedback.title)
                .lineLimit(1)

            if let displayAmount = feedback.displayAmount {
                Text(displayAmount)
                    .monospacedDigit()
                    .foregroundStyle(amountColor)
            }
        }
        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .frame(height: isCompact ? 24 : 28)
        .background(Capsule().fill(color.opacity(0.18)))
        .overlay(Capsule().stroke(color.opacity(0.50), lineWidth: 1))
        .shadow(color: color.opacity(0.24), radius: 8, y: 3)
        .accessibilityLabel("\(feedback.title), \(feedback.detail)")
    }

    private var amountColor: Color {
        guard let amount = feedback.amountCents else {
            return .white
        }

        return amount >= 0 ? CasinoTheme.emerald : CasinoTheme.red
    }
}

private struct RecentBattleLogChip: View {
    let entry: BattleLogEntry
    var isCompact = false

    var body: some View {
        HStack(spacing: 4) {
            Text("S\(entry.stageNumber) H\(entry.stageHandNumber)")
                .foregroundStyle(CasinoTheme.gold)
            Text(entry.outcomeText)
                .foregroundStyle(.white)
            Text(MoneyFormatter.signed(entry.finalBankrollChangeCents))
                .foregroundStyle(entry.finalBankrollChangeCents >= 0 ? CasinoTheme.emerald : CasinoTheme.red)
                .monospacedDigit()
        }
        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
        .lineLimit(1)
        .padding(.horizontal, 8)
        .frame(height: isCompact ? 24 : 28)
        .background(Capsule().fill(Color.white.opacity(0.07)))
        .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}

private struct BattleLogSheet: View {
    let entries: [BattleLogEntry]
    let debugEvents: [String]
    @Environment(\.dismiss) private var dismiss
#if DEBUG
    @State private var showsDebugEvents = false
#endif

    var body: some View {
        NavigationStack {
            ZStack {
                GameTableBackground()

                if entries.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(CasinoTheme.gold)
                        Text("No hands logged yet")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        Text("Deal a hand to see payouts, modifier triggers, Heat, Chips, and shoe effects here.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.62))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(entries) { entry in
                                BattleLogEntryCard(entry: entry)
                            }

#if DEBUG
                            if !debugEvents.isEmpty {
                                Button {
                                    showsDebugEvents.toggle()
                                } label: {
                                    Label(
                                        showsDebugEvents ? "Hide Developer Events" : "Show Developer Events",
                                        systemImage: showsDebugEvents ? "ladybug.slash.fill" : "ladybug.fill"
                                    )
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(CasinoTheme.neonBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black.opacity(0.30)))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(CasinoTheme.neonBlue.opacity(0.18), lineWidth: 1))
                                }
                                .buttonStyle(.plain)

                                if showsDebugEvents {
                                    BattleDebugEventSection(events: debugEvents)
                                }
                            }
#endif
                        }
                        .padding(14)
                    }
                }
            }
            .navigationTitle("Battle Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

private struct BattleLogEntryCard: View {
    let entry: BattleLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.handLabel)
                        .font(.headline.weight(.black))
                        .foregroundStyle(CasinoTheme.gold)
                    Text("Run Hand \(entry.handNumber) - Bet \(MoneyFormatter.format(entry.betAmountCents)) on \(entry.betSide.displayName)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.66))
                }

                Spacer()

                Text(MoneyFormatter.signed(entry.finalBankrollChangeCents))
                    .font(.headline.monospacedDigit().weight(.black))
                    .foregroundStyle(entry.finalBankrollChangeCents >= 0 ? CasinoTheme.emerald : CasinoTheme.red)
            }

            HStack(spacing: 8) {
                BattleLogHandSummary(title: "Player", cards: entry.playerCards)
                BattleLogHandSummary(title: "Banker", cards: entry.bankerCards)
            }

            Text(entry.outcomeText)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)

            if let basePayout = entry.basePayout {
                BattleLogLineView(
                    iconName: BattleLogEffectKind.payout.iconName,
                    title: "Base payout",
                    detail: basePayout.detail,
                    amountCents: basePayout.amountCents,
                    tint: CasinoTheme.gold
                )
            } else if !entry.didWinBet {
                BattleLogLineView(
                    iconName: BattleLogEffectKind.payout.iconName,
                    title: "Base result",
                    detail: "Lost \(entry.betSide.displayName) bet",
                    amountCents: -entry.betAmountCents,
                    tint: CasinoTheme.red
                )
            }

            ForEach(entry.modifierEffects) { effect in
                BattleLogLineView(
                    iconName: effect.kind.iconName,
                    title: effect.title,
                    detail: effect.detail,
                    amountCents: effect.amountCents,
                    resourceText: effect.resourceText,
                    tint: tint(for: effect.kind)
                )
            }

            ForEach(entry.opponentBossEffects) { effect in
                BattleLogLineView(
                    iconName: effect.kind.iconName,
                    title: effect.title,
                    detail: effect.detail,
                    amountCents: effect.amountCents,
                    resourceText: effect.resourceText,
                    tint: CasinoTheme.red
                )
            }

            HStack(spacing: 8) {
                BattleResourceDeltaPill(title: "Chips", value: entry.chipsDelta, suffix: "", tint: CasinoTheme.gold)
                BattleResourceDeltaPill(title: "Heat", value: entry.heatDelta, suffix: "", tint: CasinoTheme.red)
                if entry.heatPrevented > 0 {
                    BattleResourceDeltaPill(title: "Prevented", value: entry.heatPrevented, suffix: " Heat", tint: CasinoTheme.emerald)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.18), lineWidth: 1)
        )
    }

    private func tint(for kind: BattleLogEffectKind) -> Color {
        switch kind {
        case .boss, .heat:
            return CasinoTheme.red
        case .chips, .payout, .modifier:
            return CasinoTheme.gold
        case .reveal, .shoe:
            return CasinoTheme.neonBlue
        }
    }
}

private struct BattleLogHandSummary: View {
    let title: String
    let cards: [Card]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.54))

            Text(cards.map(\.displayText).joined(separator: " "))
                .font(.subheadline.monospaced().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(0.06)))
    }
}

private struct BattleLogLineView: View {
    let iconName: String
    let title: String
    let detail: String
    let amountCents: Int?
    var resourceText: String? = nil
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            if let amountCents {
                Text(MoneyFormatter.signed(amountCents))
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(amountCents >= 0 ? CasinoTheme.emerald : CasinoTheme.red)
            } else if let resourceText {
                Text(resourceText)
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(tint)
            }
        }
    }
}

private struct BattleResourceDeltaPill: View {
    let title: String
    let value: Int
    let suffix: String
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundStyle(.white.opacity(0.58))
            Text("\(value >= 0 ? "+" : "")\(value)\(suffix)")
                .foregroundStyle(value >= 0 ? tint : CasinoTheme.emerald)
        }
        .font(.system(size: 10, weight: .black, design: .rounded))
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(Capsule().fill(tint.opacity(0.12)))
        .overlay(Capsule().stroke(tint.opacity(0.25), lineWidth: 1))
    }
}

#if DEBUG
private struct BattleDebugEventSection: View {
    let events: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug Events")
                .font(.caption.weight(.black))
                .foregroundStyle(CasinoTheme.neonBlue)
                .textCase(.uppercase)

            ForEach(Array(events.prefix(24).enumerated()), id: \.offset) { _, event in
                Text(event)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.62))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.black.opacity(0.30)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CasinoTheme.neonBlue.opacity(0.18), lineWidth: 1))
    }
}
#endif

private struct CurrentResultStrip: View {
    let result: RoundResult?
    let presentation: RoundPresentationState
    let payoutRules: TablePayoutRules
    let selectedBetType: BetType
    let selectedBetAmountCents: Int
    let isResultRevealed: Bool
    let isAnimatingDeal: Bool
    var isCompact = false

    private var accentColor: Color {
        if isAnimatingDeal && !isResultRevealed {
            return CasinoTheme.gold
        }

        guard let result else {
            return CasinoTheme.gold
        }

        if result.isPush {
            return CasinoTheme.gold
        }

        return result.didWin ? CasinoTheme.emerald : CasinoTheme.red
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .font((isCompact ? Font.subheadline : Font.headline).weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(secondaryText)
                    .font((isCompact ? Font.caption2 : Font.caption).weight(.bold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)

                if isResultRevealed, !presentation.upgradeMessages.isEmpty {
                    Text(presentation.upgradeMessages.prefix(2).joined(separator: "  |  "))
                        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                if isResultRevealed, !presentation.payoutLedgerLines.isEmpty {
                    PayoutLedgerInlineView(lines: presentation.payoutLedgerLines, isCompact: isCompact)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(valueLabel)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .textCase(.uppercase)

                Text(valueText)
                    .font((isCompact ? Font.subheadline : Font.headline).monospacedDigit().weight(.black))
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(isCompact ? 10 : 14)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 13 : 16, style: .continuous)
                .fill(accentColor.opacity(0.13))
        )
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 13 : 16, style: .continuous)
                .stroke(accentColor.opacity(result == nil ? 0.28 : 0.62), lineWidth: 1)
        )
        .overlay {
            if isResultRevealed && result != nil && presentation.winTier.usesParticles {
                ParticleBurstView(
                    trigger: presentation.sequenceID,
                    color: presentation.winTier == .jackpot ? CasinoTheme.gold : CasinoTheme.emerald,
                    secondaryColor: CasinoTheme.gold,
                    count: presentation.winTier == .jackpot ? 42 : 24,
                    intensity: presentation.winTier == .jackpot ? 1.18 : 0.82
                )
            }
        }
    }

    private var primaryText: String {
        if isAnimatingDeal && !isResultRevealed {
            return "Dealing..."
        }

        return result?.winnerText ?? "\(selectedBetType.displayName) Bet Preview"
    }

    private var secondaryText: String {
        if isAnimatingDeal && !isResultRevealed {
            return "Cards are resolving from the shoe"
        }

        return result?.betOutcomeText ?? preDealPayoutText
    }

    private var valueLabel: String {
        if isAnimatingDeal && !isResultRevealed {
            return "Resolving"
        }

        return result == nil ? "Win Pays" : "Net"
    }

    private var valueText: String {
        if isAnimatingDeal && !isResultRevealed {
            return "..."
        }

        return result.map { MoneyFormatter.signed($0.netCents) } ?? MoneyFormatter.signed(baseWinProfitCents)
    }

    private var baseWinProfitCents: Int {
        payoutRules.profitCents(for: selectedBetType, betAmountCents: selectedBetAmountCents)
    }

    private var preDealPayoutText: String {
        payoutRules.preDealText(for: selectedBetType, betAmountCents: selectedBetAmountCents)
    }
}

private struct PayoutLedgerInlineView: View {
    let lines: [PayoutLedgerLine]
    var isCompact = false

    private var visibleLines: [PayoutLedgerLine] {
        Array(lines.filter { !$0.isStructural }.prefix(isCompact ? 2 : 3))
    }

    private var totalCents: Int {
        lines.reduce(0) { $0 + $1.amountCents }
    }

    var body: some View {
        HStack(spacing: 5) {
            Text("Ledger")
                .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.44))
                .textCase(.uppercase)

            Text(MoneyFormatter.signed(totalCents))
                .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(totalCents >= 0 ? CasinoTheme.emerald : CasinoTheme.red)

            ForEach(visibleLines) { line in
                Text("\(line.title) \(MoneyFormatter.signed(line.amountCents))")
                    .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
        }
        .lineLimit(1)
        .accessibilityLabel("Payout ledger total \(MoneyFormatter.signed(totalCents))")
    }
}

private struct UpcomingShoePreviewPanel: View {
    let preview: ShoePreview
    let forecast: DealForecast?
    let isLocked: Bool
    var isCompact = false

    private var columns: [GridItem] {
        let count = min(5, max(1, preview.entries.count))
        return Array(repeating: GridItem(.flexible(), spacing: isCompact ? 4 : 6), count: count)
    }

    private var accentColor: Color {
        isLocked ? CasinoTheme.red : CasinoTheme.neonBlue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 5 : 7) {
            HStack(spacing: 6) {
                Label(isLocked ? "Reveal Locked" : "Upcoming Shoe Preview", systemImage: isLocked ? "lock.fill" : "eye.fill")
                    .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                    .foregroundStyle(accentColor)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Spacer(minLength: 6)

                Text(isLocked ? "Boss suppressed" : "\(preview.entries.count) real card\(preview.entries.count == 1 ? "" : "s")")
                    .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .textCase(.uppercase)
                    .lineLimit(1)
            }

            if isLocked {
                Text(forecast?.summary ?? "Reveal effects are temporarily disabled.")
                    .font(.system(size: isCompact ? 9 : 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
            } else {
                LazyVGrid(columns: columns, spacing: isCompact ? 4 : 6) {
                    ForEach(preview.entries) { entry in
                        ShoePreviewCard(entry: entry, isCompact: isCompact)
                    }
                }

                Text(helpText)
                    .font(.system(size: isCompact ? 8 : 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.46))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 7 : 9)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accentColor.opacity(0.36), lineWidth: 1)
        )
        .shadow(color: accentColor.opacity(0.12), radius: 10, y: 5)
    }

    private var helpText: String {
        if preview.hasNaturalLockout {
            return "Natural opening spotted: third cards are skipped, so later revealed cards wait for the next hand."
        }

        return "Revealed cards show the next cards in the shoe in the order they will be dealt."
    }
}

private struct ShoePreviewCard: View {
    let entry: ShoePreviewEntry
    var isCompact = false

    private var cardColor: Color {
        entry.card.suit.isRed ? CasinoTheme.red : .black
    }

    private var isFutureCard: Bool {
        if case .futureHand = entry.destination {
            return true
        }

        return false
    }

    var body: some View {
        HStack(spacing: isCompact ? 5 : 6) {
            VStack(spacing: 0) {
                Text("#\(entry.order)")
                    .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .lineLimit(1)

                Text(entry.destination.shortLabel)
                    .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                    .foregroundStyle(isFutureCard ? CasinoTheme.gold.opacity(0.72) : CasinoTheme.neonBlue)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(entry.card.displayText)
                    .font(.system(size: isCompact ? 11 : 13, weight: .black, design: .rounded))
                    .foregroundStyle(cardColor)
                    .lineLimit(1)

                Text(entry.destination.displayName)
                    .font(.system(size: isCompact ? 6 : 7, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.54))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, isCompact ? 6 : 7)
        .padding(.vertical, isCompact ? 5 : 6)
        .frame(minHeight: isCompact ? 34 : 42)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(isFutureCard ? 0.82 : 0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke((isFutureCard ? CasinoTheme.gold : CasinoTheme.neonBlue).opacity(0.50), lineWidth: 1)
        )
    }
}

private struct DealForecastPanel: View {
    let forecast: DealForecast
    var isCompact = false

    private var accentColor: Color {
        switch forecast.confidence {
        case .locked:
            return CasinoTheme.red
        case .partial:
            return CasinoTheme.gold
        case .complete:
            return forecast.recommendedBet == .tie ? CasinoTheme.gold : CasinoTheme.emerald
        case .natural:
            return CasinoTheme.neonBlue
        }
    }

    private var statusText: String {
        switch forecast.confidence {
        case .locked:
            return "Locked"
        case .partial:
            return "Partial"
        case .complete:
            return "Forecast"
        case .natural:
            return "Natural"
        }
    }

    var body: some View {
        HStack(spacing: isCompact ? 8 : 10) {
            VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                HStack(spacing: 6) {
                    Label(statusText, systemImage: iconName)
                        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(accentColor)
                        .textCase(.uppercase)
                        .lineLimit(1)

                    Text(forecast.title)
                        .font(.system(size: isCompact ? 11 : 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Text(forecast.summary)
                    .font(.system(size: isCompact ? 9 : 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if !isCompact {
                    Text(forecast.detail)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.46))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }

            Spacer(minLength: 4)

            if let playerTotal = forecast.playerTotal,
               let bankerTotal = forecast.bankerTotal {
                forecastTotals(player: playerTotal, banker: bankerTotal)
            }

            if let recommendedBet = forecast.recommendedBet {
                VStack(spacing: 2) {
                    Text(recommendationLabel)
                        .font(.system(size: 7, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.58))
                        .textCase(.uppercase)
                        .lineLimit(1)

                    Text(recommendedBet.displayName)
                        .font(.system(size: isCompact ? 10 : 11, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                }
                .padding(.horizontal, isCompact ? 8 : 10)
                .padding(.vertical, isCompact ? 6 : 7)
                .background(Capsule().fill(accentColor))
            }
        }
        .padding(.horizontal, isCompact ? 10 : 12)
        .padding(.vertical, isCompact ? 8 : 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accentColor.opacity(0.34), lineWidth: 1)
        )
        .shadow(color: accentColor.opacity(0.12), radius: 10, y: 5)
    }

    private var iconName: String {
        switch forecast.confidence {
        case .locked:
            return "lock.fill"
        case .partial:
            return "eye.fill"
        case .complete:
            return "scope"
        case .natural:
            return "sparkles"
        }
    }

    private var recommendationLabel: String {
        switch forecast.confidence {
        case .partial:
            return "Lean"
        case .locked:
            return "Hidden"
        case .complete, .natural:
            return "Bet"
        }
    }

    private func forecastTotals(player: Int, banker: Int) -> some View {
        HStack(spacing: 5) {
            totalPill(label: "P", value: player, color: CasinoTheme.neonBlue)
            totalPill(label: "B", value: banker, color: CasinoTheme.red)
        }
    }

    private func totalPill(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(color)

            Text("\(value)")
                .font(.system(size: isCompact ? 11 : 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.08)))
    }
}

private struct ShoeControlStrip: View {
    let options: [ShoeControlOption]
    let isDisabled: Bool
    var isCompact = false
    let onUse: (ShoeControlActionKind) -> Void

    var body: some View {
        HStack(spacing: isCompact ? 5 : 8) {
            if !isCompact {
                Label("Shoe Control", systemImage: "slider.horizontal.3")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.gold)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .layoutPriority(1)
            }

            ForEach(options) { option in
                Button {
                    onUse(option.kind)
                } label: {
                    HStack(spacing: isCompact ? 4 : 6) {
                        Image(systemName: option.systemImage)
                            .font(.system(size: isCompact ? 10 : 12, weight: .black))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(option.title)
                                .font(.system(size: isCompact ? 10 : 11, weight: .black, design: .rounded))
                                .lineLimit(1)

                            Text(option.subtitle)
                                .font(.system(size: isCompact ? 7 : 8, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .foregroundStyle(option.isReady && !isDisabled ? .black : .white.opacity(0.42))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, isCompact ? 7 : 10)
                    .padding(.vertical, isCompact ? 5 : 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(option.isReady && !isDisabled ? CasinoTheme.gold : Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(CasinoTheme.gold.opacity(option.isReady && !isDisabled ? 0.0 : 0.22), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDisabled || !option.isReady)
            }
        }
        .padding(.horizontal, isCompact ? 7 : 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.20), lineWidth: 1)
        )
    }
}

private struct TableReadStrip: View {
    let forecast: DealForecast?
    let selectedBetType: BetType
    var isCompact = false

    private var accentColor: Color {
        guard let forecast else {
            return CasinoTheme.gold
        }

        switch forecast.confidence {
        case .locked:
            return CasinoTheme.red
        case .partial:
            return CasinoTheme.gold
        case .complete, .natural:
            return forecast.recommendedBet == selectedBetType ? CasinoTheme.emerald : CasinoTheme.neonBlue
        }
    }

    private var iconName: String {
        guard let forecast else {
            switch selectedBetType {
            case .player:
                return "person.fill"
            case .banker:
                return "building.columns.fill"
            case .tie:
                return "equal.circle.fill"
            }
        }

        switch forecast.confidence {
        case .locked:
            return "lock.fill"
        case .partial:
            return "eye.fill"
        case .complete:
            return forecast.recommendedBet == selectedBetType ? "checkmark.seal.fill" : "scope"
        case .natural:
            return "sparkles"
        }
    }

    private var title: String {
        guard let forecast else {
            return "\(selectedBetType.displayName) Read"
        }

        switch forecast.confidence {
        case .locked:
            return "Table Read Locked"
        case .partial:
            return "Partial Read"
        case .complete:
            return forecast.recommendedBet == selectedBetType ? "Forecast Supports Bet" : "Forecast Leans \(forecast.recommendedBet?.displayName ?? "Elsewhere")"
        case .natural:
            return forecast.recommendedBet == selectedBetType ? "Natural Supports Bet" : "Natural Favors \(forecast.recommendedBet?.displayName ?? "Other Side")"
        }
    }

    private var message: String {
        guard let forecast else {
            return defaultReadMessage
        }

        if forecast.confidence == .locked {
            return forecast.summary
        }

        if let recommendation = forecast.recommendedBet {
            if recommendation == selectedBetType {
                return "\(forecast.summary) Your selected bet lines up with the read."
            }

            return "\(forecast.summary) Consider \(recommendation.displayName) before dealing."
        }

        return forecast.summary
    }

    private var defaultReadMessage: String {
        switch selectedBetType {
        case .player:
            return "Clean 1:1 payout with no commission. Good for learning steady bets."
        case .banker:
            return "Slightly steadier hand. Banker usually pays less unless a house rule removes commission."
        case .tie:
            return "Rare and swingy. Base payout is 8:1, so bet small unless built for Tie."
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: isCompact ? 11 : 13, weight: .black))
                .foregroundStyle(accentColor)
                .frame(width: isCompact ? 20 : 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: isCompact ? 9 : 10, weight: .black, design: .rounded))
                    .foregroundStyle(accentColor)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(message)
                    .font(.system(size: isCompact ? 9 : 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.64))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, isCompact ? 9 : 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accentColor.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accentColor.opacity(0.24), lineWidth: 1)
        )
    }
}

private struct GameRoomBetDock: View {
    let selectedBetType: BetType
    let selectedBetAmountCents: Int
    let bankrollCents: Int
    let betAmountsCents: [Int]
    let allowedBetTypes: Set<BetType>
    let payoutRules: TablePayoutRules
    let dealButtonTitle: String
    let dealGuidanceText: String
    let rewardProgressText: String
    let canDeal: Bool
    let isReviewingHand: Bool
    let isGuidedOpeningHandLocked: Bool
    let revealBetCapCents: Int?
    var isCompact = false
    let currentStage: Int
    let unlockStageForBetAmount: (Int) -> Int
    let isBetAmountPlayable: (Int) -> Bool
    let onSelectBetType: (BetType) -> Void
    let onSelectBetAmount: (Int) -> Void
    let onDeal: () -> Void
    let onShowHelp: (UXHelpTopic) -> Void

    private var dockRewardStatusText: String {
        if isCompact, isGuidedOpeningHandLocked {
            return "Guided: Player $25"
        }

        return rewardProgressText
    }

    var body: some View {
        VStack(spacing: isCompact ? 6 : 10) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Selected Bet")
                        .font(.system(size: isCompact ? 7 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                        .textCase(.uppercase)
                        .frame(height: isCompact ? 9 : 11, alignment: .bottom)
                        .accessibilityHidden(true)

                    Text("\(selectedBetType.displayName) - \(MoneyFormatter.format(selectedBetAmountCents))")
                        .font(.system(size: isCompact ? 12 : 17, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(height: isCompact ? 17 : 22, alignment: .center)
                        .accessibilityHidden(true)

                    Label(dockRewardStatusText, systemImage: "sparkles")
                        .font(.system(size: isCompact ? 7 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.gold.opacity(0.82))
                        .textCase(.uppercase)
                        .lineLimit(isCompact ? 2 : 1)
                        .minimumScaleFactor(0.72)
                        .frame(minHeight: isCompact ? 18 : 12, alignment: .topLeading)
                        .accessibilityHidden(true)
                }
                .accessibilityHidden(true)

                Spacer()

                DealButton(
                    title: dealButtonTitle,
                    canDeal: canDeal,
                    isReviewingHand: isReviewingHand,
                    isCompact: isCompact,
                    action: onDeal
                )
                .frame(width: isCompact ? 142 : 176)
                .layoutPriority(3)
            }

            HStack(spacing: 8) {
                ForEach(BetType.allCases) { betType in
                    let guidedLocked = isGuidedOpeningHandLocked && betType != .player
                    let disabledReason = guidedLocked ? "Unlocks after the guided first hand." : nil
                    BetChipButton(
                        title: betType.displayName,
                        subtitle: guidedLocked ? "Guided lock" : betTypeSubtitle(for: betType),
                        isSelected: selectedBetType == betType,
                        isDisabled: !allowedBetTypes.contains(betType) || guidedLocked,
                        disabledReason: disabledReason,
                        isCompact: isCompact,
                        accessibilityID: "bet-type-\(betType.id)"
                    ) {
                        onSelectBetType(betType)
                    }
                }
            }

            LazyVGrid(columns: betAmountColumns, spacing: isCompact ? 5 : 7) {
                ForEach(betAmountsCents.prefix(isCompact ? 6 : 8), id: \.self) { amountCents in
                    let unlockStage = unlockStageForBetAmount(amountCents)
                    let isLocked = currentStage < unlockStage
                    let isCapped = revealBetCapCents.map { amountCents > $0 } ?? false
                    let isGuidedAmountLocked = isGuidedOpeningHandLocked && amountCents != 2_500
                    let isBankrollShort = bankrollCents < amountCents
                    let isPlayable = isBetAmountPlayable(amountCents)
                    let reason = amountUnavailableReason(
                        amountCents: amountCents,
                        unlockStage: unlockStage,
                        isLocked: isLocked,
                        isCapped: isCapped,
                        isGuidedAmountLocked: isGuidedAmountLocked,
                        isBankrollShort: isBankrollShort,
                        isPlayable: isPlayable
                    )
                    BetChipButton(
                        title: MoneyFormatter.format(amountCents),
                        subtitle: amountSubtitle(
                            amountCents: amountCents,
                            unlockStage: unlockStage,
                            isLocked: isLocked,
                            isCapped: isCapped,
                            isGuidedAmountLocked: isGuidedAmountLocked,
                            isBankrollShort: isBankrollShort,
                            isPlayable: isPlayable
                        ),
                        isSelected: selectedBetAmountCents == amountCents,
                        isDisabled: isBankrollShort || isLocked || isCapped || isGuidedAmountLocked || !isPlayable,
                        disabledReason: reason,
                        isCompact: isCompact,
                        accessibilityID: "bet-amount-\(amountCents)"
                    ) {
                        onSelectBetAmount(amountCents)
                    }
                }
            }

            if !isCompact || !canDeal {
                HStack(spacing: 8) {
                    Image(systemName: canDeal ? "hand.tap.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(canDeal ? CasinoTheme.gold : CasinoTheme.red)

                    Text(dealGuidanceText)
                        .font((isCompact ? Font.caption2 : Font.caption).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.56))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(isCompact ? 2 : 1)
                        .fixedSize(horizontal: false, vertical: true)

                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, isCompact ? 7 : 12)
        .padding(.bottom, isCompact ? 8 : 14)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22, style: .continuous)
                .fill(CrookedCasinoTheme.dustyBlack.opacity(0.82))
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(DoodleAccentView(accent: CrookedCasinoTheme.dirtyGold, density: .low).opacity(0.32).allowsHitTesting(false))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(CasinoTheme.gold.opacity(0.24))
                .frame(height: 1)
        }
    }

    private var betAmountColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: isCompact ? 6 : 8), count: 3)
    }

    private func betTypeSubtitle(for betType: BetType) -> String {
        payoutRules.payoutLabel(for: betType)
    }

    private func amountSubtitle(
        amountCents: Int,
        unlockStage: Int,
        isLocked: Bool,
        isCapped: Bool,
        isGuidedAmountLocked: Bool,
        isBankrollShort: Bool,
        isPlayable: Bool
    ) -> String? {
        if isGuidedAmountLocked {
            return "Guided lock"
        }

        if isLocked {
            return "Unlocks S\(unlockStage)"
        }

        if isBankrollShort {
            return "Need bankroll"
        }

        if isCapped {
            return "Table max"
        }

        if !isPlayable {
            return "Unavailable"
        }

        return nil
    }

    private func amountUnavailableReason(
        amountCents: Int,
        unlockStage: Int,
        isLocked: Bool,
        isCapped: Bool,
        isGuidedAmountLocked: Bool,
        isBankrollShort: Bool,
        isPlayable: Bool
    ) -> String? {
        if isGuidedAmountLocked {
            return "Unlocks after the guided first hand."
        }

        if isLocked {
            return "Unavailable in this stage. Unlocks at Stage \(unlockStage)."
        }

        if isBankrollShort {
            return "Insufficient bankroll for \(MoneyFormatter.format(amountCents))."
        }

        if isCapped {
            if let revealBetCapCents {
                return "Table maximum is \(MoneyFormatter.format(revealBetCapCents))."
            }

            return "Table maximum is lower for this hand."
        }

        if !isPlayable {
            return "Unavailable in this stage."
        }

        return nil
    }
}

private struct BetChipButton: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let isDisabled: Bool
    var disabledReason: String? = nil
    var isCompact = false
    var accessibilityID: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if title.hasPrefix("$") {
                    CrookedChipView(valueText: chipLabel, size: isCompact ? 22 : 27, tone: isSelected ? .gold : .red)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: isCompact ? 10 : 14, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .frame(height: isCompact ? 15 : 19, alignment: .center)
                        .accessibilityHidden(true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: isCompact ? 7 : 8, weight: .black, design: .rounded))
                            .textCase(.uppercase)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .frame(height: isCompact ? 10 : 12, alignment: .center)
                            .accessibilityHidden(true)
                    }
                }
            }
            .foregroundStyle(isDisabled ? .white.opacity(0.30) : (isSelected ? .black : .white))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .accessibilityHidden(true)
            .background(
                CrookedStickerShape(cornerRadius: 12)
                    .fill(isSelected ? CasinoTheme.gold : Color.white.opacity(0.09))
            )
            .overlay(
                CrookedStickerShape(cornerRadius: 12)
                    .stroke(Color.white.opacity(isSelected ? 0.0 : 0.14), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityIdentifier(accessibilityID ?? title)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHidden(isDisabled)
    }

    private var chipLabel: String {
        title
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
    }

    private var accessibilityLabel: String {
        var parts = [title]
        if let subtitle {
            parts.append(subtitle)
        }
        if isSelected {
            parts.append("selected")
        }
        if isDisabled {
            parts.append("disabled")
        }
        if let disabledReason {
            parts.append(disabledReason)
        }
        return parts.joined(separator: ", ")
    }

    private var accessibilityHint: String {
        if let disabledReason {
            return disabledReason
        }

        return "Selects this wager option."
    }
}

struct UpgradeRoomView: View {
    @ObservedObject var viewModel: GameViewModel
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?
    @State private var helpTopic: UXHelpTopic?

    var body: some View {
        CasinoRoomContainer(
            room: .upgradeRoom,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            upgradeRoomSummary
            buildSummary

            CategorizedUpgradesPanel(
                upgrades: viewModel.state.acquiredUpgrades,
                disabledUpgradeIDs: viewModel.state.bossManager.disabledUpgradeIDs
            ) { topic in
                helpTopic = topic
            }

            ArchetypeProgressPanel(
                tagCounts: tagCounts,
                activeSynergies: viewModel.activeSynergies
            )

            SynergyView(
                acquiredUpgrades: viewModel.state.acquiredUpgrades,
                activeSynergies: viewModel.activeSynergies
            )
        }
        .sheet(item: $helpTopic) { topic in
            ContextHelpSheet(topic: topic)
        }
    }

    private var upgradeRoomSummary: some View {
        RoomPanel(title: "Current Build", subtitle: "This room explains your run. Nothing here is required just to deal a hand.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                CasinoMetricCard(title: "Active Upgrades", value: "\(viewModel.state.acquiredUpgrades.count)", accentColor: CasinoTheme.gold)
                CasinoMetricCard(title: "Disabled", value: "\(viewModel.state.bossManager.disabledUpgradeIDs.count)", accentColor: CasinoTheme.red)
                CasinoMetricCard(title: "Synergies", value: "\(viewModel.activeSynergies.count)", accentColor: CasinoTheme.emerald)
                CasinoMetricCard(title: "Legendary", value: "\(legendaryUpgradeCount)", accentColor: CasinoTheme.violet)
            }
        }
    }

    private var buildSummary: some View {
        let effects = viewModel.activeUpgradeEffects

        return RoomPanel(title: "Build Readout", subtitle: "Live totals from active upgrades and synergies.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                CasinoMetricCard(title: "Reveal", value: "\(viewModel.revealedShoeCards)", accentColor: CasinoTheme.neonBlue)
                CasinoMetricCard(title: "Tie Payout", value: "\(effectiveTiePayout):1", accentColor: CasinoTheme.gold)
                CasinoMetricCard(title: "Player Bonus", value: MoneyFormatter.format(effects.playerWinBonusCents * viewModel.state.runManager.playerBonusMultiplier), accentColor: CasinoTheme.emerald)
                CasinoMetricCard(title: "Banker Bonus", value: MoneyFormatter.format(effects.bankerWinBonusCents * viewModel.state.runManager.bankerBonusMultiplier), accentColor: CasinoTheme.red)
            }

            CasinoDetailRow(
                title: "Banker Commission",
                value: effects.removesBankerCommission && !viewModel.state.bossManager.restoresBankerCommission ? "Disabled" : "Active"
            )
            CasinoDetailRow(title: "Cards Remaining", value: "\(viewModel.state.shoe.cardsRemaining)")
            CasinoDetailRow(title: "Active Synergies", value: "\(viewModel.activeSynergies.count)")

            HStack(spacing: 8) {
                ContextHelpButton(title: "Reveal", topic: .reveal) { helpTopic = $0 }
                ContextHelpButton(title: "Shoe", topic: .shoe) { helpTopic = $0 }
                ContextHelpButton(title: "Commission", topic: .bankerCommission) { helpTopic = $0 }
            }
        }
    }

    private var tagCounts: [UpgradeTag: Int] {
        var counts: [UpgradeTag: Int] = [:]

        for upgrade in viewModel.state.acquiredUpgrades {
            for tag in upgrade.tags {
                counts[tag, default: 0] += 1
            }
        }

        return counts
    }

    private var legendaryUpgradeCount: Int {
        viewModel.state.acquiredUpgrades.filter { $0.rarity == .legendary }.count
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

struct ProfileOfficeView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPurchase: (Unlockable) -> Void
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?
    @State private var helpTopic: UXHelpTopic?

    private var profile: PlayerProfile {
        viewModel.metaProgression.profile
    }

    var body: some View {
        CasinoRoomContainer(
            room: .profileOffice,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            RoomPanel(title: "Casino Profile", subtitle: "Permanent progress. Useful between runs, optional while learning the table.") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CasinoMetricCard(title: "Chips", value: formatNumber(profile.casinoChips), accentColor: CasinoTheme.gold)
                    CasinoMetricCard(title: "Reputation", value: formatNumber(profile.reputation), accentColor: CasinoTheme.neonBlue)
                    CasinoMetricCard(title: "Runs", value: "\(profile.totalRuns)", accentColor: CasinoTheme.emerald)
                    CasinoMetricCard(title: "Wins", value: "\(profile.totalWins)", accentColor: CasinoTheme.red)
                }

                ContextHelpButton(title: "Progress", topic: .permanentProgress) { helpTopic = $0 }
            }

            RoomPanel(title: "Meta Progression", subtitle: "Unlocked content enters future runs and collection completion.") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CasinoMetricCard(title: "Collection", value: "\(viewModel.collectionCompletionPercent)%", accentColor: CasinoTheme.gold)
                    CasinoMetricCard(title: "Upgrades", value: "\(profile.unlockedUpgradeNames.count)", accentColor: CasinoTheme.neonBlue)
                    CasinoMetricCard(title: "Run Mods", value: "\(profile.unlockedRunModifierIDs.count)", accentColor: CasinoTheme.emerald)
                    CasinoMetricCard(title: "Achievements", value: "\(profile.achievedAchievementIDs.count)", accentColor: CasinoTheme.red)
                }

                CasinoDetailRow(title: "Stage Rewards Unlocked", value: "\(profile.unlockedStageRewardNames.count)")
                CasinoDetailRow(title: "Boss Rewards Unlocked", value: "\(profile.unlockedBossRewardNames.count)")
                CasinoDetailRow(title: "Future Hooks", value: "\(profile.unlockedFutureHookIDs.count)")
            }

            RoomPanel(title: "Unlock Shop", subtitle: "Spend permanent currency to unlock upgrades, rewards, modifiers, and future hooks.") {
                VStack(spacing: 10) {
                    ForEach(viewModel.shopUnlockables) { unlockable in
                        ShopUnlockRow(
                            unlockable: unlockable,
                            profile: profile,
                            onPurchase: onPurchase
                        )
                    }
                }
            }

            RoomPanel(title: "Permanent Statistics", subtitle: "Lifetime run and baccarat records.") {
                VStack(spacing: 8) {
                    CasinoDetailRow(title: "Total Baccarat Rounds", value: "\(profile.totalBaccaratRounds)")
                    CasinoDetailRow(title: "Player Wins", value: "\(profile.playerWins)")
                    CasinoDetailRow(title: "Banker Wins", value: "\(profile.bankerWins)")
                    CasinoDetailRow(title: "Tie Results", value: "\(profile.tieResults)")
                    CasinoDetailRow(title: "Stages Cleared", value: "\(profile.stagesCleared)")
                    CasinoDetailRow(title: "Bosses Defeated", value: "\(profile.bossesDefeated)")
                    CasinoDetailRow(title: "Highest Bankroll", value: MoneyFormatter.format(profile.highestBankrollEverCents))
                    CasinoDetailRow(title: "Highest Profit", value: MoneyFormatter.format(profile.highestProfitEverCents))
                    CasinoDetailRow(title: "Total Chips Earned", value: formatNumber(profile.totalChipsEarned))
                    CasinoDetailRow(title: "Total Reputation Earned", value: formatNumber(profile.totalReputationEarned))
                }
            }

            RoomPanel(title: "Achievements", subtitle: "Permanent milestones and chip rewards.") {
                VStack(spacing: 8) {
                    ForEach(Achievement.allAchievements) { achievement in
                        AchievementVaultRow(
                            achievement: achievement,
                            isUnlocked: profile.achievedAchievementIDs.contains(achievement.id)
                        )
                    }
                }
            }
        }
        .sheet(item: $helpTopic) { topic in
            ContextHelpSheet(topic: topic)
        }
    }
}

struct ChallengeRoomView: View {
    @ObservedObject var viewModel: GameViewModel
    let onToggleRunModifier: (RunModifierID, Bool) -> Void
    let onSelectChallenge: (ChallengeModeID) -> Void
    let onToggleDailyRun: (Bool) -> Void
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?
    @State private var helpTopic: UXHelpTopic?

    private var profile: PlayerProfile {
        viewModel.metaProgression.profile
    }

    var body: some View {
        CasinoRoomContainer(
            room: .challengeRoom,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            RoomPanel(title: "Optional Run Setup", subtitle: "Leave Standard selected while learning. These choices apply when the next run starts.") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CasinoMetricCard(title: "Next Run", value: profile.selectedChallengeID.name, accentColor: CasinoTheme.red)
                    CasinoMetricCard(title: "Chip Bonus", value: "\(profile.selectedChallengeID.chipRewardMultiplierPercent)%", accentColor: CasinoTheme.gold)
                    CasinoMetricCard(title: "Daily", value: profile.isDailyRunEnabled ? "On" : "Off", accentColor: CasinoTheme.neonBlue)
                    CasinoMetricCard(title: "Modifiers", value: "\(profile.activeRunModifierIDs.count)", accentColor: CasinoTheme.emerald)
                }

                ContextHelpButton(title: "Challenges", topic: .challenges) { helpTopic = $0 }
            }

            RoomPanel(title: "Daily Run", subtitle: "Optional fixed run. Same seed, offerings, boss sequence, and rewards for the day.") {
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily Seed")
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(.white)

                            Text("Fixed offerings and boss sequence for today.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.56))
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { profile.isDailyRunEnabled },
                            set: onToggleDailyRun
                        ))
                        .labelsHidden()
                        .tint(CasinoTheme.gold)
                    }
                }
            }

            RoomPanel(title: "Challenge Runs", subtitle: "Optional bet restrictions and special rules for future runs.") {
                VStack(spacing: 10) {
                    ForEach(ChallengeModeID.allCases.filter { $0 != .bossRush }) { challenge in
                        ChallengeModeRow(
                            challenge: challenge,
                            profile: profile,
                            onSelect: onSelectChallenge
                        )
                    }
                }
            }

            RoomPanel(title: "Boss Rush", subtitle: "Optional high-pressure mode. Every stage becomes a boss stage for a larger chip multiplier.") {
                ChallengeModeRow(
                    challenge: .bossRush,
                    profile: profile,
                    onSelect: onSelectChallenge
                )

                ContextHelpButton(title: "Boss Effects", topic: .bossEffects) { helpTopic = $0 }
            }

            if let boss = viewModel.state.bossManager.activeBoss {
                BossHUDView(
                    boss: boss,
                    disabledUpgrades: viewModel.disabledBossUpgrades
                )
            }

            RoomPanel(title: "Run Modifiers", subtitle: "Unlocked modifiers shape future runs.") {
                VStack(spacing: 10) {
                    ForEach(RunModifierID.allCases) { modifier in
                        RunModifierRow(
                            modifier: modifier,
                            profile: profile,
                            onToggle: onToggleRunModifier
                        )
                    }
                }
            }

            if let leaderboard = profile.leaderboardPlaceholder {
            RoomPanel(title: "Daily Local Score", subtitle: "Local score for today's fixed seed.") {
                CasinoDetailRow(title: "Seed", value: "\(leaderboard.dailySeed)")
                CasinoDetailRow(title: "Score", value: MoneyFormatter.format(leaderboard.localScoreCents))
            }
            }
        }
        .sheet(item: $helpTopic) { topic in
            ContextHelpSheet(topic: topic)
        }
    }
}

struct ThemeLoungeView: View {
    @ObservedObject var viewModel: GameViewModel
    let onSelectTheme: (CasinoThemeID) -> Void
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?

    private var selectedTheme: CasinoThemeID {
        viewModel.metaProgression.profile.selectedThemeID
    }

    var body: some View {
        CasinoRoomContainer(
            room: .themeLounge,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            RoomPanel(title: "Theme Lounge", subtitle: "Cosmetic only. Pick the casino floor's backdrop and music flavor.") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CasinoMetricCard(title: "Active Theme", value: selectedTheme.name, accentColor: CasinoTheme.violet)
                    CasinoMetricCard(title: "Gameplay", value: "Unchanged", accentColor: CasinoTheme.gold)
                }
            }

            RoomPanel(title: "Visual Previews", subtitle: "Choose the atmosphere for the lobby and room backgrounds.") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    ForEach(CasinoThemeID.allCases) { theme in
                        Button {
                            onSelectTheme(theme)
                        } label: {
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: selectedTheme == theme
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            RoomPanel(title: "Music and Theme Info", subtitle: "The audio system can swap layered music by run context.") {
                CasinoDetailRow(title: "Normal Run", value: "Uses the selected casino tone")
                CasinoDetailRow(title: "Boss Music", value: "Switches during active boss stages")
                CasinoDetailRow(title: "Final Boss", value: "Uses the highest pressure layer")
                CasinoDetailRow(title: "Victory", value: "Celebration layer after a completed run")
                CasinoDetailRow(title: "Current Theme", value: selectedTheme.name)
            }
        }
    }
}

struct CollectionVaultView: View {
    @ObservedObject var viewModel: GameViewModel
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?

    var body: some View {
        CasinoRoomContainer(
            room: .collectionVault,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            RoomPanel(title: "Vault Progress", subtitle: "Unlocked and discovered content across all runs.") {
                VStack(spacing: 10) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        CasinoMetricCard(title: "Unlocked Upgrades", value: "\(unlockedUpgrades.count)", accentColor: CasinoTheme.gold)
                        CasinoMetricCard(title: "Locked Upgrades", value: "\(lockedUpgrades.count)", accentColor: .white.opacity(0.78))
                        CasinoMetricCard(title: "Bosses Seen", value: "\(bossesEncountered.count)", accentColor: CasinoTheme.red)
                        CasinoMetricCard(title: "Bosses Down", value: "\(bossesDefeated.count)", accentColor: CasinoTheme.emerald)
                    }

                    HStack {
                        Text("Completion")
                            .font(.caption.weight(.black))
                            .foregroundStyle(.white.opacity(0.58))
                            .textCase(.uppercase)

                        Spacer()

                        Text("\(viewModel.collectionCompletionPercent)%")
                            .font(.caption.monospacedDigit().weight(.black))
                            .foregroundStyle(CasinoTheme.gold)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.12))

                            Capsule()
                                .fill(CasinoTheme.gold)
                                .frame(width: geometry.size.width * CGFloat(viewModel.collectionCompletionPercent) / 100)
                        }
                    }
                    .frame(height: 9)
                }
            }

            CollectionVaultSection(title: "Unlocked Upgrades", entries: unlockedUpgrades)
            CollectionVaultSection(title: "Locked Upgrades", entries: lockedUpgrades)
            CollectionVaultSection(title: "Bosses Encountered", entries: bossesEncountered)
            CollectionVaultSection(title: "Bosses Defeated", entries: bossesDefeated)
            CollectionVaultSection(title: "Achievements", entries: entries(of: .achievement))
            CollectionVaultSection(title: "Rewards and Modifiers", entries: rewardAndModifierEntries)
        }
    }

    private var rewardAndModifierEntries: [CollectionEntry] {
        viewModel.collectionEntries.filter { entry in
            [.stageReward, .bossReward, .runModifier, .futureHook].contains(entry.kind)
        }
    }

    private func entries(of kind: CollectionEntryKind) -> [CollectionEntry] {
        viewModel.collectionEntries.filter { $0.kind == kind }
    }

    private var unlockedUpgrades: [CollectionEntry] {
        entries(of: .upgrade).filter(\.isUnlocked)
    }

    private var lockedUpgrades: [CollectionEntry] {
        entries(of: .upgrade).filter { !$0.isUnlocked }
    }

    private var bossesEncountered: [CollectionEntry] {
        entries(of: .boss).filter(\.isEncountered)
    }

    private var bossesDefeated: [CollectionEntry] {
        entries(of: .boss).filter(\.isDefeated)
    }
}

struct SettingsRoomView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var audioManager: AudioManager
    let analyticsLog: String
    let onReplayTutorial: () -> Void
    let onShowGlossary: () -> Void
    let onShowSupport: () -> Void
    let onResetProfile: () -> Void
    let onBack: () -> Void
    let onShowDebug: (() -> Void)?

    var body: some View {
        CasinoRoomContainer(
            room: .settings,
            onBack: onBack,
            onShowGlossary: onShowGlossary,
            onShowDebug: onShowDebug
        ) {
            RoomPanel(title: "Audio", subtitle: "Controls for music, SFX, and current table tones.") {
                VStack(spacing: 16) {
                    settingSlider(
                        title: "Music Volume",
                        value: $settings.musicVolume,
                        isMuted: $settings.isMusicMuted
                    )

                    settingSlider(
                        title: "SFX Volume",
                        value: $settings.sfxVolume,
                        isMuted: $settings.isSFXMuted
                    )

                    CasinoDetailRow(title: "Music Layer", value: audioManager.currentMusicLayer.displayName)
                }
            }

            RoomPanel(title: "Feel and Accessibility", subtitle: "Player comfort controls.") {
                VStack(spacing: 12) {
                    Toggle("Haptics", isOn: $settings.isHapticsEnabled)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .tint(CasinoTheme.gold)

                    Toggle("Reduce Motion", isOn: $settings.isReduceMotionEnabled)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .tint(CasinoTheme.gold)
                }
            }

            RoomPanel(title: "Playtest Tools", subtitle: "Support, tutorial, and diagnostics.") {
                VStack(spacing: 10) {
                    SettingsActionRow(title: "Replay Tutorial", systemImage: "questionmark.circle.fill", action: onReplayTutorial)
                    SettingsActionRow(title: "Open Glossary", systemImage: "book.closed.fill", action: onShowGlossary)
                    SettingsActionRow(title: "Playtest Hub", systemImage: "testtube.2", action: onShowSupport)

                    ShareLink(item: analyticsLog.isEmpty ? "No Rigged Shoe analytics events yet." : analyticsLog) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Export Playtest Logs")
                            Spacer()
                        }
                        .font(.headline.weight(.black))
                        .foregroundStyle(.black)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(CasinoTheme.gold))
                    }

                    SettingsActionRow(title: "Restore Settings Defaults", systemImage: "arrow.counterclockwise") {
                        settings.restoreDefaults()
                    }
                }
            }

            RoomPanel(title: "Credits", subtitle: BuildInfo.versionText) {
                Text("Rigged Shoe. Built with SwiftUI. Casino noir presentation, roguelike run structure, and local-only progression.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.64))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(role: .destructive, action: onResetProfile) {
                Text("Reset Profile")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(CasinoTheme.red.opacity(0.72))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func settingSlider(title: String, value: Binding<Double>, isMuted: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    isMuted.wrappedValue.toggle()
                } label: {
                    Text(isMuted.wrappedValue ? "Muted" : "On")
                        .font(.caption.weight(.black))
                        .foregroundStyle(isMuted.wrappedValue ? .white.opacity(0.56) : .black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isMuted.wrappedValue ? Color.white.opacity(0.10) : CasinoTheme.gold)
                        )
                }
                .buttonStyle(.plain)
            }

            Slider(value: value, in: 0...1)
                .tint(CasinoTheme.gold)
                .disabled(isMuted.wrappedValue)
        }
    }
}

private struct CasinoRoomContainer<Content: View>: View {
    let room: CasinoRoom
    let onBack: () -> Void
    let onShowGlossary: () -> Void
    let onShowDebug: (() -> Void)?
    let content: Content

    init(
        room: CasinoRoom,
        onBack: @escaping () -> Void,
        onShowGlossary: @escaping () -> Void,
        onShowDebug: (() -> Void)?,
        @ViewBuilder content: () -> Content
    ) {
        self.room = room
        self.onBack = onBack
        self.onShowGlossary = onShowGlossary
        self.onShowDebug = onShowDebug
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                content
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 12) {
            CasinoLightsView()

            HStack(spacing: 12) {
                Button(action: onBack) {
                    HStack(spacing: 7) {
                        Image(systemName: "chevron.left")
                        Text("Lobby")
                    }
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.10)))
                    .overlay(Capsule().stroke(room.accentColor.opacity(0.28), lineWidth: 1))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Image(systemName: room.iconName)
                            .foregroundStyle(room.accentColor)

                        Text(room.title)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                    }

                    Text(room.description)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(2)
                }

                Spacer()

                Button(action: onShowGlossary) {
                    Image(systemName: "info.circle.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                }
                .buttonStyle(.plain)

                if let onShowDebug {
                    Button(action: onShowDebug) {
                        Image(systemName: "ladybug.fill")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CasinoTheme.gold)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct LobbyRoomCard: View {
    let room: CasinoRoom
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: room.iconName)
                    .font(.title2.weight(.black))
                    .foregroundStyle(room.accentColor)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(room.accentColor.opacity(0.14)))

                Spacer()

                Text(isHighlighted ? "Start Here" : room.purposeLabel)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(isHighlighted ? .black : room.accentColor)
                    .textCase(.uppercase)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isHighlighted ? CasinoTheme.gold : room.accentColor.opacity(0.14))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(room.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Text(room.description)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isHighlighted ? CasinoTheme.gold.opacity(0.13) : Color.black.opacity(0.32))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isHighlighted ? CasinoTheme.gold.opacity(0.74) : room.accentColor.opacity(0.30), lineWidth: isHighlighted ? 2 : 1)
        )
        .shadow(color: (isHighlighted ? CasinoTheme.gold : room.accentColor).opacity(isHighlighted ? 0.24 : 0.10), radius: isHighlighted ? 22 : 16, y: 8)
    }
}

private struct DealButton: View {
    let title: String
    let canDeal: Bool
    var isReviewingHand = false
    var isCompact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isReviewingHand {
                    ProgressView()
                        .controlSize(.small)
                        .tint(canDeal ? CasinoTheme.ink : .white.opacity(0.72))
                }

                Text(title.uppercased())
                    .font(.system(size: isCompact ? 13 : 20, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .frame(height: isCompact ? 17 : 25, alignment: .center)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: isCompact ? 48 : 58)
        }
        .buttonStyle(CrookedCasinoButtonStyle(tone: canDeal ? .gold : .black))
        .disabled(!canDeal || isReviewingHand)
        .accessibilityIdentifier(isReviewingHand ? "reviewing-hand-progress" : "deal-button")
        .accessibilityLabel(isReviewingHand ? "Reviewing hand" : title)
        .accessibilityHint(isReviewingHand ? "Next action appears after the hand settles." : "Deals one baccarat hand.")
    }
}

private struct EmptyRoundResultView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Place a bet and deal the shoe.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.86))

            Text("The Game Room keeps only the current table state visible.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.56))
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 12)
    }
}

private struct RoomPanel<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.56))
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 14)
    }
}

private struct CasinoMetricCard: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.50))
                .textCase(.uppercase)

            Text(value)
                .font(.headline.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(CrookedStickerShape(cornerRadius: 10).fill(accentColor.opacity(0.10)))
        .overlay(CrookedStickerShape(cornerRadius: 10).stroke(accentColor.opacity(0.30), lineWidth: 1))
    }
}

private func tagColor(_ tag: UpgradeTag) -> Color {
    switch tag {
    case .player:
        return CasinoTheme.neonBlue
    case .banker:
        return CasinoTheme.red
    case .tie:
        return CasinoTheme.gold
    case .reveal:
        return Color(red: 0.42, green: 0.78, blue: 1.0)
    case .shoe:
        return CasinoTheme.emerald
    case .economy:
        return Color(red: 0.38, green: 0.90, blue: 0.54)
    case .boss:
        return Color(red: 1.0, green: 0.36, blue: 0.32)
    case .streak:
        return Color(red: 1.0, green: 0.58, blue: 0.25)
    case .risk:
        return Color(red: 0.95, green: 0.38, blue: 0.95)
    case .conservative:
        return Color(red: 0.45, green: 0.95, blue: 0.68)
    case .aggressive:
        return Color(red: 1.0, green: 0.52, blue: 0.20)
    case .comeback:
        return Color(red: 0.48, green: 0.72, blue: 1.0)
    case .dealerExploit:
        return Color(red: 1.0, green: 0.78, blue: 0.30)
    case .legendary:
        return CasinoTheme.gold
    }
}

private struct UpgradeCategorySpec: Identifiable {
    let tag: UpgradeTag
    let helpTopic: UXHelpTopic?

    var id: UpgradeTag {
        tag
    }
}

private struct CategorizedUpgradesPanel: View {
    let upgrades: [UpgradeCard]
    let disabledUpgradeIDs: Set<UUID>
    let onShowHelp: (UXHelpTopic) -> Void

    private let categories: [UpgradeCategorySpec] = [
        UpgradeCategorySpec(tag: .player, helpTopic: .baccarat),
        UpgradeCategorySpec(tag: .banker, helpTopic: .bankerCommission),
        UpgradeCategorySpec(tag: .tie, helpTopic: .tiePayout),
        UpgradeCategorySpec(tag: .reveal, helpTopic: .reveal),
        UpgradeCategorySpec(tag: .shoe, helpTopic: .shoe),
        UpgradeCategorySpec(tag: .economy, helpTopic: .permanentProgress),
        UpgradeCategorySpec(tag: .conservative, helpTopic: .stageTarget),
        UpgradeCategorySpec(tag: .aggressive, helpTopic: .baccarat),
        UpgradeCategorySpec(tag: .comeback, helpTopic: .stageTarget),
        UpgradeCategorySpec(tag: .dealerExploit, helpTopic: .baccarat),
        UpgradeCategorySpec(tag: .boss, helpTopic: .bossEffects)
    ]

    var body: some View {
        RoomPanel(title: "Upgrades by Strategy", subtitle: "Active upgrades grouped by the build lanes they support.") {
            if upgrades.isEmpty {
                Text("No upgrades acquired yet. Complete three baccarat rounds to choose your first build card.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 10)], spacing: 10) {
                    ForEach(categories) { category in
                        UpgradeCategoryCard(
                            category: category,
                            upgrades: upgrades.filter { $0.tags.contains(category.tag) },
                            disabledUpgradeIDs: disabledUpgradeIDs,
                            onShowHelp: onShowHelp
                        )
                    }
                }
            }
        }
    }
}

private struct UpgradeCategoryCard: View {
    let category: UpgradeCategorySpec
    let upgrades: [UpgradeCard]
    let disabledUpgradeIDs: Set<UUID>
    let onShowHelp: (UXHelpTopic) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.tag.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)

                    Text("\(upgrades.count) active")
                        .font(.caption2.monospacedDigit().weight(.black))
                        .foregroundStyle(tagColor(category.tag))
                        .textCase(.uppercase)
                }

                Spacer()

                if let helpTopic = category.helpTopic {
                    ContextHelpButton(title: "Help", topic: helpTopic, onTap: onShowHelp)
                }
            }

            if upgrades.isEmpty {
                Text(emptyText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
            } else {
                VStack(spacing: 8) {
                    ForEach(upgrades.prefix(3)) { upgrade in
                        UpgradeDescriptionRow(
                            upgrade: upgrade,
                            isDisabled: disabledUpgradeIDs.contains(upgrade.id)
                        )
                    }

                    if upgrades.count > 3 {
                        Text("+\(upgrades.count - 3) more in this lane")
                            .font(.caption.weight(.black))
                            .foregroundStyle(tagColor(category.tag))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tagColor(category.tag).opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tagColor(category.tag).opacity(0.28), lineWidth: 1)
        )
    }

    private var emptyText: String {
        switch category.tag {
        case .player:
            return "Player upgrades make Player bets stronger."
        case .banker:
            return "Banker upgrades improve the usually steady Banker lane."
        case .tie:
            return "Tie upgrades turn rare outcomes into big paydays."
        case .reveal:
            return "Reveal upgrades show future cards before you bet."
        case .shoe:
            return "Shoe upgrades add, remove, or reshape the actual card stack."
        case .economy:
            return "Economy upgrades generate extra money or reduce losses."
        case .conservative:
            return "Conservative upgrades reward smaller bets and steady bankroll control."
        case .aggressive:
            return "Aggressive upgrades reward pressing wins and raising bets at the right time."
        case .comeback:
            return "Comeback upgrades soften losing streaks and help stabilize a bad stage."
        case .dealerExploit:
            return "Dealer Exploit upgrades reward reading Banker totals and natural hands."
        case .boss:
            return "Boss upgrades protect your build during casino rule attacks."
        case .streak, .risk, .legendary:
            return "No active upgrades in this lane yet."
        }
    }
}

private struct UpgradeDescriptionRow: View {
    let upgrade: UpgradeCard
    let isDisabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(upgrade.rarity.displayName)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(isDisabled ? CasinoTheme.red : CasinoTheme.rarityColor(upgrade.rarity))
                        .textCase(.uppercase)

                    Text(upgrade.name)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)
                }

                Spacer()

                if isDisabled {
                    Text("Disabled")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(CasinoTheme.red)
                        .textCase(.uppercase)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(CasinoTheme.red.opacity(0.14)))
                }
            }

            Text(upgrade.description)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(upgrade.tags.sorted { $0.displayName < $1.displayName }, id: \.self) { tag in
                        Text(tag.displayName)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                            .textCase(.uppercase)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(CasinoTheme.gold.opacity(isDisabled ? 0.42 : 1.0)))
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isDisabled ? CasinoTheme.red.opacity(0.10) : Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke((isDisabled ? CasinoTheme.red : CasinoTheme.rarityColor(upgrade.rarity)).opacity(0.36), lineWidth: 1)
        )
    }
}

private struct ArchetypeProgressPanel: View {
    let tagCounts: [UpgradeTag: Int]
    let activeSynergies: [SynergyDefinition]

    var body: some View {
        RoomPanel(title: "Archetype Progress", subtitle: "Upgrade tags reveal which build lanes are coming online.") {
            VStack(spacing: 9) {
                ForEach(UpgradeTag.allCases.filter { $0 != .legendary }, id: \.self) { tag in
                    ArchetypeProgressRow(
                        tag: tag,
                        count: tagCounts[tag, default: 0],
                        requiredCount: requiredCount(for: tag),
                        isActive: activeSynergies.contains { $0.requiredTag == tag }
                    )
                }
            }
        }
    }

    private func requiredCount(for tag: UpgradeTag) -> Int {
        SynergyDefinition.allSynergies.first { $0.requiredTag == tag }?.requiredCount ?? 5
    }
}

private struct ArchetypeProgressRow: View {
    let tag: UpgradeTag
    let count: Int
    let requiredCount: Int
    let isActive: Bool

    private var progress: Double {
        guard requiredCount > 0 else {
            return 1
        }

        return min(1, Double(count) / Double(requiredCount))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(tag.displayName)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text(isActive ? "Active" : "\(count)/\(requiredCount)")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(isActive ? CasinoTheme.emerald : CasinoTheme.gold)
                    .textCase(.uppercase)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))

                    Capsule()
                        .fill(isActive ? CasinoTheme.emerald : CasinoTheme.gold)
                        .frame(width: geometry.size.width * CGFloat(progress))
                }
            }
            .frame(height: 7)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(isActive ? 0.09 : 0.05))
        )
    }
}

private struct CasinoDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))

            Spacer()

            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

private struct ShopUnlockRow: View {
    let unlockable: Unlockable
    let profile: PlayerProfile
    let onPurchase: (Unlockable) -> Void

    var body: some View {
        let isUnlocked = unlockable.isUnlocked(in: profile)
        let canAfford = unlockable.canAfford(with: profile)

        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(unlockable.categoryName)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.gold)
                    .textCase(.uppercase)

                Text(unlockable.name)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)

                Text(unlockable.description)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 7) {
                Text(statusText(for: unlockable, profile: profile, isUnlocked: isUnlocked))
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(statusColor(isUnlocked: isUnlocked, canAfford: canAfford))
                    .multilineTextAlignment(.trailing)

                Button {
                    onPurchase(unlockable)
                } label: {
                    Text(isUnlocked ? "Unlocked" : "Unlock")
                        .font(.caption.weight(.black))
                        .foregroundStyle(isUnlocked || !canAfford ? .white.opacity(0.46) : .black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isUnlocked || !canAfford ? Color.white.opacity(0.08) : CasinoTheme.gold)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isUnlocked || !canAfford)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(isUnlocked ? 0.05 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(isUnlocked ? 0.10 : 0.18), lineWidth: 1)
        )
    }

    private func costText(for unlockable: Unlockable) -> String {
        if unlockable.costReputation > 0 {
            return "\(formatNumber(unlockable.costChips)) Chips\n\(unlockable.costReputation) Rep"
        }

        return "\(formatNumber(unlockable.costChips)) Chips"
    }

    private func statusText(for unlockable: Unlockable, profile: PlayerProfile, isUnlocked: Bool) -> String {
        guard !isUnlocked else {
            return "Owned"
        }

        let chipShortfall = max(0, unlockable.costChips - profile.casinoChips)
        let reputationShortfall = max(0, unlockable.costReputation - profile.reputation)
        guard chipShortfall > 0 || reputationShortfall > 0 else {
            return costText(for: unlockable)
        }

        var parts: [String] = []
        if chipShortfall > 0 {
            parts.append("Need \(formatNumber(chipShortfall)) Chips")
        }
        if reputationShortfall > 0 {
            parts.append("Need \(reputationShortfall) Rep")
        }
        return parts.joined(separator: "\n")
    }

    private func statusColor(isUnlocked: Bool, canAfford: Bool) -> Color {
        if isUnlocked {
            return .green
        }

        return canAfford ? .white.opacity(0.72) : CasinoTheme.red.opacity(0.86)
    }
}

private struct ChallengeModeRow: View {
    let challenge: ChallengeModeID
    let profile: PlayerProfile
    let onSelect: (ChallengeModeID) -> Void

    var body: some View {
        let isSelected = profile.selectedChallengeID == challenge
        let record = profile.challengeRecords[challenge.rawValue] ?? ChallengeRecord()

        Button {
            onSelect(challenge)
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(isSelected ? Color.black : .white)

                    Text(challenge.description)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.64) : .white.opacity(0.56))
                        .lineLimit(2)

                    Text(challenge.tableRuleSummary)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.72) : CasinoTheme.neonBlue.opacity(0.82))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(challengeBadgeText(isSelected: isSelected))
                        .font(.caption.weight(.black))
                        .foregroundStyle(isSelected ? Color.black : CasinoTheme.gold)

                    Text("Wins \(record.wins)")
                        .font(.caption2.monospacedDigit().weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.62) : .white.opacity(0.42))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? CasinoTheme.gold : Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(CasinoTheme.gold.opacity(isSelected ? 0.0 : 0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func challengeBadgeText(isSelected: Bool) -> String {
        if isSelected {
            return "Selected"
        }

        if challenge == .standard {
            return "Recommended"
        }

        return "+\(challenge.chipRewardMultiplierPercent - 100)%"
    }
}

private struct RunModifierRow: View {
    let modifier: RunModifierID
    let profile: PlayerProfile
    let onToggle: (RunModifierID, Bool) -> Void

    var body: some View {
        let isUnlocked = profile.unlockedRunModifierIDs.contains(modifier.rawValue)
        let isActive = profile.activeRunModifierIDs.contains(modifier.rawValue)

        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(modifier.name)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)

                Text(isUnlocked ? modifier.description : "Unlock this from the Profile Office shop.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
                    .lineLimit(2)
            }

            Spacer()

            Button {
                onToggle(modifier, !isActive)
            } label: {
                Text(isActive ? "On" : isUnlocked ? "Off" : "Locked")
                    .font(.caption.weight(.black))
                    .foregroundStyle(isActive ? Color.black : .white.opacity(0.58))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isActive ? CasinoTheme.gold : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isUnlocked)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
    }
}

private struct ThemePreviewCard: View {
    let theme: CasinoThemeID
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CasinoTheme.background(for: theme))
                    .frame(height: 86)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? CasinoTheme.gold.opacity(0.70) : Color.white.opacity(0.16), lineWidth: isSelected ? 2 : 1)
                    )

                HStack(spacing: 5) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(lightColor(index))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(10)

                Image(systemName: isSelected ? "checkmark.seal.fill" : "circle.hexagongrid.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(isSelected ? CasinoTheme.gold : .white.opacity(0.56))
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(theme.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Text(themeMood)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineLimit(2)

                Text(isSelected ? "Active theme" : musicTone)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? CasinoTheme.gold : CasinoTheme.neonBlue.opacity(0.82))
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? CasinoTheme.gold.opacity(0.12) : Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? CasinoTheme.gold.opacity(0.54) : Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var themeMood: String {
        switch theme {
        case .lasVegas:
            return "Classic neon felt and red-gold casino glow."
        case .macau:
            return "Red lacquer, warm gold, and high-limit pressure."
        case .monteCarlo:
            return "Cool luxury with deep blues and velvet shadows."
        case .underground:
            return "Low light, smoky tables, and back-room tension."
        case .cyber:
            return "Electric blues, violet edges, and digital glare."
        case .goldRoom:
            return "Premium black-and-gold high roller atmosphere."
        }
    }

    private var musicTone: String {
        switch theme {
        case .lasVegas:
            return "Bright casino pulse"
        case .macau:
            return "Warm high-limit tone"
        case .monteCarlo:
            return "Smooth lounge layer"
        case .underground:
            return "Low pressure bed"
        case .cyber:
            return "Synthetic neon layer"
        case .goldRoom:
            return "Luxury jackpot layer"
        }
    }

    private func lightColor(_ index: Int) -> Color {
        switch (index + theme.rawValue.count) % 3 {
        case 0:
            return CasinoTheme.gold
        case 1:
            return CasinoTheme.red
        default:
            return CasinoTheme.neonBlue
        }
    }
}

private struct AchievementVaultRow: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isUnlocked ? "rosette" : "lock.fill")
                .foregroundStyle(isUnlocked ? CasinoTheme.gold : .white.opacity(0.34))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)

                Text(achievement.description)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
            }

            Spacer()

            Text("+\(achievement.chipReward)")
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(isUnlocked ? .green : .white.opacity(0.42))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(isUnlocked ? 0.08 : 0.04))
        )
    }
}

private struct CollectionVaultSection: View {
    let title: String
    let entries: [CollectionEntry]

    var body: some View {
        RoomPanel(title: title, subtitle: "\(entries.filter(\.countsTowardCompletion).count) of \(entries.count) complete") {
            if entries.isEmpty {
                Text("Nothing here yet. Keep playing runs to fill this shelf.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.56))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(entries) { entry in
                        CollectionVaultCard(entry: entry)
                    }
                }
            }
        }
    }
}

private struct CollectionVaultCard: View {
    let entry: CollectionEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isRevealed ? accentColor.opacity(0.20) : Color.white.opacity(0.055))
                    .frame(width: 42, height: 54)
                    .overlay {
                        if !isRevealed {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.11), .white.opacity(0.02)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(6)
                        }
                    }

                Image(systemName: iconName)
                    .font(.headline.weight(.black))
                    .foregroundStyle(isRevealed ? accentColor : .white.opacity(0.38))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(displayTitle)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    Text(entry.stateText)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(accentColor)
                        .textCase(.uppercase)
                }

                Text(displaySubtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accentColor)

                Text(displayDescription)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(isRevealed ? 0.62 : 0.42))
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(isRevealed ? 0.07 : 0.035))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(accentColor.opacity(isRevealed ? 0.42 : 0.14), lineWidth: 1)
        )
    }

    private var isRevealed: Bool {
        entry.isUnlocked || entry.isEncountered || entry.isDefeated
    }

    private var displayTitle: String {
        isRevealed ? entry.title : "Locked \(entry.kind.displayName)"
    }

    private var displaySubtitle: String {
        isRevealed ? entry.subtitle : "Silhouette"
    }

    private var displayDescription: String {
        isRevealed ? entry.description : "Keep playing runs or unlock this content from the Profile Office."
    }

    private var iconName: String {
        if entry.countsTowardCompletion {
            return "checkmark.seal.fill"
        }

        if isRevealed {
            return "eye.fill"
        }

        return "lock.fill"
    }

    private var accentColor: Color {
        if let rarity = entry.rarity {
            return CasinoTheme.rarityColor(rarity)
        }

        switch entry.kind {
        case .boss:
            return entry.isDefeated ? CasinoTheme.gold : CasinoTheme.red
        case .achievement:
            return entry.isUnlocked ? CasinoTheme.gold : .white.opacity(0.46)
        case .stageReward, .bossReward:
            return CasinoTheme.emerald
        case .runModifier:
            return CasinoTheme.neonBlue
        case .futureHook:
            return CasinoTheme.violet
        case .upgrade:
            return CasinoTheme.gold
        }
    }
}

private struct SettingsActionRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
            }
            .font(.headline.weight(.black))
            .foregroundStyle(.white)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.09)))
        }
        .buttonStyle(.plain)
    }
}

private func formatNumber(_ value: Int) -> String {
    NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
}
