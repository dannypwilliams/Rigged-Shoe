import Foundation

/// Rarity tier for rebuilt modifiers.
///
/// This intentionally mirrors the current upgrade rarity scale while separating
/// the future shop engine from the legacy `UpgradeCard` pool.
enum ModifierRarity: String, CaseIterable, Codable, Equatable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    case boss

    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .uncommon:
            return "Uncommon"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        case .boss:
            return "Boss"
        }
    }

    var defaultShopCost: Int {
        switch self {
        case .common:
            return 3
        case .uncommon:
            return 4
        case .rare:
            return 5
        case .epic:
            return 6
        case .legendary:
            return 8
        case .boss:
            return 0
        }
    }
}

/// Strategy and counterplay tags for modifiers.
///
/// Tags are the backbone of synergy, shop filtering, boss suppression, and UI
/// grouping. Keep new content tagged here instead of adding view-specific
/// booleans later.
enum ModifierTag: String, CaseIterable, Codable, Hashable {
    case banker
    case player
    case tie
    case tempo
    case natural
    case pair
    case shoeVision
    case shoeControl
    case cardSculpting
    case betControl
    case streak
    case heat
    case economy
    case comeback
    case opponentSabotage
    case boss
    case consumable
    case attachment

    var displayName: String {
        switch self {
        case .tempo:
            return "Tempo"
        case .shoeVision:
            return "Shoe Vision"
        case .shoeControl:
            return "Shoe Control"
        case .cardSculpting:
            return "Card Sculpting"
        case .betControl:
            return "Bet Control"
        case .opponentSabotage:
            return "Opponent Sabotage"
        default:
            return rawValue.capitalized
        }
    }
}

/// Event hooks that the future modifier engine can listen to.
///
/// The hand resolver should emit these events; the modifier engine can then
/// evaluate instances in order and produce payout/shoe/Heat deltas.
enum ModifierTrigger: String, CaseIterable, Codable, Hashable {
    case runStarted
    case stageStarted
    case handStarted
    case beforeBet
    case betPlaced
    case beforeDeal
    case cardRevealed
    case cardDrawn
    case handResolved
    case wagerWon
    case wagerLost
    case tieOccurred
    case naturalOccurred
    case pairOccurred
    case heatGained
    case shopEntered
    case shopRerolled
    case modifierBought
    case modifierSold
    case modifierLeveled
    case bossStarted
    case bossDefeated
    case finalHand
    case runEnded
}

extension ModifierTrigger {
    var shopLabel: String {
        switch self {
        case .runStarted:
            return "Run start"
        case .stageStarted:
            return "Stage start"
        case .handStarted:
            return "Hand start"
        case .beforeBet:
            return "Before betting"
        case .betPlaced:
            return "Bet placed"
        case .beforeDeal:
            return "Before deal"
        case .cardRevealed:
            return "Card revealed"
        case .cardDrawn:
            return "Card drawn"
        case .handResolved:
            return "Hand resolved"
        case .wagerWon:
            return "Winning wager"
        case .wagerLost:
            return "Losing wager"
        case .tieOccurred:
            return "Tie result"
        case .naturalOccurred:
            return "Natural result"
        case .pairOccurred:
            return "Pair result"
        case .heatGained:
            return "Heat gained"
        case .shopEntered:
            return "Shop entry"
        case .shopRerolled:
            return "Shop reroll"
        case .modifierBought:
            return "Modifier bought"
        case .modifierSold:
            return "Modifier sold"
        case .modifierLeveled:
            return "Modifier leveled"
        case .bossStarted:
            return "Boss start"
        case .bossDefeated:
            return "Boss defeated"
        case .finalHand:
            return "Final hand"
        case .runEnded:
            return "Run end"
        }
    }
}

/// Runtime events emitted by battles, shops, bosses, and run flow.
///
/// `ModifierTrigger` is the stable content hook stored on a modifier. `GameEvent`
/// is the richer runtime payload that lets the engine evaluate conditions and
/// calculate transparent ledger changes.
enum GameEvent: Equatable {
    case runStarted
    case stageStarted(stageNumber: Int)
    case handStarted(handIndex: Int)
    case beforeBet
    case betPlaced(betType: BetType, amountCents: Int)
    case beforeDeal
    case cardRevealed(card: Card, order: Int)
    case cardDrawn(card: Card, order: Int)
    case handResolved(result: RoundResult)
    case wagerWon(betType: BetType, winningSide: BetType, amountCents: Int, basePayoutCents: Int)
    case wagerLost(betType: BetType, winningSide: BetType, amountCents: Int)
    case tieOccurred
    case naturalOccurred
    case pairOccurred
    case heatGained(amount: Int)
    case shopEntered
    case shopRerolled
    case modifierBought(modifierID: String)
    case modifierSold(modifierID: String)
    case modifierLeveled(modifierID: String, newLevel: Int)
    case bossStarted(bossID: String)
    case bossDefeated(bossID: String)
    case finalHand
    case runEnded

    var trigger: ModifierTrigger {
        switch self {
        case .runStarted:
            return .runStarted
        case .stageStarted:
            return .stageStarted
        case .handStarted:
            return .handStarted
        case .beforeBet:
            return .beforeBet
        case .betPlaced:
            return .betPlaced
        case .beforeDeal:
            return .beforeDeal
        case .cardRevealed:
            return .cardRevealed
        case .cardDrawn:
            return .cardDrawn
        case .handResolved:
            return .handResolved
        case .wagerWon:
            return .wagerWon
        case .wagerLost:
            return .wagerLost
        case .tieOccurred:
            return .tieOccurred
        case .naturalOccurred:
            return .naturalOccurred
        case .pairOccurred:
            return .pairOccurred
        case .heatGained:
            return .heatGained
        case .shopEntered:
            return .shopEntered
        case .shopRerolled:
            return .shopRerolled
        case .modifierBought:
            return .modifierBought
        case .modifierSold:
            return .modifierSold
        case .modifierLeveled:
            return .modifierLeveled
        case .bossStarted:
            return .bossStarted
        case .bossDefeated:
            return .bossDefeated
        case .finalHand:
            return .finalHand
        case .runEnded:
            return .runEnded
        }
    }
}

/// Reusable conditions that keep modifier rules out of SwiftUI and payout code.
indirect enum ModifierCondition: Codable, Equatable {
    case always
    case betType(BetType)
    case winningSide(BetType)
    case firstPlayerSideWinThisStage
    case firstBankerSideWinThisStage
    case firstTieLossThisStage
    case firstWinningBetThisStage
    case maxLegalBet
    case bossStage
    case hasTag(ModifierTag)
    case all([ModifierCondition])
    case any([ModifierCondition])
}

extension ModifierCondition {
    var shopLabel: String? {
        switch self {
        case .always:
            return nil
        case .betType(let betType):
            return "\(betType.displayName) bet"
        case .winningSide(let betType):
            return "\(betType.displayName) result"
        case .firstPlayerSideWinThisStage:
            return "First Player win each stage"
        case .firstBankerSideWinThisStage:
            return "First Banker win each stage"
        case .firstTieLossThisStage:
            return "First losing Tie bet each stage"
        case .firstWinningBetThisStage:
            return "First winning bet each stage"
        case .maxLegalBet:
            return "Maximum legal wager"
        case .bossStage:
            return "Boss stage"
        case .hasTag(let tag):
            return "Requires \(tag.displayName)"
        case .all(let conditions):
            if conditions.contains(.firstPlayerSideWinThisStage) {
                return "First Player win each stage"
            }

            if conditions.contains(.firstBankerSideWinThisStage) {
                return "First Banker win each stage"
            }

            if conditions.contains(.firstTieLossThisStage) {
                return "First losing Tie bet each stage"
            }

            if conditions.contains(.firstWinningBetThisStage) {
                return "First winning bet each stage"
            }

            let labels = conditions.compactMap(\.shopLabel)
            return labels.isEmpty ? nil : labels.joined(separator: ", ")
        case .any(let conditions):
            let labels = conditions.compactMap(\.shopLabel)
            return labels.isEmpty ? nil : labels.joined(separator: " or ")
        }
    }
}

/// Optional fire limits for modifier instances.
///
/// The engine tracks these per instance so duplicates and leveled copies can
/// behave independently. Stage and hand counters reset through the explicit
/// `ModifierEngine` reset methods.
enum ModifierUseLimit: Codable, Equatable {
    case perHand(Int)
    case perStage(Int)
    case perRun(Int)
    case perStageByLevel(level1: Int, level2: Int, level3: Int)

    func allowedUses(for level: Int) -> Int {
        switch self {
        case .perHand(let count), .perStage(let count), .perRun(let count):
            return max(0, count)
        case .perStageByLevel(let level1, let level2, let level3):
            if level >= 3 {
                return max(0, level3)
            }

            if level == 2 {
                return max(0, level2)
            }

            return max(0, level1)
        }
    }
}

