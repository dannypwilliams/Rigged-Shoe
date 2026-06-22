import Foundation

/// Type of item shown in the rebuilt shop.
enum ShopOfferKind: String, Codable, Equatable {
    case modifier
    case consumable
    case attachment
    case bossRelic
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

    init(
        id: String,
        name: String,
        summary: String,
        tags: Set<ModifierTag>,
        triggerWindow: ModifierTrigger,
        effects: [ModifierEffect],
        charges: Int = 1,
        priceChips: Int
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.tags = tags.union([.consumable])
        self.triggerWindow = triggerWindow
        self.effects = effects
        self.charges = max(1, charges)
        self.priceChips = max(0, priceChips)
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

    init(
        id: String,
        name: String,
        summary: String,
        compatibleTags: Set<ModifierTag>,
        effects: [ModifierEffect],
        priceChips: Int
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.compatibleTags = compatibleTags
        self.effects = effects
        self.priceChips = max(0, priceChips)
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
    var summary: String
    var startingModifiers: [String]
    var startingConsumables: [String]
    var currencyAdjustments: RunCurrencyState?

    init(
        id: String,
        name: String,
        summary: String,
        startingModifiers: [String] = [],
        startingConsumables: [String] = [],
        currencyAdjustments: RunCurrencyState? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.startingModifiers = startingModifiers
        self.startingConsumables = startingConsumables
        self.currencyAdjustments = currencyAdjustments
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
    static let sampleLuckyCut = Consumable(
        id: "sample.lucky-cut",
        name: "Lucky Cut",
        summary: "Move the top card to the bottom before the deal.",
        tags: [.shoeControl],
        triggerWindow: .beforeDeal,
        effects: [.moveTopCardToBottom],
        priceChips: 2
    )
}

extension Attachment {
    static let sampleGoldClip = Attachment(
        id: "sample.gold-clip",
        name: "Gold Clip",
        summary: "Attached economy modifiers pay +$5 more.",
        compatibleTags: [.economy],
        effects: [.flatPayoutBonus(betType: nil, cents: 500)],
        priceChips: 2
    )
}

extension BossRelic {
    static let sampleEyeInTheSky = BossRelic(
        id: "sample.eye-in-the-sky",
        name: "Eye in the Sky",
        summary: "Boss reward: first reveal each stage costs no Heat.",
        sourceBossID: "surveillance",
        effects: [.custom(id: "free-first-reveal", description: "First reveal each stage ignores Heat gain.")]
    )
}

extension StartingContact {
    static let defaultFloorHost = StartingContact(
        id: "default.floor-host",
        name: "Floor Host",
        summary: "A neutral casino contact. No hidden bonuses yet; just a clean start at the first table."
    )

    static let sampleInsideDealer = StartingContact(
        id: "sample.inside-dealer",
        name: "Inside Dealer",
        summary: "Start with X-Ray Shoe and one Lucky Cut.",
        startingModifiers: ["sample.xray-shoe"],
        startingConsumables: ["sample.lucky-cut"]
    )
}
