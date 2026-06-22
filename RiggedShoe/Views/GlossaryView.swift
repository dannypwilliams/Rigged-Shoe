import SwiftUI

struct GlossaryView: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(GlossaryEntry.allEntries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.white)

                                Text(entry.summary)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.66))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.16, cornerRadius: 12)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Glossary")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Quick answers for confusing casino rules")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.gold.opacity(0.78))
                    .textCase(.uppercase)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
            .buttonStyle(.plain)
        }
    }
}