/// Data-driven effect descriptions for rebuilt modifiers.
///
/// These are declarations, not execution code. A future `ModifierEngine` should
/// interpret them and return a transparent ledger of what changed.
indirect enum ModifierEffect: Codable, Equatable {
    case grantBankroll(cents: Int)
    case grantBankrollFromAnte(percent: Int)
    case grantChips(amount: Int)
    case grantChipsOnFirstStageTrigger(amount: Int)
    case gainHeat(amount: Int)
    case reduceHeat(amount: Int)
    case preventHeat(amount: Int?)
    case revealUpcomingCards(count: Int)
    case revealUpcomingCardsWithForecast(count: Int)
    case burnCards(count: Int)
    case moveTopCardToBottom
    case moveTopCardDeeper(positions: Int)
    case addCards(ranks: [Rank], count: Int)
    case removeCards(ranks: [Rank], count: Int)
    case payoutMultiplier(betType: BetType?, percent: Int)
    case flatPayoutBonus(betType: BetType?, cents: Int)
    case lossRefund(percent: Int, maxCents: Int?)
    case gainTieCharges(count: Int)
    case adjustBetLimit(minCents: Int?, maxCents: Int?)
    case addTableRule(TableRule)
    case suppressOpponentTags(Set<ModifierTag>)
    case addShopDiscount(percent: Int)
    case addRerollDiscount(chips: Int)
    case addModifierSlot(count: Int)
    case addConsumableCharge(count: Int)
    case levelScaled(level1: [ModifierEffect], level2: [ModifierEffect], level3: [ModifierEffect])
    case composite([ModifierEffect])
    case custom(id: String, description: String)

    var shortDescription: String {
        switch self {
        case .grantBankroll(let cents):
            return "Gain \(MoneyFormatter.format(cents))"
        case .grantBankrollFromAnte(let percent):
            return "Gain \(percent)% of ante"
        case .grantChips(let amount):
            return "Gain \(amount) Chips"
        case .grantChipsOnFirstStageTrigger(let amount):
            return "First trigger each stage: +\(amount) Chips"
        case .gainHeat(let amount):
            return "Gain \(amount) Heat"
        case .reduceHeat(let amount):
            return "Lose \(amount) Heat"
        case .preventHeat(let amount):
            if let amount {
                return "Prevent \(amount) Heat"
            }
            return "Prevent Heat"
        case .revealUpcomingCards(let count):
            return "Reveal next \(count)"
        case .revealUpcomingCardsWithForecast(let count):
            return "Reveal next \(count) with forecast"
        case .burnCards(let count):
            return "Burn \(count) card\(count == 1 ? "" : "s")"
        case .moveTopCardToBottom:
            return "Move top card to bottom"
        case .moveTopCardDeeper(let positions):
            return "Move top card \(positions) deeper"
        case .addCards(let ranks, let count):
            return "Add \(count) \(ranks.map(\.shortName).joined(separator: "/")) cards"
        case .removeCards(let ranks, let count):
            return "Remove \(count) \(ranks.map(\.shortName).joined(separator: "/")) cards"
        case .payoutMultiplier(let betType, let percent):
            return "\(betType?.displayName ?? "Any") win pays +\(percent)%"
        case .flatPayoutBonus(let betType, let cents):
            return "\(betType?.displayName ?? "Any") win +\(MoneyFormatter.format(cents))"
        case .lossRefund(let percent, let maxCents):
            if let maxCents {
                return "Refund \(percent)% up to \(MoneyFormatter.format(maxCents))"
            }
            return "Refund \(percent)%"
        case .gainTieCharges(let count):
            return "+\(count) Tie charge\(count == 1 ? "" : "s")"
        case .adjustBetLimit(let minCents, let maxCents):
            let minText = minCents.map { "min \(MoneyFormatter.format($0))" }
            let maxText = maxCents.map { "max \(MoneyFormatter.format($0))" }
            return [minText, maxText].compactMap { $0 }.joined(separator: ", ")
        case .addTableRule(let rule):
            return rule.description
        case .suppressOpponentTags(let tags):
            return "Suppress \(tags.map(\.displayName).sorted().joined(separator: ", "))"
        case .addShopDiscount(let percent):
            return "Shop prices -\(percent)%"
        case .addRerollDiscount(let chips):
            return "Rerolls cost -\(chips) Chips"
        case .addModifierSlot(let count):
            return "+\(count) modifier slot"
        case .addConsumableCharge(let count):
            return "+\(count) consumable charge"
        case .levelScaled:
            return "Scales with modifier level"
        case .composite(let effects):
            return effects.map(\.shortDescription).joined(separator: "; ")
        case .custom(_, let description):
            return description
        }
    }

    var shopDescription: String {
        switch self {
        case .levelScaled(let level1, _, _):
            let baseText = level1.map(\.shopDescription).joined(separator: "; ")
            return baseText.isEmpty ? "Scales with modifier level" : "\(baseText) (levels improve)"
        case .composite(let effects):
            return effects.map(\.shopDescription).joined(separator: "; ")
        default:
            return shortDescription
        }
    }
}

/// Rebuilt shop/battle modifier definition.
///
/// Definitions are stable content records. Runtime changes such as level,
/// charges, cooldown, and boss suppression belong to `ModifierInstance`.
struct Modifier: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var summary: String
    var rulesText: String
    var rarity: ModifierRarity
    var tags: Set<ModifierTag>
    var triggers: Set<ModifierTrigger>
    var conditions: [ModifierCondition]
    var useLimits: [ModifierUseLimit]
    var heatCost: Int
    var effects: [ModifierEffect]
    var baseCostChips: Int
    var maxLevel: Int
    var sellValueChips: Int
    var minShopTier: Int
    var battleLogText: String

    init(
        id: String,
        name: String,
        summary: String,
        rulesText: String,
        rarity: ModifierRarity,
        tags: Set<ModifierTag>,
        triggers: Set<ModifierTrigger>,
        effects: [ModifierEffect],
        baseCostChips: Int,
        maxLevel: Int = 3,
        sellValueChips: Int? = nil,
        minShopTier: Int = 1,
        battleLogText: String? = nil,
        conditions: [ModifierCondition] = [.always],
        useLimits: [ModifierUseLimit] = [],
        heatCost: Int = 0
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.rulesText = rulesText
        self.rarity = rarity
        self.tags = tags
        self.triggers = triggers
        self.conditions = conditions
        self.useLimits = useLimits
        self.heatCost = max(0, heatCost)
        self.effects = effects
        self.baseCostChips = max(0, baseCostChips)
        self.maxLevel = max(1, maxLevel)
        self.sellValueChips = sellValueChips ?? max(1, baseCostChips / 2)
        self.minShopTier = min(max(1, minShopTier), 5)
        self.battleLogText = battleLogText ?? rulesText
    }
}

extension Modifier {
    var shopMechanicText: String {
        let conditionText = conditions.compactMap(\.shopLabel).joined(separator: ", ")
        let triggerText = triggers.map(\.shopLabel).sorted().joined(separator: ", ")
        let effectText = effects.map(\.shopDescription).joined(separator: "; ")
        let heatText = heatCost > 0 ? "Adds \(heatCost) Heat" : nil

        let prefix = conditionText.isEmpty ? triggerText : conditionText
        var detailParts = [effectText].filter { !$0.isEmpty }
        if let heatText {
            detailParts.append(heatText)
        }
        let details = detailParts.joined(separator: "; ")

        if prefix.isEmpty {
            return details.isEmpty ? summary : details
        }

        if details.isEmpty {
            return prefix
        }

        return "\(prefix): \(details)"
    }
}

/// Player-owned copy of a modifier.
///
/// Instances let duplicate modifiers level up, get temporarily disabled by a
/// boss, track charges, and attach enhancements without mutating the base
/// content definition.
struct ModifierInstance: Identifiable, Codable, Equatable {
    let id: UUID
    var modifierID: String
    var level: Int
    var chargesRemaining: Int?
    var cooldownHandsRemaining: Int
    var isDisabledByBoss: Bool
    var attachedIDs: [String]

    init(
        id: UUID = UUID(),
        modifierID: String,
        level: Int = 1,
        chargesRemaining: Int? = nil,
        cooldownHandsRemaining: Int = 0,
        isDisabledByBoss: Bool = false,
        attachedIDs: [String] = []
    ) {
        self.id = id
        self.modifierID = modifierID
        self.level = max(1, level)
        self.chargesRemaining = chargesRemaining
        self.cooldownHandsRemaining = max(0, cooldownHandsRemaining)
        self.isDisabledByBoss = isDisabledByBoss
        self.attachedIDs = attachedIDs
    }
}

extension Modifier {
    static let sampleDebugPool: [Modifier] = [
        Modifier(
            id: "core.banker-bias",
            name: "Banker Bias",
            summary: "Banker wins pay extra when you bet Banker.",
            rulesText: "When your Banker bet wins, gain a payout bonus. Level 3 also gives +1 Chip on the first Banker win each stage.",
            rarity: .common,
            tags: [.banker, .betControl],
            triggers: [.wagerWon],
            effects: [
                .levelScaled(
                    level1: [.payoutMultiplier(betType: .banker, percent: 10)],
                    level2: [.payoutMultiplier(betType: .banker, percent: 18)],
                    level3: [
                        .payoutMultiplier(betType: .banker, percent: 25),
                        .grantChipsOnFirstStageTrigger(amount: 1)
                    ]
                )
            ],
            baseCostChips: 3,
            conditions: [.all([.betType(.banker), .winningSide(.banker)])]
        ),
        Modifier(
            id: "core.player-surge",
            name: "Player Surge",
            summary: "First Player-side win each stage pays an ante bonus.",
            rulesText: "When you bet Player and Player wins for the first time this stage, gain bonus bankroll based on ante. Level 3 also gives +1 Chip.",
            rarity: .common,
            tags: [.player, .tempo],
            triggers: [.wagerWon],
            effects: [
                .levelScaled(
                    level1: [.grantBankrollFromAnte(percent: 100)],
                    level2: [.grantBankrollFromAnte(percent: 150)],
                    level3: [
                        .grantBankrollFromAnte(percent: 200),
                        .grantChips(amount: 1)
                    ]
                )
            ],
            baseCostChips: 3,
            conditions: [.all([.betType(.player), .winningSide(.player), .firstPlayerSideWinThisStage])],
            useLimits: [.perStage(1)]
        ),
        Modifier(
            id: "core.tie-insurance",
            name: "Tie Insurance",
            summary: "Your first missed Tie bet each stage refunds part of the loss.",
            rulesText: "When you lose a Tie bet for the first time this stage, refund part of the bet. Level 3 also gains one Tie charge.",
            rarity: .common,
            tags: [.tie, .comeback],
            triggers: [.wagerLost],
            effects: [
                .levelScaled(
                    level1: [.lossRefund(percent: 40, maxCents: nil)],
                    level2: [.lossRefund(percent: 55, maxCents: nil)],
                    level3: [
                        .lossRefund(percent: 70, maxCents: nil),
                        .gainTieCharges(count: 1)
                    ]
                )
            ],
            baseCostChips: 2,
            conditions: [.all([.betType(.tie), .firstTieLossThisStage])],
            useLimits: [.perStage(1)]
        ),
        Modifier(
            id: "core.opening-tell",
            name: "Opening Tell",
            summary: "Reveal real upcoming shoe cards at stage start.",
            rulesText: "At the start of each stage, reveal the next shoe cards. Level 3 reveals five and requests a simple side forecast.",
            rarity: .rare,
            tags: [.shoeVision],
            triggers: [.stageStarted],
            effects: [
                .levelScaled(
                    level1: [.revealUpcomingCards(count: 3)],
                    level2: [.revealUpcomingCards(count: 4)],
                    level3: [.revealUpcomingCardsWithForecast(count: 5)]
                )
            ],
            baseCostChips: 4,
            useLimits: [.perStage(1)]
        ),
        Modifier(
            id: "core.clean-hands",
            name: "Clean Hands",
            summary: "Prevent early Heat gains each stage.",
            rulesText: "When Heat would be gained, prevent the first Heat gains each stage. Level 3 also gives +1 Chip whenever Heat is prevented.",
            rarity: .common,
            tags: [.heat],
            triggers: [.heatGained],
            effects: [
                .levelScaled(
                    level1: [.preventHeat(amount: nil)],
                    level2: [.preventHeat(amount: nil)],
                    level3: [
                        .preventHeat(amount: nil),
                        .grantChips(amount: 1)
                    ]
                )
            ],
            baseCostChips: 3,
            useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]
        ),
        Modifier(
            id: "core.lucky-chip",
            name: "Lucky Chip",
            summary: "First winning bet each stage grants Chips.",
            rulesText: "The first time your bet wins each stage, gain Chips. Level 2 also grants bankroll equal to half the ante.",
            rarity: .common,
            tags: [.economy],
            triggers: [.wagerWon],
            effects: [
                .levelScaled(
                    level1: [.grantChips(amount: 1)],
                    level2: [
                        .grantChips(amount: 1),
                        .grantBankrollFromAnte(percent: 50)
                    ],
                    level3: [.grantChips(amount: 2)]
                )
            ],
            baseCostChips: 2,
            conditions: [.firstWinningBetThisStage],
            useLimits: [.perStage(1)]
        )
    ]
}

