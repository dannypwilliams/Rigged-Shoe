import Foundation

enum TutorialStepID: String, CaseIterable, Codable, Identifiable {
    case welcome
    case baccarat
    case shoe
    case firstDeal
    case upgrade
    case stage
    case boss

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Rigged Shoe"
        case .baccarat:
            return "Baccarat in 10 Seconds"
        case .shoe:
            return "The Shoe"
        case .firstDeal:
            return "Deal One Hand"
        case .upgrade:
            return "Manipulate the Shoe"
        case .stage:
            return "Beat the Debt"
        case .boss:
            return "Boss Casinos"
        }
    }

    var body: String {
        switch self {
        case .welcome:
            return "You are not playing a normal deck-builder. You are rigging the casino shoe."
        case .baccarat:
            return "Player and Banker each get cards. Totals use only the ones digit. Closest to 9 wins."
        case .shoe:
            return "The shoe is the stack cards are dealt from. Revealed cards let you plan ahead."
        case .firstDeal:
            return "The opening hand is scripted and locks a Player bet so you can see exactly how a win and payout ledger work."
        case .upgrade:
            return "Every 3 rounds you choose an upgrade. Some add cards, some reveal cards, some change payouts."
        case .stage:
            return "Each stage has a clear objective before rounds run out. Early stages teach survival, break-even play, upgrades, and growth."
        case .boss:
            return "Every few stages, bosses attack your build by disabling reveals, payouts, or upgrade tags."
        }
    }

    var actionTitle: String {
        switch self {
        case .firstDeal:
            return "Deal a Guided Hand"
        case .boss:
            return "Start Rigging"
        default:
            return "Next"
        }
    }
}

struct GlossaryEntry: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String

    static let allEntries: [GlossaryEntry] = [
        GlossaryEntry(
            id: "baccarat_total",
            title: "Baccarat Total",
            summary: "Add card values, then keep only the ones digit. A total of 17 becomes 7."
        ),
        GlossaryEntry(
            id: "banker_commission",
            title: "Banker Commission",
            summary: "Banker normally pays 0.95:1. No Commission and related effects remove that tax unless a boss restores it."
        ),
        GlossaryEntry(
            id: "tie_payout",
            title: "Tie Payout",
            summary: "Tie bets start at 8:1. Tie upgrades and rewards can raise this, but some bosses cap it back to 8:1."
        ),
        GlossaryEntry(
            id: "shoe",
            title: "Shoe",
            summary: "The shoe is the live card stack. Adding or removing cards changes future baccarat odds."
        ),
        GlossaryEntry(
            id: "reveal",
            title: "Reveal",
            summary: "Reveal effects show controlled shoe information. Strong X-Ray reads are charged and cap bet size while active."
        ),
        GlossaryEntry(
            id: "boss",
            title: "Boss Effect",
            summary: "Bosses are temporary casino rules. They only attack the current stage and restore after defeat."
        ),
        GlossaryEntry(
            id: "profit_target",
            title: "Stage Objective",
            summary: "Early stages can clear by learning goals like winning bets or triggering upgrades. Profit targets still work as a backup path."
        )
    ]
}

struct LaunchChecklistItem: Identifiable, Equatable {
    let id: String
    let area: String
    let check: String
    let isRequiredForTestFlight: Bool

    static let allItems: [LaunchChecklistItem] = [
        LaunchChecklistItem(id: "gameplay.rules", area: "Gameplay", check: "Baccarat rules, payouts, boss rules, and upgrade effects verified.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "saving.resume", area: "Saving", check: "Profile saves, active run resumes, corrupted saves fall back safely.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "performance.animations", area: "Performance", check: "Animations have no duplicate timers or runaway loops.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "accessibility.motion", area: "Accessibility", check: "Reduce Motion, haptics, audio, contrast, and labels checked.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "audio.controls", area: "Audio", check: "Music and SFX volume/mute controls verified.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "progression.meta", area: "Progression", check: "Unlocks, achievements, challenges, daily runs, and bosses persist.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "tutorial.ftue", area: "Tutorial", check: "First-time flow teaches by doing and can be skipped/replayed.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "analytics.local", area: "Analytics", check: "Local analytics capture run, stage, boss, upgrade, and retention events.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "testflight.feedback", area: "Feedback", check: "Playtester feedback link and known issues screen are visible.", isRequiredForTestFlight: true),
        LaunchChecklistItem(id: "store.assets", area: "App Store", check: "Icon, launch screen, screenshots, marketing copy, and theme art slots are planned.", isRequiredForTestFlight: false)
    ]
}

enum BuildInfo {
    static let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let feedbackEmail = "playtest-feedback@example.com"

    static var versionText: String {
        "Version \(marketingVersion) (\(buildNumber))"
    }

    static let patchNotes = [
        "Added guided onboarding and first-run scripting.",
        "Added local analytics and playtest debug tooling.",
        "Added save resilience, glossary, and TestFlight support screens."
    ]

    static let knownIssues = [
        "Audio uses generated table tones until final casino assets are produced.",
        "Daily leaderboard is local-only; online service integration is intentionally deferred.",
        "Balance targets need external playtest data before final tuning."
    ]

    static let appStorePreparation = [
        "App icon asset slots",
        "Launch screen artwork slot",
        "Feature screenshot plan",
        "Marketing description draft",
        "Theme artwork slots"
    ]
}
