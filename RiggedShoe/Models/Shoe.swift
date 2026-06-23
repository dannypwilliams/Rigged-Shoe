import Foundation

enum ShoePreviewDestination: Equatable {
    case playerFirst
    case bankerFirst
    case playerSecond
    case bankerSecond
    case possiblePlayerThird
    case possibleBankerThird
    case futureHand(Int)

    var shortLabel: String {
        switch self {
        case .playerFirst:
            return "P1"
        case .bankerFirst:
            return "B1"
        case .playerSecond:
            return "P2"
        case .bankerSecond:
            return "B2"
        case .possiblePlayerThird:
            return "P3?"
        case .possibleBankerThird:
            return "B3?"
        case .futureHand(let order):
            return "+\(order)"
        }
    }

    var displayName: String {
        switch self {
        case .playerFirst:
            return "Player first card"
        case .bankerFirst:
            return "Banker first card"
        case .playerSecond:
            return "Player second card"
        case .bankerSecond:
            return "Banker second card"
        case .possiblePlayerThird:
            return "Possible Player third"
        case .possibleBankerThird:
            return "Possible Banker third"
        case .futureHand:
            return "Future hand"
        }
    }
}

struct ShoePreviewEntry: Identifiable, Equatable {
    let order: Int
    let card: Card
    let destination: ShoePreviewDestination

    var id: String {
        "\(order)-\(card.id.uuidString)"
    }
}

struct ShoePreview: Equatable {
    let entries: [ShoePreviewEntry]
    let hasNaturalLockout: Bool

    static func make(from cards: [Card], revealedCount: Int) -> ShoePreview {
        let revealedCards = Array(cards.prefix(max(0, revealedCount)))
        let hasNaturalLockout = openingHandsAreNatural(revealedCards)
        return ShoePreview(
            entries: revealedCards.enumerated().map { index, card in
                ShoePreviewEntry(
                    order: index + 1,
                    card: card,
                    destination: destination(for: index, revealedCards: revealedCards, hasNaturalLockout: hasNaturalLockout)
                )
            },
            hasNaturalLockout: hasNaturalLockout
        )
    }

    private static func destination(for index: Int, revealedCards: [Card], hasNaturalLockout: Bool) -> ShoePreviewDestination {
        switch index {
        case 0:
            return .playerFirst
        case 1:
            return .bankerFirst
        case 2:
            return .playerSecond
        case 3:
            return .bankerSecond
        default:
            guard !hasNaturalLockout else {
                return .futureHand(index + 1)
            }

            return dynamicThirdCardDestination(for: index, revealedCards: revealedCards)
        }
    }

    private static func dynamicThirdCardDestination(for index: Int, revealedCards: [Card]) -> ShoePreviewDestination {
        guard revealedCards.count >= 4 else {
            return index == 4 ? .possiblePlayerThird : .possibleBankerThird
        }

        var playerHand = BaccaratHand(cards: [revealedCards[0], revealedCards[2]])
        let bankerHand = BaccaratHand(cards: [revealedCards[1], revealedCards[3]])

        if playerHand.total <= 5 {
            if index == 4 {
                return .possiblePlayerThird
            }

            if revealedCards.indices.contains(4) {
                playerHand.add(revealedCards[4])
                return shouldBankerDraw(bankerTotal: bankerHand.total, playerThirdCard: revealedCards[4]) && index == 5
                    ? .possibleBankerThird
                    : .futureHand(index + 1)
            }

            return index == 5 ? .possibleBankerThird : .futureHand(index + 1)
        }

        if bankerHand.total <= 5, index == 4 {
            return .possibleBankerThird
        }

        return .futureHand(index + 1)
    }

    private static func openingHandsAreNatural(_ cards: [Card]) -> Bool {
        guard cards.count >= 4 else {
            return false
        }

        let playerHand = BaccaratHand(cards: [cards[0], cards[2]])
        let bankerHand = BaccaratHand(cards: [cards[1], cards[3]])
        return playerHand.isNatural || bankerHand.isNatural
    }

