import SwiftUI

enum SupportPanelTab: String, CaseIterable, Identifiable {
    case version
    case knownIssues
    case patchNotes
    case privacy
    case checklist
    case appStore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .version: return "Version"
        case .knownIssues: return "Known Issues"
        case .patchNotes: return "Patch Notes"
        case .privacy: return "Privacy"
        case .checklist: return "Checklist"
        case .appStore: return "Store Prep"
        }
    }
}

struct TestFlightSupportView: View {
    let analyticsLog: String
    let onMarkPatchNotesSeen: () -> Void
    let onClose: () -> Void

    @State private var selectedTab: SupportPanelTab = .version

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            VStack(spacing: 14) {
                header
                tabBar
                content
                Spacer(minLength: 0)
            }
            .padding(20)
        }
    }

    private var header: some View {
        HStack {
            Text("Playtest Hub")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.white)

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

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SupportPanelTab.allCases) { tab in
                    Button {
                        selectedTab = tab
                        if tab == .patchNotes {
                            onMarkPatchNotesSeen()
                        }
                    } label: {
                        Text(tab.title)
                            .font(.caption.weight(.black))
                            .foregroundStyle(selectedTab == tab ? .black : .white.opacity(0.70))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(selectedTab == tab ? CasinoTheme.gold : Color.white.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .version:
            supportCard(title: BuildInfo.versionText, lines: [
                "Feedback: \(BuildInfo.feedbackEmail)",
                "Analytics are stored locally only.",
                "No real-money gambling, ads, monetization, or online services are active."
            ])
        case .knownIssues:
            supportCard(title: "Known Issues", lines: BuildInfo.knownIssues)
        case .patchNotes:
            supportCard(title: "Patch Notes", lines: BuildInfo.patchNotes)
        case .privacy:
            supportCard(title: "Privacy Notes", lines: [
                "This build stores profile, run, settings, and analytics data locally on device.",
                "No third-party analytics SDK is integrated.",
                "Future online feedback or leaderboard features should require an updated privacy review."
            ])
        case .checklist:
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(LaunchChecklistItem.allItems) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: item.isRequiredForTestFlight ? "checkmark.seal.fill" : "circle.dashed")
                                .foregroundStyle(item.isRequiredForTestFlight ? CasinoTheme.gold : .white.opacity(0.45))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.area)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(CasinoTheme.gold)
                                    .textCase(.uppercase)
                                Text(item.check)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.72))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.14, cornerRadius: 10)
                    }
                }
            }
        case .appStore:
            supportCard(title: "App Store Prep", lines: BuildInfo.appStorePreparation)
        }
    }

    private func supportCard(title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if selectedTab == .version {
                if let feedbackURL = URL(string: "mailto:\(BuildInfo.feedbackEmail)?subject=Rigged%20Shoe%20Playtest%20Feedback") {
                    Link(destination: feedbackURL) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Playtest Feedback")
                            Spacer()
                        }
                        .font(.headline.weight(.black))
                        .foregroundStyle(.black)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(CasinoTheme.gold))
                    }
                    .padding(.top, 4)
                }

                Text("Playtest Log Preview")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.gold)
                    .textCase(.uppercase)
                    .padding(.top, 8)

                Text(analyticsLog.isEmpty ? "No analytics events yet." : analyticsLog)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.54))
                    .lineLimit(10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.22, cornerRadius: 12)
    }
}