extension Modifier {
    static var allContent: [Modifier] {
        sampleDebugPool + expandedContent
    }

    static func definition(id: String) -> Modifier? {
        if let activeDefinition = ActiveModifierCatalog.definition(id: id, in: allContent) {
            return activeDefinition
        }

        allContent.first { $0.id == id }
    }

    static var expandedContent: [Modifier] {
        bankerEngineContent
            + playerPivotContent
            + tieHunterContent
            + shoeVisionContent
            + shoeControlContent
            + betControlContent
            + economyContent
            + heatStealthContent
            + naturalHunterContent
            + pairHunterContent
            + loadedShoeContent
            + counterMasterContent
            + bossKillerContent
            + debtLoanContent
            + opponentSabotageContent
            + finalHandSpecialistContent
    }

    private static func contentModifier(
        id: String,
        name: String,
        summary: String,
        rarity: ModifierRarity,
        tags: Set<ModifierTag>,
        trigger: ModifierTrigger,
        effects: [ModifierEffect],
        minShopTier: Int,
        conditions: [ModifierCondition] = [.always],
        useLimits: [ModifierUseLimit] = [],
        heatCost: Int = 0
    ) -> Modifier {
        Modifier(
            id: id,
            name: name,
            summary: summary,
            rulesText: summary,
            rarity: rarity,
            tags: tags,
            triggers: [trigger],
            effects: effects,
            baseCostChips: rarity.defaultShopCost,
            minShopTier: minShopTier,
            battleLogText: summary,
            conditions: conditions,
            useLimits: useLimits,
            heatCost: heatCost
        )
    }

    private static func payoutLevels(_ betType: BetType?, _ l1: Int, _ l2: Int, _ l3: Int) -> [ModifierEffect] {
        [
            .levelScaled(
                level1: [.payoutMultiplier(betType: betType, percent: l1)],
                level2: [.payoutMultiplier(betType: betType, percent: l2)],
                level3: [.payoutMultiplier(betType: betType, percent: l3)]
            )
        ]
    }

    private static func anteLevels(_ l1: Int, _ l2: Int, _ l3: Int) -> [ModifierEffect] {
        [
            .levelScaled(
                level1: [.grantBankrollFromAnte(percent: l1)],
                level2: [.grantBankrollFromAnte(percent: l2)],
                level3: [.grantBankrollFromAnte(percent: l3)]
            )
        ]
    }

