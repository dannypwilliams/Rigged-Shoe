import SwiftUI

struct BossHUDView: View {
    let boss: Boss
    let disabledUpgrades: [UpgradeCard]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: boss.iconName)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.22))
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color(red: 0.95, green: 0.22, blue: 0.22).opacity(0.18))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("Active Boss")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.95, green: 0.22, blue: 0.22))
                        .textCase(.uppercase)

                    Text(boss.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(boss.effect.ruleDescriptions, id: \.self) { rule in
                    Text(rule)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if !disabledUpgrades.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Disabled Upgrades")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.22))
                        .textCase(.uppercase)

                    HStack(spacing: 7) {
                        ForEach(disabledUpgrades) { upgrade in
                            Text(upgrade.name)
                                .font(.caption2.weight(.black))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.10))
                                )
                        }
                    }
                }
            }
        }
        .padding(14)
        .crookedPanel(kind: .boss, strokeColor: CrookedCasinoTheme.mutedRed, cornerRadius: 14)
        .accessibilityHint("Boss effects are temporary and only apply during the current boss stage.")
    }
}
