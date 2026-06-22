import Foundation

struct TutorialMechanic: Identifiable, Hashable {
    let id: String
    let title: String
    let category: TutorialMechanicCategory
    let decisionWeight: DecisionWeight
    let beginnerExplanation: String
    let advancedExplanation: String
    let exampleScenario: String
    let decisionPrompt: String
    let recommendedAction: String
    let relatedMechanicIDs: [String]
    let appearsInWarmup: Bool
    let tutorialPriority: TutorialPriority
}

enum TutorialMechanicCategory: String, CaseIterable, Identifiable {
    case coreRun
    case betting
    case handOutcome
    case shoeControl
    case modifier
    case upgrade
    case archetype
    case pressure
    case economy
    case synergy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coreRun:
            return "Core Run"
        case .betting:
            return "Betting"
        case .handOutcome:
            return "Hand Outcome"
        case .shoeControl:
            return "Shoe Control"
        case .modifier:
            return "Modifier"
        case .upgrade:
            return "Upgrade"
        case .archetype:
            return "Archetype"
        case .pressure:
            return "Pressure"
        case .economy:
            return "Economy"
        case .synergy:
            return "Synergy"
        }
    }
}

enum DecisionWeight: String, CaseIterable, Identifiable {
    case low
    case medium
    case high
    case critical

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

enum TutorialPriority: String, CaseIterable, Identifiable {
    case mustTeach
    case shouldTeach
    case optional
    case referenceOnly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mustTeach:
            return "Must Teach"
        case .shouldTeach:
            return "Should Teach"
        case .optional:
            return "Optional"
        case .referenceOnly:
            return "Reference Only"
        }
    }
}