    private static var bankerEngineContent: [Modifier] {
        [
            contentModifier(id: "banker.commission-dodge", name: "Commission Dodge", summary: "Banker wins add a small commission refund.", rarity: .common, tags: [.banker, .economy], trigger: .wagerWon, effects: payoutLevels(.banker, 5, 9, 14), minShopTier: 1, conditions: [.all([.betType(.banker), .winningSide(.banker)])]),
            contentModifier(id: "banker.house-favorite", name: "House Favorite", summary: "First Banker win each stage grants +1 Chip.", rarity: .uncommon, tags: [.banker, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantChips(amount: 1)], level2: [.grantChips(amount: 1), .grantBankrollFromAnte(percent: 50)], level3: [.grantChips(amount: 2)])], minShopTier: 1, conditions: [.all([.betType(.banker), .winningSide(.banker), .firstBankerSideWinThisStage])], useLimits: [.perStage(1)]),
            contentModifier(id: "banker.banco-battery", name: "Banco Battery", summary: "Banker wins build steady ante-scaled bankroll.", rarity: .rare, tags: [.banker, .streak], trigger: .wagerWon, effects: anteLevels(35, 60, 100), minShopTier: 2, conditions: [.all([.betType(.banker), .winningSide(.banker)])]),
            contentModifier(id: "banker.dealers-nod", name: "Dealer's Nod", summary: "Banker wins reveal one future card.", rarity: .uncommon, tags: [.banker, .shoeVision], trigger: .wagerWon, effects: [.revealUpcomingCards(count: 1)], minShopTier: 2, conditions: [.all([.betType(.banker), .winningSide(.banker)])]),
            contentModifier(id: "banker.banker-anchor", name: "Banker Anchor", summary: "Banker losses refund a little when you stay loyal.", rarity: .common, tags: [.banker, .comeback], trigger: .wagerLost, effects: [.lossRefund(percent: 20, maxCents: nil)], minShopTier: 1, conditions: [.betType(.banker)], useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]),
            contentModifier(id: "banker.backroom-banco", name: "Backroom Banco", summary: "Strong Banker payout bonus, but it adds Heat.", rarity: .epic, tags: [.banker, .heat], trigger: .wagerWon, effects: payoutLevels(.banker, 18, 28, 45), minShopTier: 3, conditions: [.all([.betType(.banker), .winningSide(.banker)])], heatCost: 1),
            contentModifier(id: "banker.loyal-customer", name: "Loyal Customer", summary: "Your first winning bet each stage pays more if it is Banker.", rarity: .rare, tags: [.banker, .streak], trigger: .wagerWon, effects: anteLevels(75, 115, 175), minShopTier: 3, conditions: [.all([.betType(.banker), .winningSide(.banker), .firstWinningBetThisStage])], useLimits: [.perStage(1)]),
            contentModifier(id: "banker.banker-lock", name: "Banker Lock", summary: "Late-run Banker wins pay a serious bonus.", rarity: .legendary, tags: [.banker, .boss], trigger: .wagerWon, effects: payoutLevels(.banker, 35, 55, 85), minShopTier: 5, conditions: [.all([.betType(.banker), .winningSide(.banker)])], heatCost: 1),
            contentModifier(id: "banker.banco-press", name: "Banco Press", summary: "After Banker wins, gain extra bankroll from ante.", rarity: .uncommon, tags: [.banker, .betControl], trigger: .wagerWon, effects: anteLevels(40, 70, 110), minShopTier: 2, conditions: [.all([.betType(.banker), .winningSide(.banker)])])
        ]
    }

    private static var playerPivotContent: [Modifier] {
        [
            contentModifier(id: "player.reversal-read", name: "Reversal Read", summary: "Player wins after a Banker result pay more.", rarity: .uncommon, tags: [.player, .comeback], trigger: .wagerWon, effects: payoutLevels(.player, 12, 20, 32), minShopTier: 1, conditions: [.all([.betType(.player), .winningSide(.player)])]),
            contentModifier(id: "player.side-step", name: "Side Step", summary: "Player wins reveal a short look ahead.", rarity: .common, tags: [.player, .shoeVision], trigger: .wagerWon, effects: [.revealUpcomingCards(count: 1)], minShopTier: 1, conditions: [.all([.betType(.player), .winningSide(.player)])]),
            contentModifier(id: "player.punto-strike", name: "Punto Strike", summary: "Player bets gain ante-scaled burst bankroll on wins.", rarity: .rare, tags: [.player, .tempo], trigger: .wagerWon, effects: anteLevels(60, 100, 160), minShopTier: 2, conditions: [.all([.betType(.player), .winningSide(.player)])]),
            contentModifier(id: "player.countertrend", name: "Countertrend", summary: "First Player win each stage grants 60% ante bankroll.", rarity: .common, tags: [.player, .comeback], trigger: .wagerWon, effects: anteLevels(60, 100, 150), minShopTier: 1, conditions: [.all([.betType(.player), .winningSide(.player), .firstPlayerSideWinThisStage])], useLimits: [.perStage(1)]),
            contentModifier(id: "player.sharp-turn", name: "Sharp Turn", summary: "Player wins give Chips once per stage.", rarity: .uncommon, tags: [.player, .economy], trigger: .wagerWon, effects: [.grantChipsOnFirstStageTrigger(amount: 1)], minShopTier: 2, conditions: [.all([.betType(.player), .winningSide(.player)])], useLimits: [.perStage(1)]),
            contentModifier(id: "player.break-pattern", name: "Break the Pattern", summary: "Player wins pay a larger bonus during boss pressure.", rarity: .epic, tags: [.player, .boss], trigger: .wagerWon, effects: payoutLevels(.player, 20, 35, 55), minShopTier: 4, conditions: [.all([.betType(.player), .winningSide(.player)])]),
            contentModifier(id: "player.punto-insurance", name: "Punto Insurance", summary: "First losing Player bet each stage refunds 20%.", rarity: .common, tags: [.player, .comeback], trigger: .wagerLost, effects: [.levelScaled(level1: [.lossRefund(percent: 20, maxCents: nil)], level2: [.lossRefund(percent: 32, maxCents: nil)], level3: [.lossRefund(percent: 45, maxCents: nil)])], minShopTier: 1, conditions: [.betType(.player)], useLimits: [.perStage(1)]),
            contentModifier(id: "player.underdog-side", name: "Underdog Side", summary: "Player wins pay more but add Heat.", rarity: .rare, tags: [.player, .heat], trigger: .wagerWon, effects: payoutLevels(.player, 18, 30, 46), minShopTier: 3, conditions: [.all([.betType(.player), .winningSide(.player)])], heatCost: 1),
            contentModifier(id: "player.player-tempo", name: "Player Tempo", summary: "Any Player win advances your economy.", rarity: .uncommon, tags: [.player, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantBankrollFromAnte(percent: 30)], level2: [.grantBankrollFromAnte(percent: 50)], level3: [.grantBankrollFromAnte(percent: 75), .grantChips(amount: 1)])], minShopTier: 2, conditions: [.all([.betType(.player), .winningSide(.player)])])
        ]
    }

    private static var tieHunterContent: [Modifier] {
        [
            contentModifier(id: "tie.tie-whisperer", name: "Tie Whisperer", summary: "Tie attempts reveal one card after the hand.", rarity: .common, tags: [.tie, .shoeVision], trigger: .wagerLost, effects: [.revealUpcomingCards(count: 1)], minShopTier: 1, conditions: [.betType(.tie)]),
            contentModifier(id: "tie.equalizer", name: "Equalizer", summary: "Tie wins gain Chips and bankroll from ante.", rarity: .rare, tags: [.tie, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantChips(amount: 1), .grantBankrollFromAnte(percent: 100)], level2: [.grantChips(amount: 2), .grantBankrollFromAnte(percent: 150)], level3: [.grantChips(amount: 3), .grantBankrollFromAnte(percent: 250)])], minShopTier: 2, conditions: [.all([.betType(.tie), .winningSide(.tie)])]),
            contentModifier(id: "tie.longshot-ledger", name: "Longshot Ledger", summary: "Tie wins pay an extra payout bonus.", rarity: .epic, tags: [.tie, .betControl], trigger: .wagerWon, effects: payoutLevels(.tie, 35, 60, 100), minShopTier: 3, conditions: [.all([.betType(.tie), .winningSide(.tie)])]),
            contentModifier(id: "tie.split-signal", name: "Split Signal", summary: "Tie results reveal two upcoming cards.", rarity: .uncommon, tags: [.tie, .shoeVision], trigger: .tieOccurred, effects: [.revealUpcomingCards(count: 2)], minShopTier: 2),
            contentModifier(id: "tie.dead-heat", name: "Dead Heat", summary: "Tie wins add a large ante-scaled bonus.", rarity: .rare, tags: [.tie, .economy], trigger: .wagerWon, effects: anteLevels(125, 200, 325), minShopTier: 3, conditions: [.all([.betType(.tie), .winningSide(.tie)])]),
            contentModifier(id: "tie.mirror-bet", name: "Mirror Bet", summary: "Lost Tie bets refund part of the risk.", rarity: .common, tags: [.tie, .comeback], trigger: .wagerLost, effects: [.lossRefund(percent: 18, maxCents: nil)], minShopTier: 1, conditions: [.betType(.tie)]),
            contentModifier(id: "tie.tie-master", name: "Tie Master", summary: "Tie wins create Chips for the shop.", rarity: .legendary, tags: [.tie, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantChips(amount: 2)], level2: [.grantChips(amount: 3), .grantBankrollFromAnte(percent: 100)], level3: [.grantChips(amount: 5), .grantBankrollFromAnte(percent: 200)])], minShopTier: 5, conditions: [.all([.betType(.tie), .winningSide(.tie)])]),
            contentModifier(id: "tie.final-hand-tie", name: "Final Hand Tie", summary: "Final hand Tie shots get insurance.", rarity: .epic, tags: [.tie, .comeback], trigger: .finalHand, effects: [.lossRefund(percent: 50, maxCents: nil)], minShopTier: 4),
            contentModifier(id: "tie.jackpot-discipline", name: "Jackpot Discipline", summary: "First Tie loss each stage refunds safely.", rarity: .uncommon, tags: [.tie, .comeback], trigger: .wagerLost, effects: [.levelScaled(level1: [.lossRefund(percent: 30, maxCents: nil)], level2: [.lossRefund(percent: 45, maxCents: nil)], level3: [.lossRefund(percent: 60, maxCents: nil)])], minShopTier: 2, conditions: [.all([.betType(.tie), .firstTieLossThisStage])], useLimits: [.perStage(1)])
        ]
    }

    private static var shoeVisionContent: [Modifier] {
        [
            contentModifier(id: "vision.dealer-glance", name: "Dealer Glance", summary: "Reveal one card at each stage start.", rarity: .common, tags: [.shoeVision], trigger: .stageStarted, effects: [.revealUpcomingCards(count: 1)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "vision.soft-peek", name: "Soft Peek", summary: "Reveal two cards at stage start.", rarity: .common, tags: [.shoeVision], trigger: .stageStarted, effects: [.revealUpcomingCards(count: 2)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "vision.deep-read", name: "Deep Read", summary: "Reveal four cards when the stage begins.", rarity: .rare, tags: [.shoeVision], trigger: .stageStarted, effects: [.revealUpcomingCards(count: 4)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "vision.pattern-memory", name: "Pattern Memory", summary: "Reveals and pays a tiny ante stipend after wins.", rarity: .uncommon, tags: [.shoeVision, .economy], trigger: .wagerWon, effects: [.revealUpcomingCards(count: 1), .grantBankrollFromAnte(percent: 20)], minShopTier: 2),
            contentModifier(id: "vision.face-down-count", name: "Face Down Count", summary: "Card draws create compact shoe knowledge.", rarity: .common, tags: [.shoeVision], trigger: .cardDrawn, effects: [.custom(id: "count-card", description: "Logged one drawn card for the counter.")], minShopTier: 1),
            contentModifier(id: "vision.third-card-forecast", name: "Third Card Forecast", summary: "Stage start reveals enough for third-card planning.", rarity: .epic, tags: [.shoeVision], trigger: .stageStarted, effects: [.revealUpcomingCardsWithForecast(count: 5)], minShopTier: 4, useLimits: [.perStage(1)]),
            contentModifier(id: "vision.banker-forecast", name: "Banker Forecast", summary: "Correct Banker reads pay extra.", rarity: .rare, tags: [.shoeVision, .banker], trigger: .wagerWon, effects: anteLevels(50, 80, 130), minShopTier: 3, conditions: [.all([.betType(.banker), .winningSide(.banker)])]),
            contentModifier(id: "vision.tie-forecast", name: "Tie Forecast", summary: "Tie attempts get deeper reveal support.", rarity: .rare, tags: [.shoeVision, .tie], trigger: .betPlaced, effects: [.revealUpcomingCards(count: 3)], minShopTier: 3, conditions: [.betType(.tie)], useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]),
            contentModifier(id: "vision.boss-scout", name: "Boss Scout", summary: "Boss stages begin with stronger information.", rarity: .epic, tags: [.shoeVision, .boss], trigger: .bossStarted, effects: [.revealUpcomingCardsWithForecast(count: 5)], minShopTier: 4)
        ]
    }

    private static var shoeControlContent: [Modifier] {
        [
            contentModifier(id: "control.burn-notice", name: "Burn Notice", summary: "Burn one card before the deal once per stage.", rarity: .common, tags: [.shoeControl], trigger: .beforeDeal, effects: [.burnCards(count: 1)], minShopTier: 1, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)], heatCost: 1),
            contentModifier(id: "control.soft-cut", name: "Soft Cut", summary: "Move the top card to the bottom.", rarity: .common, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardToBottom], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "control.dealer-slip", name: "Dealer Slip", summary: "Move the next card deeper into the shoe.", rarity: .uncommon, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardDeeper(positions: 2)], minShopTier: 2, useLimits: [.perStage(1)]),
            contentModifier(id: "control.card-delay", name: "Card Delay", summary: "Delay the top card three positions.", rarity: .rare, tags: [.shoeControl], trigger: .beforeDeal, effects: [.moveTopCardDeeper(positions: 3)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)], heatCost: 1),
            contentModifier(id: "control.control-burn", name: "Control Burn", summary: "Burn two cards, but gain Heat.", rarity: .epic, tags: [.shoeControl, .heat], trigger: .beforeDeal, effects: [.burnCards(count: 2)], minShopTier: 4, useLimits: [.perStage(1)], heatCost: 2),
            contentModifier(id: "control.discard-favor", name: "Discard Favor", summary: "Burning cards grants a small ante refund.", rarity: .uncommon, tags: [.shoeControl, .economy], trigger: .beforeDeal, effects: [.burnCards(count: 1), .grantBankrollFromAnte(percent: 30)], minShopTier: 2, useLimits: [.perStage(1)], heatCost: 1),
            contentModifier(id: "control.shoe-pocket", name: "Shoe Pocket", summary: "Add one 9 into the future shoe.", rarity: .rare, tags: [.shoeControl, .cardSculpting], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 3, useLimits: [.perStage(1)], heatCost: 1),
            contentModifier(id: "control.slipstream", name: "Slipstream", summary: "Move a card deeper and reveal one card.", rarity: .rare, tags: [.shoeControl, .shoeVision], trigger: .beforeDeal, effects: [.moveTopCardDeeper(positions: 2), .revealUpcomingCards(count: 1)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "control.hot-cut", name: "Hot Cut", summary: "Add two 8s and 9s at stage start.", rarity: .legendary, tags: [.shoeControl, .cardSculpting], trigger: .stageStarted, effects: [.addCards(ranks: [.eight, .nine], count: 4)], minShopTier: 5, useLimits: [.perStage(1)], heatCost: 2),
            contentModifier(id: "control.dealers-thumb", name: "Dealer's Thumb", summary: "Before a boss hand, delay the top card.", rarity: .epic, tags: [.shoeControl, .boss], trigger: .bossStarted, effects: [.moveTopCardDeeper(positions: 3)], minShopTier: 4)
        ]
    }

    private static var betControlContent: [Modifier] {
        [
            contentModifier(id: "bet.small-ball", name: "Small Ball", summary: "Small winning bets gain a steady ante bonus.", rarity: .common, tags: [.betControl, .economy], trigger: .wagerWon, effects: anteLevels(25, 45, 70), minShopTier: 1),
            contentModifier(id: "bet.careful-hands", name: "Careful Hands", summary: "First loss each stage refunds part of the bet.", rarity: .common, tags: [.betControl, .comeback], trigger: .wagerLost, effects: [.lossRefund(percent: 25, maxCents: nil)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "bet.press-edge", name: "Press the Edge", summary: "Wins after committing to a side pay more.", rarity: .uncommon, tags: [.betControl, .streak], trigger: .wagerWon, effects: payoutLevels(nil, 10, 16, 24), minShopTier: 2),
            contentModifier(id: "bet.high-roller", name: "High Roller", summary: "Winning bets pay more but add Heat.", rarity: .rare, tags: [.betControl, .heat], trigger: .wagerWon, effects: payoutLevels(nil, 20, 32, 50), minShopTier: 2, heatCost: 1),
            contentModifier(id: "bet.insurance-marker", name: "Insurance Marker", summary: "Losses get a partial refund.", rarity: .uncommon, tags: [.betControl, .comeback], trigger: .wagerLost, effects: [.levelScaled(level1: [.lossRefund(percent: 15, maxCents: nil)], level2: [.lossRefund(percent: 25, maxCents: nil)], level3: [.lossRefund(percent: 35, maxCents: nil)])], minShopTier: 2),
            contentModifier(id: "bet.loss-limit", name: "Loss Limit", summary: "First two losses each stage refund modestly.", rarity: .rare, tags: [.betControl, .comeback], trigger: .wagerLost, effects: [.lossRefund(percent: 30, maxCents: nil)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]),
            contentModifier(id: "bet.flat-better", name: "Flat Better", summary: "Any win pays a small predictable bonus.", rarity: .common, tags: [.betControl], trigger: .wagerWon, effects: anteLevels(20, 35, 55), minShopTier: 1),
            contentModifier(id: "bet.parlay-slip", name: "Parlay Slip", summary: "Winning bets grant Chips once per stage.", rarity: .rare, tags: [.betControl, .economy], trigger: .wagerWon, effects: [.grantChipsOnFirstStageTrigger(amount: 2)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "bet.overbet-permit", name: "Overbet Permit", summary: "Temporarily bends bet caps in your favor.", rarity: .epic, tags: [.betControl, .heat], trigger: .beforeBet, effects: [.adjustBetLimit(minCents: nil, maxCents: nil), .gainHeat(amount: 1)], minShopTier: 4, useLimits: [.perStage(1)]),
            contentModifier(id: "bet.safe-marker", name: "Safe Marker", summary: "Loss refund with no Heat risk.", rarity: .uncommon, tags: [.betControl, .comeback], trigger: .wagerLost, effects: [.lossRefund(percent: 20, maxCents: nil)], minShopTier: 2, useLimits: [.perHand(1)])
        ]
    }

    private static var economyContent: [Modifier] {
        [
            contentModifier(id: "economy.interest-ledger", name: "Interest Ledger", summary: "Stage starts pay a tiny bankroll stipend.", rarity: .common, tags: [.economy], trigger: .stageStarted, effects: anteLevels(35, 60, 100), minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "economy.shop-regular", name: "Shop Regular", summary: "Rerolls become easier to afford.", rarity: .uncommon, tags: [.economy], trigger: .shopRerolled, effects: [.addRerollDiscount(chips: 1)], minShopTier: 2),
            contentModifier(id: "economy.freeze-discount", name: "Freeze Discount", summary: "Shop entry discounts prices by 5%.", rarity: .common, tags: [.economy], trigger: .shopEntered, effects: [.addShopDiscount(percent: 5)], minShopTier: 1),
            contentModifier(id: "economy.duplicate-finder", name: "Duplicate Finder", summary: "Buying modifiers helps find copies.", rarity: .rare, tags: [.economy], trigger: .modifierBought, effects: [.custom(id: "duplicate-finder", description: "Future shops bias toward owned modifiers.")], minShopTier: 3),
            contentModifier(id: "economy.sellback", name: "Sellback", summary: "Selling modifiers returns better chip value.", rarity: .uncommon, tags: [.economy], trigger: .modifierSold, effects: [.grantChips(amount: 1)], minShopTier: 2),
            contentModifier(id: "economy.comp-points", name: "Comp Points", summary: "First win each stage grants bankroll from ante.", rarity: .common, tags: [.economy], trigger: .wagerWon, effects: anteLevels(30, 50, 80), minShopTier: 1, conditions: [.firstWinningBetThisStage], useLimits: [.perStage(1)]),
            contentModifier(id: "economy.boss-bonus", name: "Boss Bonus", summary: "Boss victories create extra Chips.", rarity: .rare, tags: [.economy, .boss], trigger: .bossDefeated, effects: [.levelScaled(level1: [.grantChips(amount: 2)], level2: [.grantChips(amount: 3)], level3: [.grantChips(amount: 5)])], minShopTier: 3),
            contentModifier(id: "economy.coupon-book", name: "Coupon Book", summary: "Shop entries grant a small discount effect.", rarity: .uncommon, tags: [.economy], trigger: .shopEntered, effects: [.addShopDiscount(percent: 10)], minShopTier: 2),
            contentModifier(id: "economy.chip-stipend", name: "Chip Stipend", summary: "Each stage start grants Chips.", rarity: .epic, tags: [.economy], trigger: .stageStarted, effects: [.levelScaled(level1: [.grantChips(amount: 1)], level2: [.grantChips(amount: 2)], level3: [.grantChips(amount: 3)])], minShopTier: 4, useLimits: [.perStage(1)])
        ]
    }

    private static var heatStealthContent: [Modifier] {
        [
            contentModifier(id: "heat.low-profile", name: "Low Profile", summary: "Reduce Heat at stage start.", rarity: .common, tags: [.heat], trigger: .stageStarted, effects: [.reduceHeat(amount: 1)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "heat.floor-distraction", name: "Floor Distraction", summary: "Prevent a Heat spike once per stage.", rarity: .uncommon, tags: [.heat, .opponentSabotage], trigger: .heatGained, effects: [.preventHeat(amount: 1)], minShopTier: 2, useLimits: [.perStage(1)]),
            contentModifier(id: "heat.quiet-dealer", name: "Quiet Dealer", summary: "Shoe-control Heat is softened.", rarity: .rare, tags: [.heat, .shoeControl], trigger: .heatGained, effects: [.preventHeat(amount: 2)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "heat.backroom-pass", name: "Backroom Pass", summary: "Boss tables begin with reduced Heat.", rarity: .rare, tags: [.heat, .boss], trigger: .bossStarted, effects: [.reduceHeat(amount: 2)], minShopTier: 3),
            contentModifier(id: "heat.pit-boss-bribe", name: "Pit Boss Bribe", summary: "Spend stealth to suppress opponent pressure.", rarity: .epic, tags: [.heat, .opponentSabotage], trigger: .bossStarted, effects: [.suppressOpponentTags([.boss])], minShopTier: 4),
            contentModifier(id: "heat.soft-footsteps", name: "Soft Footsteps", summary: "First Heat each stage is prevented.", rarity: .common, tags: [.heat], trigger: .heatGained, effects: [.preventHeat(amount: nil)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "heat.surveillance-loop", name: "Surveillance Loop", summary: "Reveal suppression hurts less.", rarity: .rare, tags: [.heat, .shoeVision], trigger: .bossStarted, effects: [.custom(id: "surveillance-loop", description: "Boss reveal suppression is logged and softened.")], minShopTier: 3),
            contentModifier(id: "heat.camera-blindspot", name: "Camera Blindspot", summary: "Prevent two Heat during boss stages.", rarity: .epic, tags: [.heat, .boss], trigger: .heatGained, effects: [.preventHeat(amount: 2)], minShopTier: 4, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]),
            contentModifier(id: "heat.cool-customer", name: "Cool Customer", summary: "Winning bets quietly reduce Heat.", rarity: .legendary, tags: [.heat, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.reduceHeat(amount: 1)], level2: [.reduceHeat(amount: 1), .grantChips(amount: 1)], level3: [.reduceHeat(amount: 2), .grantChips(amount: 1)])], minShopTier: 5)
        ]
    }

    private static var naturalHunterContent: [Modifier] {
        [
            contentModifier(id: "natural.natural-read", name: "Natural Read", summary: "Natural hands reveal a clean follow-up card.", rarity: .common, tags: [.natural, .shoeVision], trigger: .naturalOccurred, effects: [.revealUpcomingCards(count: 1)], minShopTier: 1),
            contentModifier(id: "natural.natural-bonus", name: "Natural Bonus", summary: "Natural wins grant ante-scaled bankroll.", rarity: .uncommon, tags: [.natural, .economy], trigger: .naturalOccurred, effects: anteLevels(40, 70, 110), minShopTier: 2),
            contentModifier(id: "natural.snap-nine", name: "Snap Nine", summary: "Natural pressure adds 9s to future shoes.", rarity: .rare, tags: [.natural, .cardSculpting], trigger: .naturalOccurred, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]),
            contentModifier(id: "natural.natural-comp", name: "Natural Comp", summary: "First natural each stage grants Chips.", rarity: .rare, tags: [.natural, .economy], trigger: .naturalOccurred, effects: [.levelScaled(level1: [.grantChips(amount: 1)], level2: [.grantChips(amount: 2)], level3: [.grantChips(amount: 2), .grantBankrollFromAnte(percent: 75)])], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "natural.perfect-nine", name: "Perfect Nine", summary: "Natural-focused wins become a late-run bankroll spike.", rarity: .legendary, tags: [.natural, .boss, .cardSculpting], trigger: .naturalOccurred, effects: [.levelScaled(level1: [.grantBankrollFromAnte(percent: 150)], level2: [.grantBankrollFromAnte(percent: 225), .addCards(ranks: [.nine], count: 1)], level3: [.grantBankrollFromAnte(percent: 325), .addCards(ranks: [.nine], count: 2)])], minShopTier: 5, heatCost: 1)
        ]
    }

    private static var pairHunterContent: [Modifier] {
        [
            contentModifier(id: "pair.pair-hunter", name: "Pair Hunter", summary: "Pairs pay a small scouting bonus.", rarity: .common, tags: [.pair, .shoeVision], trigger: .pairOccurred, effects: [.revealUpcomingCards(count: 1), .grantBankrollFromAnte(percent: 20)], minShopTier: 1),
            contentModifier(id: "pair.twin-signal", name: "Twin Signal", summary: "Pairs reveal two cards and support Tie plans.", rarity: .uncommon, tags: [.pair, .tie, .shoeVision], trigger: .pairOccurred, effects: [.revealUpcomingCards(count: 2), .gainTieCharges(count: 1)], minShopTier: 2),
            contentModifier(id: "pair.matchbook", name: "Matchbook", summary: "First pair each stage grants a Chip.", rarity: .uncommon, tags: [.pair, .economy], trigger: .pairOccurred, effects: [.grantChips(amount: 1)], minShopTier: 2, useLimits: [.perStage(1)]),
            contentModifier(id: "pair.split-pocket", name: "Split Pocket", summary: "Pairs slip one matching-value plan into the shoe.", rarity: .rare, tags: [.pair, .cardSculpting], trigger: .pairOccurred, effects: [.addCards(ranks: [.eight, .nine], count: 1)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]),
            contentModifier(id: "pair.twin-engine", name: "Twin Engine", summary: "Pair hits fuel a bigger shop economy.", rarity: .epic, tags: [.pair, .economy, .streak], trigger: .pairOccurred, effects: [.levelScaled(level1: [.grantChips(amount: 1), .grantBankrollFromAnte(percent: 50)], level2: [.grantChips(amount: 2), .grantBankrollFromAnte(percent: 80)], level3: [.grantChips(amount: 3), .grantBankrollFromAnte(percent: 125)])], minShopTier: 4)
        ]
    }

    private static var loadedShoeContent: [Modifier] {
        [
            contentModifier(id: "loaded.add-nine", name: "Add Nine", summary: "Add a 9 to the current shoe at stage start.", rarity: .common, tags: [.cardSculpting, .shoeControl], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 1)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "loaded.marked-nine", name: "Marked Nine", summary: "Add and reveal one future 9 line.", rarity: .uncommon, tags: [.cardSculpting, .shoeVision], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 1), .revealUpcomingCards(count: 1)], minShopTier: 2, useLimits: [.perStage(1)], heatCost: 1),
            contentModifier(id: "loaded.nine-worship", name: "Nine Worship", summary: "Natural and 9-heavy plans gain stage bankroll.", rarity: .rare, tags: [.cardSculpting, .natural, .economy], trigger: .stageStarted, effects: [.addCards(ranks: [.nine], count: 2), .grantBankrollFromAnte(percent: 50)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "loaded.eight-stack", name: "Eight Stack+", summary: "Add 8s and improve Tie/Banker texture.", rarity: .rare, tags: [.cardSculpting, .shoeControl], trigger: .stageStarted, effects: [.addCards(ranks: [.eight], count: 2)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "loaded.nine-engine", name: "Nine Engine", summary: "Every stage starts with a small loaded-shoe package.", rarity: .legendary, tags: [.cardSculpting, .boss], trigger: .stageStarted, effects: [.levelScaled(level1: [.addCards(ranks: [.nine], count: 2)], level2: [.addCards(ranks: [.eight, .nine], count: 3), .revealUpcomingCards(count: 1)], level3: [.addCards(ranks: [.nine], count: 4), .revealUpcomingCardsWithForecast(count: 3)])], minShopTier: 5, useLimits: [.perStage(1)], heatCost: 2)
        ]
    }

    private static var counterMasterContent: [Modifier] {
        [
            contentModifier(id: "counter.false-read", name: "False Read", summary: "After losing, reveal one card and soften the next risk.", rarity: .common, tags: [.comeback, .shoeVision], trigger: .wagerLost, effects: [.revealUpcomingCards(count: 1), .lossRefund(percent: 10, maxCents: nil)], minShopTier: 1),
            contentModifier(id: "counter.countertrend-plus", name: "Countertrend+", summary: "Player wins after pressure gain a stronger ante bonus.", rarity: .uncommon, tags: [.player, .comeback], trigger: .wagerWon, effects: anteLevels(45, 80, 125), minShopTier: 2, conditions: [.all([.betType(.player), .winningSide(.player)])]),
            contentModifier(id: "counter.mirror-punish", name: "Mirror Punish", summary: "Winning after a loss refunds part of the previous damage.", rarity: .rare, tags: [.comeback, .betControl], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantBankrollFromAnte(percent: 60)], level2: [.grantBankrollFromAnte(percent: 100)], level3: [.grantBankrollFromAnte(percent: 150), .grantChips(amount: 1)])], minShopTier: 3),
            contentModifier(id: "counter.reverse-count", name: "Reverse Count", summary: "Card draws after losses improve your next read.", rarity: .uncommon, tags: [.comeback, .shoeVision], trigger: .cardDrawn, effects: [.custom(id: "reverse-count", description: "Logged the drawn card for comeback reads.")], minShopTier: 2),
            contentModifier(id: "counter.turnaround-table", name: "Turnaround Table", summary: "First win after any stage loss grants Chips.", rarity: .epic, tags: [.comeback, .economy], trigger: .wagerWon, effects: [.levelScaled(level1: [.grantChips(amount: 1)], level2: [.grantChips(amount: 2)], level3: [.grantChips(amount: 2), .grantBankrollFromAnte(percent: 100)])], minShopTier: 4, useLimits: [.perStage(1)])
        ]
    }

    private static var bossKillerContent: [Modifier] {
        [
            contentModifier(id: "boss.final-table-pass", name: "Final Table Pass", summary: "Boss stages begin with lower Heat.", rarity: .rare, tags: [.boss, .heat], trigger: .bossStarted, effects: [.reduceHeat(amount: 1)], minShopTier: 3),
            contentModifier(id: "boss.inside-job", name: "Inside Job", summary: "Boss starts reveal a guarded forecast.", rarity: .epic, tags: [.boss, .shoeVision, .opponentSabotage], trigger: .bossStarted, effects: [.revealUpcomingCardsWithForecast(count: 4)], minShopTier: 4, useLimits: [.perStage(1)], heatCost: 1),
            contentModifier(id: "boss.countermeasure", name: "Countermeasure", summary: "Prevent one boss Heat spike each stage.", rarity: .uncommon, tags: [.boss, .heat], trigger: .heatGained, effects: [.preventHeat(amount: 1)], minShopTier: 2, useLimits: [.perStage(1)]),
            contentModifier(id: "boss.boss-bounty", name: "Boss Bounty", summary: "Defeating bosses pays Chips and bankroll.", rarity: .rare, tags: [.boss, .economy], trigger: .bossDefeated, effects: [.levelScaled(level1: [.grantChips(amount: 2), .grantBankrollFromAnte(percent: 100)], level2: [.grantChips(amount: 3), .grantBankrollFromAnte(percent: 150)], level3: [.grantChips(amount: 4), .grantBankrollFromAnte(percent: 225)])], minShopTier: 3),
            contentModifier(id: "boss.house-crack", name: "House Crack", summary: "Late boss wins pay a risky but bounded bonus.", rarity: .legendary, tags: [.boss, .betControl, .heat], trigger: .wagerWon, effects: payoutLevels(nil, 30, 50, 75), minShopTier: 5, heatCost: 1)
        ]
    }

    private static var debtLoanContent: [Modifier] {
        [
            contentModifier(id: "debt.emergency-marker", name: "Emergency Marker", summary: "Stage starts can borrow a controlled bankroll cushion.", rarity: .common, tags: [.economy, .comeback], trigger: .stageStarted, effects: [.grantBankrollFromAnte(percent: 50), .gainHeat(amount: 1)], minShopTier: 1, useLimits: [.perStage(1)]),
            contentModifier(id: "debt.debt-collector", name: "Debt Collector", summary: "Shop entry converts Heat pressure into Chips.", rarity: .rare, tags: [.economy, .heat], trigger: .shopEntered, effects: [.grantChips(amount: 2), .gainHeat(amount: 1)], minShopTier: 3),
            contentModifier(id: "debt.last-dollar", name: "Last Dollar", summary: "First loss each stage refunds more when you are behind.", rarity: .uncommon, tags: [.comeback, .economy], trigger: .wagerLost, effects: [.levelScaled(level1: [.lossRefund(percent: 30, maxCents: nil)], level2: [.lossRefund(percent: 45, maxCents: nil)], level3: [.lossRefund(percent: 60, maxCents: nil), .grantChips(amount: 1)])], minShopTier: 2, useLimits: [.perStage(1)]),
            contentModifier(id: "debt.credit-line", name: "Credit Line", summary: "Boss stages grant a cash buffer but add Heat.", rarity: .epic, tags: [.economy, .boss, .heat], trigger: .bossStarted, effects: [.grantBankrollFromAnte(percent: 200), .gainHeat(amount: 1)], minShopTier: 4, useLimits: [.perStage(1)]),
            contentModifier(id: "debt.marker-chain", name: "Marker Chain", summary: "Buying modifiers can create a small bankroll rebate.", rarity: .uncommon, tags: [.economy], trigger: .modifierBought, effects: [.grantBankrollFromAnte(percent: 25)], minShopTier: 2)
        ]
    }

    private static var opponentSabotageContent: [Modifier] {
        [
            contentModifier(id: "sabotage.tempo-theft", name: "Tempo Theft", summary: "Shop rerolls pressure opponents and refund a Chip later.", rarity: .uncommon, tags: [.opponentSabotage, .economy], trigger: .shopRerolled, effects: [.custom(id: "tempo-theft", description: "Next opponent scoring burst is softened.")], minShopTier: 2),
            contentModifier(id: "sabotage.opponent-tax", name: "Opponent Tax", summary: "Stage starts tax the opponent score plan.", rarity: .rare, tags: [.opponentSabotage, .economy], trigger: .stageStarted, effects: [.custom(id: "opponent-tax", description: "Opponent score pressure reduced this stage."), .grantBankrollFromAnte(percent: 40)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "sabotage.cold-read", name: "Cold Read", summary: "Boss starts suppress one hostile tag.", rarity: .epic, tags: [.opponentSabotage, .boss], trigger: .bossStarted, effects: [.suppressOpponentTags([.boss])], minShopTier: 4),
            contentModifier(id: "sabotage.table-chat", name: "Table Chat", summary: "Hand starts occasionally distract the table.", rarity: .common, tags: [.opponentSabotage], trigger: .handStarted, effects: [.custom(id: "table-chat", description: "Opponent tell noted in the battle log.")], minShopTier: 1, useLimits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]),
            contentModifier(id: "sabotage.house-static", name: "House Static", summary: "Prevent one opponent or boss Heat signal.", rarity: .rare, tags: [.opponentSabotage, .heat], trigger: .heatGained, effects: [.preventHeat(amount: 1)], minShopTier: 3, useLimits: [.perStageByLevel(level1: 1, level2: 1, level3: 2)])
        ]
    }

    private static var finalHandSpecialistContent: [Modifier] {
        [
            contentModifier(id: "final.closer", name: "Closer", summary: "Final hand wins pay an ante bonus.", rarity: .common, tags: [.streak, .betControl], trigger: .finalHand, effects: anteLevels(50, 80, 125), minShopTier: 1),
            contentModifier(id: "final.redemption-hand", name: "Redemption Hand", summary: "Final hand losses refund part of the damage.", rarity: .uncommon, tags: [.comeback], trigger: .finalHand, effects: [.levelScaled(level1: [.lossRefund(percent: 25, maxCents: nil)], level2: [.lossRefund(percent: 40, maxCents: nil)], level3: [.lossRefund(percent: 55, maxCents: nil)])], minShopTier: 2),
            contentModifier(id: "final.last-look", name: "Last Look", summary: "Reveal a forecast before the final hand.", rarity: .rare, tags: [.shoeVision, .streak], trigger: .finalHand, effects: [.revealUpcomingCardsWithForecast(count: 4)], minShopTier: 3, useLimits: [.perStage(1)]),
            contentModifier(id: "final.crown-hand", name: "Crown Hand", summary: "Final boss final hand wins grant Chips.", rarity: .epic, tags: [.boss, .economy], trigger: .finalHand, effects: [.levelScaled(level1: [.grantChips(amount: 1)], level2: [.grantChips(amount: 2)], level3: [.grantChips(amount: 3), .grantBankrollFromAnte(percent: 100)])], minShopTier: 4),
            contentModifier(id: "final.house-breaker", name: "House Breaker", summary: "A final-hand win can crack late bosses without unbounded cash.", rarity: .legendary, tags: [.boss, .betControl, .heat], trigger: .finalHand, effects: [.levelScaled(level1: [.payoutMultiplier(betType: nil, percent: 25)], level2: [.payoutMultiplier(betType: nil, percent: 40), .reduceHeat(amount: 1)], level3: [.payoutMultiplier(betType: nil, percent: 60), .reduceHeat(amount: 2)])], minShopTier: 5)
        ]
    }
}

