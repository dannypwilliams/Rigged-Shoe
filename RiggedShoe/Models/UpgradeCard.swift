import Foundation

enum UpgradeRarity: String, CaseIterable, Codable {
    case common
    case rare
    case legendary

    var displayName: String {
        rawValue.capitalized
    }

    static func weightedRandom(using seededGenerator: inout SeededRandomGenerator?) -> UpgradeRarity {
        let roll: Int

        if var generator = seededGenerator {
            roll = Int(generator.next() % 100) + 1
            seededGenerator = generator
        } else {
            roll = Int.random(in: 1...100)
        }

        switch roll {
        case 1...70:
            return .common
        case 71...95:
            return .rare
        default:
            return .legendary
        }
    }

    static func weightedRandom() -> UpgradeRarity {
        var generator: SeededRandomGenerator?
        return weightedRandom(using: &generator)
    }
}

enum UpgradeEffect: Equatable {
    case addExtraNines(count: Int)
    case addExtraEights(count: Int)
    case addCards(rank: Rank, count: Int)
    case addRandomCards(ranks: [Rank], count: Int)
    case addTiePairCards(pairs: Int)
    case removeZeroValueCards(count: Int)
    case removeCards(ranks: [Rank], count: Int)
    case playerWinBonus(cents: Int)
    case bankerWinBonus(cents: Int)
    case chosenBetWinBonus(cents: Int)
    case forecastWinBonus(cents: Int)
    case improveTiePayout(multiplier: Int)
    case tiePayoutBonus(amount: Int)
    case shoeReveal(ShoeRevealConfiguration)
    case revealCards(count: Int)
    case limitedXRayReveal(count: Int, chargesPerStage: Int)
    case revealAfterRound(count: Int)
    case noCommission
    case hotShoe(extraEights: Int, extraNines: Int)
    case coldShoe(removeZeroValueCards: Int)
    case profitMultiplier(betType: BetType?, percent: Int)
    case lossMultiplier(percent: Int)
    case lossRebatePercent(percent: Int)
    case roundStipend(cents: Int)
    case stageStartCash(cents: Int)
    case cardExitIncome(centsPerCard: Int)
    case streakBonus(betType: BetType?, centsPerWin: Int)
    case firstTieEachStageMultiplier(multiplier: Int)
    case consecutiveTiePayoutBonus(amount: Int)
    case previousLossRefundOnTie(percent: Int)
    case bossStageCash(cents: Int)
    case safetyNet(thresholdPercent: Int, cents: Int)
    case smallBetWinMultiplier(maxBetCents: Int, percent: Int)
    case smallBetStreakBonus(maxBetCents: Int, requiredWins: Int, cents: Int)
    case pressAfterWinMultiplier(percent: Int)
    case lossRebateEveryHands(percent: Int, everyHands: Int)
    case burnCardEveryHands(interval: Int)
    case moveTopCardDeeper(positions: Int)
    case bankerInitialTotalBonus(minTotal: Int, maxTotal: Int, cents: Int)
    case firstNaturalEachStageBonus(cents: Int)
    case comebackWinBonus(lossCount: Int, cents: Int)
    case firstLargeBetStageMultiplier(minBetCents: Int, percent: Int)
    case steadyBetWinBonus(cents: Int)
    case raiseWinBonus(minRaiseCents: Int, cents: Int)
    indirect case combined([UpgradeEffect])
}

struct UpgradeCard: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let rarity: UpgradeRarity
    let effect: UpgradeEffect
    let tags: Set<UpgradeTag>

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        rarity: UpgradeRarity,
        effect: UpgradeEffect,
        tags: Set<UpgradeTag>
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.rarity = rarity
        self.effect = effect

        if rarity == .legendary {
            self.tags = tags.union([.legendary])
        } else {
            self.tags = tags
        }
    }

    func copyForAcquisition() -> UpgradeCard {
        UpgradeCard(name: name, description: description, rarity: rarity, effect: effect, tags: tags)
    }

    static var allCards: [UpgradeCard] {
        baseCards
            + tieHunterCards
            + cardCounterCards
            + loadedShoeCards
            + bankerKingCards
            + playerAdvocateCards
            + highRollerCards
            + economyCards
            + bossTechCards
            + legendaryCards
    }

    static func randomChoices(
        count: Int = 3,
        availableCards: [UpgradeCard] = UpgradeCard.allCards
    ) -> [UpgradeCard] {
        var generator: SeededRandomGenerator?
        return randomChoices(count: count, availableCards: availableCards, seededGenerator: &generator)
    }

    static func randomChoices(
        count: Int = 3,
        availableCards: [UpgradeCard] = UpgradeCard.allCards,
        seededGenerator: inout SeededRandomGenerator?,
        acquiredCards: [UpgradeCard] = []
    ) -> [UpgradeCard] {
        var choices: [UpgradeCard] = []
        var usedNames = Set<String>()
        let lowValueDuplicateNames = Set(acquiredCards.filter(\.isLowValueDuplicate).map(\.name))
        var attempts = 0

        while choices.count < count && attempts < 160 {
            attempts += 1
            let rarity = UpgradeRarity.weightedRandom(using: &seededGenerator)
            let pool = availableCards.filter {
                $0.rarity == rarity
                    && !usedNames.contains($0.name)
                    && !lowValueDuplicateNames.contains($0.name)
            }

            if let choice = randomElement(from: pool, seededGenerator: &seededGenerator) {
                choices.append(choice)
                usedNames.insert(choice.name)
            }
        }

        if choices.count < count {
            for card in shuffled(availableCards, seededGenerator: &seededGenerator) where !usedNames.contains(card.name) && !lowValueDuplicateNames.contains(card.name) {
                choices.append(card)
                usedNames.insert(card.name)

                if choices.count == count {
                    break
                }
            }
        }

        if choices.count < count {
            for card in shuffled(availableCards, seededGenerator: &seededGenerator) where !usedNames.contains(card.name) {
                choices.append(card)
                usedNames.insert(card.name)

                if choices.count == count {
                    break
                }
            }
        }

        return choices
    }

    static func randomCard(
        rarity: UpgradeRarity,
        availableCards: [UpgradeCard] = UpgradeCard.allCards
    ) -> UpgradeCard? {
        var generator: SeededRandomGenerator?
        return randomCard(rarity: rarity, availableCards: availableCards, seededGenerator: &generator)
    }

    static func randomCard(
        rarity: UpgradeRarity,
        availableCards: [UpgradeCard] = UpgradeCard.allCards,
        seededGenerator: inout SeededRandomGenerator?
    ) -> UpgradeCard? {
        randomElement(from: availableCards.filter { $0.rarity == rarity }, seededGenerator: &seededGenerator)
    }

    private static func card(
        _ name: String,
        _ description: String,
        _ rarity: UpgradeRarity,
        _ effect: UpgradeEffect,
        _ tags: Set<UpgradeTag>
    ) -> UpgradeCard {
        UpgradeCard(name: name, description: description, rarity: rarity, effect: effect, tags: tags)
    }

    private static func randomElement(from cards: [UpgradeCard], seededGenerator: inout SeededRandomGenerator?) -> UpgradeCard? {
        if var generator = seededGenerator {
            let element = cards.seededRandomElement(using: &generator)
            seededGenerator = generator
            return element
        }

        return cards.randomElement()
    }

    private static func shuffled(_ cards: [UpgradeCard], seededGenerator: inout SeededRandomGenerator?) -> [UpgradeCard] {
        if var generator = seededGenerator {
            let shuffledCards = cards.seededShuffled(using: &generator)
            seededGenerator = generator
            return shuffledCards
        }

        return cards.shuffled()
    }

    var isLowValueDuplicate: Bool {
        !effect.hasMeaningfulDuplicateValue
    }
}

