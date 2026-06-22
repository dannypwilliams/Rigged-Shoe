import SwiftUI

struct HistoryView: View {
    let history: [RoundResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Last 10")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Spacer()

                Text("Round History")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.52))
                    .textCase(.uppercase)
            }

            if history.isEmpty {
                Text("No rounds yet.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 7) {
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, result in
                        HStack(spacing: 10) {
                            Text("#\(history.count - index)")
                                .font(.caption.monospacedDigit().weight(.bold))
                                .foregroundStyle(.white.opacity(0.42))
                                .frame(width: 36, alignment: .leading)

                            Text(result.winner.displayName)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)

                            Text(result.betOutcomeText)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(result.isPush ? Color(red: 0.94, green: 0.75, blue: 0.22) : (result.didWin ? .green : .red))

                            Spacer()

                            Text(MoneyFormatter.signed(result.netCents))
                                .font(.caption.monospacedDigit().weight(.black))
                                .foregroundStyle(.white.opacity(0.82))
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
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
}
