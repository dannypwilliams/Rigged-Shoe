import Foundation

/// Rarity tier for rebuilt modifiers.
///
/// This intentionally mirrors the current upgrade rarity scale while separating
/// the future shop engine from the legacy `UpgradeCard` pool.
enum ModifierRarity: String, CaseIterable, Codable, Equatable {
    case common
    case rare
    case legendary
    case boss

    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .rare:
            return "Rare"
        case .legendary:
            return "Legendary"
        case .boss:
            return "Boss"
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
    case playerWonBet
    case playerLostBet
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
    case playerWonBet(betType: BetType, winningSide: BetType, amountCents: Int, basePayoutCents: Int)
    case playerLostBet(betType: BetType, winningSide: BetType, amountCents: Int)
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
        case .playerWonBet:
            return .playerWonBet
        case .playerLostBet:
            return .playerLostBet
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
    case hasTag(ModifierTag)
    case all([ModifierCondition])
    case any([ModifierCondition])
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
    var attachedIDs: [UUID]

    init(
        id: UUID = UUID(),
        modifierID: String,
        level: Int = 1,
        chargesRemaining: Int? = nil,
        cooldownHandsRemaining: Int = 0,
        isDisabledByBoss: Bool = false,
        attachedIDs: [UUID] = []
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
            triggers: [.playerWonBet],
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
            triggers: [.playerWonBet],
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
            triggers: [.playerLostBet],
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
            summary: "First winning bet each stage creates shop economy.",
            rulesText: "The first time your bet wins each stage, gain Chips. Level 2 also grants bankroll equal to half the ante.",
            rarity: .common,
            tags: [.economy],
            triggers: [.playerWonBet],
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
    var availableHeatRoom: Int
    var stageStats: ModifierStageStats
    var activeTags: Set<ModifierTag>
    var upcomingCards: [Card]

    init(
        event: GameEvent,
        stageNumber: Int,
        handNumber: Int,
        anteCents: Int,
        availableHeatRoom: Int,
        stageStats: ModifierStageStats = ModifierStageStats(),
        activeTags: Set<ModifierTag> = [],
        upcomingCards: [Card] = []
    ) {
        self.event = event
        self.stageNumber = stageNumber
        self.handNumber = handNumber
        self.anteCents = max(0, anteCents)
        self.availableHeatRoom = max(0, availableHeatRoom)
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

    var didChangeState: Bool {
        bankrollDeltaCents != 0
            || payoutBonusCents != 0
            || chipDelta != 0
            || heatDelta != 0
            || heatPrevented != 0
            || tieChargesDelta != 0
            || revealRequest != nil
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
        context: ModifierContext
    ) -> [ModifierResolution] {
        let libraryByID = Dictionary(uniqueKeysWithValues: library.map { ($0.id, $0) })
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
        case .burnCards, .moveTopCardToBottom, .moveTopCardDeeper, .addCards, .removeCards, .adjustBetLimit,
             .addTableRule, .suppressOpponentTags, .addShopDiscount, .addRerollDiscount, .addModifierSlot,
             .addConsumableCharge:
            resolution.messages.append("\(modifier.name): \(effect.shortDescription)")
        case .payoutMultiplier(let requiredBetType, let percent):
            guard case .playerWonBet(betType: let betType, winningSide: _, amountCents: let amountCents, basePayoutCents: _) = context.event else {
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
            guard case .playerWonBet(betType: let betType, winningSide: _, amountCents: _, basePayoutCents: _) = context.event else {
                return
            }

            guard requiredBetType == nil || requiredBetType == betType else {
                return
            }

            resolution.payoutBonusCents += cents
            resolution.bankrollDeltaCents += cents
            resolution.messages.append("\(modifier.name): +\(MoneyFormatter.format(cents)) payout bonus")
        case .lossRefund(let percent, let maxCents):
            guard case .playerLostBet(betType: _, winningSide: _, amountCents: let amountCents) = context.event else {
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
             .playerWonBet(betType: let betType, winningSide: _, amountCents: _, basePayoutCents: _),
             .playerLostBet(betType: let betType, winningSide: _, amountCents: _):
            return betType
        case .handResolved(let result):
            return result.betType
        default:
            return nil
        }
    }

    var winningSide: BetType? {
        switch self {
        case .playerWonBet(betType: _, winningSide: let winningSide, amountCents: _, basePayoutCents: _),
             .playerLostBet(betType: _, winningSide: let winningSide, amountCents: _):
            return winningSide
        case .handResolved(let result):
            return result.winner
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
            event: .playerWonBet(betType: .banker, winningSide: .banker, amountCents: 10_000, basePayoutCents: 19_500),
            stageNumber: 1,
            handNumber: 1,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let result = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(result.first?.payoutBonusCents == 1_800)
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
            event: .playerWonBet(betType: .player, winningSide: .player, amountCents: 2_500, basePayoutCents: 5_000),
            stageNumber: 1,
            handNumber: 1,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let first = engine.resolve(event: context.event, modifiers: instances, library: [playerSurge, luckyChip], context: context)
        let second = engine.resolve(event: context.event, modifiers: instances, library: [playerSurge, luckyChip], context: context)
        assert(first.reduce(0) { $0 + $1.bankrollDeltaCents } == 5_000)
        assert(first.reduce(0) { $0 + $1.chipDelta } == 3)
        assert(second.isEmpty)
        return "Player Surge and Lucky Chip stage limits OK"
    }

    private static func testTieInsurance() -> String {
        let modifier = requiredModifier("core.tie-insurance")
        let instance = ModifierInstance(modifierID: modifier.id, level: 1)
        var engine = ModifierEngine()
        let context = ModifierContext(
            event: .playerLostBet(betType: .tie, winningSide: .banker, amountCents: 5_000),
            stageNumber: 1,
            handNumber: 2,
            anteCents: 2_500,
            availableHeatRoom: 5
        )
        let result = engine.resolve(event: context.event, modifiers: [instance], library: [modifier], context: context)
        assert(result.first?.bankrollDeltaCents == 2_000)
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
        assert(result.first?.revealRequest?.count == 5)
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
        assert(first.first?.heatPrevented == 2)
        assert(second.isEmpty)
        assert(afterReset.first?.heatPrevented == 2)
        return "Clean Hands Heat prevention and stage reset OK"
    }

    private static func requiredModifier(_ id: String) -> Modifier {
        guard let modifier = Modifier.sampleDebugPool.first(where: { $0.id == id }) else {
            preconditionFailure("Missing debug modifier \(id)")
        }

        return modifier
    }
}
#endif
