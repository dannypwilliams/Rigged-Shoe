import Foundation

/// Type of item shown in the rebuilt shop.
enum ShopOfferKind: String, Codable, Equatable {
    case modifier
    case consumable
    case attachment
    case bossRelic

    var displayName: String {
        switch self {
        case .modifier:
            return "Modifier"
        case .consumable:
            return "Consumable"
        case .attachment:
            return "Attachment"
        case .bossRelic:
            return "Boss Relic"
        }
    }
}

/// One purchasable slot in the shop.
///
/// Definitions are referenced by ID so the shop can stay small in persistence.
/// Future content registries can resolve the IDs to full definitions.
struct ShopOffer: Identifiable, Codable, Equatable {
    let id: UUID
    var kind: ShopOfferKind
    var contentID: String
    var priceChips: Int
    var isFrozen: Bool
    var isSoldOut: Bool

    init(
        id: UUID = UUID(),
        kind: ShopOfferKind,
        contentID: String,
        priceChips: Int,
        isFrozen: Bool = false,
        isSoldOut: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.contentID = contentID
        self.priceChips = max(0, priceChips)
        self.isFrozen = isFrozen
        self.isSoldOut = isSoldOut
    }
}

/// Shop state between battles.
///
/// This is deliberately separate from SwiftUI. The view should render offers
/// and send buy/sell/reroll intents; a future shop reducer should mutate this.
struct ShopState: Codable, Equatable {
    var ante: Int
    var rerollCostChips: Int
    var rerollsThisStage: Int
    var offers: [ShopOffer]
    var lockedOfferIDs: Set<UUID>
    var sellEnabled: Bool
    var combineEnabled: Bool

    init(
        ante: Int = 1,
        rerollCostChips: Int = 1,
        rerollsThisStage: Int = 0,
        offers: [ShopOffer] = [],
        lockedOfferIDs: Set<UUID> = [],
        sellEnabled: Bool = true,
        combineEnabled: Bool = true
    ) {
        self.ante = max(1, ante)
        self.rerollCostChips = max(0, rerollCostChips)
        self.rerollsThisStage = max(0, rerollsThisStage)
        self.offers = offers
        self.lockedOfferIDs = lockedOfferIDs
        self.sellEnabled = sellEnabled
        self.combineEnabled = combineEnabled
    }
}

extension ShopState {
    static func tier(for stageID: Int, defeatedBosses: Int = 0) -> Int {
        if stageID >= 9 {
            return 5
        }

        if defeatedBosses >= 2 || stageID >= 8 {
            return 4
        }

        if defeatedBosses >= 1 || stageID >= 5 {
            return 3
        }

        if stageID >= 3 {
            return 2
        }

        return 1
    }

    static func generated(
        stageID: Int,
        ante: Int,
        defeatedBosses: Int,
        frozenOffers: [ShopOffer],
        ownedModifierIDs: [String],
        contactBiasTags: Set<ModifierTag>,
        seededGenerator: inout SeededRandomGenerator?
    ) -> ShopState {
        let tier = Self.tier(for: stageID, defeatedBosses: defeatedBosses)
        let frozen = frozenOffers.filter {
            $0.isFrozen && !$0.isSoldOut && ActiveModifierCatalog.productionShopOfferAllowed($0)
        }
        let needed = max(0, ActiveModifierCatalog.normalShopOfferCount - frozen.count)
        let generatedOffers = generateOffers(
            count: needed,
            tier: tier,
            ownedModifierIDs: ownedModifierIDs,
            contactBiasTags: contactBiasTags,
            seededGenerator: &seededGenerator
        )

        return ShopState(
            ante: ante,
            rerollCostChips: 1,
            rerollsThisStage: 0,
            offers: Array((frozen + generatedOffers).prefix(ActiveModifierCatalog.normalShopOfferCount))
        )
    }

    private static func generateOffers(
        count: Int,
        tier: Int,
        ownedModifierIDs: [String],
        contactBiasTags: Set<ModifierTag>,
        seededGenerator: inout SeededRandomGenerator?
    ) -> [ShopOffer] {
        guard count > 0 else {
            return []
        }

        var offers: [ShopOffer] = []
        var localGenerator = seededGenerator ?? SeededRandomGenerator(seed: UInt64(Date().timeIntervalSince1970))
        let ownedSet = Set(ownedModifierIDs)

        for _ in 0..<count {
            let modifiers = weightedModifiers(tier: tier, ownedModifierIDs: ownedSet, contactBiasTags: contactBiasTags)
            let available = modifiers.filter { candidate in
                !offers.contains { $0.kind == .modifier && $0.contentID == candidate.id }
            }
            if let modifier = (available.isEmpty ? modifiers : available).seededRandomElement(using: &localGenerator) {
                offers.append(ShopOffer(kind: .modifier, contentID: modifier.id, priceChips: modifier.baseCostChips))
            }
        }

        seededGenerator = localGenerator
        return offers
    }