    private static func shouldBankerDraw(bankerTotal: Int, playerThirdCard: Card?) -> Bool {
        guard let playerThirdCard else {
            return bankerTotal <= 5
        }

        switch playerThirdCard.baccaratValue {
        case 0...1:
            return bankerTotal <= 3
        case 2...3:
            return bankerTotal <= 4
        case 4...5:
            return bankerTotal <= 5
        case 6...7:
            return bankerTotal <= 6
        case 8:
            return bankerTotal <= 2
        default:
            return bankerTotal <= 3
        }
    }
}

enum RevealPrecision: Equatable {
    case hidden
    case colorOnly
    case rankOnly
    case valueAndSuit
}

enum RevealDestinationKnowledge: Equatable {
    case none
    case maybe
    case exact
}

enum ShoeFavorability: Equatable {
    case noClearEdge
    case lean(BetType)
    case strong(BetType)
    case tieWatch

    var displayText: String {
        switch self {
        case .noClearEdge:
            return "No Clear Edge"
        case .lean(let betType):
            return "Lean: \(betType.displayName)"
        case .strong(let betType):
            return "Strong: \(betType.displayName)"
        case .tieWatch:
            return "Tie Watch"
        }
    }

    var recommendedBet: BetType? {
        switch self {
        case .lean(let betType), .strong(let betType):
            return betType
        case .tieWatch:
            return .tie
        case .noClearEdge:
            return nil
        }
    }
}

struct ShoeRevealConfiguration: Equatable {
    let id: String
    let title: String
    let maxCards: Int
    let precision: RevealPrecision
    let destinationKnowledge: RevealDestinationKnowledge
    let supportsFavorability: Bool
    let chargesPerStage: Int
    let betCapMultiplierWhileActive: Int?
    let obstructedCardIndex: Int?

    var isCharged: Bool {
        chargesPerStage > 0
    }

    var normalizedMaxCards: Int {
        min(max(maxCards, 0), 5)
    }

    var powerScore: Int {
        normalizedMaxCards * 10
            + (supportsFavorability ? 4 : 0)
            + (destinationKnowledge == .exact ? 3 : destinationKnowledge == .maybe ? 1 : 0)
            + (precision == .valueAndSuit ? 3 : precision == .rankOnly ? 2 : precision == .colorOnly ? 1 : 0)
    }

    func reducedByCards(_ count: Int, titleSuffix: String? = nil) -> ShoeRevealConfiguration {
        guard count > 0 else {
            return self
        }

        return ShoeRevealConfiguration(
            id: id,
            title: titleSuffix.map { "\(title) \($0)" } ?? title,
            maxCards: max(0, normalizedMaxCards - count),
            precision: precision,
            destinationKnowledge: destinationKnowledge,
            supportsFavorability: supportsFavorability,
            chargesPerStage: chargesPerStage,
            betCapMultiplierWhileActive: betCapMultiplierWhileActive,
            obstructedCardIndex: obstructedCardIndex
        )
    }

    static let peek = ShoeRevealConfiguration(
        id: "peek",
        title: "Peek",
        maxCards: 1,
        precision: .valueAndSuit,
        destinationKnowledge: .none,
        supportsFavorability: false,
        chargesPerStage: 0,
        betCapMultiplierWhileActive: nil,
        obstructedCardIndex: nil
    )

    static let readTheShoe = ShoeRevealConfiguration(
        id: "read_the_shoe",
        title: "Read the Shoe",
        maxCards: 2,
        precision: .valueAndSuit,
        destinationKnowledge: .maybe,
        supportsFavorability: true,
        chargesPerStage: 0,
        betCapMultiplierWhileActive: nil,
        obstructedCardIndex: nil
    )

    static let smudgedLens = ShoeRevealConfiguration(
        id: "smudged_lens",
        title: "Smudged Lens",
        maxCards: 3,
        precision: .valueAndSuit,
        destinationKnowledge: .maybe,
        supportsFavorability: true,
        chargesPerStage: 0,
        betCapMultiplierWhileActive: nil,
        obstructedCardIndex: 2
    )

    static let bentCorner = ShoeRevealConfiguration(
        id: "bent_corner",
        title: "Bent Corner",
        maxCards: 3,
        precision: .rankOnly,
        destinationKnowledge: .maybe,
        supportsFavorability: false,
        chargesPerStage: 0,
        betCapMultiplierWhileActive: nil,
        obstructedCardIndex: nil
    )

