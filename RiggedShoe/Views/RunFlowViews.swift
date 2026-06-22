import SwiftUI

struct RunStartView: View {
    let contacts: [StartingContact]
    let selectedContact: StartingContact
    let bankrollCents: Int
    let chips: Int
    let heat: Int
    let maxHeat: Int
    let onSelectContact: (StartingContact) -> Void
    let onContinue: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: CasinoTheme.gold) {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("Choose Contact")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.gold)

                    Text("Pick the opening edge for this run.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.68))
                        .multilineTextAlignment(.center)
                }

                StartingContactDetailCard(contact: selectedContact)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(contacts) { contact in
                            Button {
                                onSelectContact(contact)
                            } label: {
                                StartingContactChip(
                                    contact: contact,
                                    isSelected: contact.id == selectedContact.id
                                )
                            }
                            .buttonStyle(JuicyPressButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                }
                .frame(height: 68)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Base Bankroll", value: MoneyFormatter.format(bankrollCents + selectedContact.bankrollAdjustmentCents))
                    RunFlowStat(title: "Chips", value: "\(max(0, chips + selectedContact.chipsAdjustment))")
                    RunFlowStat(title: "Heat", value: "\(min(maxHeat, max(0, heat + selectedContact.heatAdjustment)))/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: "Preview Stage 1", action: onContinue)
            }
        }
    }
}

private struct StartingContactDetailCard: View {
    let contact: StartingContact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(contact.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(contact.difficultyRating)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.ink)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(CasinoTheme.gold))
            }

            Text(contact.recommendedArchetype)
                .font(.caption.weight(.black))
                .foregroundStyle(CasinoTheme.gold.opacity(0.86))
                .lineLimit(1)

            Text(contact.summary)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CasinoTheme.gold.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CasinoTheme.gold.opacity(0.52), lineWidth: 1)
        )
    }
}

private struct StartingContactChip: View {
    let contact: StartingContact
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(contact.name)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? CasinoTheme.gold : .white)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text(contact.difficultyRating)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? CasinoTheme.ink : .white.opacity(0.72))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(isSelected ? CasinoTheme.gold : .white.opacity(0.10)))
            }

            Text(contact.recommendedArchetype)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))
                .lineLimit(1)
        }
        .frame(width: 148, height: 58, alignment: .topLeading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? CasinoTheme.gold.opacity(0.16) : Color.white.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? CasinoTheme.gold.opacity(0.75) : Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

struct StagePreviewView: View {
    let preview: StagePreviewData
    let bankrollCents: Int
    let chips: Int
    let heat: Int
    let maxHeat: Int
    let onEnterBattle: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: preview.isBossStage ? CasinoTheme.red : CasinoTheme.emerald) {
            VStack(spacing: 16) {
                Text(preview.isBossStage ? "Boss Table" : "Stage Preview")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(preview.isBossStage ? CasinoTheme.red : CasinoTheme.gold)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stage \(preview.stageNumber)")
                                .font(.title2.weight(.black))
                                .foregroundStyle(.white)

                            Text(preview.opponentName)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white.opacity(0.72))

                            Text(preview.opponentSubtitle)
                                .font(.caption.weight(.black))
                                .foregroundStyle(CasinoTheme.gold.opacity(0.82))
                        }

                        Spacer()

                        Text("ANTE \(preview.ante)")
                            .font(.caption.weight(.black))
                            .foregroundStyle(CasinoTheme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(CasinoTheme.gold))
                    }

                    RunFlowDetailRow(title: "Battle Length", value: "\(preview.handCount) hands")
                    RunFlowDetailRow(title: "Opponent Style", value: preview.opponentStyle)
                    RunFlowDetailRow(title: "Known Weakness", value: preview.opponentWeakness)
                    RunFlowDetailRow(title: "Table Event", value: preview.tableRule)
                    Text(preview.tableRuleDetail)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                    RunFlowDetailRow(title: "Reward Tier", value: preview.rewardTier)
                    RunFlowDetailRow(title: "Optional", value: "\(preview.secondaryObjectiveTitle) · \(preview.secondaryObjectiveReward)")
                    Text(preview.secondaryObjectiveSummary)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)

                    if let bossWarning = preview.bossWarning {
                        Text(bossWarning)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(CasinoTheme.red)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(CasinoTheme.red.opacity(0.14))
                            )
                    }
                }
                .padding(16)
                .neonPanel(strokeColor: preview.isBossStage ? CasinoTheme.red : CasinoTheme.gold, opacity: 0.30)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Chips", value: "\(chips)")
                    RunFlowStat(title: "Heat", value: "\(heat)/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: preview.isBossStage ? "Face the Boss" : "Enter Battle", action: onEnterBattle)
            }
        }
    }
}

