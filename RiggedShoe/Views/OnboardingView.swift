import SwiftUI

struct OnboardingView: View {
    let onDealGuidedHand: () -> Void
    let onComplete: (Bool) -> Void

    @State private var stepIndex = 0

    private var step: TutorialStepID {
        TutorialStepID.allCases[min(stepIndex, TutorialStepID.allCases.count - 1)]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Tutorial")
                            .font(.caption.weight(.black))
                            .foregroundStyle(CasinoTheme.gold)
                            .textCase(.uppercase)

                        Spacer()

                        Text("\(stepIndex + 1) / \(TutorialStepID.allCases.count)")
                            .font(.caption.monospacedDigit().weight(.black))
                            .foregroundStyle(.white.opacity(0.56))
                    }

                    Text(step.title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(step.body)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)

                    progressBar

                    HStack(spacing: 10) {
                        Button {
                            onComplete(true)
                        } label: {
                            Text("Skip")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white.opacity(0.72))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }
                        .buttonStyle(.plain)

                        Button(action: advance) {
                            Text(step.actionTitle)
                                .font(.headline.weight(.black))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(CasinoTheme.gold)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.40, cornerRadius: 16)
            }
            .padding(18)
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))

                Capsule()
                    .fill(CasinoTheme.gold)
                    .frame(width: geometry.size.width * CGFloat(stepIndex + 1) / CGFloat(TutorialStepID.allCases.count))
            }
        }
        .frame(height: 8)
    }

    private func advance() {
        if step == .firstDeal {
            onDealGuidedHand()
        }

        if stepIndex + 1 >= TutorialStepID.allCases.count {
            onComplete(false)
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                stepIndex += 1
            }
        }
    }
}
