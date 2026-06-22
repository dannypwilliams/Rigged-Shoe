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
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isDisabled ? Color.red.opacity(0.13) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke((isDisabled ? Color.red : rarityColor(upgrade.rarity)).opacity(0.48), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.24))
        )
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
}