/// Lightweight stage counters supplied by the battle system before an event is
/// resolved. They let conditions like "first Banker win this stage" remain
/// deterministic without making the modifier engine own the whole battle state.
struct ModifierStageStats: Equatable {
    var playerSideWins: Int = 0
    var bankerSideWins: Int = 0
    var tieResults: Int = 0
    var winningBets: Int = 0
    var tieBetLosses: Int = 0
}

/// Inputs the engine needs to resolve one event.
///
/// Keep this separate from SwiftUI view state. The battle, shop, and boss
/// systems can build a context, ask the engine for resolutions, then apply the
/// returned deltas through their own authoritative state.
struct ModifierContext: Equatable {
    var event: GameEvent
    var stageNumber: Int
    var handNumber: Int
    var anteCents: Int
    var legalBetAmountsCents: [Int]
    var availableHeatRoom: Int
    var isBossStage: Bool
    var bossID: String?
    var stageStats: ModifierStageStats
    var activeTags: Set<ModifierTag>
    var upcomingCards: [Card]

    init(
        event: GameEvent,
        stageNumber: Int,
        handNumber: Int,
        anteCents: Int,
        legalBetAmountsCents: [Int] = [],
        availableHeatRoom: Int,
        isBossStage: Bool = false,
        bossID: String? = nil,
        stageStats: ModifierStageStats = ModifierStageStats(),
        activeTags: Set<ModifierTag> = [],
        upcomingCards: [Card] = []
    ) {
        self.event = event
        self.stageNumber = stageNumber
        self.handNumber = handNumber
        self.anteCents = max(0, anteCents)
        self.legalBetAmountsCents = legalBetAmountsCents.map { max(0, $0) }.sorted()
        self.availableHeatRoom = max(0, availableHeatRoom)
        self.isBossStage = isBossStage
        self.bossID = bossID
        self.stageStats = stageStats
        self.activeTags = activeTags
        self.upcomingCards = upcomingCards
    }
}

