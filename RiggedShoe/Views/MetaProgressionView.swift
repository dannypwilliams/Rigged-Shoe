import SwiftUI

enum MetaProgressionTab: String, CaseIterable, Identifiable {
    case profile
    case collection
    case shop
    case statistics

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .profile:
            return "Profile"
        case .collection:
            return "Collection"
        case .shop:
            return "Unlock Shop"
        case .statistics:
            return "Statistics"
        }
    }
}

struct MetaProgressionPanel: View {
    @Binding var selectedTab: MetaProgressionTab

    let profile: PlayerProfile
    let collectionEntries: [CollectionEntry]
    let collectionCompletionPercent: Int
    let shopUnlockables: [Unlockable]
    let onPurchase: (Unlockable) -> Void
    let onToggleRunModifier: (RunModifierID, Bool) -> Void
    let onSelectChallenge: (ChallengeModeID) -> Void
    let onToggleDailyRun: (Bool) -> Void
    let onSelectTheme: (CasinoThemeID) -> Void

    var body: some View {
        VStack(spacing: 14) {
            header
            tabBar

            switch selectedTab {
            case .profile:
                profileView
            case .collection:
                collectionView
            case .shop:
                shopView
            case .statistics:
                statisticsView
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(red: 0.94, green: 0.75, blue: 0.22).opacity(0.26), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Casino Profile")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Text("\(collectionCompletionPercent)% collection complete")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.54))
                    .textCase(.uppercase)
            }

            Spacer()

            currencyPill(title: "Chips", value: "\(formatNumber(profile.casinoChips))")
            currencyPill(title: "Rep", value: "\(formatNumber(profile.reputation))")
        }
    }

    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(MetaProgressionTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.title)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(selectedTab == tab ? Color.black : Color.white.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedTab == tab ? Color(red: 0.94, green: 0.75, blue: 0.22) : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var profileView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                profileStat(title: "Runs", value: "\(profile.totalRuns)")
                profileStat(title: "Wins", value: "\(profile.totalWins)")
                profileStat(title: "Bosses", value: "\(profile.bossesDefeated)")
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Run Modifiers")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)

                Text("Unlocked modifiers apply when the next run starts.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.55))

                ForEach(RunModifierID.allCases) { modifier in
                    runModifierRow(modifier)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )

            challengeSection
            themeSection

            VStack(spacing: 8) {
                statRow(title: "Highest Bankroll", value: MoneyFormatter.format(profile.highestBankrollEverCents))
                statRow(title: "Highest Profit", value: MoneyFormatter.format(profile.highestProfitEverCents))
                statRow(title: "Total Chips Earned", value: formatNumber(profile.totalChipsEarned))
                statRow(title: "Total Reputation Earned", value: formatNumber(profile.totalReputationEarned))
            }
        }
    }

