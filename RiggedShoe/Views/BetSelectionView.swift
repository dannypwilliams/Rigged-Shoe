import SwiftUI

struct BetSelectionView: View {
    let selectedBetType: BetType
    let selectedBetAmountCents: Int
    let bankrollCents: Int
    let betAmountsCents: [Int]
    var allowedBetTypes: Set<BetType> = Set(BetType.allCases)
    let onSelectBetType: (BetType) -> Void
    let onSelectBetAmount: (Int) -> Void

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Bet")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    ForEach(BetType.allCases) { betType in
                        selectionButton(
                            title: betType.displayName,
                            isSelected: selectedBetType == betType,
                            isDisabled: !allowedBetTypes.contains(betType)
                        ) {
                            onSelectBetType(betType)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Amount")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 74), spacing: 8)], spacing: 8) {
                    ForEach(betAmountsCents, id: \.self) { amountCents in
                        selectionButton(
                            title: MoneyFormatter.format(amountCents),
                            isSelected: selectedBetAmountCents == amountCents,
                            isDisabled: bankrollCents < amountCents
                        ) {
                            onSelectBetAmount(amountCents)
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

    private func selectionButton(
        title: String,
        isSelected: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.black))
                .foregroundStyle(isDisabled ? .white.opacity(0.34) : (isSelected ? .black : .white))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Color(red: 0.94, green: 0.75, blue: 0.22) : Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(isSelected ? 0.00 : 0.12), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
