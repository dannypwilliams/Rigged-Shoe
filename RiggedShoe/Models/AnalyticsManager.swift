import Foundation

enum AnalyticsEventName: String, Codable, CaseIterable {
    case runStarted
    case runEnded
    case stageCleared
    case bossDefeated
    case upgradeChosen
    case legendaryAcquired
    case achievementEarned
    case challengeStarted
    case challengeCompleted
    case tutorialCompleted
    case tutorialSkipped
    case sessionEnded
    case debugAction
}

struct AnalyticsEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let name: AnalyticsEventName
    let timestamp: Date
    let properties: [String: String]

    init(name: AnalyticsEventName, properties: [String: String] = [:]) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.properties = properties
    }
}

struct AnalyticsRetentionSummary: Equatable {
    let eventCount: Int
    let sessionCount: Int
    let averageSessionLengthSeconds: Int
    let averageRunLengthRounds: Int
    let highestStage: Int
    let favoriteUpgrade: String
    let mostFailedStage: String
    let mostFailedBoss: String
    let mostUsedArchetype: String
}

struct AnalyticsManager {
    private static let storageKey = "riggedShoe.analytics.events.v1"
    private static let maxStoredEvents = 1_500

    private let userDefaults: UserDefaults
    private(set) var events: [AnalyticsEvent]

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.events = Self.loadEvents(from: userDefaults)
    }

    mutating func track(_ name: AnalyticsEventName, properties: [String: String] = [:]) {
        events.append(AnalyticsEvent(name: name, properties: properties))

        if events.count > Self.maxStoredEvents {
            events.removeFirst(events.count - Self.maxStoredEvents)
        }

        save()
    }

    mutating func reset() {
        events = []
        save()
    }

    var retentionSummary: AnalyticsRetentionSummary {
        let sessions = events
            .filter { $0.name == .sessionEnded }
            .compactMap { Int($0.properties["lengthSeconds"] ?? "") }
        let runs = events.filter { $0.name == .runEnded }
        let runLengths = runs.compactMap { Int($0.properties["roundsPlayed"] ?? "") }
        let highestStage = events.compactMap { Int($0.properties["stage"] ?? "") }.max() ?? 1
        let failedStages = runs
            .filter { $0.properties["didWin"] == "false" }
            .compactMap { $0.properties["stage"] }
        let failedBosses = runs.compactMap { $0.properties["failedBoss"] }
        let upgrades = events
            .filter { $0.name == .upgradeChosen }
            .compactMap { $0.properties["upgrade"] }
        let archetypes = events
            .filter { $0.name == .runEnded }
            .compactMap { $0.properties["topArchetype"] }

        return AnalyticsRetentionSummary(
            eventCount: events.count,
            sessionCount: sessions.count,
            averageSessionLengthSeconds: average(sessions),
            averageRunLengthRounds: average(runLengths),
            highestStage: highestStage,
            favoriteUpgrade: mostCommon(upgrades) ?? "None yet",
            mostFailedStage: mostCommon(failedStages).map { "Stage \($0)" } ?? "None yet",
            mostFailedBoss: mostCommon(failedBosses) ?? "None yet",
            mostUsedArchetype: mostCommon(archetypes) ?? "None yet"
        )
    }

    var debugLogText: String {
        events
            .suffix(250)
            .map { event in
                let props = event.properties
                    .sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: " ")
                return "\(event.timestamp.ISO8601Format()) \(event.name.rawValue) \(props)"
            }
            .joined(separator: "\n")
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(events) else {
            return
        }

        userDefaults.set(data, forKey: Self.storageKey)
    }

    private static func loadEvents(from userDefaults: UserDefaults) -> [AnalyticsEvent] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        guard let events = try? JSONDecoder().decode([AnalyticsEvent].self, from: data) else {
            userDefaults.removeObject(forKey: storageKey)
            return []
        }

        return events
    }

    private func average(_ values: [Int]) -> Int {
        guard !values.isEmpty else {
            return 0
        }

        return values.reduce(0, +) / values.count
    }

    private func mostCommon(_ values: [String]) -> String? {
        values
            .reduce(into: [String: Int]()) { counts, value in
                counts[value, default: 0] += 1
            }
            .max { first, second in first.value < second.value }?
            .key
    }
}