    private var collectionView: some View {
        VStack(alignment: .leading, spacing: 14) {
            progressBar
            collectionSection(title: "Upgrades", entries: entries(of: .upgrade))
            collectionSection(title: "Bosses", entries: entries(of: .boss))
            collectionSection(title: "Rewards and Modifiers", entries: rewardAndModifierEntries)
        }
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Challenge Runs")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)

                    Text("Applies when the next run starts.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer()

                Button {
                    onToggleDailyRun(!profile.isDailyRunEnabled)
                } label: {
                    Text(profile.isDailyRunEnabled ? "Daily On" : "Daily Off")
                        .font(.caption.weight(.black))
                        .foregroundStyle(profile.isDailyRunEnabled ? Color.black : .white.opacity(0.68))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(profile.isDailyRunEnabled ? CasinoTheme.gold : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }

            ForEach(ChallengeModeID.allCases) { challenge in
                challengeRow(challenge)
            }

            if let leaderboard = profile.leaderboardPlaceholder {
                statRow(
                    title: "Daily Local Score",
                    value: "\(MoneyFormatter.format(leaderboard.localScoreCents)) seed \(leaderboard.dailySeed)"
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Casino Theme")
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
                ForEach(CasinoThemeID.allCases) { theme in
                    Button {
                        onSelectTheme(theme)
                    } label: {
                        Text(theme.name)
                            .font(.caption.weight(.black))
                            .foregroundStyle(profile.selectedThemeID == theme ? Color.black : .white.opacity(0.72))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(profile.selectedThemeID == theme ? CasinoTheme.gold : Color.white.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var shopView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spend permanent currency to add new options to future runs.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(shopUnlockables) { unlockable in
                shopCard(unlockable)
            }
        }
    }

    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 8) {
                statRow(title: "Total Baccarat Rounds", value: "\(profile.totalBaccaratRounds)")
                statRow(title: "Player Wins", value: "\(profile.playerWins)")
                statRow(title: "Banker Wins", value: "\(profile.bankerWins)")
                statRow(title: "Tie Results", value: "\(profile.tieResults)")
                statRow(title: "Stages Cleared", value: "\(profile.stagesCleared)")
                statRow(title: "Bosses Defeated", value: "\(profile.bossesDefeated)")
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Achievements")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)

                ForEach(Achievement.allAchievements) { achievement in
                    achievementRow(achievement)
                }
            }
        }
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Collection Progress")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.58))
                    .textCase(.uppercase)

                Spacer()

                Text("\(collectionCompletionPercent)%")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.22))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(Color(red: 0.94, green: 0.75, blue: 0.22))
                        .frame(width: geometry.size.width * CGFloat(collectionCompletionPercent) / 100)
                }
            }
            .frame(height: 8)
        }
    }

    private var rewardAndModifierEntries: [CollectionEntry] {
        collectionEntries.filter { entry in
            [.stageReward, .bossReward, .runModifier, .futureHook].contains(entry.kind)
        }
    }

    private func entries(of kind: CollectionEntryKind) -> [CollectionEntry] {
        collectionEntries.filter { $0.kind == kind }
    }

    private func collectionSection(title: String, entries: [CollectionEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(entries.filter(\.countsTowardCompletion).count) / \(entries.count)")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.54))
            }

            VStack(spacing: 8) {
                ForEach(entries) { entry in
                    collectionCard(entry)
                }
            }
        }
    }

    private func collectionCard(_ entry: CollectionEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(entry.countsTowardCompletion ? accentColor(for: entry).opacity(0.20) : Color.white.opacity(0.07))
                    .frame(width: 42, height: 54)

                Image(systemName: entry.countsTowardCompletion ? "checkmark.seal.fill" : "lock.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(entry.countsTowardCompletion ? accentColor(for: entry) : .white.opacity(0.38))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    Text(entry.stateText)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(accentColor(for: entry))
                        .textCase(.uppercase)
                }

                Text(entry.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accentColor(for: entry))

                Text(entry.description)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(entry.isUnlocked || entry.isEncountered ? 0.62 : 0.42))
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(entry.isUnlocked || entry.isEncountered ? 0.07 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(accentColor(for: entry).opacity(entry.isUnlocked || entry.isEncountered ? 0.42 : 0.16), lineWidth: 1)
        )
    }

    private func shopCard(_ unlockable: Unlockable) -> some View {
        let isUnlocked = unlockable.isUnlocked(in: profile)
        let canAfford = unlockable.canAfford(with: profile)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(unlockable.categoryName)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.22))
                        .textCase(.uppercase)

                    Text(unlockable.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(isUnlocked ? "Owned" : costText(for: unlockable))
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(isUnlocked ? .green : .white.opacity(0.78))
                    .multilineTextAlignment(.trailing)
            }

            Text(unlockable.description)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.62))

            Button {
                onPurchase(unlockable)
            } label: {
                Text(isUnlocked ? "Unlocked" : "Unlock")
                    .font(.caption.weight(.black))
                    .foregroundStyle(isUnlocked || !canAfford ? .white.opacity(0.50) : Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isUnlocked || !canAfford ? Color.white.opacity(0.08) : Color(red: 0.94, green: 0.75, blue: 0.22))
                    )
            }
            .buttonStyle(.plain)
            .disabled(isUnlocked || !canAfford)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(isUnlocked ? 0.05 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(isUnlocked ? 0.10 : 0.18), lineWidth: 1)
        )
    }

    private func runModifierRow(_ modifier: RunModifierID) -> some View {
        let isUnlocked = profile.unlockedRunModifierIDs.contains(modifier.rawValue)
        let isActive = profile.activeRunModifierIDs.contains(modifier.rawValue)

        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(modifier.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)

                Text(isUnlocked ? modifier.description : "Locked in the Unlock Shop.")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.54))
                    .lineLimit(2)
            }

            Spacer()

            Button {
                onToggleRunModifier(modifier, !isActive)
            } label: {
                Text(isActive ? "On" : isUnlocked ? "Off" : "Locked")
                    .font(.caption.weight(.black))
                    .foregroundStyle(isActive ? Color.black : .white.opacity(0.58))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isActive ? Color(red: 0.94, green: 0.75, blue: 0.22) : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isUnlocked)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.16))
        )
    }

    private func challengeRow(_ challenge: ChallengeModeID) -> some View {
        let isSelected = profile.selectedChallengeID == challenge
        let record = profile.challengeRecords[challenge.rawValue] ?? ChallengeRecord()

        return Button {
            onSelectChallenge(challenge)
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.name)
                        .font(.caption.weight(.black))
                        .foregroundStyle(isSelected ? Color.black : .white)

                    Text(challenge.description)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.62) : .white.opacity(0.54))
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(isSelected ? "Selected" : "+\(challenge.chipRewardMultiplierPercent - 100)%")
                        .font(.caption.weight(.black))
                        .foregroundStyle(isSelected ? Color.black : CasinoTheme.gold)

                    Text("Wins \(record.wins)")
                        .font(.caption2.monospacedDigit().weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.62) : .white.opacity(0.42))
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? CasinoTheme.gold : Color.black.opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(CasinoTheme.gold.opacity(isSelected ? 0.0 : 0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        let isUnlocked = profile.achievedAchievementIDs.contains(achievement.id)

        return HStack(spacing: 10) {
            Image(systemName: isUnlocked ? "rosette" : "lock.fill")
                .foregroundStyle(isUnlocked ? Color(red: 0.94, green: 0.75, blue: 0.22) : .white.opacity(0.34))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)

                Text(achievement.description)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
            }

            Spacer()

            Text("+\(achievement.chipReward)")
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(isUnlocked ? .green : .white.opacity(0.42))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(isUnlocked ? 0.08 : 0.04))
        )
    }

    private func profileStat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.monospacedDigit().weight(.black))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.50))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))

            Spacer()

            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 3)
    }

    private func currencyPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.50))
                .textCase(.uppercase)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func accentColor(for entry: CollectionEntry) -> Color {
        if let rarity = entry.rarity {
            return rarityColor(rarity)
        }

        switch entry.kind {
        case .boss:
            return entry.isDefeated ? Color(red: 0.94, green: 0.75, blue: 0.22) : Color(red: 0.95, green: 0.22, blue: 0.22)
        case .achievement:
            return entry.isUnlocked ? Color(red: 0.94, green: 0.75, blue: 0.22) : .white.opacity(0.46)
        case .stageReward, .bossReward:
            return Color(red: 0.34, green: 0.90, blue: 0.62)
        case .runModifier:
            return Color(red: 0.31, green: 0.65, blue: 1.00)
        case .futureHook:
            return Color(red: 0.80, green: 0.52, blue: 1.00)
        case .upgrade:
            return .white.opacity(0.60)
        }
    }

    private func rarityColor(_ rarity: UpgradeRarity) -> Color {
        switch rarity {
        case .common:
            return Color(red: 0.86, green: 0.90, blue: 0.84)
        case .rare:
            return Color(red: 0.31, green: 0.65, blue: 1.00)
        case .legendary:
            return Color(red: 1.00, green: 0.72, blue: 0.20)
        }
    }

    private func costText(for unlockable: Unlockable) -> String {
        var parts = ["\(formatNumber(unlockable.costChips)) Chips"]

        if unlockable.costReputation > 0 {
            parts.append("\(formatNumber(unlockable.costReputation)) Rep")
        }

        return parts.joined(separator: "\n")
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