private extension UpgradeEffect {
    var hasMeaningfulDuplicateValue: Bool {
        switch self {
        case .combined(let effects):
            return effects.contains { $0.hasMeaningfulDuplicateValue }
        case .shoeReveal,
             .revealCards,
             .limitedXRayReveal,
             .noCommission,
             .improveTiePayout,
             .burnCardEveryHands,
             .moveTopCardDeeper:
            return false
        case .addExtraNines,
             .addExtraEights,
             .addCards,
             .addRandomCards,
             .addTiePairCards,
             .removeZeroValueCards,
             .removeCards,
             .playerWinBonus,
             .bankerWinBonus,
             .chosenBetWinBonus,
             .forecastWinBonus,
             .tiePayoutBonus,
             .revealAfterRound,
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
             .bankerInitialTotalBonus,
             .firstNaturalEachStageBonus,
             .comebackWinBonus,
             .firstLargeBetStageMultiplier,
             .steadyBetWinBonus,
             .raiseWinBonus:
            return true
        }
    }
}

extension UpgradeCard {
    private static var baseCards: [UpgradeCard] {
        [
            card("Nine Syndicate", "Adds four 9s to the shoe.", .common, .addExtraNines(count: 4), [.shoe]),
            card("Eight Stack", "Adds four 8s to the shoe.", .common, .addExtraEights(count: 4), [.shoe]),
            card("Face Card Purge", "Removes eight zero-value cards.", .common, .removeZeroValueCards(count: 8), [.shoe]),
            card("Safety Net", "Comeback: Once per stage, dropping below the stage safety line grants $10.", .common, .safetyNet(thresholdPercent: 80, cents: 1_000), [.economy, .conservative, .comeback]),
            card("Conservative Edge", "Conservative: Minimum-bet wins pay +50% profit, turning a $10 win into +$15.", .common, .smallBetWinMultiplier(maxBetCents: 1_000, percent: 150), [.economy, .conservative]),
            card("Small Ball", "Conservative: Win 3 hands in a row while betting $10 to gain $25.", .common, .smallBetStreakBonus(maxBetCents: 1_000, requiredWins: 3, cents: 2_500), [.streak, .conservative, .economy]),
            card("Press the Advantage", "Aggressive: After a win, increase your next bet for +15% profit on a win.", .common, .pressAfterWinMultiplier(percent: 115), [.aggressive, .risk, .streak]),
            card("Damage Control", "Comeback: Losing refunds half of the bet once every 3 hands.", .common, .lossRebateEveryHands(percent: 50, everyHands: 3), [.comeback, .economy]),
            card("Peek", "Reveal the next 1 card. Shows value only, with no prediction or bet cap.", .common, .shoeReveal(.peek), [.reveal, .shoe]),
            card("Read the Shoe", "Reveal the next 2 cards with light destination hints. Useful, but still incomplete.", .common, .shoeReveal(.readTheShoe), [.reveal, .shoe]),
            card("Smudged Lens", "Reveal 3 upcoming cards, but one card is intentionally obscured. Shows a cautious table lean.", .common, .shoeReveal(.smudgedLens), [.reveal, .shoe]),
            card("Bent Corner", "Reveal 3 upcoming ranks without suits. Helpful information, not a full answer.", .common, .shoeReveal(.bentCorner), [.reveal, .shoe]),
            card("X-Ray Shoe", "Rare charged read. Gain 2 charges each stage; activate to reveal 3 cards with order and a table lean. Active hands cap bets at 3x minimum.", .rare, .shoeReveal(.xRay), [.reveal, .shoe]),
            card("Opening Tell", "Prediction: Read 2 upcoming cards. If the forecasted bet wins, gain +$10.", .common, .combined([.shoeReveal(.readTheShoe), .forecastWinBonus(cents: 1_000)]), [.reveal, .economy]),
            card("Burn Control", "Shoe Control: Every 5 hands, you may burn the next card before dealing.", .common, .burnCardEveryHands(interval: 5), [.shoe, .reveal]),
            card("Soft Shuffle", "Shoe Control: Once per stage, you may move the next card 3 positions deeper.", .common, .moveTopCardDeeper(positions: 3), [.shoe, .reveal]),
            card("Dealer Pressure", "Dealer Exploit: If Banker's first total is 4, 5, or 6, winning pays +$10.", .common, .bankerInitialTotalBonus(minTotal: 4, maxTotal: 6, cents: 1_000), [.dealerExploit, .economy]),
            card("Face Hunter", "Dealer Exploit: The first natural 8 or 9 each stage grants +$25.", .common, .firstNaturalEachStageBonus(cents: 2_500), [.dealerExploit, .economy]),
            card("Low Roller", "Conservative: Every 2 consecutive wins at $10 or less grants +$10.", .common, .smallBetStreakBonus(maxBetCents: 1_000, requiredWins: 2, cents: 1_000), [.conservative, .streak]),
            card("High Roller Spark", "Aggressive: Your first $200+ bet each stage wins with +20% profit.", .common, .firstLargeBetStageMultiplier(minBetCents: 20_000, percent: 120), [.aggressive, .risk]),
            card("Comeback Chip", "Comeback: After 2 losses in a row, your next win grants +$20.", .common, .comebackWinBonus(lossCount: 2, cents: 2_000), [.comeback, .economy]),
            card("Discipline Bonus", "Conservative: Win without raising from your previous bet to gain +$5.", .common, .steadyBetWinBonus(cents: 500), [.conservative, .economy]),
            card("Aggressive Bonus", "Aggressive: Raise by at least $20 after a hand and win to gain +$15.", .common, .raiseWinBonus(minRaiseCents: 2_000, cents: 1_500), [.aggressive, .risk]),
            card("Player Bonus", "Player wins pay +10% profit plus a $5 floor bonus.", .common, .combined([.profitMultiplier(betType: .player, percent: 110), .playerWinBonus(cents: 500)]), [.player]),
            card("Banker Bonus", "Banker wins pay +10% profit plus a $5 floor bonus.", .common, .combined([.profitMultiplier(betType: .banker, percent: 110), .bankerWinBonus(cents: 500)]), [.banker]),
            card("Safer Ties", "Tie payout improves to 10:1.", .common, .improveTiePayout(multiplier: 10), [.tie]),
            card("Marked Shoe", "Reveal the next 2 cards with light destination hints.", .rare, .shoeReveal(.readTheShoe), [.reveal]),
            card("Deep Read", "Reveal 3 upcoming cards, with one intentionally smudged.", .rare, .shoeReveal(.smudgedLens), [.reveal]),
            card("No Commission", "Banker wins no longer take commission.", .rare, .noCommission, [.banker]),
            card("Tie Hunter", "Tie bets pay 15:1.", .rare, .improveTiePayout(multiplier: 15), [.tie]),
            card("Hot Shoe", "Every shuffle adds extra 8s and 9s.", .rare, .hotShoe(extraEights: 2, extraNines: 2), [.shoe]),
            card("Cold Shoe", "Every shuffle removes zero-value cards.", .rare, .coldShoe(removeZeroValueCards: 8), [.shoe]),
            card("Full X-Ray", "Legendary charged read. Once per stage, reveal 4 cards with order and a table lean. Active hands cap bets at 2x minimum.", .legendary, .shoeReveal(.fullXRay), [.reveal]),
            card("Inside Man", "Gain the Full X-Ray read once each stage.", .legendary, .shoeReveal(.fullXRay), [.reveal]),
            card("Rigged Tie", "Tie bets pay 25:1.", .legendary, .improveTiePayout(multiplier: 25), [.tie]),
            card("Loaded Shoe", "Floods the shoe with 12 extra 9s.", .legendary, .addExtraNines(count: 12), [.shoe])
        ]
    }

