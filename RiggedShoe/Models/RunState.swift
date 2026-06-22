import Foundation

/// High-level phase for the rebuilt roguelite loop.
///
/// The current app still uses `RunManager` and `GameState` for live play. This
/// model is the data-driven target layer for the faster battle -> reward -> shop
/// structure described in the rebuild plan.
enum RunPhase: String, Codable, Equatable {
    case battle
    case stageReward
    case shop
    case bossIntro
    case bossReward
    case runOver
    case victory
}

/// Why a run ended. Keeping this explicit helps analytics, run summaries, and
/// future save migration avoid guessing from partially completed state.
enum RunEndReason: String, Codable, Equatable {
    case bankrollBusted
    case heatMaxed
    case defeatedByBoss
    case finalBossCleared
    case abandoned
}

/// Money and pressure tracked during a single run.
///
/// Bankroll is used at the baccarat table. Chips are the shop currency. Heat is
/// casino suspicion and should eventually become a second survival pressure
/// alongside bankroll. Ante is the current stage economy scale.
struct RunCurrencyState: Codable, Equatable {
    var bankrollCents: Int
    var chips: Int
    var heat: Int
    var heatCapacity: Int
    var ante: Int
    var debtCents: Int?

    init(
        bankrollCents: Int,
        chips: Int,
        heat: Int = 0,
        heatCapacity: Int,
        ante: Int = 1,
        debtCents: Int? = nil
    ) {
        self.bankrollCents = bankrollCents
        self.chips = chips
        self.heat = heat
        self.heatCapacity = max(1, heatCapacity)
        self.ante = max(1, ante)
        self.debtCents = debtCents
    }

    var isBankrupt: Bool {
        bankrollCents <= 0
    }

    var isHeatMaxed: Bool {
        heat >= heatCapacity
    }
}

/// Player-owned state that should travel through battles, rewards, and shops.
///
/// This deliberately keeps baccarat hand resolution elsewhere. The player state
/// knows what the player owns and can spend, not how a baccarat hand resolves.
struct PlayerRunState: Codable, Equatable {
    var startingBankrollCents: Int
    var currencies: RunCurrencyState
    var modifiers: [ModifierInstance]
    var consumables: [Consumable]
    var attachments: [Attachment]
    var bossRelics: [BossRelic]
    var startingContact: StartingContact?
    var boardLimit: Int
    var benchLimit: Int
    var totalHandsPlayed: Int
    var battlesWon: Int
    var bossesDefeated: Int

    init(
        startingBankrollCents: Int,
        currencies: RunCurrencyState,
        modifiers: [ModifierInstance] = [],
        consumables: [Consumable] = [],
        attachments: [Attachment] = [],
        bossRelics: [BossRelic] = [],
        startingContact: StartingContact? = nil,
        boardLimit: Int = 5,
        benchLimit: Int = 3,
        totalHandsPlayed: Int = 0,
        battlesWon: Int = 0,
        bossesDefeated: Int = 0
    ) {
        self.startingBankrollCents = startingBankrollCents
        self.currencies = currencies
        self.modifiers = modifiers
        self.consumables = consumables
        self.attachments = attachments
        self.bossRelics = bossRelics
        self.startingContact = startingContact
        self.boardLimit = boardLimit
        self.benchLimit = benchLimit
        self.totalHandsPlayed = totalHandsPlayed
        self.battlesWon = battlesWon
        self.bossesDefeated = bossesDefeated
    }
}

/// Objective type for a short baccarat battle.
///
/// The rebuilt loop should use these in place of one long profit ladder. The UI
/// can read this enum and show concise battle goals without embedding logic in
/// a SwiftUI view.
enum BattleObjective: Codable, Equatable {
    case surviveHands(count: Int)
    case winHands(count: Int)
    case reachProfit(cents: Int)
    case keepBankrollAbove(cents: Int, hands: Int)
    case winWithModifier(count: Int)
    case defeatOpponent

    var shortDescription: String {
        switch self {
        case .surviveHands(let count):
            return "Survive \(count) hands"
        case .winHands(let count):
            return "Win \(count) bets"
        case .reachProfit(let cents):
            return "Profit \(MoneyFormatter.format(cents))"
        case .keepBankrollAbove(let cents, let hands):
            return "\(hands) hands above \(MoneyFormatter.format(cents))"
        case .winWithModifier(let count):
            return "Win \(count) modifier hand"
        case .defeatOpponent:
            return "Beat the casino"
        }
    }
}

/// State for one short stage/battle in the rebuilt run.
///
/// A stage is intentionally small: roughly 6-10 baccarat hands followed by a
/// reward or shop phase. Boss battles use the same model with `bossState` set.
struct StageState: Identifiable, Codable, Equatable {
    let id: UUID
    var number: Int
    var ante: Int
    var handLimit: Int
    var handsPlayed: Int
    var objective: BattleObjective
    var startingBankrollCents: Int
    var opponent: OpponentState
    var bossState: BossState?
    var tableRules: [TableRule]
    var rewards: [StageReward]
    var isCleared: Bool
    var isFailed: Bool