/// Data-only reveal request returned by a modifier.
///
/// The shoe UI can render this directly, while headless tests can validate the
/// requested count and optional forecast without touching SwiftUI.
struct ModifierRevealRequest: Equatable {
    let count: Int
    let preview: ShoePreview
    let includesForecast: Bool
}

/// Transparent result of one modifier reacting to one event.
///
/// These records are intentionally UI-friendly: battle logs, payout ledgers,
/// and floating feedback can all name the source and show exact money/Heat/Chip
/// changes without re-running modifier logic.
struct ModifierResolution: Identifiable, Equatable {
    let id = UUID()
    let modifierID: String
    let modifierName: String
    let level: Int
    let trigger: ModifierTrigger
    var messages: [String] = []
    var bankrollDeltaCents: Int = 0
    var payoutBonusCents: Int = 0
    var chipDelta: Int = 0
    var heatDelta: Int = 0
    var heatPrevented: Int = 0
    var tieChargesDelta: Int = 0
    var revealRequest: ModifierRevealRequest?
    var deferredEffects: [ModifierEffect] = []

    var didChangeState: Bool {
        bankrollDeltaCents != 0
            || payoutBonusCents != 0
            || chipDelta != 0
            || heatDelta != 0
            || heatPrevented != 0
            || tieChargesDelta != 0
            || revealRequest != nil
            || !deferredEffects.isEmpty
            || !messages.isEmpty
    }
}

