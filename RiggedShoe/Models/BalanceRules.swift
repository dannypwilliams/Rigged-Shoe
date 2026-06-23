import Foundation

enum BalanceVersion: String, Codable, Equatable {
    case rebalancedV1
}

enum VerticalSliceBalance {
    static let startingBankrollCents = 25_000
    static let startingChips = 3
    static let startingHeat = 0
    static let activeModifierSlots = 5

    static let stage1Hands = 5
    static let stage1MinimumBetCents = 2_500
    static let stage1MaximumBetCents = 7_500
    static let stage1ClearChips = 2
    static let stage1OptionalChallengeMaxHeat = 3
    static let stage1OptionalChallengeChips = 1

    static let stage2Hands = 6
    static let stage2MinimumBetCents = 5_000
    static let stage2MaximumBetCents = 10_000
    static let stage2OptionalChallengeChips = 1

    static let pitBossHeatThreshold = 7
    static let pitBossSkimPercent = 25
    static let pitBossHeatReduction = 2
    static let crackdownBankrollPenaltyDivisor = 10
    static let crackdownHeatReduction = 2
}

enum ModifierAcquisitionClass: String, Codable, Equatable {
    case starter
    case regular
    case capstone
    case retired
    case debugOnly
}

enum BuildArchetype: String, CaseIterable, Codable, Equatable, Hashable {
    case banker
    case player
    case tie
    case vision
    case shoeControl
    case heat
    case economy

    var displayName: String {
        switch self {
        case .banker:
            return "Banker"
        case .player:
            return "Player"
        case .tie:
            return "Tie"
        case .vision:
            return "Vision"
        case .shoeControl:
            return "Shoe Control"
        case .heat:
            return "Heat / High Risk"
        case .economy:
            return "Economy / Comeback"
        }
    }

    var tags: Set<ModifierTag> {
        switch self {
        case .banker:
            return [.banker]
        case .player:
            return [.player]
        case .tie:
            return [.tie]
        case .vision:
            return [.shoeVision]
        case .shoeControl:
            return [.shoeControl, .cardSculpting]
        case .heat:
            return [.heat, .betControl]
        case .economy:
            return [.economy, .comeback]
        }
    }
}

enum VerticalSliceArchetype: String, CaseIterable, Codable, Equatable, Hashable {
    case cardReader = "Card Reader"
    case compScammer = "Comp Scammer"
    case heatGambler = "Heat Gambler"

    var fantasyTag: String {
        switch self {
        case .cardReader:
            return "Reads just enough of the shoe to pick a smarter side."
        case .compScammer:
            return "Turns pushes, losses, and casino freebies into value."
        case .heatGambler:
            return "Converts suspicious pressure into bigger payouts."
        }
    }

    var shortLabel: String {
        rawValue
    }
}

enum HeatBand: String, Codable, Equatable {
    case cool = "Cool"
    case noticed = "Noticed"
    case watched = "Watched"
    case crackdown = "Crackdown"

    static func band(for heat: Int, maxHeat: Int) -> HeatBand {
        switch max(0, heat) {
        case 0...3:
            return .cool
        case 4...6:
            return .noticed
        case 7...9:
            return .watched
        default:
            return .crackdown
        }
    }
}

struct BuildContract: Codable, Equatable, Identifiable {
    var id: BuildArchetype { archetype }
    let archetype: BuildArchetype
    let sourceStage: Int
}

struct StageBalanceProfile: Codable, Equatable {
    let stageID: Int
    let targetFailureBandPercent: ClosedRange<Int>
    let opponentToleranceAntes: Int
    let opponentToleranceDivisor: Int
    let bossPressureScalarPercent: Int

    var targetMidpointPercent: Int {
        (targetFailureBandPercent.lowerBound + targetFailureBandPercent.upperBound) / 2
    }

    func opponentClearToleranceCents(anteCents: Int) -> Int {
        guard opponentToleranceDivisor > 0 else {
            return 0
        }

        return anteCents * opponentToleranceAntes / opponentToleranceDivisor
    }