struct StageResultView: View {
    let result: StageResultData
    let bankrollCents: Int
    let heat: Int
    let maxHeat: Int
    let onContinue: () -> Void

    var body: some View {
        let accent = result.didWin ? CasinoTheme.emerald : CasinoTheme.red

        RunFlowOverlay(accentColor: accent) {
            VStack(spacing: 16) {
                Text(result.title)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(result.didWin ? CasinoTheme.gold : CasinoTheme.red)

                Text("Stage \(result.stageNumber)")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white.opacity(0.72))

                VStack(spacing: 9) {
                    RunFlowDetailRow(title: "Battle Result", value: result.reasonText)
                    RunFlowDetailRow(title: "Opponent", value: result.opponentName)
                    RunFlowDetailRow(title: "Player Score", value: MoneyFormatter.signed(result.profitCents))
                    RunFlowDetailRow(title: "Opponent Score", value: MoneyFormatter.signed(result.opponentProfitCents))
                    RunFlowDetailRow(title: "Profit / Loss", value: MoneyFormatter.signed(result.profitCents))
                    RunFlowDetailRow(title: "Bankroll Change", value: MoneyFormatter.signed(result.bankrollChangeCents))
                    RunFlowDetailRow(title: "Heat Change", value: signedNumber(result.heatChange))
                    RunFlowDetailRow(title: "Chips Earned", value: "+\(result.chipsEarned)")
                    RunFlowDetailRow(title: "Table Event", value: result.tableEventName)
                    RunFlowDetailRow(
                        title: "Optional",
                        value: result.secondaryObjectiveCompleted
                            ? "\(result.secondaryObjectiveTitle) complete"
                            : "\(result.secondaryObjectiveTitle) missed"
                    )
                    RunFlowDetailRow(title: "Main Build", value: result.buildArchetype)
                }
                .padding(16)
                .neonPanel(strokeColor: accent, opacity: 0.30)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Heat", value: "\(heat)/\(maxHeat)")
                }

                PrimaryRunFlowButton(title: result.didWin ? "Draft Reward" : "Run Summary", action: onContinue)
            }
        }
    }

    private func signedNumber(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }
}

struct ShopPhaseView: View {
    @ObservedObject var viewModel: GameViewModel
    let onContinue: () -> Void

