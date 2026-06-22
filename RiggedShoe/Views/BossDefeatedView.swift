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
            CasinoTheme.background
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
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func rewardCard(_ reward: BossReward) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Boss Reward")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.red)
                .textCase(.uppercase)

            Text(reward.name)
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(reward.description)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(red: 0.94, green: 0.75, blue: 0.22).opacity(0.58), lineWidth: 1)
        )
        .shadow(color: CasinoTheme.gold.opacity(0.16), radius: 12, y: 6)
    }
}