    static let xRay = ShoeRevealConfiguration(
        id: "x_ray_shoe",
        title: "X-Ray",
        maxCards: 3,
        precision: .valueAndSuit,
        destinationKnowledge: .exact,
        supportsFavorability: true,
        chargesPerStage: 2,
        betCapMultiplierWhileActive: 3,
        obstructedCardIndex: nil
    )

    static let fullXRay = ShoeRevealConfiguration(
        id: "full_x_ray",
        title: "Full X-Ray",
        maxCards: 4,
        precision: .valueAndSuit,
        destinationKnowledge: .exact,
        supportsFavorability: true,
        chargesPerStage: 1,
        betCapMultiplierWhileActive: 2,
        obstructedCardIndex: nil
    )

    static func passiveLegacyReveal(count: Int) -> ShoeRevealConfiguration? {
        guard count > 0 else {
            return nil
        }

        if count <= 1 {
            return .peek
        }

        if count == 2 {
            return .readTheShoe
        }

        if count == 3 {
            return .smudgedLens
        }

        let visibleCount = min(count, 5)
        return ShoeRevealConfiguration(
            id: "legacy_read_\(visibleCount)",
            title: "\(visibleCount)-Card Read",
            maxCards: visibleCount,
            precision: .valueAndSuit,
            destinationKnowledge: .maybe,
            supportsFavorability: true,
            chargesPerStage: 0,
            betCapMultiplierWhileActive: nil,
            obstructedCardIndex: nil
        )
    }

    static func chargedLegacyReveal(count: Int, chargesPerStage: Int) -> ShoeRevealConfiguration {
        if count >= 4 {
            return ShoeRevealConfiguration(
                id: "full_x_ray",
                title: "Full X-Ray",
                maxCards: 4,
                precision: .valueAndSuit,
                destinationKnowledge: .exact,
                supportsFavorability: true,
                chargesPerStage: max(1, min(chargesPerStage, 1)),
                betCapMultiplierWhileActive: 2,
                obstructedCardIndex: nil
            )
        }

        return ShoeRevealConfiguration(
            id: "x_ray_shoe",
            title: "X-Ray",
            maxCards: 3,
            precision: .valueAndSuit,
            destinationKnowledge: .exact,
            supportsFavorability: true,
            chargesPerStage: max(1, chargesPerStage),
            betCapMultiplierWhileActive: 3,
            obstructedCardIndex: nil
        )
    }
}

struct ShoeRevealCard: Identifiable, Equatable {
    let orderIndex: Int
    let actualCard: Card?
    let displayedText: String
    let destination: ShoePreviewDestination?
    let destinationKnowledge: RevealDestinationKnowledge
    let precision: RevealPrecision
    let isObstructed: Bool

    var id: String {
        "\(orderIndex)-\(actualCard?.id.uuidString ?? displayedText)"
    }

    var destinationLabel: String? {
        guard let destination else {
            return nil
        }

        switch destinationKnowledge {
        case .none:
            return nil
        case .maybe:
            return destination.shortLabel.replacingOccurrences(of: "?", with: "") + "?"
        case .exact:
            return destination.shortLabel
        }
    }
}

struct ActiveShoeReveal: Equatable {
    let sourceUpgradeId: String
    let title: String
    let maxCards: Int
    let cards: [ShoeRevealCard]
    let supportsFavorability: Bool
    let favorability: ShoeFavorability?
    let remainingHands: Int
    let remainingCharges: Int
    let betCapMultiplierWhileActive: Int?
    let forecast: DealForecast?
    let isSuppressed: Bool
    let lockedReason: String?

    var visibleCardCount: Int {
        isSuppressed ? 0 : min(cards.count, maxCards)
    }

    var statusText: String {
        if isSuppressed {
            return lockedReason ?? "Reveal locked"
        }

        var fragments: [String] = []
        if remainingCharges > 0 {
            let chargeLabel = remainingCharges == 1 ? "1 charge" : "\(remainingCharges) charges"
            fragments.append(chargeLabel)
        }

        if let betCapMultiplierWhileActive {
            fragments.append("cap \(betCapMultiplierWhileActive)x")
        }

        return fragments.isEmpty ? "\(visibleCardCount) card read" : fragments.joined(separator: " · ")
    }

