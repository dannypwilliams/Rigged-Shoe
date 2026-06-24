import Foundation

struct Achievement: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let chipReward: Int

    static let allAchievements: [Achievement] = [
        Achievement(
            id: "card_counter",
            name: "Card Counter",
            description: "Reveal 10 or more cards in the shoe preview.",
            chipReward: 500
        ),
        Achievement(
            id: "loaded_shoe",
            name: "Loaded Shoe",
            description: "Acquire the Loaded Shoe upgrade.",
            chipReward: 750
        ),
        Achievement(
            id: "big_winner",
            name: "Big Winner",
            description: "Reach a $100,000 bankroll.",
            chipReward: 1_000
        ),
        Achievement(
            id: "millionaire",
            name: "Millionaire",
            description: "Reach a $1,000,000 bankroll.",
            chipReward: 2_500
        ),
        Achievement(
            id: "boss_hunter",
            name: "Boss Hunter",
            description: "Defeat 10 bosses across all runs.",
            chipReward: 2_000
        ),
        Achievement(
            id: "casino_legend",
            name: "Casino Legend",
            description: "Beat Stage 30.",
            chipReward: 5_000
        )
    ]
}