    private static var tieHunterCards: [UpgradeCard] {
        [
            card("Tie Magnet", "Adds matched card pairs that slightly encourage ties.", .rare, .addTiePairCards(pairs: 6), [.tie, .shoe]),
            card("Twin Outcome", "The first Tie each stage pays double.", .rare, .firstTieEachStageMultiplier(multiplier: 2), [.tie]),
            card("Tie Fever", "Consecutive Ties add +2 to Tie payout.", .rare, .consecutiveTiePayoutBonus(amount: 2), [.tie, .streak]),
            card("Lucky Push", "Any Tie refunds losses from the previous round.", .rare, .previousLossRefundOnTie(percent: 100), [.tie, .economy]),
            card("Royal Tie", "Tie payout gains +5.", .legendary, .tiePayoutBonus(amount: 5), [.tie]),
            card("Split Decision", "Winning Tie bets pay an extra $40.", .common, .chosenBetWinBonus(cents: 4_000), [.tie, .economy]),
            card("Dead Heat Dividend", "Tie wins pay an extra $100.", .rare, .chosenBetWinBonus(cents: 10_000), [.tie, .economy]),
            card("Balanced Shoe", "Adds ten matched pairs to the shoe.", .rare, .addTiePairCards(pairs: 10), [.tie, .shoe]),
            card("Tie Insurance", "Losses refund 10% of the bet.", .common, .lossRebatePercent(percent: 10), [.tie, .economy]),
            card("Three-Way Trap", "Tie bets pay 15:1.", .rare, .improveTiePayout(multiplier: 15), [.tie]),
            card("Push Prophet", "Reveal +2 cards and gain $12 when your chosen bet wins.", .common, .combined([.revealCards(count: 2), .chosenBetWinBonus(cents: 1_200)]), [.tie, .reveal]),
            card("Equals Sign", "Gain $10 after every round while building toward Tie synergies.", .common, .roundStipend(cents: 1_000), [.tie, .economy])
        ]
    }

