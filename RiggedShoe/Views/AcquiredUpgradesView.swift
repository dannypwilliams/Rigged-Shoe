import SwiftUI

struct AcquiredUpgradesView: View {
    let upgrades: [UpgradeCard]
    var disabledUpgradeIDs: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Upgrades")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(upgrades.count) acquired")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.52))
                    .textCase(.uppercase)
            }

            if upgrades.isEmpty {
                Text("Earn one after every 3 completed rounds.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(upgrades) { upgrade in
                            let isDisabled = disabledUpgradeIDs.contains(upgrade.id)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(upgrade.rarity.displayName)
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .foregroundStyle(isDisabled ? .red : rarityColor(upgrade.rarity))
                                    .textCase(.uppercase)

                                Text(upgrade.name)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)

                                if isDisabled {
                                    Text("Disabled")
                                        .font(.system(size: 8, weight: .black, design: .rounded))
                                        .foregroundStyle(.red)
                                        .textCase(.uppercase)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                CrookedStickerShape(cornerRadius: 8)
                                    .fill(isDisabled ? Color.red.opacity(0.13) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                CrookedStickerShape(cornerRadius: 8)
                                    .stroke((isDisabled ? Color.red : rarityColor(upgrade.rarity)).opacity(0.48), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .padding(14)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 12)
    }

    private func rarityColor(_ rarity: UpgradeRarity) -> Color {
        switch rarity {
        case .common:
            return CrookedCasinoTheme.paper
        case .rare:
            return CrookedCasinoTheme.dirtyGold
        case .legendary:
            return CrookedCasinoTheme.dirtyGold
        }
    }
}