    private static func weightedModifiers(
        tier: Int,
        ownedModifierIDs: Set<String>,
        contactBiasTags: Set<ModifierTag>
    ) -> [Modifier] {
        let candidates = ActiveModifierCatalog.shopEligibleModifiers(
            in: Modifier.allContent,
            tier: tier,
            contactBiasTags: contactBiasTags
        )
        var weighted = candidates

        for modifier in candidates where !modifier.tags.isDisjoint(with: contactBiasTags) {
            weighted.append(contentsOf: Array(repeating: modifier, count: 2))
        }

        for modifier in candidates where ownedModifierIDs.contains(modifier.id) {
            weighted.append(modifier)
        }

        return weighted.isEmpty ? candidates : weighted
    }
}

/// One-use or limited-use table action.
///
/// Consumables are the clean place for player-timed decisions like burns,
/// cuts, temporary X-Ray, or Heat relief.
struct Consumable: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var summary: String
    var tags: Set<ModifierTag>
    var triggerWindow: ModifierTrigger
    var effects: [ModifierEffect]
    var charges: Int
    var priceChips: Int
    var minShopTier: Int

    init(
        id: String,
        name: String,
        summary: String,
        tags: Set<ModifierTag>,
        triggerWindow: ModifierTrigger,
        effects: [ModifierEffect],
        charges: Int = 1,
        priceChips: Int,
        minShopTier: Int = 1
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.tags = tags.union([.consumable])
        self.triggerWindow = triggerWindow
        self.effects = effects
        self.charges = max(1, charges)
        self.priceChips = max(0, priceChips)
        self.minShopTier = min(max(1, minShopTier), 5)
    }
}

/// Add-on that modifies a held modifier.
///
/// Attachments create shop decisions without requiring a huge modifier pool:
/// improve a build piece, add charges, or bend a trigger.
struct Attachment: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var summary: String
    var compatibleTags: Set<ModifierTag>
    var effects: [ModifierEffect]
    var priceChips: Int
    var minShopTier: Int

    init(
        id: String,
        name: String,
        summary: String,
        compatibleTags: Set<ModifierTag>,
        effects: [ModifierEffect],
        priceChips: Int,
        minShopTier: Int = 1
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.compatibleTags = compatibleTags
        self.effects = effects
        self.priceChips = max(0, priceChips)
        self.minShopTier = min(max(1, minShopTier), 5)
    }
}

/// Permanent-for-this-run reward earned from bosses.
///
/// Boss relics should feel powerful but transparent. They are modeled as data so
/// boss rewards can be balanced independently from normal shop modifiers.
struct BossRelic: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var summary: String
    var sourceBossID: String?
    var effects: [ModifierEffect]

    init(
        id: String,
        name: String,
        summary: String,
        sourceBossID: String? = nil,
        effects: [ModifierEffect]
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.sourceBossID = sourceBossID
        self.effects = effects
    }
}

/// Optional run starter unlocked by meta progression.
///
/// A contact should set the opening flavor of a run without becoming permanent
/// progression power creep that makes the first battles meaningless.
struct StartingContact: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var flavor: String
    var summary: String
    var startingModifiers: [String]
    var startingConsumables: [String]
    var currencyAdjustments: RunCurrencyState?
    var bankrollAdjustmentCents: Int
    var chipsAdjustment: Int
    var heatAdjustment: Int
    var shopBiasTags: Set<ModifierTag>
    var difficultyRating: String
    var recommendedArchetype: String
    var earlyMaxBetMultiplierPercent: Int
    var cashRewardMultiplierPercent: Int

    init(
        id: String,
        name: String,
        flavor: String = "",
        summary: String,
        startingModifiers: [String] = [],
        startingConsumables: [String] = [],
        currencyAdjustments: RunCurrencyState? = nil,
        bankrollAdjustmentCents: Int = 0,
        chipsAdjustment: Int = 0,
        heatAdjustment: Int = 0,
        shopBiasTags: Set<ModifierTag> = [],
        difficultyRating: String = "Normal",
        recommendedArchetype: String = "Flexible",
        earlyMaxBetMultiplierPercent: Int = 100,
        cashRewardMultiplierPercent: Int = 100
    ) {
        self.id = id
        self.name = name
        self.flavor = flavor
        self.summary = summary
        self.startingModifiers = startingModifiers
        self.startingConsumables = startingConsumables
        self.currencyAdjustments = currencyAdjustments
        self.bankrollAdjustmentCents = bankrollAdjustmentCents
        self.chipsAdjustment = chipsAdjustment
        self.heatAdjustment = heatAdjustment
        self.shopBiasTags = shopBiasTags
        self.difficultyRating = difficultyRating
        self.recommendedArchetype = recommendedArchetype
        self.earlyMaxBetMultiplierPercent = max(25, earlyMaxBetMultiplierPercent)
        self.cashRewardMultiplierPercent = max(0, cashRewardMultiplierPercent)
    }
}