    private static var cardCounterCards: [UpgradeCard] {
        [
            card("X-Ray Glasses", "Gain the Full X-Ray read once each stage.", .legendary, .shoeReveal(.fullXRay), [.reveal]),
            card("Dealer Tell", "Reveal +1 more card after every round.", .common, .revealAfterRound(count: 1), [.reveal]),
            card("Pattern Reader", "Prediction: If the forecasted bet wins, gain +$150.", .rare, .forecastWinBonus(cents: 15_000), [.reveal, .economy]),
            card("Known Shoe", "Start each stage with +$60 and Read the Shoe.", .rare, .combined([.stageStartCash(cents: 6_000), .shoeReveal(.readTheShoe)]), [.reveal, .economy]),
            card("Surveillance Map", "Reveal 3 upcoming cards, but one is intentionally obscured.", .rare, .shoeReveal(.smudgedLens), [.reveal]),
            card("Burn Notice", "Gain $1 whenever a card leaves the shoe.", .rare, .cardExitIncome(centsPerCard: 100), [.reveal, .economy]),
            card("Peeker's Edge", "Peek at the next 1 card every hand.", .common, .shoeReveal(.peek), [.reveal]),
            card("Open Index", "Gain the Full X-Ray read once each stage.", .legendary, .shoeReveal(.fullXRay), [.reveal]),
            card("Future Ledger", "Smudged Lens plus $20 when your chosen bet wins.", .rare, .combined([.shoeReveal(.smudgedLens), .chosenBetWinBonus(cents: 2_000)]), [.reveal, .economy]),
            card("Marked Burn Cards", "Gain $2 whenever a card leaves the shoe.", .rare, .cardExitIncome(centsPerCard: 200), [.reveal, .economy]),
            card("Lens Cleaner", "Bent Corner read plus 10% loss reduction.", .common, .combined([.shoeReveal(.bentCorner), .lossRebatePercent(percent: 10)]), [.reveal, .risk]),
            card("Table Whisperer", "Read the Shoe with 2-card destination hints.", .rare, .shoeReveal(.readTheShoe), [.reveal])
        ]
    }

    private static var loadedShoeCards: [UpgradeCard] {
        [
            card("Nine Syndicate+", "Adds 10 extra 9s to the shoe.", .rare, .addExtraNines(count: 10), [.shoe]),
            card("Ace Factory", "Adds 12 extra Aces to the shoe.", .rare, .addCards(rank: .ace, count: 12), [.shoe]),
            card("Weighted Deck", "Adds 16 Aces, 8s, and 9s.", .rare, .addRandomCards(ranks: [.ace, .eight, .nine], count: 16), [.shoe]),
            card("Stacked Shoe", "Every shuffle adds 4 extra 8s and 4 extra 9s.", .rare, .hotShoe(extraEights: 4, extraNines: 4), [.shoe]),
            card("Rigged Shuffle", "Every shuffle adds 5 high cards and removes 5 zero cards.", .legendary, .combined([.hotShoe(extraEights: 5, extraNines: 5), .coldShoe(removeZeroValueCards: 5)]), [.shoe]),
            card("Hot Table", "Every shuffle adds 8 extra 8s.", .rare, .hotShoe(extraEights: 8, extraNines: 0), [.shoe]),
            card("Low Card Mill", "Adds 12 low-value cards.", .common, .addRandomCards(ranks: [.ace, .two, .three], count: 12), [.shoe]),
            card("Face Card Purge+", "Removes 18 zero-value cards.", .rare, .removeZeroValueCards(count: 18), [.shoe]),
            card("Zero Drain", "Removes 24 10/J/Q/K cards.", .legendary, .removeZeroValueCards(count: 24), [.shoe]),
            card("Royal Flush Out", "Removes 24 J/Q/K cards.", .rare, .removeCards(ranks: [.jack, .queen, .king], count: 24), [.shoe]),
            card("Pair Injection", "Adds 12 matched pairs to the shoe.", .rare, .addTiePairCards(pairs: 12), [.shoe, .tie]),
            card("Golden Nines", "Adds 24 extra 9s.", .legendary, .addExtraNines(count: 24), [.shoe]),
            card("Eight Flood", "Adds 24 extra 8s.", .legendary, .addExtraEights(count: 24), [.shoe]),
            card("Shoe Surgeon", "Removes 32 zero-value cards.", .legendary, .removeZeroValueCards(count: 32), [.shoe]),
            card("Loaded Cut Card", "Every shuffle adds 6 8s and 6 9s.", .legendary, .hotShoe(extraEights: 6, extraNines: 6), [.shoe])
        ]
    }

    private static var bankerKingCards: [UpgradeCard] {
        [
            card("House Favorite", "Banker wins pay +15% profit.", .common, .profitMultiplier(betType: .banker, percent: 115), [.banker]),
            card("Commission Refund", "Banker wins pay +$30 and ignore commission.", .rare, .combined([.bankerWinBonus(cents: 3_000), .noCommission]), [.banker, .economy]),
            card("Banker Rush", "Banker streaks pay +$25 per previous Banker win.", .rare, .streakBonus(betType: .banker, centsPerWin: 2_500), [.banker, .streak]),
            card("Banker Dynasty", "Banker streaks pay +$75 per previous Banker win.", .legendary, .streakBonus(betType: .banker, centsPerWin: 7_500), [.banker, .streak]),
            card("Banker Streak", "Banker wins pay +$20.", .common, .bankerWinBonus(cents: 2_000), [.banker]),
            card("Velvet Rope", "Banker wins pay +25% profit.", .rare, .profitMultiplier(betType: .banker, percent: 125), [.banker]),
            card("Dealer's Friend", "Gain $40 on winning Banker bets.", .rare, .bankerWinBonus(cents: 4_000), [.banker, .economy]),
            card("Back Room Deal", "Banker wins ignore commission.", .rare, .noCommission, [.banker]),
            card("Banker's Aura", "Adds 8 extra 9s and gives Banker wins +$20.", .rare, .combined([.addExtraNines(count: 8), .bankerWinBonus(cents: 2_000)]), [.banker, .shoe]),
            card("House Ledger", "Gain $10 after every round.", .common, .roundStipend(cents: 1_000), [.banker, .economy]),
            card("Banker Monopoly", "Banker wins pay +50% profit.", .legendary, .profitMultiplier(betType: .banker, percent: 150), [.banker]),
            card("Commission Ghost", "No commission and Banker wins pay +$250.", .legendary, .combined([.noCommission, .bankerWinBonus(cents: 25_000)]), [.banker, .economy])
        ]
    }

