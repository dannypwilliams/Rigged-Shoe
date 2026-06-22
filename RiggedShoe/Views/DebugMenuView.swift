import SwiftUI

#if DEBUG
struct DebugMenuView: View {
    let analyticsSummary: AnalyticsRetentionSummary
    let onFastForward: () -> Void
    let onInstantStageClear: () -> Void
    let onGrantUpgrade: (String) -> Void
    let onGrantLegendary: () -> Void
    let onSpawnBoss: (Boss) -> Void
    let onForceDailySeed: (UInt64) -> Void
    let onRunPhase3Checks: () -> String
    let onStressGameRoomLayout: () -> Void
    let onClose: () -> Void

    @State private var upgradeName = "Marked Shoe"
    @State private var selectedBossID = Boss.surveillance.id
    @State private var dailySeedText = "20260618"
    @State private var phase3CheckResult = "Not run"

    private var selectedBoss: Boss {
        Boss.allBosses.first { $0.id == selectedBossID } ?? .surveillance
    }

    var body: some View {
        ZStack {
            CasinoTheme.warningBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    analyticsPanel
                    phase3ChecksPanel
                    actionButton("Stress Game Room Layout", action: onStressGameRoomLayout)
                    actionButton("Fast Forward 3 Rounds", action: onFastForward)
                    actionButton("Instant Stage Clear", action: onInstantStageClear)
                    grantUpgradePanel
                    bossPanel
                    seedPanel
                }
                .padding(20)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Debug Menu")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Disabled in release builds")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.red)
                    .textCase(.uppercase)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
            .buttonStyle(.plain)
        }
    }

    private var analyticsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Run Statistics")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
            debugRow("Events", "\(analyticsSummary.eventCount)")
            debugRow("Avg Session", "\(analyticsSummary.averageSessionLengthSeconds)s")
            debugRow("Avg Run", "\(analyticsSummary.averageRunLengthRounds) rounds")
            debugRow("Highest Stage", "\(analyticsSummary.highestStage)")
            debugRow("Favorite Upgrade", analyticsSummary.favoriteUpgrade)
            debugRow("Failed Stage", analyticsSummary.mostFailedStage)
            debugRow("Failed Boss", analyticsSummary.mostFailedBoss)
            debugRow("Archetype", analyticsSummary.mostUsedArchetype)
        }
        .padding(14)
        .neonPanel(strokeColor: CasinoTheme.red, opacity: 0.28, cornerRadius: 12)
    }

    private var phase3ChecksPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Phase 3 Checks")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            Text(phase3CheckResult)
                .font(.caption.monospacedDigit().weight(.bold))
                .foregroundStyle(.white.opacity(0.72))
                .frame(maxWidth: .infinity, alignment: .leading)

            actionButton("Run Balance + X-Ray Checks") {
                phase3CheckResult = onRunPhase3Checks()
            }
        }
        .padding(14)
        .neonPanel(strokeColor: CasinoTheme.neonBlue, opacity: 0.22, cornerRadius: 12)
    }

    private var grantUpgradePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grant Upgrade")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            TextField("Upgrade name", text: $upgradeName)
                .textInputAutocapitalization(.words)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.10)))
                .foregroundStyle(.white)

            HStack {
                actionButton("Grant Named") { onGrantUpgrade(upgradeName) }
                actionButton("Grant Legendary", action: onGrantLegendary)
            }
        }
        .padding(14)
        .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.22, cornerRadius: 12)
    }

    private var bossPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spawn Boss")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            Picker("Boss", selection: $selectedBossID) {
                ForEach(Boss.allBosses) { boss in
                    Text(boss.name).tag(boss.id)
                }
            }
            .pickerStyle(.menu)
            .tint(CasinoTheme.gold)

            actionButton("Spawn \(selectedBoss.name)") { onSpawnBoss(selectedBoss) }
        }
        .padding(14)
        .neonPanel(strokeColor: CasinoTheme.red, opacity: 0.24, cornerRadius: 12)
    }

    private var seedPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Force Daily Seed")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            TextField("Seed", text: $dailySeedText)
                .keyboardType(.numberPad)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.10)))
                .foregroundStyle(.white)

            actionButton("Apply Seed") {
                onForceDailySeed(UInt64(dailySeedText) ?? 2_026_061_800)
            }
        }
        .padding(14)
        .neonPanel(strokeColor: CasinoTheme.emerald, opacity: 0.20, cornerRadius: 12)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(CasinoTheme.gold))
        }
        .buttonStyle(.plain)
    }

    private func debugRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}
#endif