    var body: some View {
        RunFlowOverlay(accentColor: CasinoTheme.gold) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Shop Phase")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(CasinoTheme.gold)

                        Text("Buy, freeze, level, or sell before the next table.")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.62))
                    }

                    Spacer()

                    RunFlowStat(title: "Chips", value: "\(viewModel.state.runManager.chips)")
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(viewModel.state.shopState.offers) { offer in
                        ShopOfferCard(
                            offer: offer,
                            ownedLevel: ownedLevel(for: offer),
                            canBuy: viewModel.canBuyShopOffer(offer),
                            attachmentTargetName: attachmentTargetName(for: offer),
                            blockedReason: viewModel.shopOfferBlockedReason(offer),
                            onBuy: { viewModel.buyShopOffer(offer) },
                            onFreeze: { viewModel.toggleFreezeShopOffer(offer) }
                        )
                    }
                }

                HStack(spacing: 8) {
                    Button("Reroll · \(viewModel.state.shopState.rerollCostChips) Chip") {
                        viewModel.rerollShop()
                    }
                    .buttonStyle(CompactShopButtonStyle(isPrimary: false))
                    .disabled(viewModel.state.runManager.chips < viewModel.state.shopState.rerollCostChips)

                    PrimaryRunFlowButton(title: nextStageButtonTitle, action: onContinue)
                }

                VStack(spacing: 8) {
                    ShopInventorySection(
                        title: "Active Modifiers \(viewModel.state.activeModifiers.count)/\(viewModel.state.activeModifierSlotLimit)",
                        instances: viewModel.state.activeModifiers,
                        emptyText: "Buy modifiers to build your engine.",
                        actionTitle: "Bench",
                        onAction: viewModel.moveModifierToBench,
                        onSell: viewModel.sellModifier
                    )

                    ShopInventorySection(
                        title: "Bench \(viewModel.state.benchModifiers.count)/\(viewModel.state.benchModifierSlotLimit)",
                        instances: viewModel.state.benchModifiers,
                        emptyText: "Bench overflow or future synergies.",
                        actionTitle: "Equip",
                        onAction: viewModel.moveModifierToActive,
                        onSell: viewModel.sellModifier
                    )
                }

                if !viewModel.state.consumables.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Consumables \(viewModel.state.consumables.count)/\(viewModel.state.consumableSlotLimit)")
                            .font(.caption.weight(.black))
                            .foregroundStyle(.white.opacity(0.62))
                            .textCase(.uppercase)

                        ForEach(viewModel.state.consumables) { consumable in
                            Button {
                                viewModel.useConsumable(consumable)
                            } label: {
                                HStack {
                                    Text(consumable.name)
                                        .font(.caption.weight(.black))
                                    Spacer()
                                    Text("Use")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(0.08)))
                            }
                            .buttonStyle(JuicyPressButtonStyle())
                        }
                    }
                }
            }
        }
    }

    private var nextStageButtonTitle: String {
        viewModel.state.runManager.currentStageIndex + 1 >= viewModel.state.runManager.stages.count ? "Finish Run" : "Next Stage"
    }

    private func ownedLevel(for offer: ShopOffer) -> Int? {
        guard offer.kind == .modifier else {
            return nil
        }

        return (viewModel.state.activeModifiers + viewModel.state.benchModifiers)
            .filter { $0.modifierID == offer.contentID }
            .map(\.level)
            .max()
    }

    private func attachmentTargetName(for offer: ShopOffer) -> String? {
        guard offer.kind == .attachment else {
            return nil
        }

        return viewModel.attachmentTargetName(for: offer.contentID)
    }
}

private struct ShopOfferCard: View {
    let offer: ShopOffer
    let ownedLevel: Int?
    let canBuy: Bool
    let attachmentTargetName: String?
    let blockedReason: String?
    let onBuy: () -> Void
    let onFreeze: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(kindText)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.ink)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(kindColor))

                Spacer(minLength: 4)

                Text("\(offer.priceChips)C")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CasinoTheme.gold)
            }

            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(summary)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.66))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let tags {
                Text(tags)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.gold.opacity(0.85))
                    .lineLimit(1)
            }

            if let ownedLevel {
                Text("Owned L\(ownedLevel) · duplicate levels up")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }

            if let attachmentTargetName {
                Text("Attaches to \(attachmentTargetName)")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.neonBlue.opacity(0.90))
                    .lineLimit(1)
            } else if let blockedReason {
                Text(blockedReason)
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(CasinoTheme.red.opacity(0.80))
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                Button(offer.isFrozen ? "Frozen" : "Freeze", action: onFreeze)
                    .buttonStyle(CompactShopButtonStyle(isPrimary: false))

                Button(offer.isSoldOut ? "Bought" : "Buy", action: onBuy)
                    .buttonStyle(CompactShopButtonStyle(isPrimary: true))
                    .disabled(!canBuy || offer.isSoldOut)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(offer.isSoldOut ? Color.white.opacity(0.035) : Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(offer.isFrozen ? CasinoTheme.gold.opacity(0.82) : Color.white.opacity(0.10), lineWidth: 1)
        )
        .opacity(offer.isSoldOut ? 0.45 : 1)
    }

    private var title: String {
        switch offer.kind {
        case .modifier:
            return Modifier.definition(id: offer.contentID)?.name ?? "Unknown Modifier"
        case .consumable:
            return Consumable.definition(id: offer.contentID)?.name ?? "Unknown Consumable"
        case .attachment:
            return Attachment.definition(id: offer.contentID)?.name ?? "Unknown Attachment"
        case .bossRelic:
            return BossRelic.sampleEyeInTheSky.name
        }
    }

    private var summary: String {
        switch offer.kind {
        case .modifier:
            return Modifier.definition(id: offer.contentID)?.summary ?? "No data."
        case .consumable:
            return Consumable.definition(id: offer.contentID)?.summary ?? "No data."
        case .attachment:
            return Attachment.definition(id: offer.contentID)?.summary ?? "No data."
        case .bossRelic:
            return BossRelic.sampleEyeInTheSky.summary
        }
    }

    private var tags: String? {
        guard offer.kind == .modifier,
              let modifier = Modifier.definition(id: offer.contentID) else {
            return nil
        }

        return modifier.tags.map(\.displayName).sorted().prefix(3).joined(separator: " · ")
    }

    private var kindText: String {
        if offer.kind == .modifier,
           let modifier = Modifier.definition(id: offer.contentID) {
            return modifier.rarity.displayName.uppercased()
        }

        return offer.kind.displayName.uppercased()
    }

    private var kindColor: Color {
        if offer.kind == .modifier,
           let modifier = Modifier.definition(id: offer.contentID) {
            switch modifier.rarity {
            case .common:
                return .white.opacity(0.75)
            case .uncommon:
                return CasinoTheme.emerald
            case .rare:
                return .cyan
            case .epic:
                return .purple
            case .legendary:
                return CasinoTheme.gold
            case .boss:
                return CasinoTheme.red
            }
        }

        switch offer.kind {
        case .modifier:
            return CasinoTheme.gold
        case .consumable:
            return CasinoTheme.emerald
        case .attachment:
            return .cyan
        case .bossRelic:
            return CasinoTheme.red
        }
    }
}