    private static var playerAdvocateCards: [UpgradeCard] {
        [
            card("Player Rush", "Player streaks pay +$25 per previous Player win.", .rare, .streakBonus(betType: .player, centsPerWin: 2_500), [.player, .streak]),
            card("Player Dynasty", "Player streaks pay +$75 per previous Player win.", .legendary, .streakBonus(betType: .player, centsPerWin: 7_500), [.player, .streak]),
            card("Lucky Player", "Player wins pay +$20.", .common, .playerWinBonus(cents: 2_000), [.player]),
            card("Player Momentum", "Player wins pay +20% profit.", .rare, .profitMultiplier(betType: .player, percent: 120), [.player]),
            card("Underdog Edge", "Player wins pay +$40.", .rare, .playerWinBonus(cents: 4_000), [.player, .economy]),
            card("Blue Table", "Player wins pay +25% profit.", .rare, .profitMultiplier(betType: .player, percent: 125), [.player]),
            card("Rebel Shoe", "Adds 10 Aces and gives Player wins +$20.", .rare, .combined([.addCards(rank: .ace, count: 10), .playerWinBonus(cents: 2_000)]), [.player, .shoe]),
            card("Player Coalition", "Player wins pay +$60.", .rare, .playerWinBonus(cents: 6_000), [.player]),
            card("Lucky Cut", "Losses refund 15% while favoring Player builds.", .common, .lossRebatePercent(percent: 15), [.player, .risk]),
            card("Table Hero", "Gain $10 after every round.", .common, .roundStipend(cents: 1_000), [.player, .economy]),
            card("Player Coup", "Player wins pay +50% profit.", .legendary, .profitMultiplier(betType: .player, percent: 150), [.player]),
            card("People's Champion", "Player wins pay +$250.", .legendary, .playerWinBonus(cents: 25_000), [.player, .economy])
        ]
    }

    private static var highRollerCards: [UpgradeCard] {
        [
            card("Double Down", "All wins pay +50% profit, but losses cost 25% extra.", .rare, .combined([.profitMultiplier(betType: nil, percent: 150), .lossMultiplier(percent: 125)]), [.risk]),
            card("Last Chance", "Losses refund 30% of the bet.", .rare, .lossRebatePercent(percent: 30), [.risk, .economy]),
            card("All-In", "All wins pay +150% profit, but losses cost double.", .legendary, .combined([.profitMultiplier(betType: nil, percent: 250), .lossMultiplier(percent: 200)]), [.risk]),
            card("Gambler's Rush", "All win streaks pay +$50 per previous win.", .rare, .streakBonus(betType: nil, centsPerWin: 5_000), [.risk, .streak]),
            card("Glass Cannon", "All wins pay +75% profit, but losses cost 50% extra.", .rare, .combined([.profitMultiplier(betType: nil, percent: 175), .lossMultiplier(percent: 150)]), [.risk]),
            card("High Limit Permit", "Start each stage with +$125.", .rare, .stageStartCash(cents: 12_500), [.risk, .economy]),
            card("Danger Money", "Gain $25 when your chosen bet wins.", .common, .chosenBetWinBonus(cents: 2_500), [.risk, .economy]),
            card("Redline Bet", "All wins pay +30% profit.", .common, .profitMultiplier(betType: nil, percent: 130), [.risk]),
            card("Debt Knife", "Losses cost 50% extra, but gain $75 on wins.", .rare, .combined([.lossMultiplier(percent: 150), .chosenBetWinBonus(cents: 7_500)]), [.risk, .economy]),
            card("No Guts", "All wins pay +40% profit.", .common, .profitMultiplier(betType: nil, percent: 140), [.risk]),
            card("Whale Signal", "Start each stage with +$1,000.", .legendary, .stageStartCash(cents: 100_000), [.risk, .economy]),
            card("Table Breaker", "All wins pay triple profit, losses cost double.", .legendary, .combined([.profitMultiplier(betType: nil, percent: 300), .lossMultiplier(percent: 200)]), [.risk])
        ]
    }

    private static var economyCards: [UpgradeCard] {
        [
            card("VIP Lounge", "Gain $12 after every round.", .common, .roundStipend(cents: 1_200), [.economy]),
            card("Tax Loophole", "Losses refund 25% of the bet.", .rare, .lossRebatePercent(percent: 25), [.economy]),
            card("Lucky Chips", "Gain $20 when your chosen bet wins.", .common, .chosenBetWinBonus(cents: 2_000), [.economy]),
            card("Casino Credit", "Start each stage with +$125.", .rare, .stageStartCash(cents: 12_500), [.economy]),
            card("Comped Drinks", "Gain $8 after every round.", .common, .roundStipend(cents: 800), [.economy]),
            card("Cashback Card", "Losses refund 20% of the bet.", .common, .lossRebatePercent(percent: 20), [.economy]),
            card("Chip Runner", "Gain $2 whenever a card leaves the shoe.", .rare, .cardExitIncome(centsPerCard: 200), [.economy, .shoe]),
            card("Accounting Trick", "Gain $60 when your chosen bet wins.", .rare, .chosenBetWinBonus(cents: 6_000), [.economy]),
            card("Casino Coupon", "Start each stage with +$50.", .common, .stageStartCash(cents: 5_000), [.economy]),
            card("Private Marker", "Gain $25 after every round.", .rare, .roundStipend(cents: 2_500), [.economy]),
            card("Infinite Credit", "Start each stage with +$5,000.", .legendary, .stageStartCash(cents: 500_000), [.economy]),
            card("Money Launderer", "Gain $5 whenever a card leaves the shoe.", .legendary, .cardExitIncome(centsPerCard: 500), [.economy, .shoe])
        ]
    }