extension ShopState {
    static func sampleDebugShop(modifiers: [Modifier]) -> ShopState {
        ShopState(
            ante: 1,
            rerollCostChips: 1,
            offers: modifiers.map {
                ShopOffer(kind: .modifier, contentID: $0.id, priceChips: $0.baseCostChips)
            } + [
                ShopOffer(kind: .consumable, contentID: Consumable.sampleLuckyCut.id, priceChips: Consumable.sampleLuckyCut.priceChips),
                ShopOffer(kind: .attachment, contentID: Attachment.sampleGoldClip.id, priceChips: Attachment.sampleGoldClip.priceChips)
            ]
        )
    }
}

extension Consumable {
    static var allContent: [Consumable] {
        [
            Consumable(id: "consumable.marked-card", name: "Marked Card", summary: "Mark one upcoming card for a short read.", tags: [.shoeVision], triggerWindow: .beforeDeal, effects: [.revealUpcomingCards(count: 1)], priceChips: 2),
            Consumable(id: "consumable.burn-slip", name: "Burn Slip", summary: "Burn the next card before a hand.", tags: [.shoeControl], triggerWindow: .beforeDeal, effects: [.burnCards(count: 1)], priceChips: 2),
            Consumable(id: "consumable.dealer-favor", name: "Dealer Favor", summary: "Your next loss refunds 50%.", tags: [.comeback], triggerWindow: .wagerLost, effects: [.lossRefund(percent: 50, maxCents: nil)], priceChips: 3),
            Consumable(id: "consumable.counterfeit-chip", name: "Counterfeit Chip", summary: "Gain 3 Chips and add 1 Heat.", tags: [.economy, .heat], triggerWindow: .shopEntered, effects: [.grantChips(amount: 3), .gainHeat(amount: 1)], priceChips: 0),
            Consumable(id: "consumable.free-drink", name: "Free Drink", summary: "Remove 1 Heat.", tags: [.heat], triggerWindow: .shopEntered, effects: [.reduceHeat(amount: 1)], priceChips: 2),
            Consumable(id: "consumable.lucky-matchbook", name: "Lucky Matchbook", summary: "Next win grants 1x ante bankroll.", tags: [.economy], triggerWindow: .wagerWon, effects: [.grantBankrollFromAnte(percent: 100)], priceChips: 3),
            Consumable(id: "consumable.private-marker", name: "Private Marker", summary: "Borrow bankroll for one hand.", tags: [.economy, .betControl], triggerWindow: .beforeBet, effects: [.grantBankrollFromAnte(percent: 200)], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.false-shuffle", name: "False Shuffle", summary: "Shuffle a small segment of future shoe order.", tags: [.shoeControl], triggerWindow: .beforeDeal, effects: [.custom(id: "false-shuffle", description: "Reroll a small upcoming shoe segment.")], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.shop-coupon", name: "Shop Coupon", summary: "Next shop item costs 1 less.", tags: [.economy], triggerWindow: .shopEntered, effects: [.addShopDiscount(percent: 10)], priceChips: 2),
            Consumable(id: "consumable.freeze-token", name: "Freeze Token", summary: "Freeze one extra shop item for free.", tags: [.economy], triggerWindow: .shopEntered, effects: [.custom(id: "freeze-token", description: "Extra freeze allowance this shop.")], priceChips: 2),
            Consumable(id: "consumable.blackout-camera", name: "Blackout Camera", summary: "Next cheating action adds no Heat.", tags: [.heat, .shoeControl], triggerWindow: .heatGained, effects: [.preventHeat(amount: nil)], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.pocket-nine", name: "Pocket Nine", summary: "Slip a 9 into the future shoe.", tags: [.cardSculpting], triggerWindow: .beforeDeal, effects: [.addCards(ranks: [.nine], count: 1)], priceChips: 3),
            Consumable(id: "consumable.pocket-blank", name: "Pocket Blank", summary: "Slip a zero-value card into the future shoe.", tags: [.cardSculpting], triggerWindow: .beforeDeal, effects: [.addCards(ranks: [.king], count: 1)], priceChips: 2),
            Consumable(id: "consumable.pit-boss-bribe", name: "Pit Boss Bribe", summary: "Disable one boss penalty for one hand.", tags: [.boss, .opponentSabotage], triggerWindow: .bossStarted, effects: [.suppressOpponentTags([.boss])], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.emergency-exit", name: "Emergency Exit", summary: "End a stage early if ahead.", tags: [.betControl], triggerWindow: .finalHand, effects: [.custom(id: "emergency-exit", description: "Cash out early if the stage is ahead.")], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.double-voucher", name: "Double Voucher", summary: "Next winning payout is boosted.", tags: [.betControl], triggerWindow: .wagerWon, effects: [.payoutMultiplier(betType: nil, percent: 50)], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.insurance-slip", name: "Insurance Slip", summary: "Next losing bet is partially refunded.", tags: [.comeback], triggerWindow: .wagerLost, effects: [.lossRefund(percent: 50, maxCents: nil)], priceChips: 3),
            Consumable(id: "consumable.side-switch", name: "Side Switch", summary: "Change side after a small reveal.", tags: [.betControl, .shoeVision], triggerWindow: .beforeBet, effects: [.revealUpcomingCards(count: 1)], priceChips: 4, minShopTier: 2),
            Consumable(id: "consumable.deep-peek", name: "Deep Peek", summary: "Reveal 5 cards and add Heat.", tags: [.shoeVision, .heat], triggerWindow: .beforeDeal, effects: [.revealUpcomingCards(count: 5), .gainHeat(amount: 1)], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.loaded-cut", name: "Loaded Cut", summary: "Choose between two short shoe sequences.", tags: [.shoeControl, .cardSculpting], triggerWindow: .beforeDeal, effects: [.custom(id: "loaded-cut", description: "Choose between two upcoming shoe cuts.")], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.natural-marker", name: "Natural Marker", summary: "Prime the next natural payout line.", tags: [.natural, .shoeVision], triggerWindow: .naturalOccurred, effects: [.grantBankrollFromAnte(percent: 75), .revealUpcomingCards(count: 1)], priceChips: 3, minShopTier: 2),
            Consumable(id: "consumable.pair-ticket", name: "Pair Ticket", summary: "Cash a small bonus when a pair appears.", tags: [.pair, .economy], triggerWindow: .pairOccurred, effects: [.grantChips(amount: 1), .grantBankrollFromAnte(percent: 50)], priceChips: 3, minShopTier: 2),
            Consumable(id: "consumable.nine-slip", name: "Nine Slip", summary: "Slip two 9s into the future shoe.", tags: [.cardSculpting], triggerWindow: .beforeDeal, effects: [.addCards(ranks: [.nine], count: 2)], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.eight-slip", name: "Eight Slip", summary: "Slip two 8s into the future shoe.", tags: [.cardSculpting], triggerWindow: .beforeDeal, effects: [.addCards(ranks: [.eight], count: 2)], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.audit-pass", name: "Audit Pass", summary: "Prevent one boss or surveillance Heat gain.", tags: [.heat, .boss], triggerWindow: .heatGained, effects: [.preventHeat(amount: 1)], priceChips: 4, minShopTier: 3),
            Consumable(id: "consumable.final-chip", name: "Final Chip", summary: "Final hand win grants extra Chips.", tags: [.streak, .economy], triggerWindow: .finalHand, effects: [.grantChips(amount: 2)], priceChips: 3, minShopTier: 2),
            Consumable(id: "consumable.marker-loan", name: "Marker Loan", summary: "Borrow 2x ante and add 1 Heat.", tags: [.economy, .heat], triggerWindow: .beforeBet, effects: [.grantBankrollFromAnte(percent: 200), .gainHeat(amount: 1)], priceChips: 1, minShopTier: 1),
            Consumable(id: "consumable.fake-tell", name: "Fake Tell", summary: "Distract the opponent for one battle beat.", tags: [.opponentSabotage], triggerWindow: .handStarted, effects: [.custom(id: "fake-tell", description: "Opponent pressure softened for this hand.")], priceChips: 2, minShopTier: 1),
            Consumable(id: "consumable.clean-cut", name: "Clean Cut", summary: "Move the top card without adding Heat.", tags: [.shoeControl], triggerWindow: .beforeDeal, effects: [.moveTopCardToBottom], priceChips: 3, minShopTier: 2),
            Consumable(id: "consumable.whale-marker", name: "Whale Marker", summary: "Next winning bet pays more but looks suspicious.", tags: [.betControl, .heat], triggerWindow: .wagerWon, effects: [.payoutMultiplier(betType: nil, percent: 35), .gainHeat(amount: 1)], priceChips: 4, minShopTier: 3)
        ]
    }

    static func definition(id: String) -> Consumable? {
        allContent.first { $0.id == id }
    }

    static var sampleLuckyCut: Consumable {
        Consumable.definition(id: "consumable.burn-slip") ?? allContent[0]
    }
}

extension Attachment {
    static var allContent: [Attachment] {
        [
            Attachment(id: "attachment.red-ink", name: "Red Ink", summary: "Attached modifier grants 25% ante when it triggers.", compatibleTags: Set(ModifierTag.allCases), effects: [.grantBankrollFromAnte(percent: 25)], priceChips: 3),
            Attachment(id: "attachment.blue-ink", name: "Blue Ink", summary: "Attached modifier is stronger during boss fights.", compatibleTags: [.boss, .shoeVision, .heat], effects: [.custom(id: "blue-ink", description: "Boss trigger strengthened.")], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.gold-foil", name: "Gold Foil", summary: "Attached modifier grants +1 Chip when it triggers.", compatibleTags: Set(ModifierTag.allCases), effects: [.grantChips(amount: 1)], priceChips: 4),
            Attachment(id: "attachment.black-seal", name: "Black Seal", summary: "Attached Heat modifier prevents extra Heat.", compatibleTags: [.heat, .shoeControl], effects: [.preventHeat(amount: 1)], priceChips: 4, minShopTier: 2),
            Attachment(id: "attachment.loaded-spring", name: "Loaded Spring", summary: "Attached modifier adds a consumable charge.", compatibleTags: [.consumable, .shoeControl], effects: [.addConsumableCharge(count: 1)], priceChips: 3),
            Attachment(id: "attachment.quiet-clip", name: "Quiet Clip", summary: "Attached modifier avoids opponent counters.", compatibleTags: [.heat, .opponentSabotage], effects: [.custom(id: "quiet-clip", description: "Opponent counter suppressed.")], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.double-stamp", name: "Double Stamp", summary: "Attached modifier may trigger twice once per stage.", compatibleTags: Set(ModifierTag.allCases), effects: [.custom(id: "double-stamp", description: "Can echo once per stage.")], priceChips: 5, minShopTier: 3),
            Attachment(id: "attachment.boss-stamp", name: "Boss Stamp", summary: "Attached modifier pays 50% ante during bosses.", compatibleTags: [.boss, .banker, .player, .tie], effects: [.grantBankrollFromAnte(percent: 50)], priceChips: 4, minShopTier: 3),
            Attachment(id: "attachment.opening-stamp", name: "Opening Stamp", summary: "Attached modifier supports first-hand plans.", compatibleTags: [.shoeVision, .economy], effects: [.revealUpcomingCards(count: 1)], priceChips: 3),
            Attachment(id: "attachment.closing-stamp", name: "Closing Stamp", summary: "Attached modifier improves on final hands.", compatibleTags: [.tie, .boss, .comeback], effects: [.custom(id: "closing-stamp", description: "Final hand strength increased.")], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.insurance-stamp", name: "Insurance Stamp", summary: "Attached modifier refunds 20% when its side fails.", compatibleTags: [.betControl, .comeback, .tie], effects: [.lossRefund(percent: 20, maxCents: nil)], priceChips: 4),
            Attachment(id: "attachment.greed-stamp", name: "Greed Stamp", summary: "Attached modifier pays 75% ante but adds Heat.", compatibleTags: Set(ModifierTag.allCases), effects: [.grantBankrollFromAnte(percent: 75), .gainHeat(amount: 1)], priceChips: 5, minShopTier: 2),
            Attachment(id: "attachment.shop-stamp", name: "Shop Stamp", summary: "Attached modifier improves shop discounts.", compatibleTags: [.economy], effects: [.addShopDiscount(percent: 10)], priceChips: 3),
            Attachment(id: "attachment.duplicate-stamp", name: "Duplicate Stamp", summary: "Copies of the attached modifier appear more often.", compatibleTags: Set(ModifierTag.allCases), effects: [.custom(id: "duplicate-stamp", description: "Shop duplicate bias improved.")], priceChips: 3),
            Attachment(id: "attachment.clean-stamp", name: "Clean Stamp", summary: "First Heat from this modifier is ignored.", compatibleTags: [.heat, .shoeControl], effects: [.preventHeat(amount: nil)], priceChips: 4),
            Attachment(id: "attachment.debt-stamp", name: "Debt Stamp", summary: "Attached modifier can be bought on credit later.", compatibleTags: [.economy], effects: [.custom(id: "debt-stamp", description: "Credit purchase hook enabled.")], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.lucky-stamp", name: "Lucky Stamp", summary: "Attached modifier has a chance to upgrade itself.", compatibleTags: Set(ModifierTag.allCases), effects: [.custom(id: "lucky-stamp", description: "Upgrade chance added.")], priceChips: 5, minShopTier: 3),
            Attachment(id: "attachment.counter-stamp", name: "Counter Stamp", summary: "Attached modifier improves after losses.", compatibleTags: [.comeback, .player, .tie], effects: [.lossRefund(percent: 15, maxCents: nil)], priceChips: 3),
            Attachment(id: "attachment.streak-stamp", name: "Streak Stamp", summary: "Attached modifier pays 30% ante after wins.", compatibleTags: [.streak, .banker, .player], effects: [.grantBankrollFromAnte(percent: 30)], priceChips: 3),
            Attachment(id: "attachment.legend-stamp", name: "Legend Stamp", summary: "Attached Level 3 modifier gains a unique bonus.", compatibleTags: Set(ModifierTag.allCases), effects: [.grantChips(amount: 2)], priceChips: 5, minShopTier: 4),
            Attachment(id: "attachment.natural-seal", name: "Natural Seal", summary: "Natural modifiers reveal one extra card.", compatibleTags: [.natural, .shoeVision], effects: [.revealUpcomingCards(count: 1)], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.pair-seal", name: "Pair Seal", summary: "Pair modifiers gain a small Chip upside.", compatibleTags: [.pair, .economy], effects: [.grantChips(amount: 1)], priceChips: 4, minShopTier: 2),
            Attachment(id: "attachment.nine-seal", name: "Nine Seal", summary: "Loaded-shoe modifiers add another 9.", compatibleTags: [.cardSculpting, .natural], effects: [.addCards(ranks: [.nine], count: 1)], priceChips: 4, minShopTier: 3),
            Attachment(id: "attachment.sabotage-seal", name: "Sabotage Seal", summary: "Opponent sabotage also prevents 1 Heat.", compatibleTags: [.opponentSabotage, .heat], effects: [.preventHeat(amount: 1)], priceChips: 4, minShopTier: 3),
            Attachment(id: "attachment.final-seal", name: "Final Seal", summary: "Final-hand modifiers gain +1 Chip.", compatibleTags: [.boss, .streak, .comeback], effects: [.grantChips(amount: 1)], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.loan-seal", name: "Loan Seal", summary: "Economy modifiers can borrow bankroll with Heat pressure.", compatibleTags: [.economy], effects: [.grantBankrollFromAnte(percent: 50), .gainHeat(amount: 1)], priceChips: 3, minShopTier: 2),
            Attachment(id: "attachment.counter-seal", name: "Counter Seal", summary: "Comeback modifiers reveal one card.", compatibleTags: [.comeback, .shoeVision], effects: [.revealUpcomingCards(count: 1)], priceChips: 3),
            Attachment(id: "attachment.banker-seal", name: "Banker Seal", summary: "Banker modifiers gain a small payout boost.", compatibleTags: [.banker], effects: [.payoutMultiplier(betType: .banker, percent: 8)], priceChips: 3),
            Attachment(id: "attachment.player-seal", name: "Player Seal", summary: "Player modifiers gain a small payout boost.", compatibleTags: [.player], effects: [.payoutMultiplier(betType: .player, percent: 10)], priceChips: 3),
            Attachment(id: "attachment.tie-seal", name: "Tie Seal", summary: "Tie modifiers gain one Tie charge.", compatibleTags: [.tie], effects: [.gainTieCharges(count: 1)], priceChips: 4, minShopTier: 2)
        ]
    }

    static func definition(id: String) -> Attachment? {
        allContent.first { $0.id == id }
    }

    static var sampleGoldClip: Attachment {
        Attachment.definition(id: "attachment.gold-foil") ?? allContent[0]
    }
}

extension BossRelic {
    static let sampleEyeInTheSky = BossRelic(
        id: "sample.eye-in-the-sky",
        name: "Eye in the Sky",
        summary: "Boss reward: first reveal each stage costs no Heat.",
        sourceBossID: "surveillance",
        effects: [.custom(id: "free-first-reveal", description: "First reveal each stage ignores Heat gain.")]
    )

    static var allRelics: [BossRelic] {
        [
            BossRelic(id: "relic.pit-boss-nod", name: "Pit Boss Nod", summary: "Once per stage, ignore a repeated-side Heat penalty.", sourceBossID: "pit-boss", effects: [.preventHeat(amount: 1)]),
            BossRelic(id: "relic.vault-key", name: "Vault Key", summary: "Boss clears grant +2 extra Chips.", sourceBossID: "vault", effects: [.grantChips(amount: 2)]),
            BossRelic(id: "relic.private-room", name: "Private Room", summary: "Private table rewards gain +1 Chip.", sourceBossID: "pit-boss", effects: [.custom(id: "private-room", description: "Private table bonus improved.")]),
            BossRelic(id: "relic.house-ledger", name: "House Ledger", summary: "First winning bet each boss stage grants 1x ante.", sourceBossID: "house", effects: [.grantBankrollFromAnte(percent: 100)]),
            BossRelic(id: "relic.loaded-sleeve", name: "Loaded Sleeve", summary: "Start boss stages with one extra shoe-control charge.", sourceBossID: "inspector", effects: [.custom(id: "loaded-sleeve", description: "Shoe-control charge added on boss stages.")]),
            BossRelic(id: "relic.red-phone", name: "Red Phone", summary: "Start each boss stage with -1 Heat.", sourceBossID: "pit-boss", effects: [.reduceHeat(amount: 1)]),
            BossRelic(id: "relic.backroom-dealer", name: "Backroom Dealer", summary: "First boss-stage Banker win grants +1 Chip.", sourceBossID: "pit-boss", effects: [.grantChips(amount: 1)]),
            BossRelic(id: "relic.whale-credit", name: "Whale Credit", summary: "Boss reward cash is allowed to reach the full 5x ante cap.", sourceBossID: "house", effects: [.custom(id: "whale-credit", description: "Boss cash cap softened.")]),
            BossRelic(id: "relic.fake-shuffle-machine", name: "Fake Shuffle Machine", summary: "Forced shuffle effects are logged and softened.", sourceBossID: "inspector", effects: [.custom(id: "fake-shuffle-machine", description: "Forced shuffle pressure softened.")]),
            BossRelic(id: "relic.surveillance-loop", name: "Surveillance Loop", summary: "The first reveal suppression each stage is reduced.", sourceBossID: "surveillance", effects: [.custom(id: "surveillance-loop", description: "Reveal suppression reduced once per stage.")]),
            BossRelic(id: "relic.casino-host", name: "Casino Host", summary: "Stage previews show clearer opponent weakness text.", sourceBossID: "host", effects: [.custom(id: "casino-host", description: "Opponent hints improved.")]),
            BossRelic(id: "relic.house-blueprint", name: "House Blueprint", summary: "Final boss preview reveals the adaptive counter tag.", sourceBossID: "house", effects: [.custom(id: "house-blueprint", description: "Final boss counter preview improved.")]),
            BossRelic(id: "relic.whale-marker", name: "Whale Marker", summary: "First high-limit boss win grants 2 Chips.", sourceBossID: "whale", effects: [.grantChips(amount: 2)]),
            BossRelic(id: "relic.cooler-token", name: "Cooler Token", summary: "First comeback trigger each boss stage refunds 50% ante.", sourceBossID: "cooler", effects: [.grantBankrollFromAnte(percent: 50)]),
            BossRelic(id: "relic.insider-note", name: "Insider Note", summary: "Boss stages begin with a 3-card read.", sourceBossID: "insider", effects: [.revealUpcomingCards(count: 3)]),
            BossRelic(id: "relic.audit-shield", name: "Audit Shield", summary: "Prevent the first Heat gained from table events each stage.", sourceBossID: "auditor", effects: [.preventHeat(amount: 1)]),
            BossRelic(id: "relic.collector-waiver", name: "Collector Waiver", summary: "Shop entry after bosses discounts one offer.", sourceBossID: "collector", effects: [.addShopDiscount(percent: 15)]),
            BossRelic(id: "relic.cooler-deck", name: "Cooler Deck", summary: "Forced shuffles reveal one replacement card.", sourceBossID: "cooler", effects: [.revealUpcomingCards(count: 1)]),
            BossRelic(id: "relic.final-pass", name: "Final Pass", summary: "The final hand of each boss grants +1 Chip if won.", sourceBossID: "house", effects: [.grantChips(amount: 1)]),
            BossRelic(id: "relic.back-wall-phone", name: "Back Wall Phone", summary: "Once per stage, boss pressure can be softened.", sourceBossID: "insider", effects: [.suppressOpponentTags([.boss])])
        ]
    }

    static func definition(id: String) -> BossRelic? {
        allRelics.first { $0.id == id }
    }
}

extension StartingContact {
    static var allContacts: [StartingContact] {
        [
            StartingContact(id: "contact.banker-bias", name: "Banker Bias", flavor: "A quiet nod from the boxman.", summary: "Starts with Banker Bias. Banker wins can recover standard commission.", startingModifiers: ["core.banker-bias"], shopBiasTags: [.banker, .shoeVision, .economy], difficultyRating: "Medium", recommendedArchetype: "Banker"),
            StartingContact(id: "contact.player-surge", name: "Player Surge", flavor: "A quick pivot before the table notices.", summary: "Starts with Player Surge. Player wins gain profit and a first-stage Chip.", startingModifiers: ["core.player-surge"], shopBiasTags: [.player, .shoeVision, .comeback], difficultyRating: "Medium", recommendedArchetype: "Player"),
            StartingContact(id: "contact.opening-tell", name: "Opening Tell", flavor: "The first cards are never as quiet as they look.", summary: "Starts with Opening Tell. Stage starts reveal exact opening cards.", startingModifiers: ["core.opening-tell"], bankrollAdjustmentCents: -1_000, shopBiasTags: [.shoeVision, .shoeControl, .tie], difficultyRating: "Medium", recommendedArchetype: "Vision"),
            StartingContact(id: "contact.tie-insurance", name: "Tie Insurance", flavor: "Bad odds, better brakes.", summary: "Starts with Tie Insurance. The first failed Tie wager each stage refunds part of the loss.", startingModifiers: ["core.tie-insurance"], bankrollAdjustmentCents: -1_000, shopBiasTags: [.tie, .comeback, .shoeVision], difficultyRating: "Hard", recommendedArchetype: "Tie"),
            StartingContact(id: "contact.lucky-chip", name: "Lucky Chip", flavor: "Nobody suspects the one counting comps.", summary: "Starts with Lucky Chip. Winning wagers generate capped Chips.", startingModifiers: ["core.lucky-chip"], chipsAdjustment: 1, shopBiasTags: [.economy, .banker, .player], difficultyRating: "Easy", recommendedArchetype: "Economy / Comeback"),
            StartingContact(id: "contact.clean-hands", name: "Clean Hands", flavor: "The cameras remember you a second too late.", summary: "Starts with Clean Hands. Real Heat gains create capped Chips without preventing Heat.", startingModifiers: ["core.clean-hands"], shopBiasTags: [.heat, .betControl, .economy], difficultyRating: "Medium", recommendedArchetype: "Heat / High Risk", cashRewardMultiplierPercent: 90)
        ]
    }

    static var defaultFloorHost: StartingContact {
        tourist
    }

    static var sampleInsideDealer: StartingContact {
        openingTell
    }

    static var bankerBias: StartingContact { allContacts[0] }
    static var playerSurge: StartingContact { allContacts[1] }
    static var openingTell: StartingContact { allContacts[2] }
    static var tieInsurance: StartingContact { allContacts[3] }
    static var tourist: StartingContact { allContacts[4] }
    static var cleanHands: StartingContact { allContacts[5] }
    static var dealer: StartingContact { openingTell }
    static var accountant: StartingContact { tourist }
    static var whale: StartingContact { playerSurge }
    static var mechanic: StartingContact { openingTell }
    static var grifter: StartingContact { playerSurge }
    static var tieChaser: StartingContact { tieInsurance }
    static var ghost: StartingContact { cleanHands }

    static func definition(id: String) -> StartingContact? {
        allContacts.first { $0.id == id }
    }
}