    static let profiles: [Int: StageBalanceProfile] = [
        1: StageBalanceProfile(stageID: 1, targetFailureBandPercent: 8...12, opponentToleranceAntes: 9, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        2: StageBalanceProfile(stageID: 2, targetFailureBandPercent: 10...15, opponentToleranceAntes: 5, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        3: StageBalanceProfile(stageID: 3, targetFailureBandPercent: 15...20, opponentToleranceAntes: 5, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        4: StageBalanceProfile(stageID: 4, targetFailureBandPercent: 12...18, opponentToleranceAntes: 8, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        5: StageBalanceProfile(stageID: 5, targetFailureBandPercent: 18...24, opponentToleranceAntes: 7, opponentToleranceDivisor: 1, bossPressureScalarPercent: 110),
        6: StageBalanceProfile(stageID: 6, targetFailureBandPercent: 12...18, opponentToleranceAntes: 7, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        7: StageBalanceProfile(stageID: 7, targetFailureBandPercent: 15...20, opponentToleranceAntes: 12, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        8: StageBalanceProfile(stageID: 8, targetFailureBandPercent: 20...25, opponentToleranceAntes: 10, opponentToleranceDivisor: 1, bossPressureScalarPercent: 115),
        9: StageBalanceProfile(stageID: 9, targetFailureBandPercent: 18...24, opponentToleranceAntes: 10, opponentToleranceDivisor: 1, bossPressureScalarPercent: 100),
        10: StageBalanceProfile(stageID: 10, targetFailureBandPercent: 30...38, opponentToleranceAntes: 10, opponentToleranceDivisor: 1, bossPressureScalarPercent: 125)
    ]

    static func profile(for stageID: Int) -> StageBalanceProfile {
        profiles[stageID] ?? StageBalanceProfile(
            stageID: stageID,
            targetFailureBandPercent: 15...20,
            opponentToleranceAntes: 0,
            opponentToleranceDivisor: 1,
            bossPressureScalarPercent: 100
        )
    }
}

struct BalanceMath {
    static let ordinaryProfitBonusCapBasisPoints = 5_000
    static let heatPoweredProfitBonusCapBasisPoints = 7_500
    static let ordinaryRefundCapBasisPoints = 4_000
    static let bossRefundCapBasisPoints = 2_500
    static let tiePayoutCeiling = 12
    static let passiveChipCapPerStage = 3
    static let flatCashCapAntesPerStage = 2

    static func profitBonusCents(baseProfitCents: Int, bonusBasisPoints: [Int], heatPowered: Bool) -> Int {
        let sorted = bonusBasisPoints
            .map { max(0, $0) }
            .sorted(by: >)

        var effectiveBasisPoints = 0
        for (index, value) in sorted.enumerated() {
            switch index {
            case 0:
                effectiveBasisPoints += value
            case 1:
                effectiveBasisPoints += value / 2
            default:
                effectiveBasisPoints += value / 4
            }
        }

        let cap = heatPowered ? heatPoweredProfitBonusCapBasisPoints : ordinaryProfitBonusCapBasisPoints
        return max(0, baseProfitCents) * min(effectiveBasisPoints, cap) / 10_000
    }

    static func combinedRefundCents(lossCents: Int, refundBasisPoints: [Int], isBossHand: Bool) -> Int {
        let cappedInputs = refundBasisPoints.map { min(max(0, $0), 10_000) }
        var retainedBasisPoints = 10_000

        for refund in cappedInputs {
            retainedBasisPoints = retainedBasisPoints * (10_000 - refund) / 10_000
        }

        let combined = 10_000 - retainedBasisPoints
        let cap = isBossHand ? bossRefundCapBasisPoints : ordinaryRefundCapBasisPoints
        return max(0, lossCents) * min(combined, cap) / 10_000
    }
}

struct ActiveModifierCatalog {
    static let balanceVersion: BalanceVersion = .rebalancedV1
    static let normalShopOfferCount = 3

    static let starterIDs = [
        "core.banker-bias",
        "core.player-surge",
        "core.opening-tell",
        "core.tie-insurance",
        "core.lucky-chip",
        "core.clean-hands"
    ]

    static let regularIDs = [
        "banker.commission-dodge",
        "banker.banker-anchor",
        "banker.dealers-nod",
        "banker.banco-press",
        "player.side-step",
        "player.punto-insurance",
        "player.reversal-read",
        "player.player-tempo",
        "tie.tie-whisperer",
        "tie.mirror-bet",
        "tie.split-signal",
        "tie.equalizer",
        "vision.soft-peek",
        "vision.deep-read",
        "vision.pattern-memory",
        "vision.tie-forecast",
        "control.soft-cut",
        "control.slipstream",
        "loaded.add-nine",
        "loaded.marked-nine",
        "heat.low-profile",
        "heat.soft-footsteps",
        "bet.press-edge",
        "bet.high-roller",
        "economy.interest-ledger",
        "economy.comp-points",
        "debt.emergency-marker",
        "debt.last-dollar"
    ]

    static let capstoneIDs = [
        "banker.banker-lock",
        "player.break-pattern",
        "tie.tie-master",
        "vision.third-card-forecast",
        "control.hot-cut",
        "boss.house-crack",
        "boss.boss-bounty"
    ]

    static let activeIDs = starterIDs + regularIDs + capstoneIDs
    static let activeIDSet = Set(activeIDs)
    static let regularIDSet = Set(regularIDs)
    static let starterIDSet = Set(starterIDs)
    static let capstoneIDSet = Set(capstoneIDs)

    private static let classByID: [String: ModifierAcquisitionClass] = {
        var classes: [String: ModifierAcquisitionClass] = [:]
        starterIDs.forEach { classes[$0] = .starter }
        regularIDs.forEach { classes[$0] = .regular }
        capstoneIDs.forEach { classes[$0] = .capstone }
        return classes
    }()

    private static let archetypeByID: [String: BuildArchetype] = [
        "core.banker-bias": .banker,
        "banker.commission-dodge": .banker,
        "banker.banker-anchor": .banker,
        "banker.dealers-nod": .banker,
        "banker.banco-press": .banker,
        "banker.banker-lock": .banker,
        "core.player-surge": .player,
        "player.side-step": .player,
        "player.punto-insurance": .player,
        "player.reversal-read": .player,
        "player.player-tempo": .player,
        "player.break-pattern": .player,
        "core.tie-insurance": .tie,
        "tie.tie-whisperer": .tie,
        "tie.mirror-bet": .tie,
        "tie.split-signal": .tie,
        "tie.equalizer": .tie,
        "tie.tie-master": .tie,
        "core.opening-tell": .vision,
        "vision.soft-peek": .vision,
        "vision.deep-read": .vision,
        "vision.pattern-memory": .vision,
        "vision.tie-forecast": .vision,
        "vision.third-card-forecast": .vision,
        "control.soft-cut": .shoeControl,
        "control.slipstream": .shoeControl,
        "loaded.add-nine": .shoeControl,
        "loaded.marked-nine": .shoeControl,
        "control.hot-cut": .shoeControl,
        "core.clean-hands": .heat,
        "heat.low-profile": .heat,
        "heat.soft-footsteps": .heat,
        "bet.press-edge": .heat,
        "bet.high-roller": .heat,
        "boss.house-crack": .heat,
        "core.lucky-chip": .economy,
        "economy.interest-ledger": .economy,
        "economy.comp-points": .economy,
        "debt.emergency-marker": .economy,
        "debt.last-dollar": .economy,
        "boss.boss-bounty": .economy
    ]

    static func acquisitionClass(for id: String) -> ModifierAcquisitionClass {
        classByID[id] ?? .retired
    }

    static func archetype(for id: String) -> BuildArchetype? {
        archetypeByID[id]
    }

    static func adjacentArchetypes(to archetype: BuildArchetype) -> [BuildArchetype] {
        switch archetype {
        case .banker:
            return [.vision, .economy, .heat]
        case .player:
            return [.vision, .economy, .heat]
        case .tie:
            return [.vision, .shoeControl, .economy]
        case .vision:
            return [.banker, .player, .tie, .shoeControl]
        case .shoeControl:
            return [.vision, .tie, .heat]
        case .heat:
            return [.banker, .player, .shoeControl, .economy]
        case .economy:
            return [.banker, .player, .tie, .heat]
        }
    }

    static func isProductionAvailable(_ id: String) -> Bool {
        activeIDSet.contains(id)
    }

    static func isShopEligible(_ id: String) -> Bool {
        regularIDSet.contains(id)
    }

    static func definition(id: String, in library: [Modifier]) -> Modifier? {
        guard activeIDSet.contains(id),
              let archived = library.first(where: { $0.id == id }) else {
            return nil
        }

        return rebalanced(archived)
    }

    static func activeDefinitions(in library: [Modifier]) -> [Modifier] {
        activeIDs.compactMap { definition(id: $0, in: library) }
    }

    static func starterDefinitions(in library: [Modifier]) -> [Modifier] {
        starterIDs.compactMap { definition(id: $0, in: library) }
    }

    static func regularDefinitions(in library: [Modifier]) -> [Modifier] {
        regularIDs.compactMap { definition(id: $0, in: library) }
    }

    static func capstoneDefinitions(in library: [Modifier]) -> [Modifier] {
        capstoneIDs.compactMap { definition(id: $0, in: library) }
    }

    static func retiredDefinitions(in library: [Modifier]) -> [Modifier] {
        library.filter { !activeIDSet.contains($0.id) }
    }

    static func shopEligibleModifiers(
        in library: [Modifier],
        tier: Int,
        contactBiasTags: Set<ModifierTag>
    ) -> [Modifier] {
        let candidates = regularDefinitions(in: library)
            .filter { $0.minShopTier <= tier }

        guard !contactBiasTags.isEmpty else {
            return candidates
        }

        var weighted = candidates
        for modifier in candidates where !modifier.tags.isDisjoint(with: contactBiasTags) {
            weighted.append(contentsOf: Array(repeating: modifier, count: 2))
        }

        return weighted
    }

    static func productionShopOfferAllowed(_ offer: ShopOffer) -> Bool {
        switch offer.kind {
        case .modifier:
            return isShopEligible(offer.contentID)
        case .consumable, .attachment, .bossRelic:
            return true
        }
    }

    private static func rebalanced(_ source: Modifier) -> Modifier {
        var modifier = source
        let acquisitionClass = acquisitionClass(for: source.id)

        modifier.maxLevel = acquisitionClass == .capstone ? 1 : 3
        modifier.sellValueChips = max(1, source.sellValueChips)

        switch source.id {
        case "core.banker-bias":
            configure(
                &modifier,
                summary: "First Banker wager wins each stage refund the normal commission.",
                rules: "Trigger: wagerWon. Banker wagers only. Level 1/2/3: first 1/2/3 Banker wins each stage receive a 5% profit adjustment, matching standard commission.",
                rarity: .common,
                tags: [.banker, .betControl],
                triggers: [.wagerWon],
                effects: [.payoutMultiplier(betType: .banker, percent: 5)],
                cost: 3,
                tier: 1,
                conditions: [.betType(.banker)],
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "core.player-surge":
            configure(
                &modifier,
                summary: "Player wager wins gain profit and early stage Chips.",
                rules: "Trigger: wagerWon. Player wagers only. Level 1/2/3: +10%/+15%/+20% profit. First successful Player wager each stage grants 1 Chip.",
                rarity: .common,
                tags: [.player, .tempo],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: .player, percent: 10), .grantChipsOnFirstStageTrigger(amount: 1)],
                    level2: [.payoutMultiplier(betType: .player, percent: 15), .grantChipsOnFirstStageTrigger(amount: 1)],
                    level3: [.payoutMultiplier(betType: .player, percent: 20), .grantChipsOnFirstStageTrigger(amount: 1)]
                )],
                cost: 3,
                tier: 1,
                conditions: [.betType(.player)]
            )
        case "core.opening-tell":
            configure(
                &modifier,
                summary: "Stage start reveals exact opening cards.",
                rules: "Trigger: stageStarted. Level 1 reveals 1 exact card. Level 2 reveals 2 exact cards. Level 3 reveals 2 exact cards with forecast text. Information is refreshed at stage start.",
                rarity: .common,
                tags: [.shoeVision],
                triggers: [.stageStarted],
                effects: [.levelScaled(
                    level1: [.revealUpcomingCards(count: 1)],
                    level2: [.revealUpcomingCards(count: 2)],
                    level3: [.revealUpcomingCardsWithForecast(count: 2)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "core.tie-insurance":
            configure(
                &modifier,
                summary: "First failed Tie wager each stage gets a bounded refund.",
                rules: "Trigger: wagerLost. Tie wagers only. Level 1/2/3 refunds 20%/30%/40%. Limit: once per stage.",
                rarity: .common,
                tags: [.tie, .comeback],
                triggers: [.wagerLost],
                effects: [.levelScaled(
                    level1: [.lossRefund(percent: 20, maxCents: nil)],
                    level2: [.lossRefund(percent: 30, maxCents: nil)],
                    level3: [.lossRefund(percent: 40, maxCents: nil)]
                )],
                cost: 2,
                tier: 1,
                conditions: [.betType(.tie)],
                limits: [.perStage(1)]
            )
        case "core.lucky-chip":
            configure(
                &modifier,
                summary: "Winning wagers generate a few capped Chips each stage.",
                rules: "Trigger: wagerWon. Level 1/2/3: first 1/2/3 winning wagers each stage grant 1 Chip each. No bankroll award.",
                rarity: .common,
                tags: [.economy],
                triggers: [.wagerWon],
                effects: [.grantChips(amount: 1)],
                cost: 2,
                tier: 1,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "core.clean-hands":
            configure(
                &modifier,
                summary: "Actual Heat gains create capped Chips instead of immunity.",
                rules: "Trigger: heatGained. Level 1/2/3: first 1/2/3 net Heat gains each stage grant 1 Chip. Does not prevent Heat.",
                rarity: .common,
                tags: [.heat, .economy],
                triggers: [.heatGained],
                effects: [.grantChips(amount: 1)],
                cost: 3,
                tier: 1,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "banker.commission-dodge":
            configure(
                &modifier,
                summary: "Owned Banker commission is lower while this modifier is active.",
                rules: "Passive. Banker commission becomes 4%/3%/2% at levels 1/2/3 after table rules. Cannot make commission negative.",
                rarity: .common,
                tags: [.banker, .economy],
                triggers: [],
                effects: [.addTableRule(.bankerCommission(percent: 4))],
                cost: 3,
                tier: 1
            )
        case "banker.banker-anchor":
            configure(
                &modifier,
                summary: "First failed Banker wager each stage receives a small refund.",
                rules: "Trigger: wagerLost. Banker wagers only. Level 1/2/3 refunds 10%/15%/20%. Limit: once per stage.",
                rarity: .common,
                tags: [.banker, .comeback],
                triggers: [.wagerLost],
                effects: [.levelScaled(
                    level1: [.lossRefund(percent: 10, maxCents: nil)],
                    level2: [.lossRefund(percent: 15, maxCents: nil)],
                    level3: [.lossRefund(percent: 20, maxCents: nil)]
                )],
                cost: 3,
                tier: 1,
                conditions: [.betType(.banker)],
                limits: [.perStage(1)]
            )
        case "banker.dealers-nod":
            configure(
                &modifier,
                summary: "Banker wager wins reveal a short exact read.",
                rules: "Trigger: wagerWon. Banker wagers only. Level 1/2/3: first 1/2/3 Banker wins each stage reveal the next exact card.",
                rarity: .uncommon,
                tags: [.banker, .shoeVision],
                triggers: [.wagerWon],
                effects: [.revealUpcomingCards(count: 1)],
                cost: 4,
                tier: 2,
                conditions: [.betType(.banker)],
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "banker.banco-press":
            configure(
                &modifier,
                summary: "Banker wins receive a bounded press bonus.",
                rules: "Trigger: wagerWon. Banker wagers only. Level 1/2/3: +10%/+15%/+20% profit. Level 3 may trigger twice per stage.",
                rarity: .uncommon,
                tags: [.banker, .betControl],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: .banker, percent: 10)],
                    level2: [.payoutMultiplier(betType: .banker, percent: 15)],
                    level3: [.payoutMultiplier(betType: .banker, percent: 20)]
                )],
                cost: 4,
                tier: 2,
                conditions: [.betType(.banker)],
                limits: [.perStageByLevel(level1: 1, level2: 1, level3: 2)]
            )
        case "banker.banker-lock":
            configure(
                &modifier,
                summary: "Capstone: a Banker wager win can cash a Heat-powered lock.",
                rules: "Trigger: wagerWon. Banker wagers only. Costs 1 committed Heat. +50% profit. Limit: once per stage.",
                rarity: .legendary,
                tags: [.banker, .boss, .heat],
                triggers: [.wagerWon],
                effects: [.payoutMultiplier(betType: .banker, percent: 50)],
                cost: 0,
                tier: 5,
                conditions: [.betType(.banker)],
                limits: [.perStage(1)],
                heatCost: 1
            )
        case "player.side-step":
            configure(
                &modifier,
                summary: "Player wager wins reveal one exact card.",
                rules: "Trigger: wagerWon. Player wagers only. Level 1/2/3: first 1/2/3 Player wins each stage reveal the next exact card.",
                rarity: .common,
                tags: [.player, .shoeVision],
                triggers: [.wagerWon],
                effects: [.revealUpcomingCards(count: 1)],
                cost: 3,
                tier: 1,
                conditions: [.betType(.player)],
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "player.punto-insurance":
            configure(
                &modifier,
                summary: "First failed Player wager each stage receives a small refund.",
                rules: "Trigger: wagerLost. Player wagers only. Level 1/2/3 refunds 10%/15%/20%. Limit: once per stage.",
                rarity: .common,
                tags: [.player, .comeback],
                triggers: [.wagerLost],
                effects: [.levelScaled(
                    level1: [.lossRefund(percent: 10, maxCents: nil)],
                    level2: [.lossRefund(percent: 15, maxCents: nil)],
                    level3: [.lossRefund(percent: 20, maxCents: nil)]
                )],
                cost: 3,
                tier: 1,
                conditions: [.betType(.player)],
                limits: [.perStage(1)]
            )
        case "player.reversal-read":
            configure(
                &modifier,
                summary: "Player wager wins gain a limited reversal bonus.",
                rules: "Trigger: wagerWon. Player wagers only. Level 1/2/3: +10%/+15%/+20% profit. Level 3 may trigger twice per stage.",
                rarity: .uncommon,
                tags: [.player, .comeback],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: .player, percent: 10)],
                    level2: [.payoutMultiplier(betType: .player, percent: 15)],
                    level3: [.payoutMultiplier(betType: .player, percent: 20)]
                )],
                cost: 4,
                tier: 1,
                conditions: [.betType(.player)],
                limits: [.perStageByLevel(level1: 1, level2: 1, level3: 2)]
            )
        case "player.player-tempo":
            configure(
                &modifier,
                summary: "Player wager wins gain a small tempo bonus.",
                rules: "Trigger: wagerWon. Player wagers only. Level 1/2/3: +5%/+15%/+20% profit, bounded by payout caps.",
                rarity: .uncommon,
                tags: [.player, .economy],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: .player, percent: 5)],
                    level2: [.payoutMultiplier(betType: .player, percent: 15)],
                    level3: [.payoutMultiplier(betType: .player, percent: 20)]
                )],
                cost: 4,
                tier: 2,
                conditions: [.betType(.player)]
            )
        case "player.break-pattern":
            configure(
                &modifier,
                summary: "Capstone: a Player wager win can cash a Heat-powered pattern break.",
                rules: "Trigger: wagerWon. Player wagers only. Costs 1 committed Heat. +50% profit. Limit: once per stage.",
                rarity: .legendary,
                tags: [.player, .boss, .heat],
                triggers: [.wagerWon],
                effects: [.payoutMultiplier(betType: .player, percent: 50)],
                cost: 0,
                tier: 5,
                conditions: [.betType(.player)],
                limits: [.perStage(1)],
                heatCost: 1
            )
        case "tie.tie-whisperer":
            configure(
                &modifier,
                summary: "Stage start records a broad Tie tendency signal.",
                rules: "Trigger: stageStarted. Shows a qualitative Tie tendency based on remaining shoe composition, not future order.",
                rarity: .common,
                tags: [.tie, .shoeVision],
                triggers: [.stageStarted],
                effects: [.custom(id: "tie-tendency", description: "Displayed broad Tie tendency from remaining composition.")],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "tie.mirror-bet":
            configure(
                &modifier,
                summary: "First failed Tie wager each stage receives a mirror refund.",
                rules: "Trigger: wagerLost. Tie wagers only. Level 1/2/3 refunds 10%/15%/20%. Limit: once per stage.",
                rarity: .common,
                tags: [.tie, .comeback],
                triggers: [.wagerLost],
                effects: [.levelScaled(
                    level1: [.lossRefund(percent: 10, maxCents: nil)],
                    level2: [.lossRefund(percent: 15, maxCents: nil)],
                    level3: [.lossRefund(percent: 20, maxCents: nil)]
                )],
                cost: 3,
                tier: 1,
                conditions: [.betType(.tie)],
                limits: [.perStage(1)]
            )
        case "tie.split-signal":
            configure(
                &modifier,
                summary: "Tie results reveal exact follow-up information.",
                rules: "Trigger: tieOccurred. Level 1 reveals 1 exact card. Level 2 reveals 2. Level 3 reveals 2 and grants 1 Chip on the first Tie each stage.",
                rarity: .uncommon,
                tags: [.tie, .shoeVision],
                triggers: [.tieOccurred],
                effects: [.levelScaled(
                    level1: [.revealUpcomingCards(count: 1)],
                    level2: [.revealUpcomingCards(count: 2)],
                    level3: [.revealUpcomingCards(count: 2), .grantChipsOnFirstStageTrigger(amount: 1)]
                )],
                cost: 4,
                tier: 2
            )
        case "tie.equalizer":
            configure(
                &modifier,
                summary: "Tie wager payout improves and first Tie win grants a Chip.",
                rules: "Passive. Tie payout increases to 9:1/10:1/11:1 by level, capped at 12:1. Trigger: wagerWon on Tie grants 1 Chip once per stage.",
                rarity: .rare,
                tags: [.tie, .economy],
                triggers: [.wagerWon],
                effects: [.grantChipsOnFirstStageTrigger(amount: 1)],
                cost: 5,
                tier: 2,
                conditions: [.betType(.tie)]
            )
        case "tie.tie-master":
            configure(
                &modifier,
                summary: "Capstone: Tie payout ceiling reaches 12:1.",
                rules: "Passive capstone. Tie payout gains +1 and remains capped at 12:1. No automatic Tie manipulation.",
                rarity: .legendary,
                tags: [.tie, .economy, .boss],
                triggers: [],
                effects: [.addTableRule(.tiePayout(multiplier: 9))],
                cost: 0,
                tier: 5
            )
        case "vision.soft-peek":
            configure(
                &modifier,
                summary: "Stage start reveals a small exact opening read.",
                rules: "Trigger: stageStarted. Level 1 reveals 1 exact card. Level 2 reveals 1 exact card with forecast text. Level 3 reveals 2 exact cards.",
                rarity: .common,
                tags: [.shoeVision],
                triggers: [.stageStarted],
                effects: [.levelScaled(
                    level1: [.revealUpcomingCards(count: 1)],
                    level2: [.revealUpcomingCardsWithForecast(count: 1)],
                    level3: [.revealUpcomingCards(count: 2)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "vision.deep-read":
            configure(
                &modifier,
                summary: "Before betting, reveal exact cards once per stage.",
                rules: "Trigger: beforeBet. Level 1 reveals 1 exact card. Level 2 reveals 2. Level 3 reveals 2 with forecast text. Limit: once per stage.",
                rarity: .rare,
                tags: [.shoeVision],
                triggers: [.beforeBet],
                effects: [.levelScaled(
                    level1: [.revealUpcomingCards(count: 1)],
                    level2: [.revealUpcomingCards(count: 2)],
                    level3: [.revealUpcomingCardsWithForecast(count: 2)]
                )],
                cost: 5,
                tier: 3,
                limits: [.perStage(1)]
            )
        case "vision.pattern-memory":
            configure(
                &modifier,
                summary: "After hands resolve, logs broad composition memory.",
                rules: "Trigger: handResolved. Level 1/2/3: first 1/2/3 hands each stage show broad composition of the next 6 cards without order.",
                rarity: .uncommon,
                tags: [.shoeVision, .economy],
                triggers: [.handResolved],
                effects: [.custom(id: "pattern-memory", description: "Displayed broad unordered composition of the next 6 cards.")],
                cost: 4,
                tier: 2,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "vision.tie-forecast":
            configure(
                &modifier,
                summary: "Before betting, logs a qualitative Tie likelihood forecast.",
                rules: "Trigger: beforeBet. Level 1/2/3: first 1/2/3 uses each stage show qualitative Tie likelihood, not exact cards.",
                rarity: .rare,
                tags: [.shoeVision, .tie],
                triggers: [.beforeBet],
                effects: [.custom(id: "tie-forecast", description: "Displayed qualitative Tie likelihood forecast.")],
                cost: 5,
                tier: 3,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 3)]
            )
        case "vision.third-card-forecast":
            configure(
                &modifier,
                summary: "Capstone: a Heat-paid deep third-card forecast.",
                rules: "Trigger: beforeBet. Costs 2 committed Heat. Reveals the next four initial deal cards with forecast text. Limit: once per stage.",
                rarity: .legendary,
                tags: [.shoeVision, .boss, .heat],
                triggers: [.beforeBet],
                effects: [.revealUpcomingCardsWithForecast(count: 4)],
                cost: 0,
                tier: 5,
                limits: [.perStage(1)],
                heatCost: 2
            )
        case "control.soft-cut":
            configure(
                &modifier,
                summary: "Before dealing, displace the top card once per stage.",
                rules: "Trigger: beforeDeal. Level 1 moves the top card to bottom. Level 2/3 move it 2 positions deeper. Limit: once per stage.",
                rarity: .common,
                tags: [.shoeControl],
                triggers: [.beforeDeal],
                effects: [.levelScaled(
                    level1: [.moveTopCardToBottom],
                    level2: [.moveTopCardDeeper(positions: 2)],
                    level3: [.moveTopCardDeeper(positions: 2)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "control.slipstream":
            configure(
                &modifier,
                summary: "Before dealing, reveal after a displacement window.",
                rules: "Trigger: beforeDeal. Level 1 reveals 1 exact card. Level 2 reveals 2. Level 3 reveals 2 with forecast text. Limit: once per stage.",
                rarity: .rare,
                tags: [.shoeControl, .shoeVision],
                triggers: [.beforeDeal],
                effects: [.levelScaled(
                    level1: [.revealUpcomingCards(count: 1)],
                    level2: [.revealUpcomingCards(count: 2)],
                    level3: [.revealUpcomingCardsWithForecast(count: 2)]
                )],
                cost: 5,
                tier: 3,
                limits: [.perStage(1)]
            )
        case "loaded.add-nine":
            configure(
                &modifier,
                summary: "Stage start inserts one 9 into the shoe.",
                rules: "Trigger: stageStarted. Adds one 9 by deterministic shoe logic. Level text narrows intended insertion window for simulation telemetry.",
                rarity: .common,
                tags: [.shoeControl, .cardSculpting],
                triggers: [.stageStarted],
                effects: [.addCards(ranks: [.nine], count: 1)],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "loaded.marked-nine":
            configure(
                &modifier,
                summary: "Stage start pays Heat for a 9-distance read.",
                rules: "Trigger: stageStarted. Costs 1 committed Heat. Displays a 9-location read. Level improves the read. Limit: once per stage.",
                rarity: .uncommon,
                tags: [.shoeControl, .cardSculpting, .shoeVision, .heat],
                triggers: [.stageStarted],
                effects: [.custom(id: "marked-nine", description: "Displayed nearest-9 distance read.")],
                cost: 4,
                tier: 2,
                limits: [.perStage(1)],
                heatCost: 1
            )
        case "control.hot-cut":
            configure(
                &modifier,
                summary: "Capstone: pay Heat to reveal and reorder a tiny top-card window.",
                rules: "Trigger: beforeDeal. Costs 2 committed Heat. Reveals 3 exact cards and requests a top-card cut. Limit: once per stage.",
                rarity: .legendary,
                tags: [.shoeControl, .cardSculpting, .heat, .boss],
                triggers: [.beforeDeal],
                effects: [.revealUpcomingCards(count: 3), .moveTopCardDeeper(positions: 1)],
                cost: 0,
                tier: 5,
                limits: [.perStage(1)],
                heatCost: 2
            )
        case "heat.low-profile":
            configure(
                &modifier,
                summary: "Stage start removes existing Heat.",
                rules: "Trigger: stageStarted. Level 1 removes 1 Heat. Level 2 removes 1. Level 3 removes 2. Cannot reduce below zero.",
                rarity: .common,
                tags: [.heat],
                triggers: [.stageStarted],
                effects: [.levelScaled(
                    level1: [.reduceHeat(amount: 1)],
                    level2: [.reduceHeat(amount: 1)],
                    level3: [.reduceHeat(amount: 2)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "heat.soft-footsteps":
            configure(
                &modifier,
                summary: "First Heat gains each stage are reduced.",
                rules: "Trigger: heatGained. Level 1/2/3: first 1/2/2 Heat gains each stage reduce Heat by 1. No Chip generation.",
                rarity: .common,
                tags: [.heat],
                triggers: [.heatGained],
                effects: [.preventHeat(amount: 1)],
                cost: 3,
                tier: 1,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]
            )
        case "bet.press-edge":
            configure(
                &modifier,
                summary: "Winning wagers receive a limited press bonus.",
                rules: "Trigger: wagerWon. Any wager. Level 1/2/3: +10%/+15%/+20% profit. Level 2/3 can trigger twice per stage.",
                rarity: .uncommon,
                tags: [.betControl, .heat],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: nil, percent: 10)],
                    level2: [.payoutMultiplier(betType: nil, percent: 15)],
                    level3: [.payoutMultiplier(betType: nil, percent: 20)]
                )],
                cost: 4,
                tier: 2,
                limits: [.perStageByLevel(level1: 1, level2: 2, level3: 2)]
            )
        case "bet.high-roller":
            configure(
                &modifier,
                summary: "Maximum legal wager wins can pay a Heat-powered bonus.",
                rules: "Trigger: wagerWon. Maximum legal wager only. Costs 1 committed Heat. Level 1/2/3: +25%/+35%/+50% profit. Limit: once per stage.",
                rarity: .rare,
                tags: [.betControl, .heat],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.payoutMultiplier(betType: nil, percent: 25)],
                    level2: [.payoutMultiplier(betType: nil, percent: 35)],
                    level3: [.payoutMultiplier(betType: nil, percent: 50)]
                )],
                cost: 5,
                tier: 2,
                conditions: [.maxLegalBet],
                limits: [.perStage(1)],
                heatCost: 1
            )
        case "boss.house-crack":
            configure(
                &modifier,
                summary: "Capstone: boss-stage max wager wins can crack the house.",
                rules: "Trigger: wagerWon. Boss stage and maximum legal wager only. Costs 2 committed Heat. +50% profit. Limit: once per boss stage.",
                rarity: .legendary,
                tags: [.boss, .betControl, .heat],
                triggers: [.wagerWon],
                effects: [.payoutMultiplier(betType: nil, percent: 50)],
                cost: 0,
                tier: 5,
                conditions: [.all([.bossStage, .maxLegalBet])],
                limits: [.perStage(1)],
                heatCost: 2
            )
        case "economy.interest-ledger":
            configure(
                &modifier,
                summary: "Stage start grants bounded ante-scaled bankroll.",
                rules: "Trigger: stageStarted. Level 1/2/3: gain 25%/40%/50% of ante. Uses integer cents.",
                rarity: .common,
                tags: [.economy],
                triggers: [.stageStarted],
                effects: [.levelScaled(
                    level1: [.grantBankrollFromAnte(percent: 25)],
                    level2: [.grantBankrollFromAnte(percent: 40)],
                    level3: [.grantBankrollFromAnte(percent: 50)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "economy.comp-points":
            configure(
                &modifier,
                summary: "Winning wagers produce small capped bankroll comps.",
                rules: "Trigger: wagerWon. Level 1/2/3: gain 5%/8%/10% of ante as a compact comp. Limit: three times per stage.",
                rarity: .common,
                tags: [.economy],
                triggers: [.wagerWon],
                effects: [.levelScaled(
                    level1: [.grantBankrollFromAnte(percent: 5)],
                    level2: [.grantBankrollFromAnte(percent: 8)],
                    level3: [.grantBankrollFromAnte(percent: 10)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(3)]
            )
        case "debt.emergency-marker":
            configure(
                &modifier,
                summary: "Low-bankroll stage starts receive a comeback marker.",
                rules: "Trigger: stageStarted. Level 1/2/3: gain 50%/75%/100% ante. Intended threshold: bankroll below 3 antes. Limit: once per stage.",
                rarity: .common,
                tags: [.economy, .comeback],
                triggers: [.stageStarted],
                effects: [.levelScaled(
                    level1: [.grantBankrollFromAnte(percent: 50)],
                    level2: [.grantBankrollFromAnte(percent: 75)],
                    level3: [.grantBankrollFromAnte(percent: 100)]
                )],
                cost: 3,
                tier: 1,
                limits: [.perStage(1)]
            )
        case "debt.last-dollar":
            configure(
                &modifier,
                summary: "Losses near the next table minimum receive one refund.",
                rules: "Trigger: wagerLost. Level 1/2/3 refunds 15%/20%/25%. Limit: once per stage. Cannot create profit.",
                rarity: .uncommon,
                tags: [.economy, .comeback],
                triggers: [.wagerLost],
                effects: [.levelScaled(
                    level1: [.lossRefund(percent: 15, maxCents: nil)],
                    level2: [.lossRefund(percent: 20, maxCents: nil)],
                    level3: [.lossRefund(percent: 25, maxCents: nil)]
                )],
                cost: 4,
                tier: 2,
                limits: [.perStage(1)]
            )
        case "boss.boss-bounty":
            configure(
                &modifier,
                summary: "Capstone: boss defeats pay a measured bounty.",
                rules: "Trigger: bossDefeated. Gain 1 current-stage ante and 3 Chips. Records value on final boss defeat.",
                rarity: .legendary,
                tags: [.boss, .economy],
                triggers: [.bossDefeated],
                effects: [.grantBankrollFromAnte(percent: 100), .grantChips(amount: 3)],
                cost: 0,
                tier: 5
            )
        default:
            break
        }

        return modifier
    }

    private static func configure(
        _ modifier: inout Modifier,
        summary: String,
        rules: String,
        rarity: ModifierRarity,
        tags: Set<ModifierTag>,
        triggers: Set<ModifierTrigger>,
        effects: [ModifierEffect],
        cost: Int,
        tier: Int,
        conditions: [ModifierCondition] = [.always],
        limits: [ModifierUseLimit] = [],
        heatCost: Int = 0
    ) {
        modifier.summary = summary
        modifier.rulesText = rules
        modifier.rarity = rarity
        modifier.tags = tags
        modifier.triggers = triggers
        modifier.effects = effects
        modifier.baseCostChips = max(0, cost)
        modifier.sellValueChips = max(1, cost / 2)
        modifier.minShopTier = min(max(1, tier), 5)
        modifier.conditions = conditions
        modifier.useLimits = limits
        modifier.heatCost = max(0, heatCost)
        modifier.battleLogText = rules
    }
}

extension Modifier {
    static var productionContent: [Modifier] {
        ActiveModifierCatalog.activeDefinitions(in: allContent)
    }

    static var productionShopContent: [Modifier] {
        ActiveModifierCatalog.regularDefinitions(in: allContent)
    }
}