    private static var bossTechCards: [UpgradeCard] {
        [
            card("Boss Scout", "Reveal +4 cards and gain $125 when a boss stage begins.", .rare, .combined([.revealCards(count: 4), .bossStageCash(cents: 12_500)]), [.boss, .reveal]),
            card("Pit Bribe", "Gain $200 when a boss stage begins.", .rare, .bossStageCash(cents: 20_000), [.boss, .economy]),
            card("Camera Loop", "Reveal +6 cards against boss pressure.", .rare, .revealCards(count: 6), [.boss, .reveal]),
            card("Emergency Marker", "Losses refund 25% during dangerous runs.", .common, .lossRebatePercent(percent: 25), [.boss, .risk]),
            card("Boss Ledger", "Gain $60 when your chosen bet wins.", .rare, .chosenBetWinBonus(cents: 6_000), [.boss, .economy]),
            card("Security Badge", "Start each stage with +$150.", .rare, .stageStartCash(cents: 15_000), [.boss, .economy])
        ]
    }

    private static var legendaryCards: [UpgradeCard] {
        [
            card("Perfect Information", "Reveal the entire shoe.", .legendary, .revealCards(count: 999), [.reveal]),
            card("Master Counter", "Gain $10 whenever a card leaves the shoe.", .legendary, .cardExitIncome(centsPerCard: 1_000), [.reveal, .economy]),
            card("House Collapse", "Banker commission is permanently disabled and Banker wins pay +$500.", .legendary, .combined([.noCommission, .bankerWinBonus(cents: 50_000)]), [.banker, .economy]),
            card("Royal Flush", "Remove 60 J/Q/K cards from the shoe.", .legendary, .removeCards(ranks: [.jack, .queen, .king], count: 60), [.shoe]),
            card("Golden Parachute", "Losses refund 75% of the bet.", .legendary, .lossRebatePercent(percent: 75), [.economy, .risk]),
            card("Neon Oracle", "Reveal +25 cards and gain $250 when your chosen bet wins.", .legendary, .combined([.revealCards(count: 25), .chosenBetWinBonus(cents: 25_000)]), [.reveal, .economy]),
            card("Tie Singularity", "Tie payout becomes 35:1.", .legendary, .improveTiePayout(multiplier: 35), [.tie]),
            card("Twin Suns", "Adds 25 matched pairs to the shoe.", .legendary, .addTiePairCards(pairs: 25), [.tie, .shoe]),
            card("Dynasty Engine", "All win streaks pay +$150 per previous win.", .legendary, .streakBonus(betType: nil, centsPerWin: 15_000), [.streak]),
            card("Loaded Vault", "Adds 40 random 8s and 9s.", .legendary, .addRandomCards(ranks: [.eight, .nine], count: 40), [.shoe]),
            card("The Whale", "All wins pay +200% profit, losses cost 75% extra.", .legendary, .combined([.profitMultiplier(betType: nil, percent: 300), .lossMultiplier(percent: 175)]), [.risk]),
            card("Black Card", "Gain $300 after every round.", .legendary, .roundStipend(cents: 30_000), [.economy]),
            card("Ghost Commission", "No commission and all Banker profit gains +50%.", .legendary, .combined([.noCommission, .profitMultiplier(betType: .banker, percent: 150)]), [.banker]),
            card("Player Revolution", "All Player profit gains +75%.", .legendary, .profitMultiplier(betType: .player, percent: 175), [.player]),
            card("Red Room Invite", "Start each stage with +$2,500.", .legendary, .stageStartCash(cents: 250_000), [.economy, .risk]),
            card("Dealer's Soul", "Gain $15 whenever a card leaves the shoe.", .legendary, .cardExitIncome(centsPerCard: 1_500), [.reveal, .economy]),
            card("Mathematician", "Reveal +30 cards.", .legendary, .revealCards(count: 30), [.reveal]),
            card("Casino Inside Contact+", "Gain $2,000 when a boss stage begins.", .legendary, .bossStageCash(cents: 200_000), [.boss, .economy]),
            card("Boss Blackmail", "Boss stages start with +$3,000.", .legendary, .bossStageCash(cents: 300_000), [.boss, .risk]),
            card("Final Table", "All wins pay +100% profit.", .legendary, .profitMultiplier(betType: nil, percent: 200), [.risk]),
            card("Crown of Ties", "Consecutive Ties add +5 to Tie payout.", .legendary, .consecutiveTiePayoutBonus(amount: 5), [.tie, .streak]),
            card("Phoenix Marker", "Any Tie refunds 200% of the previous loss.", .legendary, .previousLossRefundOnTie(percent: 200), [.tie, .economy]),
            card("God Shoe", "Every shuffle adds 12 8s and 12 9s.", .legendary, .hotShoe(extraEights: 12, extraNines: 12), [.shoe]),
            card("Negative Space", "Remove 80 zero-value cards.", .legendary, .removeZeroValueCards(count: 80), [.shoe]),
            card("Blue King", "Player wins pay +$1,000.", .legendary, .playerWinBonus(cents: 100_000), [.player, .economy]),
            card("Red King", "Banker wins pay +$1,000.", .legendary, .bankerWinBonus(cents: 100_000), [.banker, .economy]),
            card("Risk Crown", "All wins pay +400% profit, but losses cost triple.", .legendary, .combined([.profitMultiplier(betType: nil, percent: 500), .lossMultiplier(percent: 300)]), [.risk]),
            card("Emerald Engine", "Gain $750 after every round.", .legendary, .roundStipend(cents: 75_000), [.economy]),
            card("Full Surveillance", "Reveal +50 cards.", .legendary, .revealCards(count: 50), [.reveal, .boss]),
            card("The Loaded Contract", "Adds 60 9s.", .legendary, .addExtraNines(count: 60), [.shoe]),
            card("No More House Edge", "No commission, losses refund 50%, and chosen wins gain $500.", .legendary, .combined([.noCommission, .lossRebatePercent(percent: 50), .chosenBetWinBonus(cents: 50_000)]), [.banker, .player, .economy]),
            card("Impossible Ledger", "Start each stage with +$10,000.", .legendary, .stageStartCash(cents: 1_000_000), [.economy]),
            card("Endless Read", "Reveal entire shoe and gain $5 per card leaving shoe.", .legendary, .combined([.revealCards(count: 999), .cardExitIncome(centsPerCard: 500)]), [.reveal, .economy])
        ]
    }
}

