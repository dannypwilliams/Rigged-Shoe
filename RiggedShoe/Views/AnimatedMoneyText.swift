import SwiftUI

struct AnimatedMoneyText: View {
    let cents: Int
    var font: Font = .title2.monospacedDigit().weight(.black)

    @State private var displayedCents: Double
    @State private var flashColor = Color.white

    init(cents: Int, font: Font = .title2.monospacedDigit().weight(.black)) {
        self.cents = cents
        self.font = font
        self._displayedCents = State(initialValue: Double(cents))
    }

    var body: some View {
        Text(MoneyFormatter.format(Int(displayedCents.rounded())))
            .font(font)
            .foregroundStyle(flashColor)
            .contentTransition(.numericText())
            .onChange(of: cents) { oldValue, newValue in
                flashColor = newValue >= oldValue ? CasinoTheme.emerald : CasinoTheme.red

                withAnimation(.easeOut(duration: 0.55)) {
                    displayedCents = Double(newValue)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        flashColor = .white
                    }
                }
            }
    }
}
