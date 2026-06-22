import Foundation

struct WarmupScenario: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let lesson: String
    let startingBankroll: Double
    let stageGoal: Double?
    let availableBets: [Double]
    let mechanicIDs: [String]
    let activeModifierIDs: [String]
    let prompt: String
    let choices: [WarmupChoice]
    let correctChoiceID: String
    let explanationAfterCorrectChoice: String
    let explanationAfterWrongChoice: String
    let takeaway: String
}

struct WarmupChoice: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let riskLabel: WarmupRiskLabel
    let predictedOutcome: String
    let strategicTag: String
}

enum WarmupRiskLabel: String, CaseIterable, Identifiable {
    case safe
    case balanced
    case greedy
    case reckless
    case buildAligned
    case edgeBased

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .safe:
            return "Safe"
        case .balanced:
            return "Balanced"
        case .greedy:
            return "Greedy"
        case .reckless:
            return "Reckless"
        case .buildAligned:
            return "Build Aligned"
        case .edgeBased:
            return "Edge Based"
        }
    }
}
