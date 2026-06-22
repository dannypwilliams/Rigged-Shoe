import SwiftUI

struct BossAnnouncementView: View {
    let boss: Boss
    let onContinue: () -> Void
    @State private var didAppear = false

    var body: some View {
        ZStack {
            CasinoTheme.warningBackground
            .ignoresSafeArea()

            VStack(spacing: 18) {
                CasinoLightsView()

                VStack(spacing: 10) {
                    Text("BOSS APPROACHING")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.red)
                        .tracking(2)
                        .scaleEffect(didAppear ? 1 : 1.18)

                    Image(systemName: boss.iconName)
                        .font(.system(size: 52, weight: .black))
                        .foregroundStyle(CasinoTheme.gold)
                        .shadow(color: CasinoTheme.red.opacity(0.55), radius: 18)

                    Text(boss.name)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(boss.difficulty.displayName)
                        .font(.caption.weight(.black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(CasinoTheme.gold)
                        )
                }

                Text(boss.description)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Boss Effect")
                        .font(.caption.weight(.black))
                        .foregroundStyle(CasinoTheme.red)
                        .textCase(.uppercase)

                    ForEach(boss.effect.ruleDescriptions, id: \.self) { rule in
                        HStack(alignment: .top, spacing: 8) {
                            Text("!")
                                .font(.caption.weight(.black))
                                .foregroundStyle(CasinoTheme.gold)

                            Text(rule)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(CasinoTheme.red.opacity(0.56), lineWidth: 1)
                )

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title3.weight(.black))
                        .foregroundStyle(Color(red: 0.08, green: 0.01, blue: 0.01))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(CasinoTheme.gold)
                        )
                }
                .buttonStyle(JuicyPressButtonStyle())
            }
            .padding(22)
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 18)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.70)) {
                didAppear = true
            }
        }
    }
}
