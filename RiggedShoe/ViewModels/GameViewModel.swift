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

enum GameplayPresentationState: Equatable {
    case idle
    case guidedOpeningLock
    case resolvingHand(roundID: UUID)
    case finalHandReview(roundID: UUID)
    case stageResultReview
}

enum DisabledWagerReason: String, Equatable {
    case guidedLock
    case stageUnavailable
    case insufficientBankroll
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published private(set) var metaProgression: MetaProgressionManager
    @Published private(set) var analytics: AnalyticsManager
    @Published private(set) var isDealResolutionLocked = false
    private let sessionStartedAt = Date()
    private let logger: RiggedShoeLogging
    private var modifierEngine = ModifierEngine()

    let betAmountsCents = Array(Set(Stage.verticalSliceStages.flatMap(\.betLimit.allowedBetAmountsCents))).sorted()

    init(metaProgression: MetaProgressionManager = MetaProgressionManager(), logger: RiggedShoeLogging = OSRiggedShoeLogger()) {
        self.logger = logger
        self.metaProgression = metaProgression
        self.analytics = AnalyticsManager()
        let configuration = metaProgression.runConfiguration()

        if let restoredState = RunPersistenceManager.restore(configuration: configuration) {
            self.state = restoredState
            normalizeTransientPresentationAfterRestore()
            clearLegacyShoeUpgradeDraftIfNeeded()
            normalizeSelectedBetForStage()
            lockGuidedOpeningBetIfNeeded()
            logState(.runRestored, fields: ["flow": state.runManager.flowState.rawValue, "status": state.runManager.status.storageValueForLogging])
        } else {
            self.state = GameState(configuration: configuration)
            clearLegacyShoeUpgradeDraftIfNeeded()
            normalizeSelectedBetForStage()
            lockGuidedOpeningBetIfNeeded()
            applyRunStartImmediateEffects()
            applyStageStartEffects()
            trackRunStarted()
            logState(.runStarted, fields: ["flow": state.runManager.flowState.rawValue])
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
            && isBetAmountPlayable(state.selectedBetAmountCents)
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
            ? "First hand: Player $25. Other bets unlock after the deal."
            : nil
    }

    var presentationState: GameplayPresentationState {
        if let latestRoundID = state.latestRound?.id {
            if state.runManager.flowState == .stageResult,
               state.runManager.currentStageRoundsPlayed >= state.runManager.currentRoundLimit {
                return .finalHandReview(roundID: latestRoundID)
            }

            if isDealResolutionLocked {
                return .resolvingHand(roundID: latestRoundID)
            }
        }

        if state.runManager.flowState == .stageResult {
            return .stageResultReview
        }

        if isGuidedOpeningHandLocked {
            return .guidedOpeningLock
        }

        return .idle
    }

    func disabledWagerReason(for betType: BetType, amountCents: Int) -> DisabledWagerReason? {
        if isGuidedOpeningHandLocked,
           (betType != .player || amountCents != minimumUnlockedBetAmountCents) {
            return .guidedLock
        }

        guard state.runManager.status == .active,
              state.runManager.flowState == .battle,
              state.pendingUpgradeChoices.isEmpty,
              state.pendingStageRewardChoices.isEmpty,
              state.bossManager.pendingAnnouncementBoss == nil,
              state.bossManager.pendingBossRewardChoices.isEmpty else {
            return .stageUnavailable
        }

        if amountCents > state.bankrollCents {
            return .insufficientBankroll
        }

        if !state.runManager.isBetAmountAllowed(amountCents, bankrollCents: state.bankrollCents)
            || amountCents > contactAdjustedMaxBetCents {
            return .stageUnavailable
        }

        return nil
    }

    var unlockedBetAmountsCents: [Int] {
        state.runManager.currentStage.betLimit.allowedBetAmountsCents
    }

    var stageResultData: StageResultData? {
        state.runManager.lastStageResult
    }

    var stagePreviewData: StagePreviewData {
        state.runManager.stagePreviewData
    }

    var currentPayoutRules: TablePayoutRules {
        var bankerCommissionPercent = activeBankerCommissionPercent()
        if let commissionLevel = highestActiveModifierLevel(for: "banker.commission-dodge") {
            let modifierCommission: Int
            switch commissionLevel {
            case 3...:
                modifierCommission = 2
            case 2:
                modifierCommission = 3
            default:
                modifierCommission = 4
            }
            bankerCommissionPercent = min(bankerCommissionPercent, modifierCommission)
        }

        if activeUpgradeEffects.removesBankerCommission,
           !state.bossManager.restoresBankerCommission {
            bankerCommissionPercent = 0
        }

        var tiePayoutMultiplier = effectiveTiePayoutMultiplier(upgrades: activeUpgradeEffects)
        if !state.bossManager.capsTiePayoutAtBase {
            if let equalizerLevel = highestActiveModifierLevel(for: "tie.equalizer") {
                tiePayoutMultiplier = max(tiePayoutMultiplier, 8 + min(3, equalizerLevel))
            }
            if highestActiveModifierLevel(for: "tie.tie-master") != nil {
                tiePayoutMultiplier = max(tiePayoutMultiplier + 1, 9)
            }
        }
        tiePayoutMultiplier = min(tiePayoutMultiplier, BalanceMath.tiePayoutCeiling)

        return TablePayoutRules(
            bankerCommissionPercent: bankerCommissionPercent,
            tiePayoutMultiplier: tiePayoutMultiplier
        )
    }

    func baseWinProfitCents(for betType: BetType, betAmountCents: Int) -> Int {
        currentPayoutRules.profitCents(for: betType, betAmountCents: betAmountCents)
    }

    func preDealPayoutText(for betType: BetType, betAmountCents: Int) -> String {
        currentPayoutRules.preDealText(for: betType, betAmountCents: betAmountCents)
    }

    var startingContacts: [StartingContact] {
        StartingContact.allContacts
    }

    var ownedModifierIDs: [String] {
        (state.activeModifiers + state.benchModifiers).map(\.modifierID)
    }

    private func highestActiveModifierLevel(for modifierID: String) -> Int? {
        state.activeModifiers
            .filter { $0.modifierID == modifierID }
            .map(\.level)
            .max()
    }

    var activeModifierDefinitions: [(ModifierInstance, Modifier)] {
        state.activeModifiers.compactMap { instance in
            guard let definition = Modifier.definition(id: instance.modifierID) else {
                return nil
            }

            return (instance, definition)
        }
    }

    var benchModifierDefinitions: [(ModifierInstance, Modifier)] {
        state.benchModifiers.compactMap { instance in
            guard let definition = Modifier.definition(id: instance.modifierID) else {
                return nil
            }

            return (instance, definition)
        }
    }

    func selectStartingContact(_ contact: StartingContact) {
        guard state.runManager.flowState == .runStart, !state.hasAppliedStartingContact else {
            return
        }

        state.startingContact = contact
        logState(.contactSelected, fields: ["contactID": contact.id])
        persistRunState()
    }

    private func applyStartingContactIfNeeded() {
        guard !state.hasAppliedStartingContact else {
            return
        }

        let contact = state.startingContact
        let adjustedBankroll = max(5_000, state.bankrollCents + contact.bankrollAdjustmentCents)
        state.bankrollCents = adjustedBankroll
        state.runManager = RunManager(startingBankrollCents: adjustedBankroll)
        state.runManager.chips = max(0, state.runManager.chips + contact.chipsAdjustment)
        state.runManager.heat = min(state.runManager.maxHeat, max(0, state.runManager.heat + contact.heatAdjustment))
        state.activeModifiers = contact.startingModifiers
            .filter { ActiveModifierCatalog.acquisitionClass(for: $0) == .starter }
            .prefix(state.activeModifierSlotLimit)
            .map { ModifierInstance(modifierID: $0) }
        state.consumables = contact.startingConsumables
            .compactMap(Consumable.definition(id:))
            .prefix(state.consumableSlotLimit)
            .map { $0 }
        state.hasAppliedStartingContact = true
        modifierEngine.resetRun()
        appendDebugBattleEvent("Starting contact selected: \(contact.name)")
        logState(.contactSelected, fields: ["contactID": contact.id, "applied": "true"])
    }

    func prepareShop(forceReroll: Bool = false, emitShopEnteredEvent: Bool = true) {
        let frozen = forceReroll ? state.shopState.offers.filter(\.isFrozen) : state.shopState.offers
        var generator = state.seededGenerator
        state.shopState = ShopState.generated(
            stageID: state.runManager.currentStage.id,
            ante: state.runManager.currentStage.ante,
            defeatedBosses: state.bossManager.defeatedBosses.count,
            frozenOffers: frozen,
            ownedModifierIDs: ownedModifierIDs,
            contactBiasTags: state.startingContact.shopBiasTags,
            seededGenerator: &generator
        )
        state.seededGenerator = generator
        appendDebugBattleEvent("Shop entered: tier \(ShopState.tier(for: state.runManager.currentStage.id, defeatedBosses: state.bossManager.defeatedBosses.count))")
        logState(.shopEntered, fields: ["offers": "\(state.shopState.offers.count)", "reroll": "\(forceReroll)"])
        if emitShopEnteredEvent {
            emitOutOfHandModifierEvent(.shopEntered)
        }
        persistRunState()
    }

    func toggleFreezeShopOffer(_ offer: ShopOffer) {
        guard let index = state.shopState.offers.firstIndex(where: { $0.id == offer.id }),
              !state.shopState.offers[index].isSoldOut else {
            return
        }

        state.shopState.offers[index].isFrozen.toggle()
        persistRunState()
    }

    func rerollShop() {
        guard state.runManager.chips >= state.shopState.rerollCostChips else {
            logState(.shopPurchaseRejected, fields: ["reason": "insufficientChips", "action": "reroll"])
            return
        }

        let nextRerollCount = state.shopState.rerollsThisStage + 1
        let rerollCost = state.shopState.rerollCostChips
        state.runManager.chips -= state.shopState.rerollCostChips
        prepareShop(forceReroll: true, emitShopEnteredEvent: false)
        state.shopState.rerollsThisStage = nextRerollCount
        appendDebugBattleEvent("GameEvent.shopRerolled cost=\(rerollCost)")
        logState(.shopRerolled, fields: ["costChips": "\(rerollCost)", "rerollCount": "\(nextRerollCount)"])
        emitOutOfHandModifierEvent(.shopRerolled)
        persistRunState()
    }

    func buyShopOffer(_ offer: ShopOffer) {
        guard let index = state.shopState.offers.firstIndex(where: { $0.id == offer.id }),
              !state.shopState.offers[index].isSoldOut,
              canBuyShopOffer(offer) else {
            logState(.shopPurchaseRejected, fields: ["offerID": offer.contentID, "kind": offer.kind.rawValue, "reason": shopOfferBlockedReason(offer) ?? "unavailable"])
            return
        }

        let chipsBeforePurchase = state.runManager.chips
        let previousOwnedLevel = highestOwnedModifierLevel(for: offer.contentID)

        switch offer.kind {
        case .modifier:
            guard buyModifier(id: offer.contentID) else {
                return
            }
        case .consumable:
            guard let consumable = Consumable.definition(id: offer.contentID),
                  state.consumables.count < state.consumableSlotLimit else {
                return
            }
            state.consumables.append(consumable)
        case .attachment:
            guard let attachment = Attachment.definition(id: offer.contentID),
                  attach(attachment) else {
                return
            }
            if !state.attachments.contains(where: { $0.id == attachment.id }) {
                state.attachments.append(attachment)
            }
        case .bossRelic:
            guard state.bossRelics.count < state.bossRelicSlotLimit else {
                return
            }
            if let relic = BossRelic.definition(id: offer.contentID) ?? BossRelic.allRelics.first {
                state.bossRelics.append(relic)
            }
        }

        state.runManager.chips -= offer.priceChips
        state.shopState.offers[index].isSoldOut = true
        state.shopState.offers[index].isFrozen = false
        if offer.kind == .modifier {
            let currentLevel = highestOwnedModifierLevel(for: offer.contentID)
            appendDebugBattleEvent("GameEvent.modifierBought \(offer.contentID)")
            logState(.modifierChanged, fields: ["modifierID": offer.contentID, "action": "bought"])
            emitOutOfHandModifierEvent(.modifierBought(modifierID: offer.contentID))

            if let previousOwnedLevel,
               let currentLevel,
               currentLevel > previousOwnedLevel {
                emitOutOfHandModifierEvent(.modifierLeveled(modifierID: offer.contentID, newLevel: currentLevel))
            }
        } else {
            appendDebugBattleEvent("Shop item bought \(offer.contentID)")
        }
        logState(
            .shopPurchaseAccepted,
            fields: [
                "offerID": offer.contentID,
                "kind": offer.kind.rawValue,
                "chipsDelta": "\(state.runManager.chips - chipsBeforePurchase)"
            ]
        )
        persistRunState()
    }

    func canBuyShopOffer(_ offer: ShopOffer) -> Bool {
        guard !offer.isSoldOut,
              state.runManager.chips >= offer.priceChips else {
            return false
        }

        switch offer.kind {
        case .modifier:
            return canBuyModifier(id: offer.contentID)
        case .consumable:
            return Consumable.definition(id: offer.contentID) != nil
                && state.consumables.count < state.consumableSlotLimit
        case .attachment:
            guard let attachment = Attachment.definition(id: offer.contentID) else {
                return false
            }

            return attachmentTargetIndex(for: attachment) != nil
        case .bossRelic:
            return state.bossRelics.count < state.bossRelicSlotLimit
        }
    }

    func shopOfferBlockedReason(_ offer: ShopOffer) -> String? {
        if offer.isSoldOut {
            return "Already bought"
        }

        if state.runManager.chips < offer.priceChips {
            return "Need \(offer.priceChips - state.runManager.chips) more Chip\(offer.priceChips - state.runManager.chips == 1 ? "" : "s")"
        }

        switch offer.kind {
        case .modifier:
            return canBuyModifier(id: offer.contentID) ? nil : "Modifier slots full"
        case .consumable:
            return state.consumables.count >= state.consumableSlotLimit ? "Consumable slot full" : nil
        case .attachment:
            guard Attachment.definition(id: offer.contentID) != nil else {
                return "Unknown attachment"
            }

            return attachmentTargetName(for: offer.contentID) == nil ? "No compatible active modifier" : nil
        case .bossRelic:
            return state.bossRelics.count >= state.bossRelicSlotLimit ? "Boss relic slot full" : nil
        }
    }

    func attachmentTargetName(for attachmentID: String) -> String? {
        guard let attachment = Attachment.definition(id: attachmentID),
              let index = attachmentTargetIndex(for: attachment),
              let modifier = Modifier.definition(id: state.activeModifiers[index].modifierID) else {
            return nil
        }

        return modifier.name
    }

    private func highestOwnedModifierLevel(for modifierID: String) -> Int? {
        (state.activeModifiers + state.benchModifiers)
            .filter { $0.modifierID == modifierID }
            .map(\.level)
            .max()
    }

    private func canBuyModifier(id: String) -> Bool {
        guard ActiveModifierCatalog.isProductionAvailable(id),
              let definition = Modifier.definition(id: id) else {
            return false
        }

        if state.activeModifiers.contains(where: { $0.modifierID == id && $0.level < definition.maxLevel }) {
            return true
        }

        if state.benchModifiers.contains(where: { $0.modifierID == id && $0.level < definition.maxLevel }) {
            return true
        }

        if state.activeModifiers.contains(where: { $0.modifierID == id })
            || state.benchModifiers.contains(where: { $0.modifierID == id }) {
            return false
        }

        return state.activeModifiers.count < state.activeModifierSlotLimit
    }

    @discardableResult
    private func buyModifier(id: String) -> Bool {
        guard ActiveModifierCatalog.isProductionAvailable(id),
              let definition = Modifier.definition(id: id) else {
            return false
        }

        if let activeIndex = state.activeModifiers.firstIndex(where: { $0.modifierID == id && $0.level < definition.maxLevel }) {
            state.activeModifiers[activeIndex].level += 1
            appendDebugBattleEvent("GameEvent.modifierLeveled \(id) level=\(state.activeModifiers[activeIndex].level)")
            return true
        }

        if let benchIndex = state.benchModifiers.firstIndex(where: { $0.modifierID == id && $0.level < definition.maxLevel }) {
            state.benchModifiers[benchIndex].level += 1
            appendDebugBattleEvent("GameEvent.modifierLeveled \(id) level=\(state.benchModifiers[benchIndex].level)")
            return true
        }

        if state.activeModifiers.contains(where: { $0.modifierID == id })
            || state.benchModifiers.contains(where: { $0.modifierID == id }) {
            return false
        }

        let instance = ModifierInstance(modifierID: id)
        if state.activeModifiers.count < state.activeModifierSlotLimit {
            state.activeModifiers.append(instance)
            return true
        }

        return false
    }

    func sellModifier(instanceID: UUID) {
        if let activeIndex = state.activeModifiers.firstIndex(where: { $0.id == instanceID }) {
            sellModifier(at: activeIndex, fromActive: true)
            return
        }

        if let benchIndex = state.benchModifiers.firstIndex(where: { $0.id == instanceID }) {
            sellModifier(at: benchIndex, fromActive: false)
        }
    }

    private func sellModifier(at index: Int, fromActive: Bool) {
        let instance = fromActive ? state.activeModifiers.remove(at: index) : state.benchModifiers.remove(at: index)
        let value = Modifier.definition(id: instance.modifierID)?.sellValueChips ?? 1
        state.runManager.chips += value
        appendDebugBattleEvent("GameEvent.modifierSold \(instance.modifierID) +\(value) Chips")
        emitOutOfHandModifierEvent(.modifierSold(modifierID: instance.modifierID))
        persistRunState()
    }

    func moveModifierToActive(instanceID: UUID) {
        guard state.activeModifiers.count < state.activeModifierSlotLimit,
              let index = state.benchModifiers.firstIndex(where: { $0.id == instanceID }) else {
            return
        }

        state.activeModifiers.append(state.benchModifiers.remove(at: index))
        persistRunState()
    }

    func moveModifierToBench(instanceID: UUID) {
        guard state.benchModifiers.count < state.benchModifierSlotLimit,
              let index = state.activeModifiers.firstIndex(where: { $0.id == instanceID }) else {
            return
        }

        state.benchModifiers.append(state.activeModifiers.remove(at: index))
        persistRunState()
    }

    func useConsumable(_ consumable: Consumable) {
        guard let index = state.consumables.firstIndex(where: { $0.id == consumable.id }) else {
            return
        }

        var messages: [String] = []
        for effect in consumable.effects {
            messages += applyConsumableEffect(effect, sourceName: consumable.name)
        }

        state.runManager.currentStageConsumablesUsed += 1
        state.consumables.remove(at: index)
        state.roundPresentation.upgradeMessages += messages
        state.roundPresentation.triggerFeedback += messages.map {
            ModifierTriggerFeedback(title: consumable.name, detail: $0, amountCents: nil, kind: battleLogKind(title: consumable.name, detail: $0))
        }
        state.roundPresentation.sequenceID = UUID()
        appendDebugBattleEvent("Consumable used: \(consumable.name)")
        persistRunState()
    }

    private func attach(_ attachment: Attachment) -> Bool {
        guard let index = attachmentTargetIndex(for: attachment) else {
            return false
        }

        state.activeModifiers[index].attachedIDs.append(attachment.id)
        let targetName = Modifier.definition(id: state.activeModifiers[index].modifierID)?.name ?? "modifier"
        appendDebugBattleEvent("Attachment applied: \(attachment.name) -> \(targetName)")
        return true
    }

    private func attachmentTargetIndex(for attachment: Attachment) -> Int? {
        state.activeModifiers.firstIndex { instance in
            guard let modifier = Modifier.definition(id: instance.modifierID) else {
                return false
            }

            return !modifier.tags.isDisjoint(with: attachment.compatibleTags)
                && !instance.attachedIDs.contains(attachment.id)
        }
    }

    private func applyConsumableEffect(_ effect: ModifierEffect, sourceName: String) -> [String] {
        switch effect {
        case .grantBankroll(let cents):
            state.bankrollCents += cents
            return ["\(sourceName): +\(MoneyFormatter.format(cents)) bankroll"]
        case .grantBankrollFromAnte(let percent):
            let cents = state.runManager.currentStage.anteCents * percent / 100
            state.bankrollCents += cents
            return ["\(sourceName): +\(MoneyFormatter.format(cents)) bankroll"]
        case .grantChips(let amount):
            state.runManager.chips += amount
            return ["\(sourceName): +\(amount) Chips"]
        case .gainHeat(let amount):
            state.runManager.heat = min(state.runManager.maxHeat, state.runManager.heat + amount)
            return ["\(sourceName): +\(amount) Heat"]
        case .reduceHeat(let amount):
            state.runManager.heat = max(0, state.runManager.heat - amount)
            return ["\(sourceName): -\(amount) Heat"]
        case .preventHeat:
            return ["\(sourceName): next Heat gain softened"]
        case .revealUpcomingCards(let count), .revealUpcomingCardsWithForecast(let count):
            state.modifierRevealCount = max(state.modifierRevealCount, count)
            return ["\(sourceName): revealed \(count) card\(count == 1 ? "" : "s")"]
        case .burnCards(let count):
            var burned = 0
            for _ in 0..<count where state.shoe.draw() != nil {
                burned += 1
            }
            clearTemporaryRevealOnShoeMutation()
            registerShoeImpact(.removedCards(burned))
            return ["\(sourceName): burned \(burned) card\(burned == 1 ? "" : "s")"]
        case .moveTopCardToBottom:
            guard let card = state.shoe.draw() else {
                return ["\(sourceName): shoe empty"]
            }
            state.shoe.placeCardsOnBottom([card])
            clearTemporaryRevealOnShoeMutation()
            registerShoeImpact(.reordered)
            return ["\(sourceName): moved top card to bottom"]
        case .moveTopCardDeeper(let positions):
            guard state.shoe.moveTopCardDeeper(positions: positions) else {
                return ["\(sourceName): shoe could not move a card"]
            }
            clearTemporaryRevealOnShoeMutation()
            registerShoeImpact(.reordered)
            return ["\(sourceName): moved top card \(positions) slots deeper"]
        case .addCards(let ranks, let count):
            mutateSeededRandom { generator in
                state.shoe.addRandomCards(ranks: ranks, count: count, seededGenerator: &generator)
            }
            clearTemporaryRevealOnShoeMutation()
            registerShoeImpact(.injectedCards(count))
            return ["\(sourceName): added \(count) card\(count == 1 ? "" : "s")"]
        case .removeCards(let ranks, let count):
            let removed = mutateSeededRandom { generator in
                state.shoe.removeRandomCards(ranks: Set(ranks), count: count, seededGenerator: &generator)
            }
            clearTemporaryRevealOnShoeMutation()
            registerShoeImpact(.removedCards(removed))
            return ["\(sourceName): removed \(removed) card\(removed == 1 ? "" : "s")"]
        case .payoutMultiplier, .flatPayoutBonus, .lossRefund, .custom, .adjustBetLimit,
             .addTableRule, .suppressOpponentTags, .addShopDiscount, .addRerollDiscount, .addModifierSlot,
             .addConsumableCharge, .grantChipsOnFirstStageTrigger, .gainTieCharges, .levelScaled, .composite:
            return ["\(sourceName): \(effect.shortDescription)"]
        }
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
                subtitle = "Active: next \(chargedReveal.normalizedMaxCards)"
            } else {
                let chargeText = "\(state.xRayChargesRemainingThisStage) charge\(state.xRayChargesRemainingThisStage == 1 ? "" : "s")"
                subtitle = "\(chargeText) - reveal next \(chargedReveal.normalizedMaxCards)"
            }

            options.append(
                ShoeControlOption(
                    kind: .xRay,
                    title: "\(chargedReveal.title) Read",
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

    func unlockStage(forBetAmountCents amountCents: Int) -> Int {
        Stage.allStages.first { $0.betLimit.allows(amountCents) }?.id ?? Stage.allStages.last?.id ?? 1
    }

    func isBetAmountPlayable(_ amountCents: Int) -> Bool {
        guard state.runManager.isBetAmountAllowed(amountCents, bankrollCents: state.bankrollCents) else {
            return false
        }

        if amountCents > contactAdjustedMaxBetCents {
            return false
        }

        if let activeRevealBetCapCents, amountCents > activeRevealBetCapCents {
            return false
        }

        return true
    }

    func betCapReason(for amountCents: Int) -> String? {
        if let activeRevealBetCapCents, amountCents > activeRevealBetCapCents {
            return "\(activeShoeReveal?.title ?? "Reveal") caps this hand at \(MoneyFormatter.format(activeRevealBetCapCents))."
        }

        if amountCents > contactAdjustedMaxBetCents {
            return "\(state.startingContact.name) keeps early bets capped at \(MoneyFormatter.format(contactAdjustedMaxBetCents))."
        }

        return state.runManager.betCapReason(for: amountCents, bankrollCents: state.bankrollCents)
    }

    private var contactAdjustedMaxBetCents: Int {
        let baseMax = state.runManager.maximumBetCents(bankrollCents: state.bankrollCents)
        guard state.runManager.currentStage.id <= 2,
              state.startingContact.earlyMaxBetMultiplierPercent < 100 else {
            return baseMax
        }

        return max(
            state.runManager.minimumBetCents(),
            baseMax * state.startingContact.earlyMaxBetMultiplierPercent / 100
        )
    }

    func continueFromRunStart() {
        applyStartingContactIfNeeded()
        resetVisibleBattleStateForStage(reason: "run start contact confirmed")
        resolveStageStartedModifiersIfNeeded()
        state.runManager.startRunPreview()
        logState(.stageEntered, fields: ["flow": state.runManager.flowState.rawValue])
        persistRunState()
    }

    func startStageBattle() {
        state.runManager.startStageBattle()
        if state.runManager.currentStageRoundsPlayed == 0 {
            resetVisibleBattleStateForStage(reason: "stage battle entry")
        }
        normalizeSelectedBetForStage()
        logState(.stageEntered, fields: ["flow": state.runManager.flowState.rawValue])
        persistRunState()
    }

    func continueFromStageResult() {
        if state.runManager.status == .failed {
            state.runManager.failRunAfterResult()
            recordRunEndIfNeeded()
            logState(.stageResolved, fields: ["result": "failed", "flow": state.runManager.flowState.rawValue])
            persistRunState()
            return
        }

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            logState(.stageResolved, fields: ["result": "completed", "flow": state.runManager.flowState.rawValue])
            persistRunState()
            return
        }

        if state.runManager.currentStageIndex + 1 >= state.runManager.stages.count {
            state.runManager.showRewardDraft()
            recordRunEndIfNeeded()
            logState(.stageResolved, fields: ["result": "completed", "flow": state.runManager.flowState.rawValue])
            persistRunState()
            return
        }

        if state.pendingStageRewardChoices.isEmpty,
           state.bossManager.pendingBossRewardChoices.isEmpty {
            createStageRewardDraft()
        }

        state.runManager.showRewardDraft()
        logState(.stageResolved, fields: ["result": "cleared", "flow": state.runManager.flowState.rawValue])
        persistRunState()
    }

    private func createStageRewardDraft() {
        let rewards = mutateSeededRandom { generator in
            StageReward.randomDraftChoices(
                count: 3,
                stage: state.runManager.currentStage,
                activeModifiers: state.activeModifiers,
                acquiredUpgrades: state.acquiredUpgrades,
                unlockedRewardNames: metaProgression.profile.unlockedStageRewardNames,
                unlockedUpgradeCards: unlockedUpgradeCards,
                seededGenerator: &generator
            )
        }
        state.pendingStageRewardChoices = rewards
        state.rewardDraftState = RewardDraftState.stageDraft(
            stage: state.runManager.currentStage,
            rewards: rewards,
            activeModifiers: state.activeModifiers
        )
        appendDebugBattleEvent(
            "RewardDraft.stage stage=\(state.runManager.currentStage.id) choices=\(rewards.map(\.name).joined(separator: ","))"
        )
    }

    private func refreshBossRewardDraftState() {
        guard !state.bossManager.pendingBossRewardChoices.isEmpty else {
            state.rewardDraftState = nil
            return
        }

        state.rewardDraftState = RewardDraftState.bossDraft(
            stage: state.runManager.currentStage,
            rewards: state.bossManager.pendingBossRewardChoices,
            activeModifiers: state.activeModifiers
        )
        appendDebugBattleEvent(
            "RewardDraft.boss stage=\(state.runManager.currentStage.id) choices=\(state.bossManager.pendingBossRewardChoices.map(\.name).joined(separator: ","))"
        )
    }

    func continueFromShop() {
        guard state.runManager.status == .stageCleared else {
            return
        }

        state.runManager.advanceAfterStageClear(bankrollCents: state.bankrollCents)
        resetVisibleBattleStateForStage(reason: "shop complete")
        prepareBossAnnouncementIfNeeded()
        applyStageStartEffects()
        normalizeSelectedBetForStage()
        if state.runManager.status == .active {
            queueShoeUpgradeRewardIfNeeded()
        }
        state.shopState = ShopState()
        logState(.stageEntered, fields: ["flow": state.runManager.flowState.rawValue])
        persistRunState()
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
        var selectedConfiguration = chargedRevealIsValid ? chargedConfiguration : passiveConfiguration
        let hasRevealPotential = passiveConfiguration != nil || chargedConfiguration != nil

        if hasRevealPotential, state.challengeID == .noReveal {
            return .locked(title: "Reveal Locked", reason: "No Reveal challenge hides shoe information.")
        }

        if hasRevealPotential, state.bossManager.suppressesReveal {
            return .locked(title: "Surveillance", reason: "Boss surveillance is suppressing reveal upgrades.")
        }

        if let configuration = selectedConfiguration {
            selectedConfiguration = bossAdjustedRevealConfiguration(configuration)
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

    private func bossAdjustedRevealConfiguration(_ configuration: ShoeRevealConfiguration) -> ShoeRevealConfiguration {
        guard isInspectorPressureActive else {
            return configuration
        }

        return configuration.reducedByCards(1, titleSuffix: "(inspected)")
    }

    private var isInspectorPressureActive: Bool {
        guard let activeBoss = state.bossManager.activeBoss else {
            return false
        }

        return activeBoss.id == Boss.shoeInspector.id || activeBoss.id == Boss.house.id
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

        if let modifierReveal = ShoeRevealConfiguration.passiveLegacyReveal(count: min(state.modifierRevealCount, 5)) {
            configurations.append(modifierReveal)
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
        switch state.runManager.flowState {
        case .runStart:
            return "Choose a starting contact"
        case .stagePreview:
            return "Preview the next table"
        case .stageResult:
            return "Review the stage result"
        case .rewardDraft:
            return "Choose a stage reward"
        case .shop:
            return "Shop: buy, reroll, or continue"
        case .runComplete:
            return "Run complete"
        case .runFailed:
            return "Run over"
        case .battle:
            break
        }

        if state.bossManager.pendingAnnouncementBoss != nil {
            return "Boss approaching"
        }

        if !state.bossManager.pendingBossRewardChoices.isEmpty {
            return "Choose a boss reward to continue"
        }

        if !state.pendingStageRewardChoices.isEmpty {
            return "Choose a stage reward to continue"
        }

        return "Stage \(state.runManager.stageReached): \(state.runManager.roundsRemaining) hands left"
    }

    func selectBetType(_ betType: BetType) {
        guard !isGuidedOpeningHandLocked || betType == .player else {
            logState(.wagerRejected, fields: ["reason": DisabledWagerReason.guidedLock.rawValue, "betType": betType.rawValue])
            state.selectedBetType = .player
            state.roundPresentation.upgradeMessages = ["Tutorial Hand: Player bet locked"]
            state.roundPresentation.payoutLedgerLines = []
            state.roundPresentation.sequenceID = UUID()
            persistRunState()
            return
        }

        guard state.challengeID.allowsBet(betType) else {
            logState(.wagerRejected, fields: ["reason": DisabledWagerReason.stageUnavailable.rawValue, "betType": betType.rawValue])
            return
        }

        state.selectedBetType = betType
        logState(.wagerAccepted, fields: ["betType": betType.rawValue, "amountCents": "\(state.selectedBetAmountCents)"])
        persistRunState()
    }

    func selectBetAmount(_ amountCents: Int) {
        guard !isGuidedOpeningHandLocked || amountCents == minimumUnlockedBetAmountCents else {
            logState(.wagerRejected, fields: ["reason": DisabledWagerReason.guidedLock.rawValue, "amountCents": "\(amountCents)"])
            state.selectedBetAmountCents = minimumUnlockedBetAmountCents
            state.roundPresentation.upgradeMessages = ["Tutorial Hand: minimum bet locked"]
            state.roundPresentation.payoutLedgerLines = []
            state.roundPresentation.sequenceID = UUID()
            persistRunState()
            return
        }

        guard isBetAmountUnlocked(amountCents) else {
            logState(.wagerRejected, fields: ["reason": DisabledWagerReason.stageUnavailable.rawValue, "amountCents": "\(amountCents)"])
            return
        }

        if let activeRevealBetCapCents, amountCents > activeRevealBetCapCents {
            logState(.wagerRejected, fields: ["reason": DisabledWagerReason.stageUnavailable.rawValue, "amountCents": "\(amountCents)", "capCents": "\(activeRevealBetCapCents)"])
            registerManualShoeControl(
                message: "\(activeShoeReveal?.title ?? "Reveal") caps bets at \(MoneyFormatter.format(activeRevealBetCapCents))",
                impact: .none
            )
            return
        }

        state.selectedBetAmountCents = amountCents
        logState(.wagerAccepted, fields: ["betType": state.selectedBetType.rawValue, "amountCents": "\(amountCents)"])
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
    func debugSetBankrollForTesting(_ bankrollCents: Int) {
        state.bankrollCents = max(0, bankrollCents)
        normalizeSelectedBetForStage()
        persistRunState()
    }

    func debugSetActiveModifiersForTesting(_ modifierIDs: [String]) {
        state.activeModifiers = modifierIDs.map { ModifierInstance(modifierID: $0) }
        persistRunState()
    }

    func debugSetShopStateForTesting(_ shopState: ShopState) {
        state.shopState = shopState
        persistRunState()
    }

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
        state.runManager.currentStageRoundsPlayed = state.runManager.currentRoundLimit
        state.runManager.currentStageOpponentProfitCents = 0
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
            refreshBossRewardDraftState()
        } else if state.runManager.status == .stageCleared,
                  state.runManager.currentStageIndex + 1 < state.runManager.stages.count,
                  state.pendingStageRewardChoices.isEmpty {
            createStageRewardDraft()
        }

        persistRunState()
    }

    func debugGrantUpgrade(named name: String) {
        track(.debugAction, properties: ["action": "grantUpgrade", "upgrade": name])
        guard UpgradeCard.allCards.first(where: { $0.name.localizedCaseInsensitiveContains(name) }) != nil else {
            return
        }

        state.runManager.chips += 2
        appendDebugBattleEvent("Legacy debug upgrade grant converted to +2 Chips")
        persistRunState()
    }

    func debugGrantLegendary() {
        track(.debugAction, properties: ["action": "grantLegendary"])
        state.runManager.chips += 5
        appendDebugBattleEvent("Legacy debug legendary grant converted to +5 Chips")
        persistRunState()
    }

    func debugSpawnBoss(_ boss: Boss) {
        track(.debugAction, properties: ["action": "spawnBoss", "boss": boss.name])
        state.bossManager.pendingAnnouncementBoss = nil
        state.bossManager.activeBoss = boss
        state.bossManager.disabledUpgradeIDs = []
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
        let betLimitPass = manager.currentStage.betLimit.allows(manager.currentStage.minimumBetCents)
            && !manager.currentStage.betLimit.allows(1_000)

        manager.currentStageRoundsPlayed = manager.currentRoundLimit
        let objectivePass = manager.currentStage.teachingObjective?.isComplete(in: manager, bankrollCents: 25_000) == true
        let failPass = manager.currentStage.teachingObjective?.isFailed(in: manager, bankrollCents: 0) == true

        manager.status = .stageCleared
        manager.advanceAfterStageClear(bankrollCents: 28_600)
        let carryoverPass = manager.stageStartingBankrollCents == 28_600
            && manager.currentStage.id == 2
            && manager.currentStage.betLimit.allows(manager.currentStage.minimumBetCents)

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

        var shopGenerator: SeededRandomGenerator? = SeededRandomGenerator(seed: 99)
        let generatedShop = ShopState.generated(
            stageID: 3,
            ante: 75,
            defeatedBosses: 0,
            frozenOffers: [],
            ownedModifierIDs: [],
            contactBiasTags: StartingContact.tourist.shopBiasTags,
            seededGenerator: &shopGenerator
        )
        let contentCatalogPass = Modifier.allContent.count >= 100
            && Modifier.productionContent.count == 41
            && ActiveModifierCatalog.starterIDs.count == 6
            && ActiveModifierCatalog.regularIDs.count == 28
            && ActiveModifierCatalog.capstoneIDs.count == 7
            && Consumable.allContent.count >= 30
            && Attachment.allContent.count >= 30
            && StartingContact.allContacts.count == 6
            && OpponentState.allOpponents.count >= 16
            && TableEvent.allEvents.count >= 16
            && BossRelic.allRelics.count >= 20
        let shopTierPass = ShopState.tier(for: 1, defeatedBosses: 0) == 1
            && ShopState.tier(for: 3, defeatedBosses: 0) == 2
            && ShopState.tier(for: 5, defeatedBosses: 1) == 3
            && ShopState.tier(for: 8, defeatedBosses: 2) == 4
            && ShopState.tier(for: 9, defeatedBosses: 2) == 5
        let generatedShopPass = generatedShop.offers.count == ActiveModifierCatalog.normalShopOfferCount
            && generatedShop.offers.allSatisfy { $0.priceChips >= 0 }
            && generatedShop.offers.allSatisfy {
                $0.kind != .modifier || ActiveModifierCatalog.acquisitionClass(for: $0.contentID) == .regular
            }
        let contactPass = StartingContact.allContacts.allSatisfy { contact in
                contact.startingModifiers.allSatisfy { Modifier.definition(id: $0) != nil }
                    && contact.startingModifiers.allSatisfy { ActiveModifierCatalog.acquisitionClass(for: $0) == .starter }
                    && contact.startingConsumables.allSatisfy { Consumable.definition(id: $0) != nil }
            }
        let modifierEnginePass = ModifierEngineDebugTests.runAll().allSatisfy { $0.contains("OK") }
        let shopFlowPass = debugShopFlowPass()

        let checks = [
            ("X-Ray labels", previewPass),
            ("Stage 1 bet lock", betLimitPass),
            ("Stage objective", objectivePass),
            ("Stage fail state", failPass),
            ("Bankroll carryover", carryoverPass),
            ("Hidden shoe visibility", visibilityPass),
            ("Reveal tier counts", revealTierPass),
            ("Reveal tiers", upgradePass),
            ("Modifier catalog counts", contentCatalogPass),
            ("Shop tier curve", shopTierPass),
            ("Shop generation", generatedShopPass),
            ("Starting contacts", contactPass),
            ("Modifier engine tests", modifierEnginePass),
            ("Shop flow actions", shopFlowPass)
        ]
        let failedChecks = checks.filter { !$0.1 }.map(\.0)
        let summary = failedChecks.isEmpty
            ? "Phase 3 checks passed: \(checks.count)/\(checks.count)"
            : "Phase 3 checks failed: \(failedChecks.joined(separator: ", "))"

        print("[Rigged Shoe Debug] \(summary)")
        return summary
    }

    private func debugShopFlowPass() -> Bool {
        let savedState = state
        let savedEngine = modifierEngine
        defer {
            state = savedState
            modifierEngine = savedEngine
            persistRunState()
        }

        state = GameState(configuration: RunConfiguration(
            startingBankrollCents: RunManager.defaultStartingBankrollCents,
            chipRewardMultiplierPercent: 100,
            startingUpgradeNames: [],
            activeRunModifierIDs: [],
            challengeID: .standard,
            isDailyRun: false,
            dailySeed: 1234,
            themeID: .lasVegas,
            isGuidedFirstRun: false
        ))
        state.runManager.chips = 40
        state.activeModifiers = [ModifierInstance(modifierID: "core.banker-bias")]
        state.benchModifiers = []
        state.consumables = []
        state.attachments = []
        state.bossRelics = []

        let duplicateOffer = ShopOffer(kind: .modifier, contentID: "core.banker-bias", priceChips: 3)
        let consumableOffer = ShopOffer(kind: .consumable, contentID: "consumable.burn-slip", priceChips: 2)
        let secondConsumableOffer = ShopOffer(kind: .consumable, contentID: "consumable.marked-card", priceChips: 2)
        let compatibleAttachmentOffer = ShopOffer(kind: .attachment, contentID: "attachment.gold-foil", priceChips: 4)
        let blockedAttachmentOffer = ShopOffer(kind: .attachment, contentID: "attachment.shop-stamp", priceChips: 3)
        state.shopState = ShopState(
            ante: 25,
            offers: [
                duplicateOffer,
                consumableOffer,
                compatibleAttachmentOffer,
                blockedAttachmentOffer
            ]
        )

        let canLevelDuplicate = canBuyShopOffer(duplicateOffer)
        buyShopOffer(duplicateOffer)
        let duplicateLeveled = state.activeModifiers.first(where: { $0.modifierID == "core.banker-bias" })?.level == 2

        let canBuyConsumable = canBuyShopOffer(consumableOffer)
        buyShopOffer(consumableOffer)
        let consumableFilled = state.consumables.map(\.id) == ["consumable.burn-slip"]
        let consumableSlotBlocksSecond = !canBuyShopOffer(secondConsumableOffer)
            && shopOfferBlockedReason(secondConsumableOffer) == "Consumable slot full"

        let compatibleAttachmentTargetsBanker = attachmentTargetName(for: compatibleAttachmentOffer.contentID) == "Banker Bias"
        let blockedAttachmentHasReason = !canBuyShopOffer(blockedAttachmentOffer)
            && shopOfferBlockedReason(blockedAttachmentOffer) == "No compatible active modifier"
        buyShopOffer(compatibleAttachmentOffer)
        let attachmentApplied = state.activeModifiers.first(where: { $0.modifierID == "core.banker-bias" })?.attachedIDs.contains("attachment.gold-foil") == true

        let frozenOffer = ShopOffer(kind: .modifier, contentID: "player.side-step", priceChips: 3)
        state.shopState = ShopState(
            ante: 25,
            offers: [
                frozenOffer,
                ShopOffer(kind: .modifier, contentID: "banker.commission-dodge", priceChips: 3),
                ShopOffer(kind: .consumable, contentID: "consumable.free-drink", priceChips: 2),
                ShopOffer(kind: .attachment, contentID: "attachment.red-ink", priceChips: 3)
            ]
        )
        toggleFreezeShopOffer(frozenOffer)
        let frozenID = state.shopState.offers.first?.id
        rerollShop()
        let frozenSurvivedReroll = state.shopState.offers.contains { offer in
            offer.id == frozenID && offer.isFrozen && !offer.isSoldOut
        }
        let rerollTracked = state.shopState.rerollsThisStage == 1

        state.activeModifierSlotLimit = 1
        state.benchModifierSlotLimit = 2
        state.activeModifiers = [ModifierInstance(modifierID: "core.banker-bias")]
        state.benchModifiers = [ModifierInstance(modifierID: "core.player-surge")]
        let activeID = state.activeModifiers[0].id
        let benchID = state.benchModifiers[0].id
        moveModifierToActive(instanceID: benchID)
        let fullActiveBlocksEquip = state.activeModifiers.count == 1
            && state.benchModifiers.count == 1
        moveModifierToBench(instanceID: activeID)
        let movedToBench = state.activeModifiers.isEmpty
            && state.benchModifiers.count == 2
        moveModifierToActive(instanceID: benchID)
        let movedBackToActive = state.activeModifiers.contains { $0.id == benchID }
        let chipsBeforeSell = state.runManager.chips
        if let sellID = state.activeModifiers.first?.id {
            sellModifier(instanceID: sellID)
        }
        let sellAddsChips = state.runManager.chips > chipsBeforeSell

        return canLevelDuplicate
            && duplicateLeveled
            && canBuyConsumable
            && consumableFilled
            && consumableSlotBlocksSecond
            && compatibleAttachmentTargetsBanker
            && blockedAttachmentHasReason
            && attachmentApplied
            && frozenSurvivedReroll
            && rerollTracked
            && fullActiveBlocksEquip
            && movedToBench
            && movedBackToActive
            && sellAddsChips
    }

    func debugStressGameRoomLayout() {
        track(.debugAction, properties: ["action": "stressGameRoomLayout"])
        let stressModifierIDs = [
            "core.opening-tell",
            "banker.commission-dodge",
            "player.side-step",
            "tie.split-signal",
            "vision.deep-read",
            "control.soft-cut",
            "heat.low-profile"
        ]
        let existingIDs = Set((state.activeModifiers + state.benchModifiers).map(\.modifierID))

        for modifierID in stressModifierIDs where !existingIDs.contains(modifierID) {
            guard ActiveModifierCatalog.isProductionAvailable(modifierID) else {
                continue
            }

            if state.activeModifiers.count < state.activeModifierSlotLimit {
                state.activeModifiers.append(ModifierInstance(modifierID: modifierID))
            } else if state.benchModifiers.count < state.benchModifierSlotLimit {
                state.benchModifiers.append(ModifierInstance(modifierID: modifierID))
            }
        }

        persistRunState()
    }
#endif

    func dealRound(allowPresentationLockBypass: Bool = false) {
        let canDealNow = allowPresentationLockBypass ? canDealIgnoringPresentationLock : canDeal
        guard canDealNow else {
            let reason = disabledWagerReason(for: state.selectedBetType, amountCents: state.selectedBetAmountCents)
            logState(.wagerRejected, fields: ["reason": reason?.rawValue ?? "dealLocked"])
            return
        }

        if !allowPresentationLockBypass {
            isDealResolutionLocked = true
        }

        let bankrollBeforeRound = state.bankrollCents
        let chipsBeforeRound = state.runManager.chips
        let heatBeforeRound = state.runManager.heat
        let battleLogHandNumber = state.runManager.totalRoundsPlayed + 1
        var shoeImpact = ShoeImpact.none
        var activationMessages: [String] = []
        var payoutLedgerLines: [PayoutLedgerLine] = []
        logState(.handStarted, hand: battleLogHandNumber, fields: ["betType": state.selectedBetType.rawValue, "amountCents": "\(state.selectedBetAmountCents)"])
        logState(.presentationChanged, hand: battleLogHandNumber, fields: ["state": "\(presentationState)"])
        appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.handStarted")
        var preBetModifierResolutions = resolveActiveModifiers(event: .handStarted(handIndex: battleLogHandNumber), handNumber: battleLogHandNumber)

        if state.shoe.cardsRemaining < 20 {
            reshuffleShoe()
            shoeImpact = .shuffled
        }

        let preDealShoeControl = applyAutomaticShoeControlBeforeDeal()
        if preDealShoeControl.impact != .none {
            shoeImpact = preDealShoeControl.impact
        }

        prepareGuidedFirstDealIfNeeded()
        let betType = state.selectedBetType
        let betAmountCents = state.selectedBetAmountCents
        activationMessages += preDealShoeControl.messages

        let isFinalHand = state.runManager.currentStageRoundsPlayed + 1 >= state.runManager.currentRoundLimit
        if isFinalHand {
            appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.finalHand")
            preBetModifierResolutions += resolveActiveModifiers(event: .finalHand, handNumber: battleLogHandNumber)
        }
        appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.beforeBet")
        preBetModifierResolutions += resolveActiveModifiers(event: .beforeBet, handNumber: battleLogHandNumber)
        appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.betPlaced \(betType.displayName) \(MoneyFormatter.format(betAmountCents))")
        var preDealModifierResolutions = preBetModifierResolutions + resolveActiveModifiers(
            event: .betPlaced(betType: betType, amountCents: betAmountCents),
            handNumber: battleLogHandNumber
        )
        state.bankrollCents -= betAmountCents
        appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.beforeDeal")
        preDealModifierResolutions += resolveActiveModifiers(event: .beforeDeal, handNumber: battleLogHandNumber)
        appendHeatPreventionIfNeeded(to: &preDealModifierResolutions, handNumber: battleLogHandNumber)
        let preDealModifierLedgerLines = applyModifierResolutions(preDealModifierResolutions)
        activationMessages += preDealModifierResolutions.flatMap(\.messages)
        payoutLedgerLines += preDealModifierLedgerLines

        let revealBeforeRound = activeShoeReveal
        let wasXRayActive = state.isXRayActiveForNextHand
        let forecastBeforeRound = dealForecast
        let revealCountBeforeRound = revealedShoeCards
        let xRayPreviewBeforeRound = wasXRayActive && revealBeforeRound?.isSuppressed == false
            ? state.shoe.previewCards(limit: min(revealBeforeRound?.maxCards ?? 0, 4))
            : []
        logXRayPreviewIfNeeded(xRayPreviewBeforeRound)
        let cardsBeforeRound = state.shoe.cardsRemaining
        var bossPreDealResolutions = bossPreDealResolutions(
            betType: betType,
            revealedCardCount: revealCountBeforeRound,
            didUseShoeControl: preDealShoeControl.impact != .none,
            handNumber: battleLogHandNumber
        )
        appendHeatPreventionIfNeeded(to: &bossPreDealResolutions, handNumber: battleLogHandNumber)
        let bossPreDealLedgerLines = applyModifierResolutions(bossPreDealResolutions)
        activationMessages += bossPreDealResolutions.flatMap(\.messages)
        payoutLedgerLines += bossPreDealLedgerLines

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
        activationMessages += roundResolution.payout.activationMessages
        payoutLedgerLines += roundResolution.payout.ledgerLines
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
        if state.runManager.currentStage.tableEvent.id == "cold-table",
           !result.isPush,
           !result.didWin,
           state.runManager.currentStageLosses == 0 {
            let opponentBoostCents = state.runManager.currentStage.anteCents * 2
            state.runManager.heat = min(state.runManager.maxHeat, state.runManager.heat + 2)
            state.runManager.currentStageOpponentProfitCents += opponentBoostCents
            activationMessages.append("Cold Table: first loss +2 Heat")
            activationMessages.append("Cold Table: opponent momentum +\(MoneyFormatter.format(opponentBoostCents))")
        }
        if revealCountBeforeRound > 0,
           let teachingObjective = state.runManager.currentStage.teachingObjective,
           teachingObjective.kind == .triggerUpgrades || teachingObjective.kind == .winWithReveal {
            activationMessages.insert("Reveal read \(revealCountBeforeRound) cards", at: 0)
        }
        let safetyNet = applyPostPayoutStageSafetyNetIfNeeded()
        activationMessages += safetyNet.messages
        payoutLedgerLines += safetyNet.ledgerLines
        var modifierResolutions: [ModifierResolution] = []
        for (offset, card) in dealtCardsInOrder(from: result).enumerated() {
            modifierResolutions += resolveActiveModifiers(
                event: .cardDrawn(card: card, order: offset + 1),
                handNumber: battleLogHandNumber
            )
        }
        if result.playerHand.isNatural || result.bankerHand.isNatural {
            modifierResolutions += resolveActiveModifiers(event: .naturalOccurred, handNumber: battleLogHandNumber)
        }
        if hasOpeningPair(result.playerHand) || hasOpeningPair(result.bankerHand) {
            modifierResolutions += resolveActiveModifiers(event: .pairOccurred, handNumber: battleLogHandNumber)
        }
        if result.didWin {
            modifierResolutions += resolveActiveModifiers(
                event: .wagerWon(betType: betType, winningSide: result.winner, amountCents: betAmountCents, basePayoutCents: result.payoutCents),
                handNumber: battleLogHandNumber
            )
        } else if !result.isPush {
            modifierResolutions += resolveActiveModifiers(
                event: .wagerLost(betType: betType, winningSide: result.winner, amountCents: betAmountCents),
                handNumber: battleLogHandNumber
            )
        }
        if result.winner == .tie {
            modifierResolutions += resolveActiveModifiers(event: .tieOccurred, handNumber: battleLogHandNumber)
        }
        modifierResolutions += resolveActiveModifiers(event: .handResolved(result: result), handNumber: battleLogHandNumber)
        appendHeatPreventionIfNeeded(to: &modifierResolutions, handNumber: battleLogHandNumber)
        let modifierLedgerLines = applyModifierResolutions(modifierResolutions)
        let modifierBankrollDelta = modifierResolutions.reduce(0) { $0 + $1.bankrollDeltaCents }
        if modifierBankrollDelta > 0 {
            result = result.addingPayoutBonus(modifierBankrollDelta)
        }
        activationMessages += modifierResolutions.flatMap(\.messages)
        payoutLedgerLines += modifierLedgerLines
        var heatPressureResolutions = baselineHeatResolutions(
            result: result,
            handNumber: battleLogHandNumber
        )
        appendHeatPreventionIfNeeded(to: &heatPressureResolutions, handNumber: battleLogHandNumber)
        let heatLedgerLines = applyModifierResolutions(heatPressureResolutions)
        activationMessages += heatPressureResolutions.flatMap(\.messages)
        payoutLedgerLines += heatLedgerLines
        let heatResponse = applyHeatResponseIfNeeded(bankrollBeforeRoundCents: bankrollBeforeRound)
        activationMessages += heatResponse.messages
        payoutLedgerLines += heatResponse.ledgerLines
        let allModifierResolutions = preDealModifierResolutions + bossPreDealResolutions + modifierResolutions + heatPressureResolutions
        let triggerFeedback = triggerFeedbackEntries(
            activationMessages: activationMessages,
            payoutLedgerLines: payoutLedgerLines,
            modifierResolutions: allModifierResolutions
        )
        logUpgradeActivations(activationMessages)
        state.roundPresentation = RoundPresentationState(
            bankrollDeltaCents: state.bankrollCents - bankrollBeforeRound,
            winTier: winTier(for: result),
            shoeImpact: shoeImpact,
            upgradeMessages: activationMessages,
            payoutLedgerLines: payoutLedgerLines,
            triggerFeedback: triggerFeedback
        )
        state.latestRound = result
        state.history.insert(result, at: 0)
        state.roundsSinceLastUpgrade += 1
        appendDebugBattleEvent("Hand \(battleLogHandNumber): GameEvent.handResolved winner=\(result.winner.displayName) bet=\(result.betType.displayName)")
        appendDebugBattleEvent(
            "Hand \(battleLogHandNumber): \(result.didWin ? "GameEvent.wagerWon" : result.isPush ? "GameEvent.tieOccurred" : "GameEvent.wagerLost")"
        )
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
        enrichLastStageResultWithBuildArchetype()
        logState(
            .handResolved,
            hand: battleLogHandNumber,
            fields: [
                "winner": result.winner.rawValue,
                "betType": result.betType.rawValue,
                "bankrollDeltaCents": "\(state.bankrollCents - bankrollBeforeRound)",
                "shoeDelta": "\(state.shoe.cardsRemaining - cardsBeforeRound)"
            ]
        )
        logState(.bankrollChanged, hand: battleLogHandNumber, fields: ["deltaCents": "\(state.bankrollCents - bankrollBeforeRound)"])
        logState(.chipsChanged, hand: battleLogHandNumber, fields: ["delta": "\(state.runManager.chips - chipsBeforeRound)"])
        logState(.heatChanged, hand: battleLogHandNumber, fields: ["delta": "\(state.runManager.heat - heatBeforeRound)"])
        logState(.shoeChanged, hand: battleLogHandNumber, fields: ["deltaCards": "\(state.shoe.cardsRemaining - cardsBeforeRound)"])
        appendBattleLogEntry(
            handNumber: battleLogHandNumber,
            result: result,
            bankrollBeforeRound: bankrollBeforeRound,
            chipsBeforeRound: chipsBeforeRound,
            heatBeforeRound: heatBeforeRound,
            payoutLedgerLines: payoutLedgerLines,
            activationMessages: activationMessages,
            modifierResolutions: allModifierResolutions
        )

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
                refreshBossRewardDraftState()
                persistRunState()
                return
            }

            if state.runManager.currentStageIndex + 1 < state.runManager.stages.count {
                createStageRewardDraft()
            }
            persistRunState()
            return
        }

        if state.runManager.status == .active {
            queueShoeUpgradeRewardIfNeeded()
            normalizeSelectedBetForStage()
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
            refreshBossRewardDraftState()
            return
        }

        if state.pendingStageRewardChoices.isEmpty {
            createStageRewardDraft()
        }
    }

    func selectUpgrade(_ upgrade: UpgradeCard) {
        let chipCompensation: Int
        switch upgrade.rarity {
        case .common:
            chipCompensation = 1
        case .rare:
            chipCompensation = 3
        case .legendary:
            chipCompensation = 5
        }

        state.runManager.chips += chipCompensation
        state.pendingUpgradeChoices = []
        state.roundsSinceLastUpgrade = 0
        appendDebugBattleEvent("Legacy upgrade choice \(upgrade.name) converted to +\(chipCompensation) Chips")
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
        resetBossPressureStateForStage()
        applyBossStageStartEffects()
        persistRunState()
    }

    func selectStageReward(_ reward: StageReward) {
        guard state.runManager.status == .stageCleared,
              state.pendingStageRewardChoices.contains(where: { $0.id == reward.id }) else {
            logState(.rewardSelected, fields: ["rewardID": reward.id.uuidString, "accepted": "false"])
            return
        }

        let bankrollBeforeReward = state.bankrollCents
        let chipsBeforeReward = state.runManager.chips
        let heatBeforeReward = state.runManager.heat
        applyStageReward(reward)
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        recordRunSnapshot()
        state.pendingStageRewardChoices = []
        state.rewardDraftState = nil
        logState(
            .rewardSelected,
            fields: [
                "rewardID": reward.id.uuidString,
                "accepted": "true",
                "bankrollDeltaCents": "\(state.bankrollCents - bankrollBeforeReward)",
                "chipsDelta": "\(state.runManager.chips - chipsBeforeReward)",
                "heatDelta": "\(state.runManager.heat - heatBeforeReward)"
            ]
        )

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        state.runManager.enterShop()
        prepareShop(forceReroll: true)

        persistRunState()
    }

    func selectBossReward(_ reward: BossReward) {
        guard !state.bossManager.pendingBossRewardChoices.isEmpty else {
            logState(.rewardSelected, fields: ["rewardID": reward.id.uuidString, "accepted": "false"])
            return
        }

        let bankrollBeforeReward = state.bankrollCents
        let chipsBeforeReward = state.runManager.chips
        let heatBeforeReward = state.runManager.heat
        applyBossReward(reward)
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        recordRunSnapshot()
        state.bossManager.clearBossRewardChoices()
        state.rewardDraftState = nil
        logState(
            .rewardSelected,
            fields: [
                "rewardID": reward.id.uuidString,
                "accepted": "true",
                "bankrollDeltaCents": "\(state.bankrollCents - bankrollBeforeReward)",
                "chipsDelta": "\(state.runManager.chips - chipsBeforeReward)",
                "heatDelta": "\(state.runManager.heat - heatBeforeReward)"
            ]
        )

        if state.runManager.status == .completed {
            recordRunEndIfNeeded()
            persistRunState()
            return
        }

        state.runManager.enterShop()
        prepareShop(forceReroll: true)

        persistRunState()
    }

    func startNewRun() {
        RunPersistenceManager.clear()
        state = GameState(configuration: metaProgression.runConfiguration())
        isDealResolutionLocked = false
        normalizeSelectedBetForStage()
        lockGuidedOpeningBetIfNeeded()
        applyRunStartImmediateEffects()
        applyStageStartEffects()
        trackRunStarted()
        logState(.replayStarted, fields: ["flow": state.runManager.flowState.rawValue])
        persistRunState()
    }

    private func normalizeTransientPresentationAfterRestore() {
        isDealResolutionLocked = false
        state.latestRound = nil
        state.history.removeAll()
        state.roundPresentation = RoundPresentationState()
        state.isXRayActiveForNextHand = false
    }

    private func resetVisibleBattleStateForStage(reason: String) {
        let stageNumber = state.runManager.currentStage.id
        isDealResolutionLocked = false
        state.latestRound = nil
        state.history.removeAll()
        state.roundPresentation = RoundPresentationState()
        state.pendingUpgradeChoices = []
        state.rewardDraftState = nil
        state.previousRoundLossCents = 0
        state.smallBetWinStreak = 0
        state.consecutiveLosses = 0
        state.lastRoundDidWin = false
        state.lastBetAmountCents = 0
        state.playerWinStreak = 0
        state.bankerWinStreak = 0
        state.tieStreak = 0
        state.hasMovedCardThisStage = false
        state.isXRayActiveForNextHand = false
        state.modifierRevealCount = 0
        state.selectedBetType = defaultBetTypeForCurrentStage()
        state.selectedBetAmountCents = state.runManager.currentStage.minimumBetCents
        modifierEngine.resetStage()
        appendDebugBattleEvent("[StageFlow] Entering stage \(stageNumber): reset hand/presentation state (\(reason))")
        appendDebugBattleEvent("[StageFlow] Cleared handState, resultBanner, animationPhase, pendingTriggers")
        appendDebugBattleEvent("[StageFlow] Active build persists: \(state.activeModifiers.map(\.modifierID).joined(separator: ","))")
    }

    private func defaultBetTypeForCurrentStage() -> BetType {
        if state.challengeID.allowsBet(.player) {
            return .player
        }

        if state.challengeID.allowsBet(.banker) {
            return .banker
        }

        return .tie
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
        if isBetAmountPlayable(state.selectedBetAmountCents),
           selectedBetIsWithinRevealCap {
            return
        }

        let previousAmount = state.selectedBetAmountCents
        let legalAmounts = unlockedBetAmountsCents
            .filter(isBetAmountPlayable)
            .sorted()

        state.selectedBetAmountCents = legalAmounts.last ?? unlockedBetAmountsCents.first ?? minimumUnlockedBetAmountCents
        resolveNoLegalBetIfNeeded(legalAmounts: legalAmounts)
        clampSelectedBetForRevealCap()
        if previousAmount != state.selectedBetAmountCents {
            showBetAdjustedExplanation(from: previousAmount, to: state.selectedBetAmountCents)
        }
    }

    private func resolveNoLegalBetIfNeeded(legalAmounts: [Int]) {
        guard legalAmounts.isEmpty,
              state.runManager.status == .active,
              state.runManager.flowState != .runStart,
              state.bankrollCents < state.runManager.currentStage.minimumBetCents else {
            return
        }

        appendDebugBattleEvent("[Bet] No legal wager available; resolving stage failure")
        state.runManager.evaluateStage(bankrollCents: state.bankrollCents)
        logState(.noLegalWager, fields: ["minimumCents": "\(state.runManager.currentStage.minimumBetCents)", "bankrollCents": "\(state.bankrollCents)"])
    }

    private func clampSelectedBetForRevealCap() {
        guard let activeRevealBetCapCents,
              state.selectedBetAmountCents > activeRevealBetCapCents else {
            return
        }

        let legalAmounts = unlockedBetAmountsCents
            .filter { $0 <= activeRevealBetCapCents && isBetAmountPlayable($0) }
            .sorted()

        let previousAmount = state.selectedBetAmountCents
        state.selectedBetAmountCents = legalAmounts.last ?? minimumUnlockedBetAmountCents
        if previousAmount != state.selectedBetAmountCents {
            showBetAdjustedExplanation(from: previousAmount, to: state.selectedBetAmountCents)
        }
    }

    private func showBetAdjustedExplanation(from oldAmountCents: Int, to newAmountCents: Int) {
        state.roundPresentation.upgradeMessages = [
            "Bet adjusted: \(MoneyFormatter.format(oldAmountCents)) is not legal here. Selected \(MoneyFormatter.format(newAmountCents))."
        ]
        state.roundPresentation.payoutLedgerLines = []
        state.roundPresentation.triggerFeedback = []
        state.roundPresentation.sequenceID = UUID()
        appendDebugBattleEvent("[Bet] Bet adjusted \(MoneyFormatter.format(oldAmountCents)) -> \(MoneyFormatter.format(newAmountCents))")
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

    private func resolveActiveModifiers(event: GameEvent, handNumber: Int) -> [ModifierResolution] {
        guard !state.activeModifiers.isEmpty else {
            return []
        }

        appendDebugBattleEvent("Hand \(handNumber): ModifierEngine.\(event.trigger.rawValue)")
        let context = ModifierContext(
            event: event,
            stageNumber: state.runManager.currentStage.id,
            handNumber: handNumber,
            anteCents: state.runManager.currentStage.anteCents,
            legalBetAmountsCents: state.runManager.currentStage.betLimit.allowedBetAmountsCents,
            availableHeatRoom: max(0, state.runManager.maxHeat - state.runManager.heat),
            isBossStage: state.bossManager.activeBoss != nil || state.runManager.currentStage.isBossStage,
            bossID: state.bossManager.activeBoss.map { "\($0.id)" },
            stageStats: modifierStageStats(),
            activeTags: activeModifierTags(),
            upcomingCards: state.shoe.previewCards(limit: 8)
        )

        var resolutions = modifierEngine.resolve(
            event: event,
            modifiers: state.activeModifiers,
            library: Modifier.productionContent,
            attachments: state.attachments,
            context: context
        )

        for index in resolutions.indices {
            resolutions[index].messages.insert(
                "\(resolutions[index].modifierName) triggered",
                at: 0
            )
        }

        return resolutions
    }

    private func appendHeatPreventionIfNeeded(to resolutions: inout [ModifierResolution], handNumber: Int) {
        let heatToGain = resolutions.reduce(0) { partial, resolution in
            partial + max(0, resolution.heatDelta)
        }

        guard heatToGain > 0 else {
            return
        }

        let preventionResolutions = resolveActiveModifiers(
            event: .heatGained(amount: heatToGain),
            handNumber: handNumber
        )

        guard !preventionResolutions.isEmpty else {
            return
        }

        resolutions.insert(contentsOf: preventionResolutions, at: 0)
    }

    private func bossPreDealResolutions(
        betType: BetType,
        revealedCardCount: Int,
        didUseShoeControl: Bool,
        handNumber: Int
    ) -> [ModifierResolution] {
        guard let activeBoss = state.bossManager.activeBoss else {
            return []
        }

        var resolutions: [ModifierResolution] = []

        if activeBoss.id == Boss.pitBoss.id || activeBoss.id == Boss.house.id {
            resolutions += applyPitBossPressure(
                bossName: activeBoss.id == Boss.house.id ? "The House" : activeBoss.name,
                betType: betType,
                handNumber: handNumber
            )
        }

        if activeBoss.id == Boss.shoeInspector.id || activeBoss.id == Boss.house.id {
            resolutions += applyInspectorPressure(
                bossName: activeBoss.id == Boss.house.id ? "The House" : activeBoss.name,
                revealedCardCount: revealedCardCount,
                didUseShoeControl: didUseShoeControl,
                handNumber: handNumber
            )
        }

        if activeBoss.id == Boss.house.id {
            resolutions += applyHouseAdaptivePressure(handNumber: handNumber)
            resolutions += applyHouseRuleShiftIfNeeded(handNumber: handNumber)
        }

        return resolutions
    }

    private func applyPitBossPressure(
        bossName: String,
        betType: BetType,
        handNumber: Int
    ) -> [ModifierResolution] {
        if state.bossLastBetType == betType {
            state.bossSameSideBetCount += 1
        } else {
            state.bossLastBetType = betType
            state.bossSameSideBetCount = 1
        }

        guard state.bossSameSideBetCount >= 3 else {
            return []
        }

        let opponentBoostCents = bossName == "The House"
            ? state.runManager.currentStage.anteCents * 3 / 4
            : state.runManager.currentStage.anteCents / 5
        state.runManager.currentStageOpponentProfitCents += opponentBoostCents

        var messages = [
            "\(bossName): repeated \(betType.displayName) betting spotted",
            "\(bossName): opponent pressure +\(MoneyFormatter.format(opponentBoostCents))"
        ]
        var heatDelta = 0

        if state.bossSameSideBetCount % 4 == 0 {
            heatDelta = 1
            messages.append("\(bossName): same side 4 times, +1 Heat")
        }

        appendDebugBattleEvent("Hand \(handNumber): \(bossName) repeated-side pressure count=\(state.bossSameSideBetCount) heat=\(heatDelta)")
        return [
            ModifierResolution(
                modifierID: "boss.pit-boss-pressure",
                modifierName: bossName,
                level: 1,
                trigger: .betPlaced,
                messages: messages,
                heatDelta: heatDelta
            )
        ]
    }

    private func applyInspectorPressure(
        bossName: String,
        revealedCardCount: Int,
        didUseShoeControl: Bool,
        handNumber: Int
    ) -> [ModifierResolution] {
        guard !state.bossInspectorPressureUsedThisStage else {
            return []
        }

        guard revealedCardCount > 0 || didUseShoeControl else {
            return []
        }

        state.bossInspectorPressureUsedThisStage = true
        let reason = revealedCardCount > 0
            ? "first reveal reduced by 1 card and flagged"
            : "first shoe-control action flagged"
        let opponentBoostCents = state.runManager.currentStage.anteCents * 4
        state.runManager.currentStageOpponentProfitCents += opponentBoostCents
        appendDebugBattleEvent("Hand \(handNumber): \(bossName) inspector pressure reason=\(reason)")

        return [
            ModifierResolution(
                modifierID: "boss.inspector-pressure",
                modifierName: bossName,
                level: 1,
                trigger: .beforeDeal,
                messages: [
                    "\(bossName): \(reason)",
                    "\(bossName): opponent audit +\(MoneyFormatter.format(opponentBoostCents))",
                    "\(bossName): +2 Heat"
                ],
                heatDelta: 2
            )
        ]
    }

    private func applyHouseAdaptivePressure(handNumber: Int) -> [ModifierResolution] {
        guard !state.houseAdaptivePressureUsedThisStage,
              let dominantTag = dominantModifierTagForHouse() else {
            return []
        }

        state.houseAdaptivePressureUsedThisStage = true
        appendDebugBattleEvent("Hand \(handNumber): The House adapted to \(dominantTag.rawValue)")

        return [
            ModifierResolution(
                modifierID: "boss.house-adaptive-pressure",
                modifierName: "The House",
                level: 1,
                trigger: .beforeDeal,
                messages: [
                    "The House adapted to your \(dominantTag.displayName) engine",
                    "The House: +1 Heat"
                ],
                heatDelta: 1
            )
        ]
    }

    private func applyHouseRuleShiftIfNeeded(handNumber: Int) -> [ModifierResolution] {
        guard !state.houseRuleShiftAppliedThisStage,
              state.runManager.currentStageRoundsPlayed >= state.runManager.currentRoundLimit / 2 else {
            return []
        }

        state.houseRuleShiftAppliedThisStage = true
        appendDebugBattleEvent("Hand \(handNumber): The House changed table pressure halfway")

        return [
            ModifierResolution(
                modifierID: "boss.house-rule-shift",
                modifierName: "The House",
                level: 1,
                trigger: .beforeDeal,
                messages: [
                    "The House changed the table rules halfway",
                    "The House: +1 Heat"
                ],
                heatDelta: 1
            )
        ]
    }

    private func dominantModifierTagForHouse() -> ModifierTag? {
        var counts: [ModifierTag: Int] = [:]

        for instance in state.activeModifiers {
            guard let modifier = Modifier.definition(id: instance.modifierID) else {
                continue
            }

            for tag in modifier.tags {
                counts[tag, default: 0] += max(1, instance.level)
            }
        }

        return counts
            .filter { $0.value >= 2 }
            .max { $0.value < $1.value }?
            .key
    }

    private func emitOutOfHandModifierEvent(_ event: GameEvent) {
        var resolutions = resolveActiveModifiers(
            event: event,
            handNumber: state.runManager.totalRoundsPlayed + 1
        )

        if event.trigger != .heatGained {
            appendHeatPreventionIfNeeded(
                to: &resolutions,
                handNumber: state.runManager.totalRoundsPlayed + 1
            )
        }

        let ledgerLines = applyModifierResolutions(resolutions)
        guard !resolutions.isEmpty else {
            return
        }

        let messages = resolutions.flatMap(\.messages)
        state.roundPresentation.upgradeMessages += messages
        state.roundPresentation.payoutLedgerLines += ledgerLines
        state.roundPresentation.triggerFeedback += resolutions.flatMap { resolution in
            resolution.messages.map { message in
                ModifierTriggerFeedback(
                    title: resolution.modifierName,
                    detail: message,
                    amountCents: visibleMoneyCents(for: resolution),
                    resourceText: resourceText(for: resolution),
                    kind: battleLogKind(for: resolution)
                )
            }
        }
        state.roundPresentation.sequenceID = UUID()
    }

    private func applyModifierResolutions(_ resolutions: [ModifierResolution]) -> [PayoutLedgerLine] {
        var ledgerLines: [PayoutLedgerLine] = []

        for resolution in resolutions {
            if resolution.bankrollDeltaCents != 0 {
                state.bankrollCents += resolution.bankrollDeltaCents
                ledgerLines.append(
                    PayoutLedgerLine(
                        title: resolution.modifierName,
                        detail: primaryMessage(for: resolution),
                        amountCents: resolution.bankrollDeltaCents
                    )
                )
            }

            if resolution.chipDelta != 0 {
                state.runManager.chips = max(0, state.runManager.chips + resolution.chipDelta)
            }

            if resolution.heatDelta != 0 {
                state.runManager.heat = min(
                    state.runManager.maxHeat,
                    max(0, state.runManager.heat + resolution.heatDelta)
                )
            }

            if let revealRequest = resolution.revealRequest {
                state.modifierRevealCount = max(state.modifierRevealCount, revealRequest.count)
            }

            for effect in resolution.deferredEffects {
                let effectMessages = applyConsumableEffect(effect, sourceName: resolution.modifierName)
                for message in effectMessages {
                    appendDebugBattleEvent(message)
                }
            }

            for message in resolution.messages {
                appendDebugBattleEvent(message)
            }

            appendDebugBattleEvent(
                "ModifierResolution \(resolution.modifierName) trigger=\(resolution.trigger.rawValue) bankroll=\(resolution.bankrollDeltaCents) chips=\(resolution.chipDelta) heat=\(resolution.heatDelta) prevented=\(resolution.heatPrevented) reveal=\(resolution.revealRequest?.count ?? 0)"
            )
        }

        if !resolutions.isEmpty {
            state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        }

        return ledgerLines
    }

    private func baselineHeatResolutions(
        result: RoundResult,
        handNumber: Int
    ) -> [ModifierResolution] {
        var heatDelta = 0
        var reasons: [String] = []

        let tableHeat = state.runManager.currentStage.effectiveTableRules.compactMap { rule -> Int? in
            if case .heatGainOnSuspiciousWin(let amount) = rule, result.didWin {
                return amount
            }

            if case .heatGainOnLoss(let amount) = rule, !result.didWin, !result.isPush {
                return amount
            }

            return nil
        }.reduce(0, +)

        if tableHeat > 0 {
            heatDelta += tableHeat
            reasons.append(state.runManager.currentStage.tableEvent.name)
        }

        guard heatDelta != 0 else {
            return []
        }

        let signedHeat = heatDelta > 0 ? "+\(heatDelta)" : "\(heatDelta)"
        let reasonText = reasons.joined(separator: ", ")
        appendDebugBattleEvent("[Heat] Heat changed by \(signedHeat): reason=\(reasonText)")

        return [
            ModifierResolution(
                modifierID: "system.heat-pressure",
                modifierName: "Table Heat",
                level: 1,
                trigger: .handResolved,
                messages: ["Heat \(signedHeat): \(reasonText)"],
                heatDelta: heatDelta
            )
        ]
    }

    private func applyHeatResponseIfNeeded(bankrollBeforeRoundCents: Int) -> (messages: [String], ledgerLines: [PayoutLedgerLine]) {
        if state.runManager.heat >= VerticalSliceBalance.pitBossHeatThreshold,
           state.bankrollCents > bankrollBeforeRoundCents {
            let heatBeforeResponse = state.runManager.heat
            let positiveProfitCents = state.bankrollCents - bankrollBeforeRoundCents
            let skimCents = min(
                state.bankrollCents,
                max(1, positiveProfitCents * VerticalSliceBalance.pitBossSkimPercent / 100)
            )
            state.bankrollCents = max(0, state.bankrollCents - skimCents)
            state.runManager.heat = max(0, state.runManager.heat - VerticalSliceBalance.pitBossHeatReduction)
            state.runManager.updateHighs(bankrollCents: state.bankrollCents)
            appendDebugBattleEvent("[Heat] Pit Boss Skim: heat \(heatBeforeResponse)->\(state.runManager.heat) skim=\(MoneyFormatter.format(skimCents))")

            return (
                [
                    "Pit Boss Skim: Heat \(heatBeforeResponse) attracted attention",
                    "Pit Boss Skim: lost \(MoneyFormatter.format(skimCents)), Heat cooled to \(state.runManager.heat)"
                ],
                [
                    PayoutLedgerLine(
                        title: "Pit Boss Skim",
                        detail: "Heat 7+ after a profitable hand",
                        amountCents: -skimCents
                    )
                ]
            )
        }

        guard state.runManager.heat >= state.runManager.maxHeat else {
            return ([], [])
        }

        let heatBeforePenalty = state.runManager.heat
        let penaltyCents = min(
            state.bankrollCents,
            max(
                state.runManager.currentStage.minimumBetCents,
                state.bankrollCents / VerticalSliceBalance.crackdownBankrollPenaltyDivisor
            )
        )
        state.bankrollCents = max(0, state.bankrollCents - penaltyCents)
        state.runManager.heat = max(0, state.runManager.heat - VerticalSliceBalance.crackdownHeatReduction)
        state.runManager.updateHighs(bankrollCents: state.bankrollCents)
        appendDebugBattleEvent("[Heat] Crackdown: heat \(heatBeforePenalty)->\(state.runManager.heat) bankrollPenalty=\(MoneyFormatter.format(penaltyCents))")

        return (
            [
                "Crackdown: Heat maxed",
                "Crackdown: lost \(MoneyFormatter.format(penaltyCents)), Heat cooled to \(state.runManager.heat)"
            ],
            [
                PayoutLedgerLine(
                    title: "Crackdown",
                    detail: "Heat maxed; casino took a visible penalty",
                    amountCents: -penaltyCents
                )
            ]
        )
    }

    private func modifierStageStats() -> ModifierStageStats {
        let stageHistory = Array(state.history.prefix(state.runManager.currentStageRoundsPlayed))
        return ModifierStageStats(
            playerSideWins: stageHistory.filter { $0.winner == .player }.count,
            bankerSideWins: stageHistory.filter { $0.winner == .banker }.count,
            tieResults: stageHistory.filter { $0.winner == .tie }.count,
            winningBets: state.runManager.currentStageWinningBets,
            tieBetLosses: stageHistory.filter { $0.betType == .tie && !$0.didWin }.count
        )
    }

    private func activeModifierTags() -> Set<ModifierTag> {
        let definitions = state.activeModifiers.compactMap { Modifier.definition(id: $0.modifierID) }
        return definitions.reduce(into: Set<ModifierTag>()) { result, modifier in
            result.formUnion(modifier.tags)
        }
    }

    private func visibleMoneyCents(for resolution: ModifierResolution) -> Int? {
        if resolution.bankrollDeltaCents != 0 {
            return resolution.bankrollDeltaCents
        }

        if resolution.payoutBonusCents != 0 {
            return resolution.payoutBonusCents
        }

        return nil
    }

    private func resourceText(for resolution: ModifierResolution) -> String? {
        if resolution.chipDelta != 0 {
            return "\(resolution.chipDelta > 0 ? "+" : "")\(resolution.chipDelta) Chip\(abs(resolution.chipDelta) == 1 ? "" : "s")"
        }

        if resolution.heatPrevented > 0 {
            return "Blocked \(resolution.heatPrevented) Heat"
        }

        if resolution.heatDelta != 0 {
            return "\(resolution.heatDelta > 0 ? "+" : "")\(resolution.heatDelta) Heat"
        }

        if let revealRequest = resolution.revealRequest {
            return "\(revealRequest.count) card\(revealRequest.count == 1 ? "" : "s")"
        }

        if resolution.tieChargesDelta != 0 {
            return "\(resolution.tieChargesDelta > 0 ? "+" : "")\(resolution.tieChargesDelta) Tie"
        }

        if !resolution.deferredEffects.isEmpty {
            return "\(resolution.deferredEffects.count) shoe"
        }

        return nil
    }

    private func battleLogKind(for resolution: ModifierResolution) -> BattleLogEffectKind {
        if resolution.heatPrevented > 0 || resolution.heatDelta != 0 {
            return .heat
        }

        if resolution.chipDelta != 0 {
            return .chips
        }

        if resolution.revealRequest != nil {
            return .reveal
        }

        if !resolution.deferredEffects.isEmpty {
            return .shoe
        }

        if visibleMoneyCents(for: resolution) != nil {
            return .payout
        }

        return .modifier
    }

    private func primaryMessage(for resolution: ModifierResolution) -> String {
        resolution.messages.first { !$0.hasSuffix(" triggered") }
            ?? "\(resolution.modifierName) triggered"
    }

    private func modifierResolutionFeedbackEntries(_ resolutions: [ModifierResolution]) -> [ModifierTriggerFeedback] {
        resolutions.map { resolution in
            ModifierTriggerFeedback(
                title: resolution.modifierName,
                detail: primaryMessage(for: resolution),
                amountCents: visibleMoneyCents(for: resolution),
                resourceText: resourceText(for: resolution),
                kind: battleLogKind(for: resolution)
            )
        }
    }

    private func modifierResolutionEffectLines(_ resolutions: [ModifierResolution]) -> [BattleLogEffectLine] {
        resolutions.flatMap { resolution -> [BattleLogEffectLine] in
            var lines: [BattleLogEffectLine] = []

            if let money = visibleMoneyCents(for: resolution) {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: primaryMessage(for: resolution),
                        amountCents: money,
                        kind: .payout
                    )
                )
            }

            if resolution.chipDelta != 0 {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: "\(resolution.chipDelta > 0 ? "Gained" : "Spent") Chips",
                        amountCents: nil,
                        resourceText: "\(resolution.chipDelta > 0 ? "+" : "")\(resolution.chipDelta)",
                        kind: .chips
                    )
                )
            }

            if resolution.heatPrevented > 0 {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: "Prevented casino Heat",
                        amountCents: nil,
                        resourceText: "Blocked \(resolution.heatPrevented)",
                        kind: .heat
                    )
                )
            }

            if resolution.heatDelta != 0 {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: resolution.heatDelta > 0 ? "Added Heat" : "Reduced Heat",
                        amountCents: nil,
                        resourceText: "\(resolution.heatDelta > 0 ? "+" : "")\(resolution.heatDelta)",
                        kind: .heat
                    )
                )
            }

            if let revealRequest = resolution.revealRequest {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: revealRequest.includesForecast ? "Revealed cards with forecast" : "Revealed upcoming shoe cards",
                        amountCents: nil,
                        resourceText: "\(revealRequest.count) card\(revealRequest.count == 1 ? "" : "s")",
                        kind: .reveal
                    )
                )
            }

            if resolution.tieChargesDelta != 0 {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: "Tie charge changed",
                        amountCents: nil,
                        resourceText: "\(resolution.tieChargesDelta > 0 ? "+" : "")\(resolution.tieChargesDelta)",
                        kind: .modifier
                    )
                )
            }

            for effect in resolution.deferredEffects {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: effect.shortDescription,
                        amountCents: nil,
                        kind: .shoe
                    )
                )
            }

            if lines.isEmpty, !resolution.messages.isEmpty {
                lines.append(
                    BattleLogEffectLine(
                        title: resolution.modifierName,
                        detail: primaryMessage(for: resolution),
                        amountCents: nil,
                        kind: battleLogKind(for: resolution)
                    )
                )
            }

            return lines
        }
    }

    private func triggerFeedbackEntries(
        activationMessages: [String],
        payoutLedgerLines: [PayoutLedgerLine],
        modifierResolutions: [ModifierResolution] = []
    ) -> [ModifierTriggerFeedback] {
        let resolutionNames = Set(modifierResolutions.map(\.modifierName))
        let resolutionMessages = Set(modifierResolutions.flatMap(\.messages))
        var feedback = modifierResolutionFeedbackEntries(modifierResolutions)

        feedback += payoutLedgerLines
            .filter { !$0.isStructural }
            .filter { !resolutionNames.contains($0.title) }
            .map { line in
                ModifierTriggerFeedback(
                    title: line.title,
                    detail: line.detail,
                    amountCents: line.amountCents,
                    kind: battleLogKind(title: line.title, detail: line.detail)
                )
            }

        let existingTitles = Set(feedback.map(\.title))
        for message in activationMessages where !message.isEmpty && !resolutionMessages.contains(message) {
            let title = battleLogTitle(from: message)
            guard !existingTitles.contains(title) else {
                continue
            }

            feedback.append(
                ModifierTriggerFeedback(
                    title: title,
                    detail: message,
                    amountCents: nil,
                    kind: battleLogKind(title: title, detail: message)
                )
            )
        }

        return Array(feedback.prefix(5))
    }

    private func appendBattleLogEntry(
        handNumber: Int,
        result: RoundResult,
        bankrollBeforeRound: Int,
        chipsBeforeRound: Int,
        heatBeforeRound: Int,
        payoutLedgerLines: [PayoutLedgerLine],
        activationMessages: [String],
        modifierResolutions: [ModifierResolution]
    ) {
        let structuralBase = payoutLedgerLines.first {
            $0.title == "Base Payout" || $0.title == "Tie Push Refund"
        }
        let resolutionNames = Set(modifierResolutions.map(\.modifierName))
        let resolutionMessages = Set(modifierResolutions.flatMap(\.messages))
        let effectLines = battleLogEffectLines(
            activationMessages: activationMessages,
            payoutLedgerLines: payoutLedgerLines,
            excludingTitles: resolutionNames,
            excludingMessages: resolutionMessages
        ) + modifierResolutionEffectLines(modifierResolutions)
        let bossEffects = bossBattleLogEffects(activationMessages: activationMessages)
        let heatDelta = state.runManager.heat - heatBeforeRound
        let chipsDelta = state.runManager.chips - chipsBeforeRound
        let heatPrevented = modifierResolutions.reduce(0) { $0 + $1.heatPrevented }
        let entry = BattleLogEntry(
            handNumber: handNumber,
            stageNumber: state.runManager.currentStage.id,
            stageHandNumber: max(1, state.runManager.currentStageRoundsPlayed),
            stageHandLimit: state.runManager.currentRoundLimit,
            betSide: result.betType,
            betAmountCents: result.betAmountCents,
            playerCards: result.playerHand.cards,
            bankerCards: result.bankerHand.cards,
            baccaratResult: result.winner,
            basePayout: structuralBase,
            modifierEffects: effectLines,
            chipsDelta: chipsDelta,
            heatDelta: heatDelta,
            heatPrevented: heatPrevented,
            finalBankrollChangeCents: state.bankrollCents - bankrollBeforeRound,
            opponentBossEffects: bossEffects
        )

        state.battleLog.insert(entry, at: 0)
        if state.battleLog.count > 60 {
            state.battleLog.removeLast(state.battleLog.count - 60)
        }

        appendDebugBattleEvent("Hand \(handNumber): BattleLogEntry effects=\(effectLines.count) chipsDelta=\(chipsDelta) heatDelta=\(heatDelta)")
    }

    private func battleLogEffectLines(
        activationMessages: [String],
        payoutLedgerLines: [PayoutLedgerLine],
        excludingTitles: Set<String> = [],
        excludingMessages: Set<String> = []
    ) -> [BattleLogEffectLine] {
        var lines: [BattleLogEffectLine] = payoutLedgerLines
            .filter { !$0.isStructural }
            .filter { !excludingTitles.contains($0.title) }
            .map { line in
                BattleLogEffectLine(
                    title: line.title,
                    detail: line.detail,
                    amountCents: line.amountCents,
                    kind: battleLogKind(title: line.title, detail: line.detail)
                )
            }

        let existingTitles = Set(lines.map(\.title))
        for message in activationMessages where !message.isEmpty && !excludingMessages.contains(message) {
            let title = battleLogTitle(from: message)
            guard !existingTitles.contains(title) else {
                continue
            }

            lines.append(
                BattleLogEffectLine(
                    title: title,
                    detail: message,
                    amountCents: nil,
                    kind: battleLogKind(title: title, detail: message)
                )
            )
        }

        return lines
    }

    private func bossBattleLogEffects(activationMessages: [String]) -> [BattleLogEffectLine] {
        activationMessages
            .filter { message in
                let lower = message.lowercased()
                return lower.contains("boss") || lower.contains("surveillance") || lower.contains("suppressed")
            }
            .map { message in
                BattleLogEffectLine(
                    title: battleLogTitle(from: message),
                    detail: message,
                    amountCents: nil,
                    kind: .boss
                )
            }
    }

    private func battleLogTitle(from message: String) -> String {
        let separators = [" +", " refunded", ":", " x", " spent", " hit", " extra", " read"]
        for separator in separators {
            if let range = message.range(of: separator) {
                return String(message[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func battleLogKind(title: String, detail: String) -> BattleLogEffectKind {
        let combined = "\(title) \(detail)".lowercased()

        if combined.contains("heat") {
            return .heat
        }

        if combined.contains("chip") {
            return .chips
        }

        if combined.contains("reveal") || combined.contains("x-ray") || combined.contains("forecast") || combined.contains("read") {
            return .reveal
        }

        if combined.contains("shoe") || combined.contains("burn") || combined.contains("shuffle") || combined.contains("cut") || combined.contains("card") {
            return .shoe
        }

        if combined.contains("boss") || combined.contains("surveillance") || combined.contains("suppressed") {
            return .boss
        }

        if combined.contains("payout") || combined.contains("commission") || combined.contains("bonus") || combined.contains("refund") {
            return .payout
        }

        return .modifier
    }

    private func appendDebugBattleEvent(_ message: String) {
#if DEBUG
        state.debugGameEventLog.insert("[Battle] \(message)", at: 0)
        if state.debugGameEventLog.count > 120 {
            state.debugGameEventLog.removeLast(state.debugGameEventLog.count - 120)
        }
        print("[Rigged Shoe BattleLog] \(message)")
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

    private func hasOpeningPair(_ hand: BaccaratHand) -> Bool {
        guard hand.cards.count >= 2 else {
            return false
        }

        return hand.cards[0].rank == hand.cards[1].rank
    }

    private func prepareGuidedFirstDealIfNeeded() {
        guard state.isGuidedFirstRun,
              !state.guidedExcitingWinDelivered,
              state.runManager.totalRoundsPlayed == 0 else {
            return
        }

        state.selectedBetType = .player
        state.selectedBetAmountCents = minimumUnlockedBetAmountCents
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
        let payoutRules = currentPayoutRules
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
            let tableCommissionPercent = activeBankerCommissionPercent()
            profitCents = payoutRules.profitCents(for: .banker, betAmountCents: betAmountCents)
            ledgerLines.append(
                PayoutLedgerLine(
                    title: "Base Payout",
                    detail: payoutRules.payoutDetail(for: .banker),
                    amountCents: profitCents,
                    isStructural: true
                )
            )
            if payoutRules.bankerCommissionPercent == 0,
               tableCommissionPercent == 0 {
                activationMessages.append("\(state.runManager.currentStage.tableEvent.name): Banker pays 1:1")
            } else if payoutRules.bankerCommissionPercent == 0,
                      upgrades.removesBankerCommission {
                let source = upgradeSourceLabel(matching: { effect in
                    if case .noCommission = effect { return true }
                    return false
                }, fallback: "No Commission")
                activationMessages.append("\(source): Banker pays 1:1")
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
            let baseTieMultiplier = activeBaseTiePayoutMultiplier()
            profitCents = betAmountCents * baseTieMultiplier
            ledgerLines.append(PayoutLedgerLine(title: "Base Payout", detail: "Tie pays \(baseTieMultiplier):1", amountCents: profitCents, isStructural: true))
            if tieMultiplier > baseTieMultiplier {
                let tieBonus = betAmountCents * (tieMultiplier - baseTieMultiplier)
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

        let tableTie = activeBaseTiePayoutMultiplier()
        let upgradedTie = upgrades.tiePayoutMultiplier + upgrades.tiePayoutBonus + state.runManager.tiePayoutBonus
        let rewardTie = state.runManager.tiePayoutOverride ?? 8
        return max(tableTie + state.runManager.tiePayoutBonus, upgradedTie, rewardTie)
    }

    private func activeBankerCommissionPercent() -> Int {
        if state.bossManager.restoresBankerCommission {
            return 5
        }

        let tableCommissions = state.runManager.currentStage.effectiveTableRules.compactMap { rule -> Int? in
            if case .bankerCommission(let percent) = rule {
                return percent
            }

            return nil
        }

        return tableCommissions.min() ?? 5
    }

    private func activeBaseTiePayoutMultiplier() -> Int {
        if state.bossManager.capsTiePayoutAtBase {
            return 8
        }

        let tableTieMultipliers = state.runManager.currentStage.effectiveTableRules.compactMap { rule -> Int? in
            if case .tiePayout(let multiplier) = rule {
                return multiplier
            }

            return nil
        }

        return max(8, tableTieMultipliers.max() ?? 8)
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
        clearLegacyShoeUpgradeDraftIfNeeded()
    }

    private var shouldOfferLegacyShoeUpgradeDrafts: Bool {
        // The rebuilt roguelite loop awards build choices through stage rewards
        // and the shop. The older every-few-hands UpgradeCard overlay remains in
        // the project for collection/meta compatibility, but should not interrupt
        // compact battles.
        false
    }

    private func clearLegacyShoeUpgradeDraftIfNeeded() {
        guard !shouldOfferLegacyShoeUpgradeDrafts,
              !state.pendingUpgradeChoices.isEmpty || state.roundsSinceLastUpgrade >= upgradeRewardThreshold else {
            return
        }

        state.pendingUpgradeChoices = []
        state.roundsSinceLastUpgrade = 0
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
             .playerAnteWinBonus,
             .bankerWinBonus,
             .bankerAnteWinBonus,
             .chosenBetWinBonus,
             .chosenBetAnteWinBonus,
             .forecastWinBonus,
             .forecastAnteWinBonus,
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
             .roundAnteStipend,
             .stageStartCash,
             .stageStartAnteCash,
             .cardExitIncome,
             .streakBonus,
             .firstTieEachStageMultiplier,
             .consecutiveTiePayoutBonus,
             .previousLossRefundOnTie,
             .bossStageCash,
             .bossStageAnteCash,
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
        if let rebuildEffect = reward.rebuildEffect {
            applyRebuildStageReward(rebuildEffect, sourceName: reward.name)
            return
        }

        switch reward.effect {
        case .gainCash(let cents):
            state.bankrollCents += adjustedContactCashReward(cents)
        case .gainAnteScaledCash(let multiplierPercent):
            let calculation = EconomyRewardCalculation.stageCashReward(
                stage: state.runManager.currentStage,
                bankrollCents: state.bankrollCents,
                multiplierPercent: multiplierPercent
            )
            let adjustedCash = adjustedContactCashReward(calculation.cashRewardCents)
            state.bankrollCents += adjustedCash
            logRewardCalculation(calculation)
            logContactCashAdjustmentIfNeeded(originalCents: calculation.cashRewardCents, adjustedCents: adjustedCash)
        case .gainChips(let amount):
            state.runManager.chips += max(0, amount)
        case .reduceHeat(let amount):
            state.runManager.heat = max(0, state.runManager.heat - max(0, amount))
        case .removeRandomAcquiredUpgrade:
            state.runManager.chips += 1
            appendDebugBattleEvent("\(reward.name): retired upgrade removal converted to +1 Chip")
        case .duplicateRandomAcquiredUpgrade:
            state.runManager.chips += 2
            appendDebugBattleEvent("\(reward.name): retired upgrade duplicate converted to +2 Chips")
        case .addRandomUpgrade(let rarity):
            let chips = rarity == .legendary ? 5 : 3
            state.runManager.chips += chips
            appendDebugBattleEvent("\(reward.name): retired \(rarity.displayName) upgrade converted to +\(chips) Chips")
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

    private func applyRebuildStageReward(_ effect: RebuildStageRewardEffect, sourceName: String) {
        switch effect {
        case .bankroll(let cents):
            let adjustedCash = adjustedContactCashReward(cents)
            state.bankrollCents += adjustedCash
            appendDebugBattleEvent("\(sourceName): +\(MoneyFormatter.format(adjustedCash)) bankroll")
        case .chips(let amount):
            state.runManager.chips += max(0, amount)
            appendDebugBattleEvent("\(sourceName): +\(max(0, amount)) Chips")
        case .heatReduction(let amount):
            let before = state.runManager.heat
            state.runManager.heat = max(0, state.runManager.heat - max(0, amount))
            appendDebugBattleEvent("\(sourceName): -\(before - state.runManager.heat) Heat")
        case .modifierDraft(let rarity):
            grantDraftModifier(rarity: rarity, sourceName: sourceName)
        case .consumableDraft:
            grantDraftConsumable(sourceName: sourceName)
        case .attachmentDraft:
            grantDraftAttachment(sourceName: sourceName)
        case .bossRelicDraft:
            grantDraftBossRelic(sourceName: sourceName)
        case .shopDiscount(let percent):
            let chips = max(1, percent / 10)
            state.runManager.chips += chips
            appendDebugBattleEvent("\(sourceName): future shop discount converted to +\(chips) Chips")
        }
    }

    private func grantDraftModifier(rarity: ModifierRarity?, sourceName: String) {
        let tier = ShopState.tier(
            for: state.runManager.currentStage.id,
            defeatedBosses: state.bossManager.defeatedBosses.count
        )
        let dominantTags = RewardDraftState.dominantTags(from: state.activeModifiers)
        let candidates = ActiveModifierCatalog.regularDefinitions(in: Modifier.allContent).filter { modifier in
            modifier.minShopTier <= tier
                && (rarity == nil || modifier.rarity == rarity)
        }
        let weighted = weightedModifiers(candidates, dominantTags: dominantTags)

        guard let modifier = mutateSeededRandom({ generator in
            seededRandomElement(from: weighted.isEmpty ? candidates : weighted, seededGenerator: &generator)
        }) else {
            state.runManager.chips += 1
            appendDebugBattleEvent("\(sourceName): no modifier available, +1 Chip")
            return
        }

        if buyModifier(id: modifier.id) {
            appendDebugBattleEvent("\(sourceName): drafted \(modifier.name)")
            emitOutOfHandModifierEvent(.modifierBought(modifierID: modifier.id))
        } else {
            state.runManager.chips += max(1, modifier.sellValueChips)
            appendDebugBattleEvent("\(sourceName): no modifier slot, +\(max(1, modifier.sellValueChips)) Chips")
        }
    }

    private func grantCapstoneModifier(sourceName: String) {
        let ownedIDs = Set((state.activeModifiers + state.benchModifiers).map(\.modifierID))
        let dominantTags = RewardDraftState.dominantTags(from: state.activeModifiers)
        let candidates = ActiveModifierCatalog.capstoneDefinitions(in: Modifier.allContent).filter { modifier in
            !ownedIDs.contains(modifier.id)
        }
        let weighted = weightedModifiers(candidates, dominantTags: dominantTags)

        guard let modifier = mutateSeededRandom({ generator in
            seededRandomElement(from: weighted.isEmpty ? candidates : weighted, seededGenerator: &generator)
        }) else {
            state.runManager.chips += 3
            appendDebugBattleEvent("\(sourceName): no capstone available, +3 Chips")
            return
        }

        if buyModifier(id: modifier.id) {
            appendDebugBattleEvent("\(sourceName): drafted capstone \(modifier.name)")
            emitOutOfHandModifierEvent(.modifierBought(modifierID: modifier.id))
        } else {
            state.runManager.chips += max(3, modifier.sellValueChips)
            appendDebugBattleEvent("\(sourceName): no capstone slot, +\(max(3, modifier.sellValueChips)) Chips")
        }
    }

    private func grantDraftConsumable(sourceName: String) {
        let tier = ShopState.tier(
            for: state.runManager.currentStage.id,
            defeatedBosses: state.bossManager.defeatedBosses.count
        )
        let candidates = Consumable.allContent.filter { $0.minShopTier <= tier }

        guard state.consumables.count < state.consumableSlotLimit,
              let consumable = mutateSeededRandom({ generator in
                  seededRandomElement(from: candidates, seededGenerator: &generator)
              }) else {
            state.runManager.chips += 1
            appendDebugBattleEvent("\(sourceName): consumable slot full, +1 Chip")
            return
        }

        state.consumables.append(consumable)
        appendDebugBattleEvent("\(sourceName): gained \(consumable.name)")
    }

    private func grantDraftAttachment(sourceName: String) {
        let tier = ShopState.tier(
            for: state.runManager.currentStage.id,
            defeatedBosses: state.bossManager.defeatedBosses.count
        )
        let candidates = Attachment.allContent.filter { attachment in
            attachment.minShopTier <= tier && attachmentTargetIndex(for: attachment) != nil
        }

        guard let attachment = mutateSeededRandom({ generator in
            seededRandomElement(from: candidates, seededGenerator: &generator)
        }), attach(attachment) else {
            state.runManager.chips += 1
            appendDebugBattleEvent("\(sourceName): no compatible attachment target, +1 Chip")
            return
        }

        if !state.attachments.contains(where: { $0.id == attachment.id }) {
            state.attachments.append(attachment)
        }
        appendDebugBattleEvent("\(sourceName): applied \(attachment.name)")
    }

    private func grantDraftBossRelic(sourceName: String) {
        guard state.bossRelics.count < state.bossRelicSlotLimit else {
            state.runManager.chips += 2
            appendDebugBattleEvent("\(sourceName): boss relic slot full, +2 Chips")
            return
        }

        let owned = Set(state.bossRelics.map(\.id))
        let candidates = BossRelic.allRelics.filter { !owned.contains($0.id) }
        guard let relic = mutateSeededRandom({ generator in
            seededRandomElement(from: candidates, seededGenerator: &generator)
        }) else {
            state.runManager.chips += 2
            appendDebugBattleEvent("\(sourceName): no boss relic available, +2 Chips")
            return
        }

        state.bossRelics.append(relic)
        appendDebugBattleEvent("\(sourceName): gained \(relic.name)")
    }

    private func weightedModifiers(_ modifiers: [Modifier], dominantTags: Set<ModifierTag>) -> [Modifier] {
        guard !dominantTags.isEmpty else {
            return modifiers
        }

        var weighted: [Modifier] = []
        for modifier in modifiers {
            weighted.append(modifier)
            if !modifier.tags.isDisjoint(with: dominantTags) {
                weighted.append(contentsOf: [modifier, modifier])
            }
        }
        return weighted
    }

    private func seededRandomElement<T>(
        from values: [T],
        seededGenerator: inout SeededRandomGenerator?
    ) -> T? {
        guard !values.isEmpty else {
            return nil
        }

        if var generator = seededGenerator {
            let value = values.seededRandomElement(using: &generator)
            seededGenerator = generator
            return value
        }

        return values.randomElement()
    }

    private func logRewardCalculation(_ calculation: EconomyRewardCalculation) {
        let capStatus = calculation.capApplied ? "cap applied" : "no cap"
        appendDebugBattleEvent(
            "Reward calc stage=\(calculation.stageNumber) anteCents=\(calculation.anteCents) cashCents=\(calculation.cashRewardCents) chips=\(calculation.chipsReward) \(capStatus) reason=\(calculation.reason)"
        )
    }

    private func adjustedContactCashReward(_ cents: Int) -> Int {
        max(0, cents * state.startingContact.cashRewardMultiplierPercent / 100)
    }

    private func logContactCashAdjustmentIfNeeded(originalCents: Int, adjustedCents: Int) {
        guard originalCents != adjustedCents else {
            return
        }

        appendDebugBattleEvent(
            "\(state.startingContact.name) adjusted immediate cash reward \(MoneyFormatter.format(originalCents)) -> \(MoneyFormatter.format(adjustedCents))"
        )
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
            state.bankrollCents += adjustedContactCashReward(cents)
        case .gainAnteScaledCash(let multiplierPercent, let chips):
            let calculation = EconomyRewardCalculation.bossCashReward(
                stage: state.runManager.currentStage,
                bankrollCents: state.bankrollCents,
                multiplierPercent: multiplierPercent,
                chipsReward: chips
            )
            let adjustedCash = adjustedContactCashReward(calculation.cashRewardCents)
            state.bankrollCents += adjustedCash
            state.runManager.chips += calculation.chipsReward
            logRewardCalculation(calculation)
            logContactCashAdjustmentIfNeeded(originalCents: calculation.cashRewardCents, adjustedCents: adjustedCash)
        case .duplicateRandomUpgrades(let count):
            let chips = max(1, count) * 2
            state.runManager.chips += chips
            appendDebugBattleEvent("\(reward.name): retired boss upgrade duplicate converted to +\(chips) Chips")
        case .removeAllFaceCards:
            let removedCount = state.shoe.removeAllFaceCards()
            registerShoeImpact(.removedCards(removedCount))
        case .addRandomLegendaryUpgrade:
            state.runManager.chips += 5
            appendDebugBattleEvent("\(reward.name): retired legendary upgrade converted to +5 Chips")
        case .casinoInsideContact(let extraRounds):
            state.runManager.futureStageRoundBonus += extraRounds
        case .grantBossRelic(let id):
            guard state.bossRelics.count < state.bossRelicSlotLimit,
                  let relic = BossRelic.definition(id: id),
                  !state.bossRelics.contains(where: { $0.id == relic.id }) else {
                return
            }

            state.bossRelics.append(relic)
        case .draftCapstoneModifier:
            grantCapstoneModifier(sourceName: reward.name)
        }
    }

    private func enrichLastStageResultWithBuildArchetype() {
        guard let result = state.runManager.lastStageResult else {
            return
        }

        state.runManager.lastStageResult = StageResultData(
            stageNumber: result.stageNumber,
            didWin: result.didWin,
            startingBankrollCents: result.startingBankrollCents,
            endingBankrollCents: result.endingBankrollCents,
            profitCents: result.profitCents,
            opponentName: result.opponentName,
            opponentProfitCents: result.opponentProfitCents,
            bankrollChangeCents: result.bankrollChangeCents,
            objectiveDescription: result.objectiveDescription,
            objectiveProgressText: result.objectiveProgressText,
            scoreMarginCents: result.scoreMarginCents,
            heatChange: result.heatChange,
            chipsEarned: result.chipsEarned,
            failureReason: result.failureReason,
            tableEventName: result.tableEventName,
            secondaryObjectiveTitle: result.secondaryObjectiveTitle,
            secondaryObjectiveCompleted: result.secondaryObjectiveCompleted,
            secondaryObjectiveReward: result.secondaryObjectiveReward,
            lossExplanation: result.lossExplanation,
            buildArchetype: BuildArchetypeDetector.detect(activeModifiers: state.activeModifiers),
            triggeredModifierSummaries: stageModifierActivitySummary(stageNumber: result.stageNumber)
        )
    }

    private func stageModifierActivitySummary(stageNumber: Int) -> [String] {
        let lines = state.battleLog
            .filter { $0.stageNumber == stageNumber }
            .flatMap(\.importantEffects)
            .filter { $0.kind == .modifier || $0.kind == .payout || $0.kind == .chips || $0.kind == .heat || $0.kind == .reveal || $0.kind == .shoe }

        guard !lines.isEmpty else {
            return ["No modifier triggers recorded this stage."]
        }

        var counts: [String: Int] = [:]
        for line in lines {
            counts[line.title, default: 0] += 1
        }

        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(5)
            .map { "\($0.key) triggered \($0.value)x" }
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
        resetBossPressureStateForStage()
        state.hasPaidFirstTieThisStage = false
        state.hasUsedSafetyNetThisStage = false
        state.hasUsedHighRollerSparkThisStage = false
        state.hasPaidFaceHunterThisStage = false
        state.hasMovedCardThisStage = false
        state.isXRayActiveForNextHand = false
        state.xRayChargesRemainingThisStage = activeUpgradeEffects.chargedShoeReveal?.chargesPerStage ?? 0
        state.modifierRevealCount = 0
        modifierEngine.resetStage()
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

        resolveStageStartedModifiersIfNeeded()
    }

    private func resetBossPressureStateForStage() {
        state.bossLastBetType = nil
        state.bossSameSideBetCount = 0
        state.bossInspectorPressureUsedThisStage = false
        state.houseAdaptivePressureUsedThisStage = false
        state.houseRuleShiftAppliedThisStage = false
    }

    private func resolveStageStartedModifiersIfNeeded() {
        let stageResolutions = resolveActiveModifiers(
            event: .stageStarted(stageNumber: state.runManager.currentStage.id),
            handNumber: state.runManager.totalRoundsPlayed + 1
        )
        let stageLedgerLines = applyModifierResolutions(stageResolutions)
        guard !stageResolutions.isEmpty else {
            return
        }

        state.roundPresentation.upgradeMessages += stageResolutions.flatMap(\.messages)
        state.roundPresentation.payoutLedgerLines += stageLedgerLines
        state.roundPresentation.triggerFeedback += stageResolutions.flatMap { resolution in
            resolution.messages.map {
                ModifierTriggerFeedback(
                    title: resolution.modifierName,
                    detail: $0,
                    amountCents: visibleMoneyCents(for: resolution),
                    resourceText: resourceText(for: resolution),
                    kind: battleLogKind(for: resolution)
                )
            }
        }
        state.roundPresentation.sequenceID = UUID()
        recordRunSnapshot()
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
        logState(.runSaved, fields: ["flow": state.runManager.flowState.rawValue, "status": state.runManager.status.storageValueForLogging])
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

    private func logState(_ event: RiggedShoeLogEvent, hand: Int? = nil, fields: [String: String] = [:]) {
        logger.log(
            RiggedShoeLogRecord(
                event: event,
                runID: state.runID,
                stage: state.runManager.currentStage.id,
                hand: hand ?? state.runManager.totalRoundsPlayed,
                fields: fields
            )
        )
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

private extension RunStatus {
    var storageValueForLogging: String {
        switch self {
        case .active:
            return "active"
        case .stageCleared:
            return "stageCleared"
        case .failed:
            return "failed"
        case .completed:
            return "completed"
        }
    }
}
