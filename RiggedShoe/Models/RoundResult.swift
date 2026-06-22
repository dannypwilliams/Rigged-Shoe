import Foundation

enum DealForecastConfidence: Equatable {
    case locked
    case partial
    case complete
    case natural
}

struct DealForecast: Equatable {
    let confidence: DealForecastConfidence
    let title: String
    let summary: String
    let detail: String
    let recommendedBet: BetType?
    let playerTotal: Int?
    let bankerTotal: Int?

    static func locked(reason: String) -> DealForecast {
        DealForecast(
            confidence: .locked,
            title: "Forecast Locked",
            summary: reason,
            detail: "Reveal information is hidden for this hand.",
            recommendedBet: nil,
            playerTotal: nil,
            bankerTotal: nil
        )
    }

    static func make(from revealedCards: [Card]) -> DealForecast? {
        guard !revealedCards.isEmpty else {
            return nil
        }

        guard revealedCards.count >= 4 else {
            return DealForecast(
                confidence: .partial,
                title: "Partial Read",
                summary: "Need \(4 - revealedCards.count) more card\(revealedCards.count == 3 ? "" : "s") for opening totals.",
                detail: "Revealed cards still show the deal order, but not enough to compare Player and Banker yet.",
                recommendedBet: nil,
                playerTotal: nil,
                bankerTotal: nil
            )
        }

        var playerHand = BaccaratHand(cards: [revealedCards[0], revealedCards[2]])
        var bankerHand = BaccaratHand(cards: [revealedCards[1], revealedCards[3]])
        let openingPlayerTotal = playerHand.total
        let openingBankerTotal = bankerHand.total

        if playerHand.isNatural || bankerHand.isNatural {
            let winner = determineWinner(playerTotal: playerHand.total, bankerTotal: bankerHand.total)
            return DealForecast(
                confidence: .natural,
                title: "Natural Forecast",
                summary: "\(winner.displayName) is locked by a natural.",
                detail: "Opening totals: Player \(openingPlayerTotal), Banker \(openingBankerTotal). No third cards draw.",
                recommendedBet: winner,
                playerTotal: playerHand.total,
                bankerTotal: bankerHand.total
            )
        }

        var nextCardIndex = 4
        var playerThirdCard: Card?

        if playerHand.total <= 5 {
            guard revealedCards.indices.contains(nextCardIndex) else {
                return partialOpeningForecast(
                    playerTotal: openingPlayerTotal,
                    bankerTotal: openingBankerTotal,
                    reason: "Player draws third; P3 is not revealed yet."
                )
            }

            let card = revealedCards[nextCardIndex]
            playerThirdCard = card
            playerHand.add(card)
            nextCardIndex += 1
        }

        if shouldBankerDraw(bankerTotal: bankerHand.total, playerThirdCard: playerThirdCard) {
            guard revealedCards.indices.contains(nextCardIndex) else {
                return partialOpeningForecast(
                    playerTotal: playerHand.total,
                    bankerTotal: bankerHand.total,
                    reason: "Banker draw is still hidden."
                )
            }

            bankerHand.add(revealedCards[nextCardIndex])
        }

        let winner = determineWinner(playerTotal: playerHand.total, bankerTotal: bankerHand.total)
        return DealForecast(
            confidence: .complete,
            title: "Full Forecast",
            summary: "\(winner.displayName) favored if shoe stays unchanged.",
            detail: "Projected totals: Player \(playerHand.total), Banker \(bankerHand.total).",
            recommendedBet: winner,
            playerTotal: playerHand.total,
            bankerTotal: bankerHand.total
        )
    }

    private static func partialOpeningForecast(playerTotal: Int, bankerTotal: Int, reason: String) -> DealForecast {
        let leader: BetType?
        if playerTotal > bankerTotal {
            leader = .player
        } else if bankerTotal > playerTotal {
            leader = .banker
        } else {
            leader = .tie
        }

        return DealForecast(
            confidence: .partial,
            title: "Opening Read",
            summary: "Opening totals: Player \(playerTotal), Banker \(bankerTotal).",
            detail: "\(reason) Current lean: \(leader?.displayName ?? "None").",
            recommendedBet: leader,
            playerTotal: playerTotal,
            bankerTotal: bankerTotal
        )
    }

    private static func shouldBankerDraw(bankerTotal: Int, playerThirdCard: Card?) -> Bool {
        guard let playerThirdCard else {
            return bankerTotal <= 5
        }

        let playerThirdValue = playerThirdCard.baccaratValue

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

    private static func determineWinner(playerTotal: Int, bankerTotal: Int) -> BetType {
        if playerTotal > bankerTotal {
            return .player
        }

        if bankerTotal > playerTotal {
            return .banker
        }

        return .tie
    }
}

struct RoundResult: Identifiable, Equatable {
    let id = UUID()
    let playerHand: BaccaratHand
    let bankerHand: BaccaratHand
    let winner: BetType
    let betType: BetType
    let betAmountCents: Int
    let payoutCents: Int
    let isPush: Bool

    var didWin: Bool {
        !isPush && winner == betType
    }

    var netCents: Int {
        payoutCents - betAmountCents
    }

    var winnerText: String {
        "\(winner.displayName) Wins"
    }

    var betOutcomeText: String {
        if isPush {
            return "Push"
        }

        return didWin ? "Winning Bet" : "Losing Bet"
    }

    func addingPayoutBonus(_ bonusCents: Int) -> RoundResult {
        RoundResult(
            playerHand: playerHand,
            bankerHand: bankerHand,
            winner: winner,
            betType: betType,
            betAmountCents: betAmountCents,
            payoutCents: payoutCents + bonusCents,
            isPush: isPush
        )
    }
}