/// Per-instance usage counters owned by the modifier engine.
struct ModifierUsage: Codable, Equatable {
    var handUses: Int = 0
    var stageUses: Int = 0
    var runUses: Int = 0
}

/// Event-driven resolver for player, opponent, and future boss modifiers.
///
/// The engine does not own bankroll, Heat, Chips, or the shoe. It returns
/// explicit `ModifierResolution` values so the caller can apply changes through
/// the same authoritative state used by normal baccarat and shop logic.
struct ModifierEngine: Equatable {
    private(set) var usageByInstanceID: [UUID: ModifierUsage] = [:]

    mutating func resolve(
        event: GameEvent,
        modifiers: [ModifierInstance],
        library: [Modifier],
        attachments: [Attachment] = [],
        context: ModifierContext
    ) -> [ModifierResolution] {
        let libraryByID = Dictionary(uniqueKeysWithValues: library.map { ($0.id, $0) })
        let attachmentsByID = Dictionary(attachments.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var resolutions: [ModifierResolution] = []

        for instance in modifiers {
            guard let modifier = libraryByID[instance.modifierID] else {
                continue
            }

            guard modifier.triggers.contains(event.trigger), !instance.isDisabledByBoss else {
                continue
            }

            let clampedLevel = min(max(1, instance.level), modifier.maxLevel)
            let usage = usageByInstanceID[instance.id, default: ModifierUsage()]

            guard canUse(modifier: modifier, level: clampedLevel, usage: usage) else {
                continue
            }

            guard modifier.conditions.allSatisfy({ $0.isSatisfied(by: context, usage: usage) }) else {
                continue
            }

            guard modifier.heatCost <= context.availableHeatRoom else {
                resolutions.append(
                    ModifierResolution(
                        modifierID: modifier.id,
                        modifierName: modifier.name,
                        level: clampedLevel,
                        trigger: event.trigger,
                        messages: ["\(modifier.name) did not trigger: not enough Heat room."]
                    )
                )
                continue
            }

            var resolution = ModifierResolution(
                modifierID: modifier.id,
                modifierName: modifier.name,
                level: clampedLevel,
                trigger: event.trigger
            )

            if modifier.heatCost > 0 {
                resolution.heatDelta += modifier.heatCost
                resolution.messages.append("\(modifier.name): +\(modifier.heatCost) Heat cost")
            }

            let effects = expandedEffects(modifier.effects, level: clampedLevel)
            for effect in effects {
                apply(effect, modifier: modifier, usage: usage, context: context, resolution: &resolution)
            }

            for attachmentID in instance.attachedIDs {
                guard let attachment = attachmentsByID[attachmentID],
                      !attachment.compatibleTags.isDisjoint(with: modifier.tags) else {
                    continue
                }

                resolution.messages.append("\(attachment.name) empowered \(modifier.name)")
                for effect in expandedEffects(attachment.effects, level: clampedLevel) {
                    apply(effect, modifier: modifier, usage: usage, context: context, resolution: &resolution)
                }
            }

            if resolution.didChangeState {
                incrementUsage(for: instance.id)
                resolutions.append(resolution)
            }
        }

        return resolutions
    }

    mutating func resetHand() {
        for key in usageByInstanceID.keys {
            usageByInstanceID[key]?.handUses = 0
        }
    }

    mutating func resetStage() {
        for key in usageByInstanceID.keys {
            usageByInstanceID[key]?.handUses = 0
            usageByInstanceID[key]?.stageUses = 0
        }
    }

    mutating func resetRun() {
        usageByInstanceID.removeAll()
    }

    private func canUse(modifier: Modifier, level: Int, usage: ModifierUsage) -> Bool {
        modifier.useLimits.allSatisfy { limit in
            switch limit {
            case .perHand:
                return usage.handUses < limit.allowedUses(for: level)
            case .perStage, .perStageByLevel:
                return usage.stageUses < limit.allowedUses(for: level)
            case .perRun:
                return usage.runUses < limit.allowedUses(for: level)
            }
        }
    }

    private mutating func incrementUsage(for instanceID: UUID) {
        var usage = usageByInstanceID[instanceID, default: ModifierUsage()]
        usage.handUses += 1
        usage.stageUses += 1
        usage.runUses += 1
        usageByInstanceID[instanceID] = usage
    }

    private func expandedEffects(_ effects: [ModifierEffect], level: Int) -> [ModifierEffect] {
        effects.flatMap { effect -> [ModifierEffect] in
            switch effect {
            case .levelScaled(let level1, let level2, let level3):
                if level >= 3 {
                    return expandedEffects(level3, level: level)
                }

                if level == 2 {
                    return expandedEffects(level2, level: level)
                }

                return expandedEffects(level1, level: level)
            case .composite(let nested):
                return expandedEffects(nested, level: level)
            default:
                return [effect]
            }
        }
    }

    private func apply(
        _ effect: ModifierEffect,
        modifier: Modifier,
        usage: ModifierUsage,
        context: ModifierContext,
        resolution: inout ModifierResolution
    ) {
        switch effect {
        case .grantBankroll(let cents):
            resolution.bankrollDeltaCents += cents
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(cents)) bankroll")
        case .grantBankrollFromAnte(let percent):
            let cents = context.anteCents * percent / 100
            resolution.bankrollDeltaCents += cents
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(cents)) (\(percent)% ante)")
        case .grantChips(let amount):
            resolution.chipDelta += amount
            resolution.messages.append("\(modifier.name): +\(amount) Chip\(amount == 1 ? "" : "s")")
        case .grantChipsOnFirstStageTrigger(let amount):
            guard usage.stageUses == 0 else {
                return
            }

            resolution.chipDelta += amount
            resolution.messages.append("\(modifier.name): first trigger +\(amount) Chip\(amount == 1 ? "" : "s")")
        case .gainHeat(let amount):
            resolution.heatDelta += amount
            resolution.messages.append("\(modifier.name): +\(amount) Heat")
        case .reduceHeat(let amount):
            resolution.heatDelta -= amount
            resolution.messages.append("\(modifier.name): -\(amount) Heat")
        case .preventHeat(let optionalAmount):
            guard case .heatGained(let heatAmount) = context.event else {
                return
            }

            let prevented = min(optionalAmount ?? heatAmount, heatAmount)
            resolution.heatPrevented += prevented
            resolution.heatDelta -= prevented
            resolution.messages.append("\(modifier.name): prevented \(prevented) Heat")
        case .revealUpcomingCards(let count):
            addRevealRequest(count: count, includesForecast: false, context: context, modifier: modifier, resolution: &resolution)
        case .revealUpcomingCardsWithForecast(let count):
            addRevealRequest(count: count, includesForecast: true, context: context, modifier: modifier, resolution: &resolution)
        case .burnCards, .moveTopCardToBottom, .moveTopCardDeeper, .addCards, .removeCards:
            resolution.deferredEffects.append(effect)
            resolution.messages.append("\(modifier.name): \(effect.shortDescription)")
        case .adjustBetLimit, .addTableRule, .suppressOpponentTags, .addShopDiscount, .addRerollDiscount, .addModifierSlot,
             .addConsumableCharge:
            resolution.messages.append("\(modifier.name): \(effect.shortDescription)")
        case .payoutMultiplier(let requiredBetType, let percent):
            guard let betType = context.event.betType,
                  let amountCents = context.event.betAmountCents,
                  context.event.trigger == .wagerWon else {
                return
            }

            guard requiredBetType == nil || requiredBetType == betType else {
                return
            }

            let bonus = amountCents * percent / 100
            resolution.payoutBonusCents += bonus
            resolution.bankrollDeltaCents += bonus
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(bonus)) payout bonus (+\(percent)%)")
        case .flatPayoutBonus(let requiredBetType, let cents):
            guard let betType = context.event.betType,
                  context.event.trigger == .wagerWon else {
                return
            }