struct UpgradeEffectSummary: Equatable {
    var playerWinBonusCents = 0
    var bankerWinBonusCents = 0
    var chosenBetWinBonusCents = 0
    var forecastWinBonusCents = 0
    var tiePayoutMultiplier = 8
    var tiePayoutBonus = 0
    var revealedCards = 0
    var xRayRevealCount = 0
    var xRayChargesPerStage = 0
    var passiveShoeReveal: ShoeRevealConfiguration?
    var chargedShoeReveal: ShoeRevealConfiguration?
    var revealAfterRoundCards = 0
    var removesBankerCommission = false
    var hotShoeExtraEights = 0
    var hotShoeExtraNines = 0
    var coldShoeZeroCardsToRemove = 0
    var allProfitMultiplierPercent = 100
    var playerProfitMultiplierPercent = 100
    var bankerProfitMultiplierPercent = 100
    var tieProfitMultiplierPercent = 100
    var lossMultiplierPercent = 100
    var lossRebatePercent = 0
    var roundStipendCents = 0
    var stageStartCashCents = 0
    var cardExitIncomeCents = 0
    var allStreakBonusCents = 0
    var playerStreakBonusCents = 0
    var bankerStreakBonusCents = 0
    var tieStreakBonusCents = 0
    var firstTieEachStageMultiplier = 1
    var consecutiveTiePayoutBonus = 0
    var previousLossRefundOnTiePercent = 0
    var bossStageCashCents = 0
    var safetyNetThresholdPercent = 0
    var safetyNetCents = 0
    var smallBetMaxCents = 0
    var smallBetWinMultiplierPercent = 100
    var smallBetStreakMaxCents = 0
    var smallBetStreakRequiredWins = 0
    var smallBetStreakBonusCents = 0
    var pressAfterWinMultiplierPercent = 100
    var damageControlRebatePercent = 0
    var damageControlEveryHands = 0
    var burnCardInterval = 0
    var moveTopCardDeeperPositions = 0
    var bankerInitialBonusMinTotal = 0
    var bankerInitialBonusMaxTotal = -1
    var bankerInitialBonusCents = 0
    var firstNaturalEachStageBonusCents = 0
    var comebackLossCount = 0
    var comebackWinBonusCents = 0
    var firstLargeBetMinCents = 0
    var firstLargeBetMultiplierPercent = 100
    var steadyBetWinBonusCents = 0
    var raiseWinMinCents = 0
    var raiseWinBonusCents = 0

    init(upgrades: [UpgradeCard], extraEffects: [UpgradeEffect] = []) {
        for upgrade in upgrades {
            apply(upgrade.effect)
        }

        for effect in extraEffects {
            apply(effect)
        }
    }

