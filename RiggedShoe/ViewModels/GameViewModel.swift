import SwiftUI

private struct PayoutResolution {
    var amount: Int
    var isPush: Bool
    var activationMessages: [String] = []
    var ledgerLines: [PayoutLedgerLine] = []
    var usedDamageControl = false
    var usedHighRollerSparkAttempt = false
    var usedFaceHunter = false
}

enum ShoeControlActionKind: String, Identifiable, Equatable {
    case softShuffle
    case burnControl
    case xRay

    var id: String {
        rawValue
    }
}

struct ShoeControlOption: Identifiable, Equatable {
    let kind: ShoeControlActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let isReady: Bool

    var id: String {
        kind.id
    }
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published private(set) var metaProgression: MetaProgressionManager
    @Published private(set) var analytics: AnalyticsManager
    @Published private(set) var isDealResolutionLocked = false
    private let sessionStartedAt = Date()

    let betAmountsCents = [
        1_000,
        2_000,
        3_000,
        5_000,
        7_500,
        10_000,
        20_000,
        30_000,
        50_000,
        100_000
    ]

    init(metaProgression: MetaProgressionManager = MetaProgressionManager()) {
        self.metaProgression = metaProgression
        self.analytics = AnalyticsManager()
        let configuration = metaProgression.runConfiguration()

        if let restoredState = RunPersistenceManager.restore(configuration: configuration) {
            self.state = restoredState
            normalizeSelectedBetForStage()
            lockGuidedOpeningBetIfNeeded()
        } else {
            self.state = GameState(configuration: configuration)
            normalizeSelectedBetForStage()
            lockGuidedOpeningBetIfNeeded()
            applyRunStartImmediateEffects()
            applyStageStartEffects()
            trackRunStarted()
            persistRunState()
        }
    }

    var canDeal: Bool {
        canDealIgnoringPresentationLock && !isDealResolutionLocked
    }

    private var canDealIgnoringPresentationLock: Bool {
        state.runManager.status == .active
            && state.pendingUpgradeChoices.isEmpty
            && state.pendingStageRewardChoices.isEmpty
            && state.bossManager.pendingAnnouncementBoss == nil
            && state.bossManager.pendingBossRewardChoices.isEmpty
            && state.bankrollCents >= state.selectedBetAmountCents
            && isBetAmountUnlocked(state.selectedBetAmountCents)
            && selectedBetIsWithinRevealCap
            && state.challengeID.allowsBet(state.selectedBetType)
    }

    var isGuidedOpeningHandLocked: Bool {
        state.isGuidedFirstRun
            && !state.guidedExcitingWinDelivered
            && state.runManager.totalRoundsPlayed == 0
    }

    var guidedOpeningHandNotice: String? {
        isGuidedOpeningHandLocked
            ? "Tutorial Hand: scripted Player bet. Other bets unlock after this hand."
            : nil
    }

    var unlockedBetAmountsCents: [Int] {
        state.runManager.currentStage.betLimit.allowedBetAmountsCents
    }

    var shoeControlOptions: [ShoeControlOption] {
        let upgrades = activeUpgradeEffects
        var options: [ShoeControlOption] = []

        if upgrades.moveTopCardDeeperPositions > 0 {
            let isReady = canUseShoeControlNow
                && !state.hasMovedCardThisStage
                && state.shoe.cardsRemaining > 1
            let subtitle = state.hasMovedCardThisStage
                ? "USED"
                : "Push top card \(upgrades.moveTopCardDeeperPositions) slots"

            options.append(
                ShoeControlOption(
                    kind: .softShuffle,
                    title: "Soft Shuffle",
                    subtitle: subtitle,
                    systemImage: "arrow.down.to.line.compact",
                    isReady: isReady
                )
            )
        }

        if upgrades.burnCardInterval > 0 {
            let charges = burnControlCharges(upgrades: upgrades)
            let isReady = canUseShoeControlNow
                && charges > 0
                && state.shoe.cardsRemaining > 0
            let cooldown = burnControlRoundsUntilReady(upgrades: upgrades)
            let subtitle = charges > 0
                ? "READY"
                : "\(cooldown) hand\(cooldown == 1 ? "" : "s") remaining"

            options.append(
                ShoeControlOption(
                    kind: .burnControl,
                    title: "Burn Control",
                    subtitle: subtitle,
                    systemImage: "flame.fill",
                    isReady: isReady
                )
            )
        }

        if let chargedReveal = upgrades.chargedShoeReveal {
            let isLocked = state.challengeID == .noReveal || state.bossManager.suppressesReveal
            let isReady = canUseShoeControlNow
                && !isLocked
                && !state.isXRayActiveForNextHand
                && state.xRayChargesRemainingThisStage > 0
                && state.shoe.cardsRemaining > 0
            let subtitle: String

            if isLocked {
                subtitle = state.bossManager.suppressesReveal ? "Suppressed by boss" : "Reveal locked"
            } else if state.isXRayActiveForNextHand && state.xRayChargesRemainingThisStage > 0 {
                subtitle = "Active this hand"
            } else {
                subtitle = "\(state.xRayChargesRemainingThisStage) charge\(state.xRayChargesRemainingThisStage == 1 ? "" : "s")"
            }

            options.append(
                ShoeControlOption(
                    kind: .xRay,
                    title: chargedReveal.title,
                    subtitle: subtitle,
                    systemImage: "eye.fill",
                    isReady: isReady
                )
            )
        }

        return options
    }

    func isBetAmountUnlocked(_ amountCents: Int) -> Bool {
        state.runManager.currentStage.betLimit.allows(amountCents)
    }

    func isBetAmountPlayable(_ amountCents: Int) -> Bool {
        state.runManager.isBetAmountAllowed(amountCents, bankrollCents: state.bankrollCents)
            && (activeRevealBetCapCents.map { amountCents <= $0 } ?? true)
    }

    func betCapReason(for amountCents: Int) -> String? {
        if let activeRevealBetCapCents, amountCents > activeRevealBetCapCents {
            return "\(activeShoeReveal?.title ?? "Reveal") caps this hand at \(MoneyFormatter.format(activeRevealBetCapCents))."
        }

        return state.runManager.betCapReason(for: amountCents, bankrollCents: state.bankrollCents)
    }

    func unlockStage(forBetAmountCents amountCents: Int) -> Int {
        Stage.allStages.first { $0.betLimit.allows(amountCents) }?.id ?? Stage.allStages.last?.id ?? 1
    }

    var activeSynergies: [SynergyDefinition] {
        SynergyDefinition.allSynergies.filter { $0.isActive(for: effectiveUpgrades) }
    }

    var activeUpgradeEffects: UpgradeEffectSummary {
        UpgradeEffectSummary(
            upgrades: effectiveUpgrades,
            extraEffects: activeSynergies.flatMap(\.effects) + challengeEffects
        )
    }

    var shoePreviewLimit: Int {
        max(8, activeShoeReveal?.maxCards ?? 0)
    }

    var revealedShoeCards: Int {
        activeShoeReveal?.visibleCardCount ?? 0
    }

    var shoeVisibilityState: ShoeVisibilityState {
        ShoeVisibilityState(
            hiddenDisplayCount: 5,
            activeReveal: activeShoeReveal
        )
    }

    var dealForecast: DealForecast? {
        guard let reveal = activeShoeReveal else {
            return nil
        }

        if reveal.isSuppressed {
            return .locked(reason: reveal.lockedReason ?? "Reveal information is hidden.")
        }

        guard reveal.supportsFavorability else {
            return nil
        }

        return reveal.forecast
    }

    var activeShoeReveal: ActiveShoeReveal? {
        let upgrades = activeUpgradeEffects
        let passiveConfiguration = bestPassiveRevealConfiguration(upgrades: upgrades)
        let chargedConfiguration = upgrades.chargedShoeReveal
        let chargedRevealIsValid = state.isXRayActiveForNextHand
            && state.xRayChargesRemainingThisStage > 0
        let selectedConfiguration = chargedRevealIsValid ? chargedConfiguration : passiveConfiguration
        let hasRevealPotential = passiveConfiguration != nil || chargedConfiguration != nil

        if hasRevealPotential, state.challengeID == .noReveal {
            return .locked(title: "Reveal Locked", reason: "No Reveal challenge hides shoe information.")
        }

        if hasRevealPotential, state.bossManager.suppressesReveal {
            return .locked(title: "Surveillance", reason: "Boss surveillance is suppressing reveal upgrades.")
        }

        guard let selectedConfiguration else {
            return nil
        }

        return ActiveShoeReveal.make(
            configuration: selectedConfiguration,
            previewCards: state.shoe.previewCards(limit: selectedConfiguration.normalizedMaxCards),
            remainingCharges: selectedConfiguration.isCharged ? state.xRayChargesRemainingThisStage : 0
        )
    }

    var activeRevealBetCapCents: Int? {
        guard let reveal = activeShoeReveal,
              !reveal.isSuppressed,
              let multiplier = reveal.betCapMultiplierWhileActive else {
            return nil
        }

        return minimumUnlockedBetAmountCents * multiplier
    }

    private var selectedBetIsWithinRevealCap: Bool {
        guard let activeRevealBetCapCents else {
            return true
        }

        return state.selectedBetAmountCents <= activeRevealBetCapCents
    }

    private var minimumUnlockedBetAmountCents: Int {
        unlockedBetAmountsCents.min() ?? betAmountsCents.first ?? 1_000
    }

    private func bestPassiveRevealConfiguration(upgrades: UpgradeEffectSummary) -> ShoeRevealConfiguration? {
        var configurations: [ShoeRevealConfiguration] = []

        if let passive = upgrades.passiveShoeReveal {
            configurations.append(passive)
        }

        if let permanent = ShoeRevealConfiguration.passiveLegacyReveal(count: min(state.runManager.permanentRevealCount, 2)) {
            configurations.append(permanent)
        }

        return configurations.max { $0.powerScore < $1.powerScore }
    }

    var disabledBossUpgrades: [UpgradeCard] {
        state.acquiredUpgrades.filter { state.bossManager.disabledUpgradeIDs.contains($0.id) }
    }

    private var effectiveUpgrades: [UpgradeCard] {
        state.acquiredUpgrades.filter { !state.bossManager.disabledUpgradeIDs.contains($0.id) }
    }

    private var challengeEffects: [UpgradeEffect] {
        switch state.challengeID {
        case .highRoller:
            return [.lossMultiplier(percent: 125)]
        case .standard, .tieOnly, .bankerOnly, .playerOnly, .noReveal, .bossRush:
            return []
        }
    }

    var collectionEntries: [CollectionEntry] {
        metaProgression.collectionEntries
    }

    var collectionCompletionPercent: Int {
        metaProgression.collectionCompletionPercent
    }

    var stagePreviewData: StagePreviewData {
        state.runManager.stagePreviewData
    }