            guard requiredBetType == nil || requiredBetType == betType else {
                return
            }

            resolution.payoutBonusCents += cents
            resolution.bankrollDeltaCents += cents
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(cents)) payout bonus")
        case .lossRefund(let percent, let maxCents):
            guard let amountCents = context.event.betAmountCents,
                  context.event.trigger == .wagerLost else {
                return
            }

            let rawRefund = amountCents * percent / 100
            let refund = min(rawRefund, maxCents ?? rawRefund)
            resolution.bankrollDeltaCents += refund
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(refund)) loss refund (\(percent)%)")
        case .gainTieCharges(let count):
            resolution.tieChargesDelta += count
            resolution.messages.append("\(modifier.name): +\(count) Tie charge\(count == 1 ? "" : "s")")
        case .levelScaled, .composite:
            break
        case .custom(_, let description):
            resolution.messages.append("\(modifier.name): \(description)")
        }
    }

    private func addRevealRequest(
        count: Int,
        includesForecast: Bool,
        context: ModifierContext,
        modifier: Modifier,
        resolution: inout ModifierResolution
    ) {
        let revealCount = min(max(0, count), context.upcomingCards.count)
        let preview = ShoePreview.make(from: context.upcomingCards, revealedCount: revealCount)
        resolution.revealRequest = ModifierRevealRequest(
            count: revealCount,
            preview: preview,
            includesForecast: includesForecast
        )
        resolution.messages.append("\(modifier.name): revealed \(revealCount) card\(revealCount == 1 ? "" : "s")")
    }
}

private extension ModifierCondition {
    func isSatisfied(by context: ModifierContext, usage: ModifierUsage) -> Bool {
        switch self {
        case .always:
            return true
        case .betType(let expected):
            return context.event.betType == expected
        case .winningSide(let expected):
            return context.event.winningSide == expected
        case .firstPlayerSideWinThisStage:
            return context.stageStats.playerSideWins == 0
        case .firstBankerSideWinThisStage:
            return context.stageStats.bankerSideWins == 0
        case .firstTieLossThisStage:
            return context.stageStats.tieBetLosses == 0
        case .firstWinningBetThisStage:
            return context.stageStats.winningBets == 0
        case .maxLegalBet:
            guard let wagerAmount = context.event.betAmountCents,
                  let maximum = context.legalBetAmountsCents.max() else {
                return false
            }

            return wagerAmount >= maximum
        case .bossStage:
            return context.isBossStage
        case .hasTag(let tag):
            return context.activeTags.contains(tag)
        case .all(let conditions):
            return conditions.allSatisfy { $0.isSatisfied(by: context, usage: usage) }
        case .any(let conditions):
            return conditions.contains { $0.isSatisfied(by: context, usage: usage) }
        }
    }
}

private extension GameEvent {
    var betType: BetType? {
        switch self {
        case .betPlaced(betType: let betType, amountCents: _),
             .wagerWon(betType: let betType, winningSide: _, amountCents: _, basePayoutCents: _),
             .wagerLost(betType: let betType, winningSide: _, amountCents: _):
            return betType
        case .handResolved(let result):
            return result.betType
        default:
            return nil
        }
    }

    var winningSide: BetType? {
        switch self {
        case .wagerWon(betType: _, winningSide: let winningSide, amountCents: _, basePayoutCents: _),
             .wagerLost(betType: _, winningSide: let winningSide, amountCents: _):
            return winningSide
        case .handResolved(let result):
            return result.winner
        default:
            return nil
        }
    }

    var betAmountCents: Int? {
        switch self {
        case .betPlaced(betType: _, amountCents: let amountCents),
             .wagerWon(betType: _, winningSide: _, amountCents: let amountCents, basePayoutCents: _),
             .wagerLost(betType: _, winningSide: _, amountCents: let amountCents):
            return amountCents
        default:
            return nil
        }
    }
}

#if DEBUG
/// Small deterministic smoke tests for the modifier engine.
///
/// These are intentionally model-only and RAM-light. They can be called from a
/// debug menu or a temporary breakpoint without launching a heavy simulator
/// script.
enum ModifierEngineDebugTests {
    static func runAll() -> [String] {
        var notes: [String] = []
        notes.append(testBankerBiasLevelScaling())
        notes.append(testPlayerSurgeAndLuckyChipStageLimits())
        notes.append(testTieInsurance())
        notes.append(testOpeningTellRevealRequest())
        notes.append(testCleanHandsHeatPreventionAndReset())
        return notes
    }

    private static func testBankerBiasLevelScaling() -> String {
        let modifier = requiredModifier("core.banker-bias")
        let instance = ModifierInstance(modifierID: modifier.id, level: 2)
        var engine = ModifierEngine()
        let context = ModifierContext(
            event: .wagerWon(betType: .banker, winningSide: .banker, amountCents: 10_000, basePayoutCents: 19_500),
            stageNumber: 1,
            handNumber: 1,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let result = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(result.first?.payoutBonusCents == 500)
        assert(result.first?.messages.isEmpty == false)
        return "Banker Bias level scaling OK"
    }

    private static func testPlayerSurgeAndLuckyChipStageLimits() -> String {
        let playerSurge = requiredModifier("core.player-surge")
        let luckyChip = requiredModifier("core.lucky-chip")
        let instances = [
            ModifierInstance(modifierID: playerSurge.id, level: 3),
            ModifierInstance(modifierID: luckyChip.id, level: 3)
        ]
        var engine = ModifierEngine()
        let context = ModifierContext(
            event: .wagerWon(betType: .player, winningSide: .player, amountCents: 2_500, basePayoutCents: 5_000),
            stageNumber: 1,
            handNumber: 1,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let first = engine.resolve(event: context.event, modifiers: instances, library: [playerSurge, luckyChip], context: context)
        let second = engine.resolve(event: context.event, modifiers: instances, library: [playerSurge, luckyChip], context: context)
        assert(first.reduce(0) { $0 + $1.bankrollDeltaCents } == 500)
        assert(first.reduce(0) { $0 + $1.chipDelta } == 2)
        assert(second.reduce(0) { $0 + $1.bankrollDeltaCents } == 500)
        assert(second.reduce(0) { $0 + $1.chipDelta } == 1)
        return "Player Surge and Lucky Chip stage limits OK"
    }

    private static func testTieInsurance() -> String {
        let modifier = requiredModifier("core.tie-insurance")
        let instance = ModifierInstance(modifierID: modifier.id, level: 1)
        var engine = ModifierEngine()
        let context = ModifierContext(
            event: .wagerLost(betType: .tie, winningSide: .banker, amountCents: 5_000),
            stageNumber: 1,
            handNumber: 2,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let result = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(result.first?.bankrollDeltaCents == 1_000)
        return "Tie Insurance refund OK"
    }

    private static func testOpeningTellRevealRequest() -> String {
        let modifier = requiredModifier("core.opening-tell")
        let instance = ModifierInstance(modifierID: modifier.id, level: 3)
        var engine = ModifierEngine()
        let cards = [
            Card(suit: .spades, rank: .five),
            Card(suit: .hearts, rank: .seven),
            Card(suit: .clubs, rank: .king),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .spades, rank: .ace)
        ]
        let context = ModifierContext(
            event: .stageStarted(stageNumber: 1),
            stageNumber: 1,
            handNumber: 0,
            anteCents: 2_500,
            availableHeatRoom: 5,
            upcomingCards: cards
        )
        let result = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(result.first?.revealRequest?.count == 2)
        assert(result.first?.revealRequest?.includesForecast == true)
        return "Opening Tell reveal request OK"
    }

    private static func testCleanHandsHeatPreventionAndReset() -> String {
        let modifier = requiredModifier("core.clean-hands")
        let instance = ModifierInstance(modifierID: modifier.id, level: 1)
        var engine = ModifierEngine()
        let context = ModifierContext(
            event: .heatGained(amount: 2),
            stageNumber: 1,
            handNumber: 3,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let first = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        let second = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        engine.resetStage()
        let afterReset = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(first.first?.chipDelta == 1)
        assert(first.first?.heatPrevented == 0)
        assert(second.isEmpty)
        assert(afterReset.first?.chipDelta == 1)
        return "Clean Hands chip trigger and stage reset OK"
    }

    private static func requiredModifier(_ id: String) -> Modifier {
        guard let modifier = Modifier.definition(id: id) else {
            preconditionFailure("Missing debug modifier \(id)")
        }

        return modifier
    }
}
#endif
