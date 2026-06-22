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
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.dirtyGold, cornerRadius: 12)
    }

    private func selectionButton(
        title: String,
        isSelected: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if title.hasPrefix("$") {
                    CrookedChipView(valueText: chipLabel(for: title), size: 24, tone: isSelected ? .gold : .red)
                }

                Text(title)
                    .font(.subheadline.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .foregroundStyle(isDisabled ? .white.opacity(0.34) : (isSelected ? .black : .white))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                CrookedStickerShape(cornerRadius: 10)
                    .fill(isSelected ? Color(red: 0.94, green: 0.75, blue: 0.22) : Color.white.opacity(0.10))
            )
            .overlay(
                CrookedStickerShape(cornerRadius: 10)
                    .stroke(Color.white.opacity(isSelected ? 0.00 : 0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private func chipLabel(for title: String) -> String {
        title
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
    }
}
