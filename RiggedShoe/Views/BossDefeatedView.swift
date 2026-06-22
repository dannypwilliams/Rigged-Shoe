import SwiftUI

struct BossDefeatedView: View {
    let boss: Boss
    let runManager: RunManager
    let bankrollCents: Int
    let choices: [BossReward]
    let onSelect: (BossReward) -> Void
    @State private var didAppear = false
    @State private var particleTrigger = UUID()

    private var currentProfitCents: Int {
        runManager.stageProfitCents(bankrollCents: bankrollCents)
    }

    var body: some View {
        ZStack {
            CrookedCasinoTheme.tableBackground
            .ignoresSafeArea()

            ParticleBurstView(
                trigger: particleTrigger,
                color: CasinoTheme.gold,
                secondaryColor: CasinoTheme.red,
                count: 52,
                intensity: 1.2
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    CasinoLightsView()

                    VStack(spacing: 8) {
                        Text("BOSS DEFEATED")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(CasinoTheme.gold)
                            .multilineTextAlignment(.center)
                            .shadow(color: CasinoTheme.gold.opacity(0.46), radius: 14)

                        Text(boss.name)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 10) {
                        stat(title: "Stage Gain", value: MoneyFormatter.signed(currentProfitCents))
                        stat(title: "Rounds Left", value: "\(runManager.roundsRemaining)")
                    }

                    VStack(spacing: 8) {
                        Text("Reward Granted")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)

                        Text("Choose 1 of 3 powerful boss rewards.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.62))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        ForEach(choices) { reward in
                            Button {
                                onSelect(reward)
                            } label: {
                                rewardCard(reward)
                            }
                            .buttonStyle(JuicyPressButtonStyle())
                        }
                    }
                }
                .padding(20)
                .padding(.vertical, 24)
                .opacity(didAppear ? 1 : 0)
                .scaleEffect(didAppear ? 1 : 0.96)
            }
        }
        .onAppear {
            particleTrigger = UUID()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                didAppear = true
            }
        }
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.54))
                .textCase(.uppercase)

            Text(value)
                .font(.title3.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.mutedRed, cornerRadius: 10)
    }

    private func rewardCard(_ reward: BossReward) -> some View {
        CrookedCasinoCard(
            kind: .boss,
            eyebrow: "Boss Reward",
            title: reward.name,
            description: reward.description,
            icon: .crown,
            footer: "Powerful reward",
            isCompact: false
        )
    }
}