    static func locked(title: String, reason: String) -> ActiveShoeReveal {
        ActiveShoeReveal(
            sourceUpgradeId: "locked",
            title: title,
            maxCards: 0,
            cards: [],
            supportsFavorability: false,
            favorability: nil,
            remainingHands: 0,
            remainingCharges: 0,
            betCapMultiplierWhileActive: nil,
            forecast: nil,
            isSuppressed: true,
            lockedReason: reason
        )
    }

    static func make(
        configuration: ShoeRevealConfiguration,
        previewCards: [Card],
        remainingCharges: Int
    ) -> ActiveShoeReveal {
        let maxCards = configuration.normalizedMaxCards
        let cards = Array(previewCards.prefix(maxCards))
        let preview = ShoePreview.make(from: cards, revealedCount: cards.count)
        let entriesByOrder = Dictionary(uniqueKeysWithValues: preview.entries.map { ($0.order, $0) })
        let revealCards = cards.enumerated().map { index, card in
            revealCard(
                index: index,
                card: card,
                entry: entriesByOrder[index + 1],
                configuration: configuration
            )
        }
        let forecast = configuration.supportsFavorability
            ? DealForecast.make(from: cards)
            : nil

        return ActiveShoeReveal(
            sourceUpgradeId: configuration.id,
            title: configuration.title,
            maxCards: maxCards,
            cards: revealCards,
            supportsFavorability: configuration.supportsFavorability,
            favorability: configuration.supportsFavorability ? favorability(from: forecast, cardCount: cards.count) : nil,
            remainingHands: configuration.isCharged ? 1 : 0,
            remainingCharges: remainingCharges,
            betCapMultiplierWhileActive: configuration.betCapMultiplierWhileActive,
            forecast: forecast,
            isSuppressed: false,
            lockedReason: nil
        )
    }

    private static func revealCard(
        index: Int,
        card: Card,
        entry: ShoePreviewEntry?,
        configuration: ShoeRevealConfiguration
    ) -> ShoeRevealCard {
        let isObstructed = configuration.obstructedCardIndex == index
        let precision = isObstructed ? .hidden : configuration.precision

        return ShoeRevealCard(
            orderIndex: index + 1,
            actualCard: card,
            displayedText: displayedText(for: card, precision: precision),
            destination: entry?.destination,
            destinationKnowledge: isObstructed ? .none : configuration.destinationKnowledge,
            precision: precision,
            isObstructed: isObstructed
        )
    }

    private static func displayedText(for card: Card, precision: RevealPrecision) -> String {
        switch precision {
        case .hidden:
            return "??"
        case .colorOnly:
            return card.suit.isRed ? "Red" : "Black"
        case .rankOnly:
            return "\(card.rank.shortName)?"
        case .valueAndSuit:
            return card.displayText
        }
    }

    private static func favorability(from forecast: DealForecast?, cardCount: Int) -> ShoeFavorability {
        guard let forecast,
              let recommendedBet = forecast.recommendedBet else {
            return .noClearEdge
        }

        if recommendedBet == .tie {
            return .tieWatch
        }

        switch forecast.confidence {
        case .natural, .complete:
            return cardCount >= 4 ? .strong(recommendedBet) : .lean(recommendedBet)
        case .partial:
            return .lean(recommendedBet)
        case .locked:
            return .noClearEdge
        }
    }
}

struct ShoeVisibilityState: Equatable {
    let hiddenDisplayCount: Int
    let activeReveal: ActiveShoeReveal?

    var revealedCards: [ShoeRevealCard] {
        guard let activeReveal,
              !activeReveal.isSuppressed,
              activeReveal.visibleCardCount > 0 else {
            return []
        }

        return Array(activeReveal.cards.prefix(activeReveal.visibleCardCount))
    }

    var isRevealActive: Bool {
        !revealedCards.isEmpty
    }

    var isSuppressed: Bool {
        activeReveal?.isSuppressed == true
    }