    init(
        id: UUID = UUID(),
        number: Int,
        ante: Int,
        handLimit: Int,
        handsPlayed: Int = 0,
        objective: BattleObjective,
        startingBankrollCents: Int,
        opponent: OpponentState,
        bossState: BossState? = nil,
        tableRules: [TableRule] = [],
        rewards: [StageReward] = [],
        isCleared: Bool = false,
        isFailed: Bool = false
    ) {
        self.id = id
        self.number = number
        self.ante = max(1, ante)
        self.handLimit = max(1, handLimit)
        self.handsPlayed = max(0, handsPlayed)
        self.objective = objective
        self.startingBankrollCents = startingBankrollCents
        self.opponent = opponent
        self.bossState = bossState
        self.tableRules = tableRules
        self.rewards = rewards
        self.isCleared = isCleared
        self.isFailed = isFailed
    }

    var handsRemaining: Int {
        max(0, handLimit - handsPlayed)
    }

    var isBossStage: Bool {
        bossState != nil
    }
}

/// Top-level saveable run model for the rebuilt roguelite structure.
///
/// This is not wired into the current live game yet. It gives the next phase a
/// stable target so battle pacing, shops, Heat, bosses, and compact modifier
/// engines can be implemented without further bloating `GameViewModel`.
struct RunState: Identifiable, Codable, Equatable {
    let id: UUID
    var seed: UInt64
    var phase: RunPhase
    var currentStageIndex: Int
    var stages: [StageState]
    var player: PlayerRunState
    var shop: ShopState
    var pendingRewards: [StageReward]
    var runStartedAt: Date
    var runEndedAt: Date?
    var endReason: RunEndReason?

    init(
        id: UUID = UUID(),
        seed: UInt64,
        phase: RunPhase = .battle,
        currentStageIndex: Int = 0,
        stages: [StageState],
        player: PlayerRunState,
        shop: ShopState = ShopState(),
        pendingRewards: [StageReward] = [],
        runStartedAt: Date = Date(),
        runEndedAt: Date? = nil,
        endReason: RunEndReason? = nil
    ) {
        self.id = id
        self.seed = seed
        self.phase = phase
        self.currentStageIndex = currentStageIndex
        self.stages = stages
        self.player = player
        self.shop = shop
        self.pendingRewards = pendingRewards
        self.runStartedAt = runStartedAt
        self.runEndedAt = runEndedAt
        self.endReason = endReason
    }

    var currentStage: StageState? {
        guard stages.indices.contains(currentStageIndex) else {
            return nil
        }

        return stages[currentStageIndex]
    }
}

extension RunState {
    /// Creates a small deterministic run for previews, debug menus, and future
    /// simulator wiring. The dummy modifiers intentionally cover vision,
    /// payout, and Heat so the architecture can be exercised without a full
    /// content pass.
    static func sampleDebugRun(seed: UInt64 = 62_201) -> RunState {
        let modifiers = Modifier.sampleDebugPool
        let instances = modifiers.map { ModifierInstance(modifierID: $0.id) }
        let startingBankrollCents = 25_000
        let currencies = RunCurrencyState(
            bankrollCents: startingBankrollCents,
            chips: 3,
            heatCapacity: 8,
            ante: Stage.allStages.first?.ante ?? 25
        )
        let player = PlayerRunState(
            startingBankrollCents: startingBankrollCents,
            currencies: currencies,
            modifiers: instances,
            consumables: [.sampleLuckyCut],
            attachments: [.sampleGoldClip],
            bossRelics: [],
            startingContact: .sampleInsideDealer
        )
        let stages = StageState.sampleTenStageRun(startingBankrollCents: startingBankrollCents)

        return RunState(
            seed: seed,
            phase: .battle,
            stages: stages,
            player: player,
            shop: ShopState.sampleDebugShop(modifiers: modifiers)
        )
    }
}

extension StageState {
    static func sampleTenStageRun(startingBankrollCents: Int) -> [StageState] {
        (1...10).map { stageNumber in
            let liveStage = Stage.allStages.first { $0.id == stageNumber }
            let ante = liveStage?.ante ?? 25
            let anteCents = liveStage?.anteCents ?? 2_500
            let isBoss = [5, 8, 10].contains(stageNumber)
            let boss = isBoss ? BossState.sample(stageNumber: stageNumber) : nil
            let opponent = OpponentState.sample(stageNumber: stageNumber, isBoss: isBoss)

            return StageState(
                number: stageNumber,
                ante: ante,
                handLimit: stageNumber <= 2 ? 6 : min(10, 6 + stageNumber / 2),
                objective: isBoss ? .defeatOpponent : .reachProfit(cents: anteCents),
                startingBankrollCents: startingBankrollCents,
                opponent: opponent,
                bossState: boss,
                tableRules: [
                    .minBet(cents: anteCents),
                    .maxBet(cents: liveStage?.stageMaxBetCents ?? anteCents * 4),
                    .heatGainOnSuspiciousWin(amount: max(1, ante))
                ]
            )
        }
    }
}