    var stageResultData: StageResultData? {
        state.runManager.lastStageResult
    }

    var shopUnlockables: [Unlockable] {
        Unlockable.allUnlockables.sorted { first, second in
            let firstUnlocked = first.isUnlocked(in: metaProgression.profile)
            let secondUnlocked = second.isUnlocked(in: metaProgression.profile)

            if firstUnlocked != secondUnlocked {
                return !firstUnlocked
            }

            if first.categoryName != second.categoryName {
                return first.categoryName < second.categoryName
            }

            return first.costChips < second.costChips
        }
    }

    private var unlockedUpgradeCards: [UpgradeCard] {
        metaProgression.unlockedUpgradeCards
    }

    private var upgradeRewardThreshold: Int {
        state.acquiredUpgrades.isEmpty ? 2 : 3
    }

    var rewardProgressText: String {
        if state.bossManager.pendingAnnouncementBoss != nil {
            return "Boss approaching"
        }

        if !state.bossManager.pendingBossRewardChoices.isEmpty {
            return "Choose a boss reward to continue"
        }

        if !state.pendingStageRewardChoices.isEmpty {
            return "Choose a stage reward to continue"
        }

        if !state.pendingUpgradeChoices.isEmpty {
            return "Choose an upgrade to continue"
        }

        let remaining = max(0, upgradeRewardThreshold - state.roundsSinceLastUpgrade)
        return remaining == 1 ? "Shoe upgrade in 1 round" : "Shoe upgrade in \(remaining) rounds"
    }

    func selectBetType(_ betType: BetType) {
        guard !isGuidedOpeningHandLocked || betType == .player else {
            state.selectedBetType = .player
            state.roundPresentation.upgradeMessages = ["Tutorial Hand: Player bet locked"]
            state.roundPresentation.payoutLedgerLines = []
            state.roundPresentation.sequenceID = UUID()
            persistRunState()
            return
        }

        guard state.challengeID.allowsBet(betType) else {
            return
        }

        state.selectedBetType = betType
        persistRunState()
    }

    func selectBetAmount(_ amountCents: Int) {
        guard !isGuidedOpeningHandLocked || amountCents == minimumUnlockedBetAmountCents else {
            state.selectedBetAmountCents = minimumUnlockedBetAmountCents
            state.roundPresentation.upgradeMessages = ["Tutorial Hand: minimum bet locked"]
            state.roundPresentation.payoutLedgerLines = []
            state.roundPresentation.sequenceID = UUID()
            persistRunState()
            return
        }

        guard isBetAmountUnlocked(amountCents) else {
            return
        }

        if let activeRevealBetCapCents, amountCents > activeRevealBetCapCents {
            registerManualShoeControl(
                message: "\(activeShoeReveal?.title ?? "Reveal") caps bets at \(MoneyFormatter.format(activeRevealBetCapCents))",
                impact: .none
            )
            return
        }

        state.selectedBetAmountCents = amountCents
        persistRunState()
    }

    func useShoeControl(_ kind: ShoeControlActionKind) {
        guard canUseShoeControlNow else {
            return
        }

        let upgrades = activeUpgradeEffects

        switch kind {
        case .softShuffle:
            guard upgrades.moveTopCardDeeperPositions > 0,
                  !state.hasMovedCardThisStage,
                  state.shoe.moveTopCardDeeper(positions: upgrades.moveTopCardDeeperPositions) else {
                return
            }

            state.hasMovedCardThisStage = true
            clearTemporaryRevealOnShoeMutation()
            registerManualShoeControl(
                message: "Soft Shuffle moved the next card",
                impact: .reordered
            )
        case .burnControl:
            guard upgrades.burnCardInterval > 0,
                  burnControlCharges(upgrades: upgrades) > 0,
                  let burnedCard = state.shoe.burnTopCard() else {
                return
            }

            state.burnControlUses += 1
            clearTemporaryRevealOnShoeMutation()
            registerManualShoeControl(
                message: "Burn Control burned \(burnedCard.displayText)",
                impact: .removedCards(1)
            )
        case .xRay:
            guard let chargedReveal = upgrades.chargedShoeReveal,
                  state.xRayChargesRemainingThisStage > 0,
                  !state.isXRayActiveForNextHand,
                  state.challengeID != .noReveal,
                  !state.bossManager.suppressesReveal else {
                return
            }

            var impact = ShoeImpact.none
            if state.shoe.cardsRemaining < 20 {
                reshuffleShoe()
                impact = .shuffled
            }

            state.isXRayActiveForNextHand = true
            let capText: String
            if let cap = activeRevealBetCapCents {
                clampSelectedBetForRevealCap()
                capText = "; bet capped at \(MoneyFormatter.format(cap))"
            } else {
                capText = ""
            }
            registerManualShoeControl(
                message: "\(chargedReveal.title) armed: \(chargedReveal.normalizedMaxCards)-card read\(capText)",
                impact: impact
            )
        }
    }

    func purchaseUnlockable(_ unlockable: Unlockable) {
        var manager = metaProgression
        guard manager.purchase(unlockable) else {
            return
        }

        metaProgression = manager
    }

    func setRunModifier(_ modifier: RunModifierID, isActive: Bool) {
        var manager = metaProgression
        manager.setRunModifier(modifier, isActive: isActive)
        metaProgression = manager
    }

    func setChallenge(_ challengeID: ChallengeModeID) {
        var manager = metaProgression
        manager.setChallenge(challengeID)
        metaProgression = manager
    }

    func setDailyRunEnabled(_ isEnabled: Bool) {
        var manager = metaProgression
        manager.setDailyRunEnabled(isEnabled)
        metaProgression = manager
    }

    func setTheme(_ themeID: CasinoThemeID) {
        var manager = metaProgression
        manager.setTheme(themeID)
        metaProgression = manager
    }

    func resetProfile() {
        var manager = metaProgression
        manager.resetProfile()
        metaProgression = manager
        analytics.reset()
        startNewRun()
    }

    func completeOnboarding(skipped: Bool = false) {
        var manager = metaProgression
        manager.markOnboardingCompleted(skipped: skipped)
        metaProgression = manager
        track(skipped ? .tutorialSkipped : .tutorialCompleted)
    }

    func markPatchNotesSeen() {
        var manager = metaProgression
        manager.markPatchNotesSeen()
        metaProgression = manager
    }

    func recordSessionEnded() {
        track(
            .sessionEnded,
            properties: [
                "lengthSeconds": "\(Int(Date().timeIntervalSince(sessionStartedAt)))",
                "stage": "\(state.runManager.stageReached)",
                "roundsPlayed": "\(state.runManager.totalRoundsPlayed)"
            ]
        )
        persistRunState()
    }

#if DEBUG
    func debugFastForwardThreeRounds() {
        track(.debugAction, properties: ["action": "fastForwardThreeRounds"])

        for _ in 0..<3 where canDealIgnoringPresentationLock {
            dealRound(allowPresentationLockBypass: true)
        }
    }

    func debugInstantStageClear() {
        track(.debugAction, properties: ["action": "instantStageClear"])
        let targetBankroll = state.runManager.stageTargetBankrollCents()
        state.bankrollCents = max(state.bankrollCents, targetBankroll)
        state.runManager.evaluateStage(bankrollCents: state.bankrollCents)

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
        } else if state.runManager.status == .stageCleared, let _ = state.bossManager.activeBoss {
            mutateSeededRandom { generator in
                state.bossManager.defeatActiveBoss(
                    acquiredUpgrades: state.acquiredUpgrades,
                    unlockedRewardNames: metaProgression.profile.unlockedBossRewardNames,
                    unlockedUpgradeCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }
        } else if state.runManager.status == .stageCleared, state.pendingStageRewardChoices.isEmpty {
            state.pendingStageRewardChoices = mutateSeededRandom { generator in
                StageReward.randomChoices(
                    count: 3,
                    acquiredUpgrades: state.acquiredUpgrades,
                    unlockedRewardNames: metaProgression.profile.unlockedStageRewardNames,
                    unlockedUpgradeCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }
        }

        persistRunState()
    }

    func debugGrantUpgrade(named name: String) {
        track(.debugAction, properties: ["action": "grantUpgrade", "upgrade": name])
        guard let upgrade = UpgradeCard.allCards.first(where: { $0.name.localizedCaseInsensitiveContains(name) })?.copyForAcquisition() else {
            return
        }

        state.acquiredUpgrades.append(upgrade)
        registerShoeImpact(applyImmediateEffect(upgrade.effect))
        persistRunState()
    }

    func debugGrantLegendary() {
        track(.debugAction, properties: ["action": "grantLegendary"])
        guard let upgrade = UpgradeCard.allCards.filter({ $0.rarity == .legendary }).randomElement()?.copyForAcquisition() else {
            return
        }

        state.acquiredUpgrades.append(upgrade)
        registerShoeImpact(applyImmediateEffect(upgrade.effect))
        persistRunState()
    }

    func debugSpawnBoss(_ boss: Boss) {
        track(.debugAction, properties: ["action": "spawnBoss", "boss": boss.name])
        state.bossManager.pendingAnnouncementBoss = nil
        state.bossManager.activeBoss = boss
        state.bossManager.disabledUpgradeIDs = Set(
            state.acquiredUpgrades
                .filter { !$0.tags.isDisjoint(with: boss.effect.suppressedTags) }
                .map(\.id)
        )
        persistRunState()
    }

    func debugForceDailySeed(_ seed: UInt64) {
        track(.debugAction, properties: ["action": "forceDailySeed", "seed": "\(seed)"])
        state.isDailyRun = true
        state.dailySeed = seed
        state.seededGenerator = SeededRandomGenerator(seed: seed)
        persistRunState()
    }

    func debugRunPhase3Checks() -> String {
        track(.debugAction, properties: ["action": "runPhase3Checks"])

        let cards = [
            Card(suit: .diamonds, rank: .seven),
            Card(suit: .clubs, rank: .four),
            Card(suit: .spades, rank: .king),
            Card(suit: .hearts, rank: .five),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .clubs, rank: .six)
        ]
        let preview = ShoePreview.make(from: cards, revealedCount: 6)
        let previewLabels = preview.entries.map(\.destination.shortLabel)
        let previewPass = Array(previewLabels.prefix(4)) == ["P1", "B1", "P2", "B2"]
        let peekReveal = ActiveShoeReveal.make(configuration: .peek, previewCards: cards, remainingCharges: 0)
        let readReveal = ActiveShoeReveal.make(configuration: .readTheShoe, previewCards: cards, remainingCharges: 0)
        let smudgedReveal = ActiveShoeReveal.make(configuration: .smudgedLens, previewCards: cards, remainingCharges: 0)
        let xRayReveal = ActiveShoeReveal.make(configuration: .xRay, previewCards: cards, remainingCharges: 2)
        let fullXRayReveal = ActiveShoeReveal.make(configuration: .fullXRay, previewCards: cards, remainingCharges: 1)
        let fiveCardReveal = ActiveShoeReveal.make(
            configuration: ShoeRevealConfiguration.passiveLegacyReveal(count: 5) ?? .smudgedLens,
            previewCards: cards,
            remainingCharges: 0
        )
        let hiddenVisibility = ShoeVisibilityState.hidden()
        let activeVisibility = ShoeVisibilityState(hiddenDisplayCount: 5, activeReveal: xRayReveal)
        let revealTierPass = peekReveal.visibleCardCount == 1
            && readReveal.visibleCardCount == 2
            && smudgedReveal.visibleCardCount == 3
            && smudgedReveal.cards.contains { $0.isObstructed && $0.displayedText == "??" }
            && xRayReveal.visibleCardCount == 3
            && xRayReveal.betCapMultiplierWhileActive == 3
            && fullXRayReveal.visibleCardCount == 4
            && fullXRayReveal.betCapMultiplierWhileActive == 2
            && fiveCardReveal.visibleCardCount == 5
            && [peekReveal, readReveal, smudgedReveal, xRayReveal, fullXRayReveal, fiveCardReveal].allSatisfy { $0.visibleCardCount <= 5 }
        let visibilityPass = hiddenVisibility.revealedCards.isEmpty
            && !hiddenVisibility.isRevealActive
            && activeVisibility.revealedCards.count == 3

        var manager = RunManager()
        let betLimitPass = manager.currentStage.betLimit.allows(1_000)
            && !manager.currentStage.betLimit.allows(2_000)

        manager.currentStageRoundsPlayed = 10
        let objectivePass = manager.currentStage.teachingObjective?.isComplete(in: manager, bankrollCents: 25_000) == true
        let failPass = manager.currentStage.teachingObjective?.isFailed(in: manager, bankrollCents: 19_900) == true

        manager.status = .stageCleared
        manager.advanceAfterStageClear(bankrollCents: 28_600)
        let carryoverPass = manager.stageStartingBankrollCents == 28_600
            && manager.currentStage.id == 2
            && manager.currentStage.betLimit.allows(2_000)

        let xRayUpgrade = UpgradeCard.allCards.first { $0.name == "X-Ray Shoe" }
        let xRaySummary = xRayUpgrade.map { UpgradeEffectSummary(upgrades: [$0]) }
        let fullXRayUpgrade = UpgradeCard.allCards.first { $0.name == "Full X-Ray" }
        let fullXRaySummary = fullXRayUpgrade.map { UpgradeEffectSummary(upgrades: [$0]) }
        let upgradePass = xRayUpgrade?.rarity == .rare
            && xRaySummary?.xRayRevealCount == 3
            && xRaySummary?.xRayChargesPerStage == 2
            && xRaySummary?.chargedShoeReveal?.betCapMultiplierWhileActive == 3
            && fullXRayUpgrade?.rarity == .legendary
            && fullXRaySummary?.xRayRevealCount == 4
            && fullXRaySummary?.xRayChargesPerStage == 1
            && fullXRaySummary?.chargedShoeReveal?.betCapMultiplierWhileActive == 2

        let checks = [
            ("X-Ray labels", previewPass),
            ("Stage 1 bet lock", betLimitPass),
            ("Stage objective", objectivePass),
            ("Stage fail state", failPass),
            ("Bankroll carryover", carryoverPass),
            ("Hidden shoe visibility", visibilityPass),
            ("Reveal tier counts", revealTierPass),
            ("Reveal tiers", upgradePass)
        ]
        let failedChecks = checks.filter { !$0.1 }.map(\.0)
        let summary = failedChecks.isEmpty
            ? "Phase 3 checks passed: \(checks.count)/\(checks.count)"
            : "Phase 3 checks failed: \(failedChecks.joined(separator: ", "))"

        print("[Rigged Shoe Debug] \(summary)")
        return summary
    }

