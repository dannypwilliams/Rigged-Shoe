import SwiftUI

struct SynergyView: View {
    let acquiredUpgrades: [UpgradeCard]
    let activeSynergies: [SynergyDefinition]

    private var tagCounts: [UpgradeTag: Int] {
        var counts: [UpgradeTag: Int] = [:]

        for upgrade in acquiredUpgrades {
            for tag in upgrade.tags {
                counts[tag, default: 0] += 1
            }
        }

        return counts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Archetypes")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(activeSynergies.count) active")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(CasinoTheme.gold.opacity(0.78))
                    .textCase(.uppercase)
            }

            tagRail

            if activeSynergies.isEmpty {
                Text("Collect tagged upgrades to activate visible build synergies.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.56))
            } else {
                VStack(spacing: 8) {
                    ForEach(activeSynergies) { synergy in
                        synergyRow(synergy)
                    }
                }
            }
        }
        .padding(14)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold.opacity(activeSynergies.isEmpty ? 0.48 : 0.86), cornerRadius: 12)
    }

    private var tagRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(UpgradeTag.allCases, id: \.self) { tag in
                    let count = tagCounts[tag, default: 0]

                    VStack(spacing: 3) {
                        Text(tag.displayName)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(count > 0 ? .white : .white.opacity(0.42))
                            .textCase(.uppercase)

                        Text("\(count)")
                            .font(.caption.monospacedDigit().weight(.black))
                            .foregroundStyle(count > 0 ? CasinoTheme.gold : .white.opacity(0.34))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 7)
                    .background(
                        CrookedStickerShape(cornerRadius: 8)
                            .fill(count > 0 ? CasinoTheme.gold.opacity(0.14) : Color.white.opacity(0.06))
                    )
                    .overlay(
                        CrookedStickerShape(cornerRadius: 8)
                            .stroke(CasinoTheme.gold.opacity(count > 0 ? 0.32 : 0.10), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func synergyRow(_ synergy: SynergyDefinition) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.black))
                .foregroundStyle(CasinoTheme.gold)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(synergy.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)

                Text(synergy.description)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.60))
            }

            Spacer()
        }
        .padding(10)
        .background(
            CrookedStickerShape(cornerRadius: 8)
                .fill(CasinoTheme.gold.opacity(0.10))
        )
    }
}