    static func hidden(displayCount: Int = 5) -> ShoeVisibilityState {
        ShoeVisibilityState(hiddenDisplayCount: displayCount, activeReveal: nil)
    }
}

struct Shoe: Equatable {
    private(set) var cards: [Card]
    let deckCount: Int

    init(deckCount: Int = 6) {
        var generator: SeededRandomGenerator?
        self.init(deckCount: deckCount, seededGenerator: &generator)
    }

    init(deckCount: Int, seededGenerator: inout SeededRandomGenerator?) {
        self.deckCount = deckCount
        self.cards = Self.makeCards(deckCount: deckCount)
        shuffleCards(&self.cards, seededGenerator: &seededGenerator)
    }

    init(deckCount: Int = 6, cards: [Card]) {
        self.deckCount = deckCount
        self.cards = cards
    }

    mutating func placeCardsOnTop(_ newCards: [Card]) {
        guard !newCards.isEmpty else {
            return
        }

        cards.replaceSubrange(0..<min(newCards.count, cards.count), with: newCards.prefix(cards.count))
    }

    mutating func placeCardsOnBottom(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
    }

    var cardsRemaining: Int {
        cards.count
    }

    func previewCards(limit: Int) -> [Card] {
        Array(cards.prefix(limit))
    }

    mutating func shuffleRemainingCards() {
        cards.shuffle()
    }

    mutating func shuffleRemainingCards(seededGenerator: inout SeededRandomGenerator?) {
        shuffleCards(&cards, seededGenerator: &seededGenerator)
    }

    mutating func addRandomCards(rank: Rank, count: Int) {
        addRandomCards(ranks: [rank], count: count)
    }

    mutating func addRandomCards(ranks: [Rank], count: Int) {
        var generator: SeededRandomGenerator?
        addRandomCards(ranks: ranks, count: count, seededGenerator: &generator)
    }

    mutating func addRandomCards(ranks: [Rank], count: Int, seededGenerator: inout SeededRandomGenerator?) {
        guard count > 0, !ranks.isEmpty else {
            return
        }

        for _ in 0..<count {
            let rank = randomRank(from: ranks, seededGenerator: &seededGenerator)
            let suit = randomSuit(seededGenerator: &seededGenerator)
            cards.append(Card(suit: suit, rank: rank))
        }

        shuffleCards(&cards, seededGenerator: &seededGenerator)
    }

    mutating func addTiePairCards(pairs: Int) {
        var generator: SeededRandomGenerator?
        addTiePairCards(pairs: pairs, seededGenerator: &generator)
    }

    mutating func addTiePairCards(pairs: Int, seededGenerator: inout SeededRandomGenerator?) {
        guard pairs > 0 else {
            return
        }

        for _ in 0..<pairs {
            let rank = randomRank(from: Rank.allCases, seededGenerator: &seededGenerator)
            cards.append(Card(suit: randomSuit(seededGenerator: &seededGenerator), rank: rank))
            cards.append(Card(suit: randomSuit(seededGenerator: &seededGenerator), rank: rank))
        }

        shuffleCards(&cards, seededGenerator: &seededGenerator)
    }

    mutating func addRandomHighValueCards(count: Int) {
        addRandomCards(ranks: [.eight, .nine], count: count)
    }

    mutating func addRandomHighValueCards(count: Int, seededGenerator: inout SeededRandomGenerator?) {
        addRandomCards(ranks: [.eight, .nine], count: count, seededGenerator: &seededGenerator)
    }

    @discardableResult
    mutating func removeRandomZeroValueCards(count: Int) -> Int {
        var generator: SeededRandomGenerator?
        return removeRandomZeroValueCards(count: count, seededGenerator: &generator)
    }

    @discardableResult
    mutating func removeRandomZeroValueCards(count: Int, seededGenerator: inout SeededRandomGenerator?) -> Int {
        guard count > 0 else {
            return 0
        }

        return removeCards(count: count, seededGenerator: &seededGenerator, matching: { $0.baccaratValue == 0 })
    }

    @discardableResult
    mutating func removeRandomFaceCards(count: Int) -> Int {
        var generator: SeededRandomGenerator?
        return removeRandomFaceCards(count: count, seededGenerator: &generator)
    }