    func debugStressGameRoomLayout() {
        track(.debugAction, properties: ["action": "stressGameRoomLayout"])
        let stressUpgradeNames = [
            "X-Ray Shoe",
            "Opening Tell",
            "Burn Control",
            "Soft Shuffle",
            "Marked Shoe",
            "Deep Read",
            "Dealer Pressure"
        ]
        let existingNames = Set(state.acquiredUpgrades.map(\.name))

        for name in stressUpgradeNames where !existingNames.contains(name) {
            guard let upgrade = UpgradeCard.allCards.first(where: { $0.name == name })?.copyForAcquisition() else {
                continue
            }

            state.acquiredUpgrades.append(upgrade)
            registerShoeImpact(applyImmediateEffect(upgrade.effect))
        }

        persistRunState()
    }
#endif

    func dealRound(allowPresentationLockBypass: Bool = false) {
        let canDealNow = allowPresentationLockBypass ? canDealIgnoringPresentationLock : canDeal
        guard canDealNow else {
            return
        }

        if !allowPresentationLockBypass {
            isDealResolutionLocked = true
        }

        let bankrollBeforeRound = state.bankrollCents
        var shoeImpact = ShoeImpact.none

        if state.shoe.cardsRemaining < 20 {
            reshuffleShoe()
            shoeImpact = .shuffled
        }

        let preDealShoeControl = applyAutomaticShoeControlBeforeDeal()
        if preDealShoeControl.impact != .none {
            shoeImpact = preDealShoeControl.impact
        }

        prepareGuidedFirstDealIfNeeded()
        let revealBeforeRound = activeShoeReveal
        let wasXRayActive = state.isXRayActiveForNextHand
        let forecastBeforeRound = dealForecast
        let revealCountBeforeRound = revealedShoeCards
        let xRayPreviewBeforeRound = wasXRayActive && revealBeforeRound?.isSuppressed == false
            ? state.shoe.previewCards(limit: min(revealBeforeRound?.maxCards ?? 0, 4))
            : []
        logXRayPreviewIfNeeded(xRayPreviewBeforeRound)
        let cardsBeforeRound = state.shoe.cardsRemaining
        let betType = state.selectedBetType
        let betAmountCents = state.selectedBetAmountCents
        state.bankrollCents -= betAmountCents

        let roundResolution = playBaccaratRound(
            betType: betType,
            betAmountCents: betAmountCents,
            cardsBeforeRound: cardsBeforeRound,
            forecastBeforeRound: forecastBeforeRound
        )
        var result = roundResolution.result
        verifyXRayPreviewIfNeeded(xRayPreviewBeforeRound, result: result)
        let guidedFirstWinBonusCents = guidedFirstWinBonusIfNeeded(for: result)
        result = result.addingPayoutBonus(guidedFirstWinBonusCents)
        state.bankrollCents += result.payoutCents
        var activationMessages = preDealShoeControl.messages + roundResolution.payout.activationMessages
        var payoutLedgerLines = roundResolution.payout.ledgerLines
        if wasXRayActive {
            state.xRayChargesRemainingThisStage = max(0, state.xRayChargesRemainingThisStage - 1)
            state.isXRayActiveForNextHand = false
            activationMessages.insert("\(revealBeforeRound?.title ?? "Reveal") spent 1 charge", at: 0)
        }
        if guidedFirstWinBonusCents > 0 {
            activationMessages.append("Tutorial Hand Bonus +\(MoneyFormatter.format(guidedFirstWinBonusCents))")
            payoutLedgerLines.append(
                PayoutLedgerLine(
                    title: "Tutorial Hand Bonus",
                    detail: "Scripted first-hand reward",
                    amountCents: guidedFirstWinBonusCents
                )
            )
        }
        if revealCountBeforeRound > 0,
           let teachingObjective = state.runManager.currentStage.teachingObjective,
           teachingObjective.kind == .triggerUpgrades || teachingObjective.kind == .winWithReveal {
            activationMessages.insert("Reveal read \(revealCountBeforeRound) cards", at: 0)
        }
        let safetyNet = applyPostPayoutStageSafetyNetIfNeeded()
        activationMessages += safetyNet.messages
        payoutLedgerLines += safetyNet.ledgerLines
        logUpgradeActivations(activationMessages)
        state.roundPresentation = RoundPresentationState(
            bankrollDeltaCents: state.bankrollCents - bankrollBeforeRound,
            winTier: winTier(for: result),
            shoeImpact: shoeImpact,
            upgradeMessages: activationMessages,
            payoutLedgerLines: payoutLedgerLines
        )
        state.latestRound = result
        state.history.insert(result, at: 0)
        state.roundsSinceLastUpgrade += 1
        updateRoundMemory(
            result: result,
            bankrollBeforeRound: bankrollBeforeRound,
            payout: roundResolution.payout
        )
        state.runManager.recordRound(
            result: result,
            bankrollCents: state.bankrollCents,
            didWinBet: result.didWin,
            upgradeTriggerCount: activationMessages.count,
            didWinWithReveal: revealCountBeforeRound > 0 && result.didWin,
            bankrollBeforeRoundCents: bankrollBeforeRound
        )
        recordProgressionAward(
            mutateMetaProgression { manager in
                manager.recordRound(
                    result: result,
                    bankrollCents: state.bankrollCents,
                    profitCents: state.runManager.currentProfitCents(bankrollCents: state.bankrollCents),
                    revealedCards: revealedShoeCards,
                    acquiredUpgrades: state.acquiredUpgrades
                )
            }
        )

        if state.bossManager.shufflesAfterEveryRound {
            shuffleRemainingShoeForBoss()
        }

        if state.history.count > 10 {
            state.history.removeLast(state.history.count - 10)
        }

        state.runManager.evaluateStage(bankrollCents: state.bankrollCents)

        if state.runManager.status == .failed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        if state.runManager.status == .stageCleared {
            if state.isGuidedFirstRun {
                markGuidedFirstRunCompleted()
            }

            recordProgressionAward(
                mutateMetaProgression { manager in
                    manager.recordStageCleared(
                        stageID: state.runManager.currentStage.id,
                        chipMultiplierPercent: state.chipRewardMultiplierPercent
                    )
                }
            )
            track(
                .stageCleared,
                properties: [
                    "stage": "\(state.runManager.currentStage.id)",
                    "profit": "\(state.runManager.currentProfitCents(bankrollCents: state.bankrollCents))",
                    "roundsRemaining": "\(state.runManager.roundsRemaining)"
                ]
            )

            if let activeBoss = state.bossManager.activeBoss {
                recordProgressionAward(
                    mutateMetaProgression { manager in
                        manager.recordBossDefeated(
                            activeBoss,
                            chipMultiplierPercent: state.chipRewardMultiplierPercent
                        )
                    }
                )
                track(
                    .bossDefeated,
                    properties: [
                        "boss": activeBoss.name,
                        "stage": "\(state.runManager.currentStage.id)"
                    ]
                )
                mutateSeededRandom { generator in
                    state.bossManager.defeatActiveBoss(
                        acquiredUpgrades: state.acquiredUpgrades,
                        unlockedRewardNames: metaProgression.profile.unlockedBossRewardNames,
                        unlockedUpgradeCards: unlockedUpgradeCards,
                        seededGenerator: &generator
                    )
                }
                persistRunState()
                return
            }

            state.pendingStageRewardChoices = mutateSeededRandom { generator in
                StageReward.randomChoices(
                    count: 3,
                    acquiredUpgrades: state.acquiredUpgrades,
                    unlockedRewardNames: metaProgression.profile.unlockedStageRewardNames,
                    unlockedUpgradeCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }
            persistRunState()
            return
        }

        if state.runManager.status == .active {
            queueShoeUpgradeRewardIfNeeded()
        }

        persistRunState()
    }

    func completeDealPresentation(for roundID: UUID? = nil) {
        guard roundID == nil || state.latestRound?.id == roundID else {
            return
        }

        isDealResolutionLocked = false
    }

    private func resolveStageClearFromNonRoundProgress() {
        guard state.runManager.status == .stageCleared else {
            return
        }

        if state.isGuidedFirstRun {
            markGuidedFirstRunCompleted()
        }

        recordProgressionAward(
            mutateMetaProgression { manager in
                manager.recordStageCleared(
                    stageID: state.runManager.currentStage.id,
                    chipMultiplierPercent: state.chipRewardMultiplierPercent
                )
            }
        )
        track(
            .stageCleared,
            properties: [
                "stage": "\(state.runManager.currentStage.id)",
                "profit": "\(state.runManager.currentProfitCents(bankrollCents: state.bankrollCents))",
                "roundsRemaining": "\(state.runManager.roundsRemaining)",
                "source": "shoeControl"
            ]
        )

        if let activeBoss = state.bossManager.activeBoss {
            recordProgressionAward(
                mutateMetaProgression { manager in
                    manager.recordBossDefeated(
                        activeBoss,
                        chipMultiplierPercent: state.chipRewardMultiplierPercent
                    )
                }
            )
            track(
                .bossDefeated,
                properties: [
                    "boss": activeBoss.name,
                    "stage": "\(state.runManager.currentStage.id)"
                ]
            )
            mutateSeededRandom { generator in
                state.bossManager.defeatActiveBoss(
                    acquiredUpgrades: state.acquiredUpgrades,
                    unlockedRewardNames: metaProgression.profile.unlockedBossRewardNames,
                    unlockedUpgradeCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }
            return
        }

        if state.pendingStageRewardChoices.isEmpty {
            state.pendingStageRewardChoices = mutateSeededRandom { generator in
                StageReward.randomChoices(
                    count: 3,
                    acquiredUpgrades: state.acquiredUpgrades,
                    unlockedRewardNames: metaProgression.profile.unlockedStageRewardNames,
                    unlockedUpgradeCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }
        }
    }

    func selectUpgrade(_ upgrade: UpgradeCard) {
        state.acquiredUpgrades.append(upgrade)
        let shoeImpact = applyImmediateEffect(upgrade.effect)
        if shoeImpact != .none {
            state.roundPresentation.shoeImpact = shoeImpact
            state.roundPresentation.sequenceID = UUID()
        }

        state.pendingUpgradeChoices = []
        state.roundsSinceLastUpgrade = 0
        track(
            .upgradeChosen,
            properties: [
                "upgrade": upgrade.name,
                "rarity": upgrade.rarity.displayName,
                "tags": upgrade.tags.map(\.rawValue).sorted().joined(separator: ",")
            ]
        )

        if upgrade.rarity == .legendary {
            track(.legendaryAcquired, properties: ["upgrade": upgrade.name])
        }

        recordRunSnapshot()
        persistRunState()
    }

    func continueToBoss() {
        if let boss = state.bossManager.pendingAnnouncementBoss {
            var manager = metaProgression
            manager.recordBossEncountered(boss)
            metaProgression = manager
        }

        mutateSeededRandom { generator in
            state.bossManager.startPendingBoss(
                acquiredUpgrades: state.acquiredUpgrades,
                seededGenerator: &generator
            )
        }
        applyBossStageStartEffects()
        persistRunState()
    }

    func continueFromRunStart() {
        state.runManager.startRunPreview()
        persistRunState()
    }

    func startStageBattle() {
        state.runManager.startStageBattle()
        persistRunState()
    }

    func continueFromStageResult() {
        switch state.runManager.status {
        case .failed:
            state.runManager.failRunAfterResult()
        case .stageCleared:
            if !state.bossManager.pendingBossRewardChoices.isEmpty
                || !state.pendingStageRewardChoices.isEmpty {
                state.runManager.flowState = .rewardDraft
            } else {
                state.runManager.showRewardDraft()
            }
        case .completed:
            state.runManager.flowState = .runComplete
        case .active:
            state.runManager.flowState = .battle
        }

        persistRunState()
    }

    func continueFromShop() {
        guard state.runManager.status == .stageCleared else {
            state.runManager.startStageBattle()
            persistRunState()
            return
        }

        state.runManager.advanceAfterStageClear(bankrollCents: state.bankrollCents)

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        prepareBossAnnouncementIfNeeded()
        applyStageStartEffects()
        normalizeSelectedBetForStage()
        persistRunState()
    }

    func selectStageReward(_ reward: StageReward) {
        guard state.runManager.status == .stageCleared else {
            return
        }

        applyStageReward(reward)
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        recordRunSnapshot()
        state.pendingStageRewardChoices = []
        state.runManager.advanceAfterStageClear(bankrollCents: state.bankrollCents)

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        prepareBossAnnouncementIfNeeded()
        applyStageStartEffects()
        normalizeSelectedBetForStage()

        if state.runManager.status == .active {
            queueShoeUpgradeRewardIfNeeded()
        }

        persistRunState()
    }

    func selectBossReward(_ reward: BossReward) {
        guard !state.bossManager.pendingBossRewardChoices.isEmpty else {
            return
        }

        applyBossReward(reward)
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        recordRunSnapshot()
        state.bossManager.clearBossRewardChoices()
        state.runManager.advanceAfterStageClear(bankrollCents: state.bankrollCents)

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        prepareBossAnnouncementIfNeeded()
        applyStageStartEffects()
        normalizeSelectedBetForStage()

        if state.runManager.status == .active {
            queueShoeUpgradeRewardIfNeeded()
        }

        persistRunState()
    }

    func startNewRun() {
        RunPersistenceManager.clear()
        state = GameState(configuration: metaProgression.runConfiguration())
        normalizeSelectedBetForStage()
        lockGuidedOpeningBetIfNeeded()
        applyRunStartImmediateEffects()
        applyStageStartEffects()
        trackRunStarted()
        persistRunState()
    }

    private func drawCard() -> Card {
        if let card = state.shoe.draw() {
            return card
        }

        reshuffleShoe()
        if let card = state.shoe.draw() {
            return card
        }

        state.shoe = Shoe(deckCount: 6)
        return state.shoe.draw() ?? Card(suit: .spades, rank: .ace)
    }

    private func normalizeSelectedBetForStage() {
        if isBetAmountUnlocked(state.selectedBetAmountCents),
           selectedBetIsWithinRevealCap {
            return
        }

        state.selectedBetAmountCents = unlockedBetAmountsCents.first ?? 1_000
        clampSelectedBetForRevealCap()
    }

    private func clampSelectedBetForRevealCap() {
        guard let activeRevealBetCapCents,
              state.selectedBetAmountCents > activeRevealBetCapCents else {
            return
        }

        let legalAmounts = unlockedBetAmountsCents
            .filter { $0 <= activeRevealBetCapCents && $0 <= state.bankrollCents }
            .sorted()

        state.selectedBetAmountCents = legalAmounts.last ?? minimumUnlockedBetAmountCents
    }

    private var canUseShoeControlNow: Bool {
        state.runManager.status == .active
            && state.pendingUpgradeChoices.isEmpty
            && state.pendingStageRewardChoices.isEmpty
            && state.bossManager.pendingAnnouncementBoss == nil
            && state.bossManager.pendingBossRewardChoices.isEmpty
    }

    private func burnControlCharges(upgrades: UpgradeEffectSummary) -> Int {
        guard upgrades.burnCardInterval > 0 else {
            return 0
        }

        let earnedCharges = state.runManager.totalRoundsPlayed / upgrades.burnCardInterval
        return max(0, earnedCharges - state.burnControlUses)
    }

    private func burnControlRoundsUntilReady(upgrades: UpgradeEffectSummary) -> Int {
        guard upgrades.burnCardInterval > 0 else {
            return 0
        }

        if burnControlCharges(upgrades: upgrades) > 0 {
            return 0
        }

        let remainder = state.runManager.totalRoundsPlayed % upgrades.burnCardInterval
        return upgrades.burnCardInterval - remainder
    }

    private func applyAutomaticShoeControlBeforeDeal() -> (impact: ShoeImpact, messages: [String]) {
        // Shoe-control powers are player-triggered from the table so manipulation feels intentional.
        return (.none, [])
    }

    private func registerManualShoeControl(message: String, impact: ShoeImpact) {
        state.runManager.currentStageUpgradeTriggers += 1
        state.roundPresentation.shoeImpact = impact
        state.roundPresentation.upgradeMessages = [message]
        state.roundPresentation.payoutLedgerLines = []
        state.roundPresentation.sequenceID = UUID()
        logUpgradeActivations([message])
        state.runManager.evaluateStage(bankrollCents: state.bankrollCents)

        if state.runManager.status == .stageCleared {
            resolveStageClearFromNonRoundProgress()
        }

        persistRunState()
    }

    private func applyPostPayoutStageSafetyNetIfNeeded() -> (messages: [String], ledgerLines: [PayoutLedgerLine]) {
        let upgrades = activeUpgradeEffects
        guard upgrades.safetyNetThresholdPercent > 0,
              upgrades.safetyNetCents > 0,
              !state.hasUsedSafetyNetThisStage else {
            return ([], [])
        }

        let threshold = state.runManager.stageStartingBankrollCents * upgrades.safetyNetThresholdPercent / 100
        guard state.bankrollCents < threshold else {
            return ([], [])
        }

        state.bankrollCents += upgrades.safetyNetCents
        state.hasUsedSafetyNetThisStage = true
        return (
            ["Safety Net +\(MoneyFormatter.format(upgrades.safetyNetCents))"],
            [
                PayoutLedgerLine(
                    title: "Safety Net",
                    detail: "Bankroll fell below \(upgrades.safetyNetThresholdPercent)% of stage start",
                    amountCents: upgrades.safetyNetCents
                )
            ]
        )
    }

    private func logUpgradeActivations(_ messages: [String]) {
        guard !messages.isEmpty else {
            return
        }

#if DEBUG
        for message in messages {
            print("[Rigged Shoe Upgrade] \(message)")
        }
#endif
    }

    private func upgradeSourceLabel(
        matching predicate: (UpgradeEffect) -> Bool,
        fallback: String
    ) -> String {
        let names = effectiveUpgrades
            .filter { upgradeEffect($0.effect, contains: predicate) }
            .map(\.name)

        guard !names.isEmpty else {
            return fallback
        }

        if names.count <= 2 {
            return names.joined(separator: " + ")
        }

        return "\(names[0]) + \(names.count - 1) more"
    }

    private func upgradeEffect(
        _ effect: UpgradeEffect,
        contains predicate: (UpgradeEffect) -> Bool
    ) -> Bool {
        if predicate(effect) {
            return true
        }

        if case .combined(let nestedEffects) = effect {
            return nestedEffects.contains { upgradeEffect($0, contains: predicate) }
        }

        return false
    }

    private func logXRayPreviewIfNeeded(_ previewCards: [Card]) {
        guard !previewCards.isEmpty else {
            return
        }

#if DEBUG
        let preview = previewCards
            .enumerated()
            .map { "#\($0.offset + 1): \($0.element.displayText)" }
            .joined(separator: ", ")
        print("[Rigged Shoe X-Ray] Preview -> \(preview)")
#endif
    }

    private func verifyXRayPreviewIfNeeded(_ previewCards: [Card], result: RoundResult) {
        guard !previewCards.isEmpty else {
            return
        }

#if DEBUG
        let dealtCards = dealtCardsInOrder(from: result)
        let comparedCount = min(previewCards.count, dealtCards.count)
        let mismatches = (0..<comparedCount).filter { previewCards[$0].id != dealtCards[$0].id }

        if mismatches.isEmpty {
            let dealt = dealtCards
                .prefix(comparedCount)
                .enumerated()
                .map { "#\($0.offset + 1): \($0.element.displayText)" }
                .joined(separator: ", ")
            print("[Rigged Shoe X-Ray] Confirmed deal order -> \(dealt)")
        } else {
            let firstMismatch = mismatches[0]
            let expected = previewCards[firstMismatch].displayText
            let actual = dealtCards[firstMismatch].displayText
            print("[Rigged Shoe X-Ray WARNING] Preview mismatch at #\(firstMismatch + 1). Expected \(expected), dealt \(actual).")
        }
#endif
    }

    private func dealtCardsInOrder(from result: RoundResult) -> [Card] {
        var cards: [Card] = []

        if result.playerHand.cards.indices.contains(0) {
            cards.append(result.playerHand.cards[0])
        }

        if result.bankerHand.cards.indices.contains(0) {
            cards.append(result.bankerHand.cards[0])
        }

        if result.playerHand.cards.indices.contains(1) {
            cards.append(result.playerHand.cards[1])
        }

        if result.bankerHand.cards.indices.contains(1) {
            cards.append(result.bankerHand.cards[1])
        }

        if result.playerHand.cards.indices.contains(2) {
            cards.append(result.playerHand.cards[2])
        }

        if result.bankerHand.cards.indices.contains(2) {
            cards.append(result.bankerHand.cards[2])
        }

        return cards
    }

    private func prepareGuidedFirstDealIfNeeded() {
        guard state.isGuidedFirstRun,
              !state.guidedExcitingWinDelivered,
              state.runManager.totalRoundsPlayed == 0 else {
            return
        }

        state.selectedBetType = .player
        state.selectedBetAmountCents = min(state.selectedBetAmountCents, 1_000)
        state.shoe.placeCardsOnTop([
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .two),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .spades, rank: .three)
        ])
    }

    private func lockGuidedOpeningBetIfNeeded() {
        guard isGuidedOpeningHandLocked else {
            return
        }

        state.selectedBetType = .player
        state.selectedBetAmountCents = minimumUnlockedBetAmountCents
    }

    private func guidedFirstWinBonusIfNeeded(for result: RoundResult) -> Int {
        guard state.isGuidedFirstRun,
              !state.guidedExcitingWinDelivered,
              result.didWin else {
            return 0
        }

        state.guidedExcitingWinDelivered = true
        return 7_500
    }

    private func playBaccaratRound(
        betType: BetType,
        betAmountCents: Int,
        cardsBeforeRound: Int,
        forecastBeforeRound: DealForecast?
    ) -> (result: RoundResult, payout: PayoutResolution) {
        var playerHand = BaccaratHand()
        var bankerHand = BaccaratHand()

        playerHand.add(drawCard())
        bankerHand.add(drawCard())
        playerHand.add(drawCard())
        bankerHand.add(drawCard())
        let bankerInitialTotal = bankerHand.total
        let hasNatural = playerHand.isNatural || bankerHand.isNatural

        // Natural rule: if either initial two-card hand is 8 or 9, both hands stand.
        if !playerHand.isNatural && !bankerHand.isNatural {
            var playerThirdCard: Card?

            // Player draws on 0-5 and stands on 6-7.
            if playerHand.total <= 5 {
                let card = drawCard()
                playerThirdCard = card
                playerHand.add(card)
            }

            if shouldBankerDraw(bankerTotal: bankerHand.total, playerThirdCard: playerThirdCard) {
                bankerHand.add(drawCard())
            }
        }

        let winner = determineWinner(playerTotal: playerHand.total, bankerTotal: bankerHand.total)
        let cardsDealt = max(0, cardsBeforeRound - state.shoe.cardsRemaining)
        let payout = payoutCents(
            winner: winner,
            betType: betType,
            betAmountCents: betAmountCents,
            cardsDealt: cardsDealt,
            bankerInitialTotal: bankerInitialTotal,
            hasNatural: hasNatural,
            forecastBeforeRound: forecastBeforeRound
        )

        let result = RoundResult(
            playerHand: playerHand,
            bankerHand: bankerHand,
            winner: winner,
            betType: betType,
            betAmountCents: betAmountCents,
            payoutCents: payout.amount,
            isPush: payout.isPush
        )

        return (result, payout)
    }

    private func shouldBankerDraw(bankerTotal: Int, playerThirdCard: Card?) -> Bool {
        guard let playerThirdCard else {
            // If Player stood, Banker draws on 0-5 and stands on 6-7.
            return bankerTotal <= 5
        }

        let playerThirdValue = playerThirdCard.baccaratValue

        // Banker third-card rules are based on Banker's two-card total and Player's third card value.
        switch bankerTotal {
        case 0...2:
            return true
        case 3:
            return playerThirdValue != 8
        case 4:
            return (2...7).contains(playerThirdValue)
        case 5:
            return (4...7).contains(playerThirdValue)
        case 6:
            return (6...7).contains(playerThirdValue)
        default:
            return false
        }
    }

    private func determineWinner(playerTotal: Int, bankerTotal: Int) -> BetType {
        if playerTotal > bankerTotal {
            return .player
        }

        if bankerTotal > playerTotal {
            return .banker
        }

        return .tie
    }

    private func payoutCents(
        winner: BetType,
        betType: BetType,
        betAmountCents: Int,
        cardsDealt: Int,
        bankerInitialTotal: Int,
        hasNatural: Bool,
        forecastBeforeRound: DealForecast?
    ) -> PayoutResolution {
        let upgrades = activeUpgradeEffects
        var activationMessages: [String] = []
        var ledgerLines: [PayoutLedgerLine] = [
            PayoutLedgerLine(
                title: "Bet Placed",
                detail: "\(betType.displayName) wager",
                amountCents: -betAmountCents,
                isStructural: true
            )
        ]
        var usedDamageControl = false
        var usedHighRollerSparkAttempt = false
        var usedFaceHunter = false
        let roundStipend = upgrades.roundStipendCents
        let cardExitIncome = cardsDealt * upgrades.cardExitIncomeCents
        let passiveIncome = roundStipend + cardExitIncome
        let previousLossRefund = winner == .tie
            ? state.previousRoundLossCents * upgrades.previousLossRefundOnTiePercent / 100
            : 0

        if roundStipend > 0 {
            let source = upgradeSourceLabel(matching: { effect in
                if case .roundStipend = effect { return true }
                return false
            }, fallback: "Round Stipend")
            activationMessages.append("\(source) +\(MoneyFormatter.format(roundStipend))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "Round income", amountCents: roundStipend))
        }

        if cardExitIncome > 0 {
            let source = upgradeSourceLabel(matching: { effect in
                if case .cardExitIncome = effect { return true }
                return false
            }, fallback: "Shoe Income")
            activationMessages.append("\(source) +\(MoneyFormatter.format(cardExitIncome))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "\(cardsDealt) cards left the shoe", amountCents: cardExitIncome))
        }

        if previousLossRefund > 0 {
            let source = upgradeSourceLabel(matching: { effect in
                if case .previousLossRefundOnTie = effect { return true }
                return false
            }, fallback: "Lucky Push")
            activationMessages.append("\(source) refunded \(MoneyFormatter.format(previousLossRefund))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "Previous loss refunded by Tie", amountCents: previousLossRefund))
        }

        if winner == .tie && betType != .tie {
            return PayoutResolution(
                amount: betAmountCents + passiveIncome + previousLossRefund,
                isPush: true,
                activationMessages: activationMessages,
                ledgerLines: ledgerLines + [
                    PayoutLedgerLine(
                        title: "Tie Push Refund",
                        detail: "\(betType.displayName) bets push on Tie",
                        amountCents: betAmountCents,
                        isStructural: true
                    )
                ]
            )
        }

        guard winner == betType else {
            if upgrades.firstLargeBetMinCents > 0,
               betAmountCents >= upgrades.firstLargeBetMinCents,
               !state.hasUsedHighRollerSparkThisStage {
                usedHighRollerSparkAttempt = true
                activationMessages.append("High Roller Spark spent")
            }

            var lossRebate = betAmountCents * upgrades.lossRebatePercent / 100
            if lossRebate > 0 {
                let source = upgradeSourceLabel(matching: { effect in
                    if case .lossRebatePercent = effect { return true }
                    return false
                }, fallback: "Loss Rebate")
                activationMessages.append("\(source) refunded \(MoneyFormatter.format(lossRebate))")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Loss rebate", amountCents: lossRebate))
            }
            if upgrades.damageControlRebatePercent > 0,
               upgrades.damageControlEveryHands > 0,
               state.damageControlHandsSinceUse >= upgrades.damageControlEveryHands {
                let damageControlRebate = betAmountCents * upgrades.damageControlRebatePercent / 100
                lossRebate += damageControlRebate
                usedDamageControl = true
                activationMessages.append("Damage Control refunded \(MoneyFormatter.format(damageControlRebate))")
                ledgerLines.append(PayoutLedgerLine(title: "Damage Control", detail: "Once-per-cooldown loss refund", amountCents: damageControlRebate))
            }

            let extraLoss = betAmountCents * max(0, upgrades.lossMultiplierPercent - 100) / 100
            if extraLoss > 0 {
                let source = upgradeSourceLabel(matching: { effect in
                    if case .lossMultiplier = effect { return true }
                    return false
                }, fallback: "Risk Penalty")
                activationMessages.append("\(source) extra loss \(MoneyFormatter.format(extraLoss))")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Loss multiplier penalty", amountCents: -extraLoss))
            }

            return PayoutResolution(
                amount: passiveIncome + lossRebate - extraLoss + previousLossRefund,
                isPush: false,
                activationMessages: activationMessages,
                ledgerLines: ledgerLines,
                usedDamageControl: usedDamageControl,
                usedHighRollerSparkAttempt: usedHighRollerSparkAttempt
            )
        }

        var profitCents: Int
        var flatBonusCents = passiveIncome
            + previousLossRefund
            + upgrades.chosenBetWinBonusCents
            + upgrades.streakBonusCents(for: betType, streakCount: currentStreak(for: betType))
        if upgrades.chosenBetWinBonusCents > 0 {
            let source = upgradeSourceLabel(matching: { effect in
                if case .chosenBetWinBonus = effect { return true }
                return false
            }, fallback: "Chosen Bet Bonus")
            activationMessages.append("\(source) +\(MoneyFormatter.format(upgrades.chosenBetWinBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "Chosen bet won", amountCents: upgrades.chosenBetWinBonusCents))
        }

        let streakBonus = upgrades.streakBonusCents(for: betType, streakCount: currentStreak(for: betType))
        if streakBonus > 0 {
            let source = upgradeSourceLabel(matching: { effect in
                if case .streakBonus = effect { return true }
                return false
            }, fallback: "Streak Bonus")
            activationMessages.append("\(source) +\(MoneyFormatter.format(streakBonus))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "\(betType.displayName) streak bonus", amountCents: streakBonus))
        }

        if upgrades.forecastWinBonusCents > 0,
           let forecastBeforeRound,
           forecastBeforeRound.confidence != .locked,
           forecastBeforeRound.recommendedBet == betType,
           forecastBeforeRound.recommendedBet == winner {
            flatBonusCents += upgrades.forecastWinBonusCents
            let source = upgradeSourceLabel(matching: { effect in
                if case .forecastWinBonus = effect { return true }
                return false
            }, fallback: "Forecast Hit")
            activationMessages.append("\(source) hit +\(MoneyFormatter.format(upgrades.forecastWinBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "Correct predicted side", amountCents: upgrades.forecastWinBonusCents))
        }

        ledgerLines.append(
            PayoutLedgerLine(
                title: "Returned Stake",
                detail: "Winning \(betType.displayName) bet",
                amountCents: betAmountCents,
                isStructural: true
            )
        )

        switch betType {
        case .player:
            profitCents = betAmountCents
            ledgerLines.append(PayoutLedgerLine(title: "Base Payout", detail: "Player pays 1:1", amountCents: profitCents, isStructural: true))
            let playerBonus = upgrades.playerWinBonusCents * state.runManager.playerBonusMultiplier
            flatBonusCents += playerBonus
            if playerBonus > 0 {
                let source = upgradeSourceLabel(matching: { effect in
                    if case .playerWinBonus = effect { return true }
                    return false
                }, fallback: "Player Bonus")
                activationMessages.append("\(source) +\(MoneyFormatter.format(playerBonus))")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Player win bonus", amountCents: playerBonus))
            }
        case .banker:
            let noCommission = upgrades.removesBankerCommission && !state.bossManager.restoresBankerCommission
            let commissionedProfit = betAmountCents * 95 / 100
            profitCents = commissionedProfit
            ledgerLines.append(PayoutLedgerLine(title: "Base Payout", detail: "Banker pays 0.95:1 after commission", amountCents: commissionedProfit, isStructural: true))
            if noCommission {
                let commissionRefund = betAmountCents - commissionedProfit
                profitCents += commissionRefund
                let source = upgradeSourceLabel(matching: { effect in
                    if case .noCommission = effect { return true }
                    return false
                }, fallback: "No Commission")
                activationMessages.append("\(source): commission removed")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Banker commission removed", amountCents: commissionRefund))
            } else if state.bossManager.restoresBankerCommission && upgrades.removesBankerCommission {
                activationMessages.append("No Commission suppressed by boss")
            }
            let bankerBonus = upgrades.bankerWinBonusCents * state.runManager.bankerBonusMultiplier
            flatBonusCents += bankerBonus
            if bankerBonus > 0 {
                let source = upgradeSourceLabel(matching: { effect in
                    if case .bankerWinBonus = effect { return true }
                    return false
                }, fallback: "Banker Bonus")
                activationMessages.append("\(source) +\(MoneyFormatter.format(bankerBonus))")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Banker win bonus", amountCents: bankerBonus))
            }
        case .tie:
            var tieMultiplier = effectiveTiePayoutMultiplier(upgrades: upgrades)
            tieMultiplier += state.tieStreak * upgrades.consecutiveTiePayoutBonus
            profitCents = betAmountCents * 8
            ledgerLines.append(PayoutLedgerLine(title: "Base Payout", detail: "Tie pays 8:1", amountCents: profitCents, isStructural: true))
            if tieMultiplier > 8 {
                let tieBonus = betAmountCents * (tieMultiplier - 8)
                profitCents += tieBonus
                let source = upgradeSourceLabel(matching: { effect in
                    switch effect {
                    case .improveTiePayout, .tiePayoutBonus, .consecutiveTiePayoutBonus:
                        return true
                    default:
                        return false
                    }
                }, fallback: "Tie Payout")
                activationMessages.append("\(source): Tie payout \(tieMultiplier):1")
                ledgerLines.append(PayoutLedgerLine(title: source, detail: "Tie payout improved to \(tieMultiplier):1", amountCents: tieBonus))
            }

            if !state.hasPaidFirstTieThisStage {
                let before = profitCents
                profitCents *= upgrades.firstTieEachStageMultiplier
                if upgrades.firstTieEachStageMultiplier > 1 {
                    let source = upgradeSourceLabel(matching: { effect in
                        if case .firstTieEachStageMultiplier = effect { return true }
                        return false
                    }, fallback: "Twin Outcome")
                    activationMessages.append("\(source) x\(upgrades.firstTieEachStageMultiplier)")
                    ledgerLines.append(PayoutLedgerLine(title: source, detail: "First Tie this stage", amountCents: profitCents - before))
                }
            }
        }

        if betAmountCents <= upgrades.smallBetMaxCents,
           upgrades.smallBetWinMultiplierPercent > 100 {
            let before = profitCents
            profitCents = profitCents * upgrades.smallBetWinMultiplierPercent / 100
            activationMessages.append("Conservative Edge +\(MoneyFormatter.format(profitCents - before))")
            ledgerLines.append(PayoutLedgerLine(title: "Conservative Edge", detail: "Small bet win multiplier", amountCents: profitCents - before))
        }

        if state.lastRoundDidWin,
           betAmountCents > state.lastBetAmountCents,
           upgrades.pressAfterWinMultiplierPercent > 100 {
            let before = profitCents
            profitCents = profitCents * upgrades.pressAfterWinMultiplierPercent / 100
            activationMessages.append("Press the Advantage +\(MoneyFormatter.format(profitCents - before))")
            ledgerLines.append(PayoutLedgerLine(title: "Press the Advantage", detail: "Raised after a win", amountCents: profitCents - before))
        }

        if upgrades.firstLargeBetMinCents > 0,
           betAmountCents >= upgrades.firstLargeBetMinCents,
           !state.hasUsedHighRollerSparkThisStage {
            usedHighRollerSparkAttempt = true
            if upgrades.firstLargeBetMultiplierPercent > 100 {
                let before = profitCents
                profitCents = profitCents * upgrades.firstLargeBetMultiplierPercent / 100
                activationMessages.append("High Roller Spark +\(MoneyFormatter.format(profitCents - before))")
                ledgerLines.append(PayoutLedgerLine(title: "High Roller Spark", detail: "First large bet this stage", amountCents: profitCents - before))
            }
        }

        if upgrades.bankerInitialBonusCents > 0,
           bankerInitialTotal >= upgrades.bankerInitialBonusMinTotal,
           bankerInitialTotal <= upgrades.bankerInitialBonusMaxTotal {
            flatBonusCents += upgrades.bankerInitialBonusCents
            activationMessages.append("Dealer Pressure +\(MoneyFormatter.format(upgrades.bankerInitialBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: "Dealer Pressure", detail: "Banker initial total \(bankerInitialTotal)", amountCents: upgrades.bankerInitialBonusCents))
        }

        if hasNatural,
           upgrades.firstNaturalEachStageBonusCents > 0,
           !state.hasPaidFaceHunterThisStage {
            flatBonusCents += upgrades.firstNaturalEachStageBonusCents
            usedFaceHunter = true
            activationMessages.append("Face Hunter +\(MoneyFormatter.format(upgrades.firstNaturalEachStageBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: "Face Hunter", detail: "First natural this stage", amountCents: upgrades.firstNaturalEachStageBonusCents))
        }

        if upgrades.comebackWinBonusCents > 0,
           upgrades.comebackLossCount > 0,
           state.consecutiveLosses >= upgrades.comebackLossCount {
            flatBonusCents += upgrades.comebackWinBonusCents
            activationMessages.append("Comeback Chip +\(MoneyFormatter.format(upgrades.comebackWinBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: "Comeback Chip", detail: "Win after \(state.consecutiveLosses) losses", amountCents: upgrades.comebackWinBonusCents))
        }

        if upgrades.steadyBetWinBonusCents > 0,
           state.lastBetAmountCents > 0,
           betAmountCents <= state.lastBetAmountCents {
            flatBonusCents += upgrades.steadyBetWinBonusCents
            activationMessages.append("Discipline Bonus +\(MoneyFormatter.format(upgrades.steadyBetWinBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: "Discipline Bonus", detail: "Won without raising", amountCents: upgrades.steadyBetWinBonusCents))
        }

        if upgrades.raiseWinBonusCents > 0,
           upgrades.raiseWinMinCents > 0,
           state.lastBetAmountCents > 0,
           betAmountCents - state.lastBetAmountCents >= upgrades.raiseWinMinCents {
            flatBonusCents += upgrades.raiseWinBonusCents
            activationMessages.append("Aggressive Bonus +\(MoneyFormatter.format(upgrades.raiseWinBonusCents))")
            ledgerLines.append(PayoutLedgerLine(title: "Aggressive Bonus", detail: "Won after raising", amountCents: upgrades.raiseWinBonusCents))
        }

        if upgrades.smallBetStreakBonusCents > 0,
           upgrades.smallBetStreakRequiredWins > 0,
           betAmountCents <= upgrades.smallBetStreakMaxCents {
            let nextStreak = state.smallBetWinStreak + 1
            if nextStreak % upgrades.smallBetStreakRequiredWins == 0 {
                flatBonusCents += upgrades.smallBetStreakBonusCents
                activationMessages.append("Small Ball streak +\(MoneyFormatter.format(upgrades.smallBetStreakBonusCents))")
                ledgerLines.append(PayoutLedgerLine(title: "Small Ball", detail: "\(nextStreak) small-bet wins", amountCents: upgrades.smallBetStreakBonusCents))
            }
        }

        let profitMultiplier = upgrades.profitMultiplierPercent(for: betType)
        if profitMultiplier > 100 {
            let before = profitCents
            profitCents = profitCents * profitMultiplier / 100
            let source = upgradeSourceLabel(matching: { effect in
                if case .profitMultiplier = effect { return true }
                return false
            }, fallback: "\(betType.displayName) Bonus")
            activationMessages.append("\(source) +\(MoneyFormatter.format(profitCents - before))")
            ledgerLines.append(PayoutLedgerLine(title: source, detail: "\(betType.displayName) profit multiplier", amountCents: profitCents - before))
        } else {
            profitCents = profitCents * profitMultiplier / 100
        }
        return PayoutResolution(
            amount: betAmountCents + profitCents + flatBonusCents,
            isPush: false,
            activationMessages: activationMessages,
            ledgerLines: ledgerLines,
            usedDamageControl: usedDamageControl,
            usedHighRollerSparkAttempt: usedHighRollerSparkAttempt,
            usedFaceHunter: usedFaceHunter
        )
    }

    private func effectiveTiePayoutMultiplier(upgrades: UpgradeEffectSummary) -> Int {
        if state.bossManager.capsTiePayoutAtBase {
            return 8
        }

        let upgradedTie = upgrades.tiePayoutMultiplier + upgrades.tiePayoutBonus + state.runManager.tiePayoutBonus
        let rewardTie = state.runManager.tiePayoutOverride ?? 8
        return max(8 + state.runManager.tiePayoutBonus, upgradedTie, rewardTie)
    }

    private func currentStreak(for betType: BetType) -> Int {
        switch betType {
        case .player:
            return state.playerWinStreak
        case .banker:
            return state.bankerWinStreak
        case .tie:
            return state.tieStreak
        }
    }

    private func randomAcquiredUpgradeIndex() -> Int? {
        guard !state.acquiredUpgrades.isEmpty else {
            return nil
        }

        if var generator = state.seededGenerator {
            let index = Int(generator.next() % UInt64(state.acquiredUpgrades.count))
            state.seededGenerator = generator
            return index
        }

        return state.acquiredUpgrades.indices.randomElement()
    }

    private func shuffledAcquiredUpgrades() -> [UpgradeCard] {
        if var generator = state.seededGenerator {
            let shuffled = state.acquiredUpgrades.seededShuffled(using: &generator)
            state.seededGenerator = generator
            return shuffled
        }

        return state.acquiredUpgrades.shuffled()
    }

    private func mutateSeededRandom<T>(_ operation: (inout SeededRandomGenerator?) -> T) -> T {
        var generator = state.seededGenerator
        let value = operation(&generator)
        state.seededGenerator = generator
        return value
    }

    private func updateRoundMemory(result: RoundResult, bankrollBeforeRound: Int, payout: PayoutResolution) {
        let netChange = state.bankrollCents - bankrollBeforeRound
        state.previousRoundLossCents = max(0, -netChange)

        if result.didWin && result.winner == .tie {
            state.hasPaidFirstTieThisStage = true
        }

        if payout.usedDamageControl {
            state.damageControlHandsSinceUse = 0
        } else {
            state.damageControlHandsSinceUse += 1
        }

        if payout.usedHighRollerSparkAttempt {
            state.hasUsedHighRollerSparkThisStage = true
        }

        if payout.usedFaceHunter {
            state.hasPaidFaceHunterThisStage = true
        }

        if result.didWin {
            state.consecutiveLosses = 0
        } else if !result.isPush {
            state.consecutiveLosses += 1
        }

        let smallBetStreakMax = activeUpgradeEffects.smallBetStreakMaxCents
        if smallBetStreakMax > 0,
           result.didWin,
           result.betAmountCents <= smallBetStreakMax {
            state.smallBetWinStreak += 1
        } else if !result.isPush {
            state.smallBetWinStreak = 0
        }

        state.lastRoundDidWin = result.didWin
        state.lastBetAmountCents = result.betAmountCents

        switch result.winner {
        case .player:
            state.playerWinStreak += 1
            state.bankerWinStreak = 0
            state.tieStreak = 0
        case .banker:
            state.playerWinStreak = 0
            state.bankerWinStreak += 1
            state.tieStreak = 0
        case .tie:
            state.playerWinStreak = 0
            state.bankerWinStreak = 0
            state.tieStreak += 1
        }

        let revealGain = activeUpgradeEffects.revealAfterRoundCards
        if revealGain > 0 {
            state.runManager.permanentRevealCount = min(2, state.runManager.permanentRevealCount + revealGain)
        }

    }

    private func queueShoeUpgradeRewardIfNeeded() {
        guard state.roundsSinceLastUpgrade >= upgradeRewardThreshold else {
            return
        }

        if state.isGuidedFirstRun && !state.hasOfferedGuidedUpgrade {
            state.hasOfferedGuidedUpgrade = true
            let curatedNames = ["Opening Tell", "Conservative Edge", "Press the Advantage"]
            let curatedChoices = curatedNames.compactMap { name in
                unlockedUpgradeCards.first { $0.name == name }?.copyForAcquisition()
                    ?? UpgradeCard.allCards.first { $0.name == name }?.copyForAcquisition()
            }

            if curatedChoices.count == 3 {
                state.pendingUpgradeChoices = curatedChoices
                return
            }
        }

        state.pendingUpgradeChoices = mutateSeededRandom { generator in
            UpgradeCard.randomChoices(
                count: 3,
                availableCards: unlockedUpgradeCards,
                seededGenerator: &generator,
                acquiredCards: state.acquiredUpgrades
            )
        }
    }

    private func applyImmediateEffect(_ effect: UpgradeEffect) -> ShoeImpact {
        switch effect {
        case .combined(let effects):
            var latestImpact = ShoeImpact.none

            for nestedEffect in effects {
                let impact = applyImmediateEffect(nestedEffect)
                if impact != .none {
                    latestImpact = impact
                }
            }

            return latestImpact
        case .addExtraNines(let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: [.nine], count: count, seededGenerator: &generator)
            }
            return .injectedCards(count)
        case .addExtraEights(let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: [.eight], count: count, seededGenerator: &generator)
            }
            return .injectedCards(count)
        case .addCards(let rank, let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: [rank], count: count, seededGenerator: &generator)
            }
            return .injectedCards(count)
        case .addRandomCards(let ranks, let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: ranks, count: count, seededGenerator: &generator)
            }
            return .injectedCards(count)
        case .addTiePairCards(let pairs):
            mutateSeededRandom { generator in
                state.shoe.addTiePairCards(pairs: pairs, seededGenerator: &generator)
            }
            return .injectedCards(pairs * 2)
        case .removeZeroValueCards(let count):
            let removedCount = mutateSeededRandom { generator in
                state.shoe.removeRandomZeroValueCards(count: count, seededGenerator: &generator)
            }
            return .removedCards(removedCount)
        case .removeCards(let ranks, let count):
            let removedCount = mutateSeededRandom { generator in
                state.shoe.removeRandomCards(ranks: Set(ranks), count: count, seededGenerator: &generator)
            }
            return .removedCards(removedCount)
        case .limitedXRayReveal(_, let chargesPerStage):
            state.xRayChargesRemainingThisStage = max(state.xRayChargesRemainingThisStage, chargesPerStage)
            state.isXRayActiveForNextHand = false
            return .none
        case .shoeReveal(let configuration):
            if configuration.isCharged {
                state.xRayChargesRemainingThisStage = max(state.xRayChargesRemainingThisStage, configuration.chargesPerStage)
                state.isXRayActiveForNextHand = false
            }
            return .none
        case .playerWinBonus,
             .bankerWinBonus,
             .chosenBetWinBonus,
             .forecastWinBonus,
             .improveTiePayout,
             .tiePayoutBonus,
             .revealCards,
             .revealAfterRound,
             .noCommission,
             .hotShoe,
             .coldShoe,
             .profitMultiplier,
             .lossMultiplier,
             .lossRebatePercent,
             .roundStipend,
             .stageStartCash,
             .cardExitIncome,
             .streakBonus,
             .firstTieEachStageMultiplier,
             .consecutiveTiePayoutBonus,
             .previousLossRefundOnTie,
             .bossStageCash,
             .safetyNet,
             .smallBetWinMultiplier,
             .smallBetStreakBonus,
             .pressAfterWinMultiplier,
             .lossRebateEveryHands,
             .burnCardEveryHands,
             .moveTopCardDeeper,
             .bankerInitialTotalBonus,
             .firstNaturalEachStageBonus,
             .comebackWinBonus,
             .firstLargeBetStageMultiplier,
             .steadyBetWinBonus,
             .raiseWinBonus:
            return .none
        }
    }

    private func applyStageReward(_ reward: StageReward) {
        switch reward.effect {
        case .gainCash(let cents):
            state.bankrollCents += cents
        case .gainAnteScaledCash(let multiplierPercent):
            let calculation = EconomyRewardCalculation.stageCashReward(
                stage: state.runManager.currentStage,
                bankrollCents: state.bankrollCents,
                multiplierPercent: multiplierPercent
            )
            state.bankrollCents += calculation.cashRewardCents
        case .gainChips(let amount):
            state.runManager.chips += max(0, amount)
        case .reduceHeat(let amount):
            state.runManager.heat = max(0, state.runManager.heat - max(0, amount))
        case .removeRandomAcquiredUpgrade:
            guard let index = randomAcquiredUpgradeIndex() else {
                return
            }

            state.acquiredUpgrades.remove(at: index)
        case .duplicateRandomAcquiredUpgrade:
            guard let index = randomAcquiredUpgradeIndex() else {
                return
            }

            let upgrade = state.acquiredUpgrades[index].copyForAcquisition()
            state.acquiredUpgrades.append(upgrade)
            registerShoeImpact(applyImmediateEffect(upgrade.effect))
        case .addRandomUpgrade(let rarity):
            guard let upgrade = mutateSeededRandom({ generator in
                UpgradeCard.randomCard(
                    rarity: rarity,
                    availableCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }) else {
                return
            }

            state.acquiredUpgrades.append(upgrade)
            registerShoeImpact(applyImmediateEffect(upgrade.effect))
        case .increaseTiePayout(let amount):
            state.runManager.tiePayoutBonus += amount
        case .addRandomHighValueCards(let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomHighValueCards(count: count, seededGenerator: &generator)
            }
            registerShoeImpact(.injectedCards(count))
        case .removeRandomFaceCards(let count):
            let removedCount = mutateSeededRandom { generator in
                state.shoe.removeRandomFaceCards(count: count, seededGenerator: &generator)
            }
            registerShoeImpact(.removedCards(removedCount))
        }
    }

    private func applyBossReward(_ reward: BossReward) {
        switch reward.effect {
        case .doublePlayerBonuses:
            state.runManager.playerBonusMultiplier *= 2
        case .doubleBankerBonuses:
            state.runManager.bankerBonusMultiplier *= 2
        case .addRandomHighValueCards(let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomHighValueCards(count: count, seededGenerator: &generator)
            }
            registerShoeImpact(.injectedCards(count))
        case .revealCardsPermanently(let count):
            state.runManager.permanentRevealCount = max(state.runManager.permanentRevealCount, count)
        case .setTiePayout(let multiplier):
            state.runManager.tiePayoutOverride = max(state.runManager.tiePayoutOverride ?? 8, multiplier)
        case .gainCash(let cents):
            state.bankrollCents += cents
        case .gainAnteScaledCash(let multiplierPercent, let chips):
            let calculation = EconomyRewardCalculation.bossCashReward(
                stage: state.runManager.currentStage,
                bankrollCents: state.bankrollCents,
                multiplierPercent: multiplierPercent,
                chipsReward: chips
            )
            state.bankrollCents += calculation.cashRewardCents
            state.runManager.chips += calculation.chipsReward
        case .duplicateRandomUpgrades(let count):
            for upgrade in shuffledAcquiredUpgrades().prefix(count) {
                let copiedUpgrade = upgrade.copyForAcquisition()
                state.acquiredUpgrades.append(copiedUpgrade)
                registerShoeImpact(applyImmediateEffect(copiedUpgrade.effect))
            }
        case .removeAllFaceCards:
            let removedCount = state.shoe.removeAllFaceCards()
            registerShoeImpact(.removedCards(removedCount))
        case .addRandomLegendaryUpgrade:
            guard let upgrade = mutateSeededRandom({ generator in
                UpgradeCard.randomCard(
                    rarity: .legendary,
                    availableCards: unlockedUpgradeCards,
                    seededGenerator: &generator
                )
            }) else {
                return
            }

            state.acquiredUpgrades.append(upgrade)
            registerShoeImpact(applyImmediateEffect(upgrade.effect))
        case .casinoInsideContact(let extraRounds):
            state.runManager.futureStageRoundBonus += extraRounds
        }
    }

    private func prepareBossAnnouncementIfNeeded() {
        guard state.runManager.status == .active else {
            return
        }

        var bossGenerator = state.dailySeed.map {
            SeededRandomGenerator(seed: $0 &+ UInt64(state.runManager.currentStage.id * 10_007))
        } ?? state.seededGenerator

        state.bossManager.prepareBossIfNeeded(
            for: state.runManager.currentStage.id,
            challengeID: state.challengeID,
            seededGenerator: &bossGenerator
        )

        if state.dailySeed == nil {
            state.seededGenerator = bossGenerator
        }
    }

    private func reshuffleShoe() {
        clearTemporaryRevealOnShoeMutation()
        mutateSeededRandom { generator in
            state.shoe.reshuffle(seededGenerator: &generator)
        }
        applyReshuffleEffects()
    }

    private func shuffleRemainingShoeForBoss() {
        clearTemporaryRevealOnShoeMutation()
        mutateSeededRandom { generator in
            state.shoe.shuffleRemainingCards(seededGenerator: &generator)
        }
        applyReshuffleEffects()
    }

    private func clearTemporaryRevealOnShoeMutation() {
        state.isXRayActiveForNextHand = false
    }

    private func applyReshuffleEffects() {
        let upgrades = activeUpgradeEffects

        if upgrades.hotShoeExtraEights > 0 {
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: [.eight], count: upgrades.hotShoeExtraEights, seededGenerator: &generator)
            }
        }

        if upgrades.hotShoeExtraNines > 0 {
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: [.nine], count: upgrades.hotShoeExtraNines, seededGenerator: &generator)
            }
        }

        if upgrades.coldShoeZeroCardsToRemove > 0 {
            _ = mutateSeededRandom { generator in
                state.shoe.removeRandomZeroValueCards(count: upgrades.coldShoeZeroCardsToRemove, seededGenerator: &generator)
            }
        }
    }

    private func applyRunStartImmediateEffects() {
        for upgrade in state.acquiredUpgrades {
            _ = applyImmediateEffect(upgrade.effect)
        }
    }

    private func applyStageStartEffects() {
        state.hasPaidFirstTieThisStage = false
        state.hasUsedSafetyNetThisStage = false
        state.hasUsedHighRollerSparkThisStage = false
        state.hasPaidFaceHunterThisStage = false
        state.hasMovedCardThisStage = false
        state.isXRayActiveForNextHand = false
        state.xRayChargesRemainingThisStage = activeUpgradeEffects.chargedShoeReveal?.chargesPerStage ?? 0
        let cash = activeUpgradeEffects.stageStartCashCents

        if cash > 0 {
            state.bankrollCents += cash
            state.runManager.updateHighs(bankrollCents: state.bankrollCents)
            state.roundPresentation.bankrollDeltaCents = cash
            state.roundPresentation.payoutLedgerLines = [
                PayoutLedgerLine(title: "Stage Start Cash", detail: "Upgrade granted cash at stage start", amountCents: cash)
            ]
            state.roundPresentation.sequenceID = UUID()
            recordRunSnapshot()
        }
    }

    private func applyBossStageStartEffects() {
        guard state.bossManager.activeBoss != nil else {
            return
        }

        let cash = activeUpgradeEffects.bossStageCashCents
        guard cash > 0 else {
            return
        }

        state.bankrollCents += cash
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        state.roundPresentation.bankrollDeltaCents = cash
        state.roundPresentation.payoutLedgerLines = [
            PayoutLedgerLine(title: "Boss Stage Cash", detail: "Upgrade granted cash for boss stage", amountCents: cash)
        ]
        state.roundPresentation.sequenceID = UUID()
        recordRunSnapshot()
    }

    private func registerShoeImpact(_ impact: ShoeImpact) {
        guard impact != .none else {
            return
        }

        state.roundPresentation.shoeImpact = impact
        state.roundPresentation.sequenceID = UUID()
    }

    private func winTier(for result: RoundResult) -> WinTier {
        if result.isPush {
            return .push
        }

        guard result.didWin else {
            return .loss
        }

        let net = result.netCents
        let bet = max(1, result.betAmountCents)

        if net >= bet * 25 {
            return .jackpot
        }

        if net >= bet * 10 {
            return .huge
        }

        if net >= bet * 2 {
            return .big
        }

        return .normal
    }

    private func recordRunSnapshot() {
        recordProgressionAward(
            mutateMetaProgression { manager in
                manager.recordRunSnapshot(
                    bankrollCents: state.bankrollCents,
                    profitCents: state.runManager.currentProfitCents(bankrollCents: state.bankrollCents),
                    revealedCards: revealedShoeCards,
                    acquiredUpgrades: state.acquiredUpgrades
                )
            }
        )
    }

    private func recordRunEndIfNeeded() {
        guard !state.didRecordRunEnd,
              state.runManager.status == .failed || state.runManager.status == .completed else {
            return
        }

        state.didRecordRunEnd = true

        recordProgressionAward(
            mutateMetaProgression { manager in
                manager.recordRunEnded(
                    didWin: state.runManager.status == .completed,
                    bankrollCents: state.bankrollCents,
                    profitCents: state.runManager.currentProfitCents(bankrollCents: state.bankrollCents),
                    revealedCards: revealedShoeCards,
                    acquiredUpgrades: state.acquiredUpgrades,
                    chipMultiplierPercent: state.chipRewardMultiplierPercent,
                    challengeID: state.challengeID,
                    stageReached: state.runManager.stageReached,
                    isDailyRun: state.isDailyRun,
                    dailySeed: state.dailySeed
                )
            }
        )

        let didWin = state.runManager.status == .completed
        track(
            .runEnded,
            properties: [
                "didWin": "\(didWin)",
                "stage": "\(state.runManager.stageReached)",
                "profit": "\(state.runManager.currentProfitCents(bankrollCents: state.bankrollCents))",
                "roundsPlayed": "\(state.runManager.totalRoundsPlayed)",
                "highestProfit": "\(state.runManager.highestProfitCents)",
                "challenge": state.challengeID.rawValue,
                "topArchetype": topArchetypeName(),
                "failedBoss": state.bossManager.activeBoss?.name ?? ""
            ]
        )

        if state.challengeID != .standard {
            track(
                .challengeCompleted,
                properties: [
                    "challenge": state.challengeID.rawValue,
                    "didWin": "\(didWin)",
                    "stage": "\(state.runManager.stageReached)"
                ]
            )
        }
    }

    private func mutateMetaProgression(_ mutation: (inout MetaProgressionManager) -> ProgressionAward) -> ProgressionAward {
        var manager = metaProgression
        let award = mutation(&manager)
        metaProgression = manager
        return award
    }

    private func recordProgressionAward(_ award: ProgressionAward) {
        state.metaChipsEarnedThisRun += award.chips
        state.metaReputationEarnedThisRun += award.reputation

        for achievement in award.achievements {
            track(
                .achievementEarned,
                properties: [
                    "achievement": achievement.name,
                    "chips": "\(achievement.chipReward)"
                ]
            )
        }
    }

    private func markGuidedFirstRunCompleted() {
        var manager = metaProgression
        manager.markGuidedFirstRunCompleted()
        metaProgression = manager
        state.isGuidedFirstRun = false
    }

    private func persistRunState() {
        RunPersistenceManager.save(state)
    }

    private func trackRunStarted() {
        track(
            .runStarted,
            properties: [
                "challenge": state.challengeID.rawValue,
                "isDaily": "\(state.isDailyRun)",
                "startingBankroll": "\(state.runManager.startingBankrollCents)",
                "theme": state.themeID.rawValue
            ]
        )

        if state.challengeID != .standard {
            track(.challengeStarted, properties: ["challenge": state.challengeID.rawValue])
        }
    }

    private func track(_ name: AnalyticsEventName, properties: [String: String] = [:]) {
        var manager = analytics
        manager.track(name, properties: properties)
        analytics = manager
    }

    private func topArchetypeName() -> String {
        var counts: [UpgradeTag: Int] = [:]

        for upgrade in state.acquiredUpgrades {
            for tag in upgrade.tags where tag != .legendary {
                counts[tag, default: 0] += 1
            }
        }

        return counts.max { first, second in first.value < second.value }?.key.displayName ?? "None"
    }
}