private struct ShopInventorySection: View {
    let title: String
    let instances: [ModifierInstance]
    let emptyText: String
    let actionTitle: String
    let onAction: (UUID) -> Void
    let onSell: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.62))
                .textCase(.uppercase)

            if instances.isEmpty {
                Text(emptyText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.52))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(0.045)))
            } else {
                ForEach(instances) { instance in
                    if let modifier = Modifier.definition(id: instance.modifierID) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(modifier.name) L\(instance.level)")
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(.white)
                                if !instance.attachedIDs.isEmpty {
                                    Text(instance.attachedIDs.compactMap { Attachment.definition(id: $0)?.name }.joined(separator: ", "))
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(CasinoTheme.gold.opacity(0.78))
                                        .lineLimit(1)
                                } else {
                                    Text(modifier.tags.map(\.displayName).sorted().prefix(3).joined(separator: " · "))
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.48))
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Button(actionTitle) {
                                onAction(instance.id)
                            }
                            .buttonStyle(CompactShopButtonStyle(isPrimary: false))

                            Button("Sell") {
                                onSell(instance.id)
                            }
                            .buttonStyle(CompactShopButtonStyle(isPrimary: false))
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(0.06)))
                    }
                }
            }
        }
    }
}

private struct CompactShopButtonStyle: ButtonStyle {
    let isPrimary: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(isEnabled ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }

    private var foregroundColor: Color {
        guard isEnabled else {
            return .white.opacity(0.34)
        }

        return isPrimary ? CasinoTheme.ink : .white
    }

    private var backgroundColor: Color {
        guard isEnabled else {
            return Color.white.opacity(0.045)
        }

        return isPrimary ? CasinoTheme.gold : Color.white.opacity(0.10)
    }
}

private struct RunFlowOverlay<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content
    @State private var didAppear = false

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            GeometryReader { proxy in
                VStack {
                    Spacer(minLength: 0)

                    content
                        .padding(18)
                        .frame(maxWidth: min(proxy.size.width - 28, 460))
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.black.opacity(0.64))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(accentColor.opacity(0.52), lineWidth: 1)
                        )
                        .shadow(color: accentColor.opacity(0.22), radius: 22, y: 12)
                        .scaleEffect(didAppear ? 1 : 0.96)
                        .opacity(didAppear ? 1 : 0)

                    Spacer(minLength: 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .padding(.horizontal, 14)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                didAppear = true
            }
        }
    }
}

private struct RunFlowStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.56))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}

private struct RunFlowDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.58))
                .textCase(.uppercase)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
    }
}

private struct PrimaryRunFlowButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(CasinoTheme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(CasinoTheme.gold)
                )
        }
        .buttonStyle(JuicyPressButtonStyle())
    }
}