    @discardableResult
    mutating func removeRandomFaceCards(count: Int, seededGenerator: inout SeededRandomGenerator?) -> Int {
        guard count > 0 else {
            return 0
        }

        return removeCards(count: count, seededGenerator: &seededGenerator, matching: { [.jack, .queen, .king].contains($0.rank) })
    }

    @discardableResult
    mutating func removeRandomCards(ranks: Set<Rank>, count: Int) -> Int {
        var generator: SeededRandomGenerator?
        return removeRandomCards(ranks: ranks, count: count, seededGenerator: &generator)
    }

    @discardableResult
    mutating func removeRandomCards(ranks: Set<Rank>, count: Int, seededGenerator: inout SeededRandomGenerator?) -> Int {
        guard count > 0, !ranks.isEmpty else {
            return 0
        }

        return removeCards(count: count, seededGenerator: &seededGenerator, matching: { ranks.contains($0.rank) })
    }

    @discardableResult
    mutating func removeAllFaceCards() -> Int {
        let faceIndices = cards.indices
            .filter { [.jack, .queen, .king].contains(cards[$0].rank) }
            .sorted(by: >)

        for index in faceIndices {
            cards.remove(at: index)
        }

        return faceIndices.count
    }

    mutating func draw() -> Card? {
        guard !cards.isEmpty else {
            return nil
        }

        return cards.removeFirst()
    }

    @discardableResult
    mutating func burnTopCard() -> Card? {
        draw()
    }

    mutating func moveTopCardDeeper(positions: Int) -> Bool {
        guard positions > 0, cards.count > 1 else {
            return false
        }

        let card = cards.removeFirst()
        let insertionIndex = min(positions, cards.count)
        cards.insert(card, at: insertionIndex)
        return true
    }

    mutating func reshuffle() {
        var generator: SeededRandomGenerator?
        reshuffle(seededGenerator: &generator)
    }

    mutating func reshuffle(seededGenerator: inout SeededRandomGenerator?) {
        cards = Self.makeCards(deckCount: deckCount)
        shuffleCards(&cards, seededGenerator: &seededGenerator)
    }

    private static func makeCards(deckCount: Int) -> [Card] {
        var cards: [Card] = []
        cards.reserveCapacity(deckCount * Suit.allCases.count * Rank.allCases.count)

        for _ in 0..<deckCount {
            for suit in Suit.allCases {
                for rank in Rank.allCases {
                    cards.append(Card(suit: suit, rank: rank))
                }
            }
        }

        return cards
    }

    private func randomSuit(seededGenerator: inout SeededRandomGenerator?) -> Suit {
        if var generator = seededGenerator {
            let suit = Suit.allCases[Int(generator.next() % UInt64(Suit.allCases.count))]
            seededGenerator = generator
            return suit
        }

        return Suit.allCases.randomElement() ?? .spades
    }

    private func randomRank(from ranks: [Rank], seededGenerator: inout SeededRandomGenerator?) -> Rank {
        if var generator = seededGenerator {
            let rank = ranks[Int(generator.next() % UInt64(ranks.count))]
            seededGenerator = generator
            return rank
        }

        return ranks.randomElement() ?? .ace
    }

    private func shuffleCards(_ cards: inout [Card], seededGenerator: inout SeededRandomGenerator?) {
        if var generator = seededGenerator {
            cards = cards.seededShuffled(using: &generator)
            seededGenerator = generator
        } else {
            cards.shuffle()
        }
    }

    @discardableResult
    private mutating func removeCards(
        count: Int,
        seededGenerator: inout SeededRandomGenerator?,
        matching shouldRemove: (Card) -> Bool
    ) -> Int {
        let removableIndices = cards.indices.filter { shouldRemove(cards[$0]) }
        let selectedIndices: [Int]

        if var generator = seededGenerator {
            selectedIndices = Array(removableIndices.seededShuffled(using: &generator).prefix(count)).sorted(by: >)
            seededGenerator = generator
        } else {
            selectedIndices = Array(removableIndices.shuffled().prefix(count)).sorted(by: >)
        }

        for index in selectedIndices {
            cards.remove(at: index)
        }

        return selectedIndices.count
    }
}