    private mutating func apply(_ effect: UpgradeEffect) {
        switch effect {
        case .addExtraNines, .addExtraEights, .addCards, .addRandomCards, .addTiePairCards, .removeZeroValueCards, .removeCards:
            break
        case .combined(let effects):
            for effect in effects {
                apply(effect)
            }
        case .playerWinBonus(let cents):
            playerWinBonusCents += cents
        case .bankerWinBonus(let cents):
            bankerWinBonusCents += cents
        case .chosenBetWinBonus(let cents):
            chosenBetWinBonusCents += cents
        case .forecastWinBonus(let cents):
            forecastWinBonusCents += cents
        case .improveTiePayout(let multiplier):
            tiePayoutMultiplier = max(tiePayoutMultiplier, multiplier)
        case .tiePayoutBonus(let amount):
            tiePayoutBonus += amount
        case .shoeReveal(let configuration):
            registerReveal(configuration)
        case .revealCards(let count):
            revealedCards = max(revealedCards, count)
            if let configuration = ShoeRevealConfiguration.passiveLegacyReveal(count: count) {
                registerReveal(configuration)
            }
        case .limitedXRayReveal(let count, let chargesPerStage):
            xRayRevealCount = max(xRayRevealCount, count)
            xRayChargesPerStage = max(xRayChargesPerStage, chargesPerStage)
            registerReveal(.chargedLegacyReveal(count: count, chargesPerStage: chargesPerStage))
        case .revealAfterRound(let count):
            revealAfterRoundCards += count
        case .noCommission:
            removesBankerCommission = true
        case .hotShoe(let extraEights, let extraNines):
            hotShoeExtraEights += extraEights
            hotShoeExtraNines += extraNines
        case .coldShoe(let removeZeroValueCards):
            coldShoeZeroCardsToRemove += removeZeroValueCards
        case .profitMultiplier(let betType, let percent):
            switch betType {
            case .player:
                playerProfitMultiplierPercent += max(0, percent - 100)
            case .banker:
                bankerProfitMultiplierPercent += max(0, percent - 100)
            case .tie:
                tieProfitMultiplierPercent += max(0, percent - 100)
            case nil:
                allProfitMultiplierPercent += max(0, percent - 100)
            }
        case .lossMultiplier(let percent):
            lossMultiplierPercent += max(0, percent - 100)
        case .lossRebatePercent(let percent):
            lossRebatePercent = max(lossRebatePercent, percent)
        case .roundStipend(let cents):
            roundStipendCents += cents
        case .stageStartCash(let cents):
            stageStartCashCents += cents
        case .cardExitIncome(let centsPerCard):
            cardExitIncomeCents += centsPerCard
        case .streakBonus(let betType, let centsPerWin):
            switch betType {
            case .player:
                playerStreakBonusCents += centsPerWin
            case .banker:
                bankerStreakBonusCents += centsPerWin
            case .tie:
                tieStreakBonusCents += centsPerWin
            case nil:
                allStreakBonusCents += centsPerWin
            }
        case .firstTieEachStageMultiplier(let multiplier):
            firstTieEachStageMultiplier = max(firstTieEachStageMultiplier, multiplier)
        case .consecutiveTiePayoutBonus(let amount):
            consecutiveTiePayoutBonus += amount
        case .previousLossRefundOnTie(let percent):
            previousLossRefundOnTiePercent = max(previousLossRefundOnTiePercent, percent)
        case .bossStageCash(let cents):
            bossStageCashCents += cents
        case .safetyNet(let thresholdPercent, let cents):
            safetyNetThresholdPercent = max(safetyNetThresholdPercent, thresholdPercent)
            safetyNetCents += cents
        case .smallBetWinMultiplier(let maxBetCents, let percent):
            smallBetMaxCents = max(smallBetMaxCents, maxBetCents)
            smallBetWinMultiplierPercent += max(0, percent - 100)
        case .smallBetStreakBonus(let maxBetCents, let requiredWins, let cents):
            smallBetStreakMaxCents = max(smallBetStreakMaxCents, maxBetCents)
            smallBetStreakRequiredWins = smallBetStreakRequiredWins == 0 ? requiredWins : min(smallBetStreakRequiredWins, requiredWins)
            smallBetStreakBonusCents += cents
        case .pressAfterWinMultiplier(let percent):
            pressAfterWinMultiplierPercent += max(0, percent - 100)
        case .lossRebateEveryHands(let percent, let everyHands):
            damageControlRebatePercent = max(damageControlRebatePercent, percent)
            damageControlEveryHands = damageControlEveryHands == 0 ? everyHands : min(damageControlEveryHands, everyHands)
        case .burnCardEveryHands(let interval):
            burnCardInterval = burnCardInterval == 0 ? interval : min(burnCardInterval, interval)
        case .moveTopCardDeeper(let positions):
            moveTopCardDeeperPositions = max(moveTopCardDeeperPositions, positions)
        case .bankerInitialTotalBonus(let minTotal, let maxTotal, let cents):
            if bankerInitialBonusMaxTotal < bankerInitialBonusMinTotal {
                bankerInitialBonusMinTotal = minTotal
                bankerInitialBonusMaxTotal = maxTotal
            } else {
                bankerInitialBonusMinTotal = min(bankerInitialBonusMinTotal, minTotal)
                bankerInitialBonusMaxTotal = max(bankerInitialBonusMaxTotal, maxTotal)
            }
            bankerInitialBonusCents += cents
        case .firstNaturalEachStageBonus(let cents):
            firstNaturalEachStageBonusCents += cents
        case .comebackWinBonus(let lossCount, let cents):
            comebackLossCount = comebackLossCount == 0 ? lossCount : min(comebackLossCount, lossCount)
            comebackWinBonusCents += cents
        case .firstLargeBetStageMultiplier(let minBetCents, let percent):
            firstLargeBetMinCents = firstLargeBetMinCents == 0 ? minBetCents : min(firstLargeBetMinCents, minBetCents)
            firstLargeBetMultiplierPercent += max(0, percent - 100)
        case .steadyBetWinBonus(let cents):
            steadyBetWinBonusCents += cents
        case .raiseWinBonus(let minRaiseCents, let cents):
            raiseWinMinCents = raiseWinMinCents == 0 ? minRaiseCents : min(raiseWinMinCents, minRaiseCents)
            raiseWinBonusCents += cents
        }
    }

    private mutating func registerReveal(_ configuration: ShoeRevealConfiguration) {
        if configuration.isCharged {
            if let existing = chargedShoeReveal {
                chargedShoeReveal = configuration.powerScore > existing.powerScore ? configuration : existing
            } else {
                chargedShoeReveal = configuration
            }

            xRayRevealCount = max(xRayRevealCount, configuration.normalizedMaxCards)
            xRayChargesPerStage = max(xRayChargesPerStage, configuration.chargesPerStage)
            return
        }

        if let existing = passiveShoeReveal {
            passiveShoeReveal = configuration.powerScore > existing.powerScore ? configuration : existing
        } else {
            passiveShoeReveal = configuration
        }

        revealedCards = max(revealedCards, configuration.normalizedMaxCards)
    }

    func profitMultiplierPercent(for betType: BetType) -> Int {
        let specific: Int

        switch betType {
        case .player:
            specific = playerProfitMultiplierPercent
        case .banker:
            specific = bankerProfitMultiplierPercent
        case .tie:
            specific = tieProfitMultiplierPercent
        }

        return max(0, allProfitMultiplierPercent + specific - 100)
    }

    func streakBonusCents(for betType: BetType, streakCount: Int) -> Int {
        let specific: Int

        switch betType {
        case .player:
            specific = playerStreakBonusCents
        case .banker:
            specific = bankerStreakBonusCents
        case .tie:
            specific = tieStreakBonusCents
        }

        return streakCount * (allStreakBonusCents + specific)
    }
}
