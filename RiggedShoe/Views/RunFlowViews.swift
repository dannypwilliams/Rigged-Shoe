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

    private var contactHeatText: String {
        let adjustedHeat = min(maxHeat, max(0, heat + selectedContact.heatAdjustment))
        return "\(adjustedHeat)/\(maxHeat) \(HeatBand.band(for: adjustedHeat, maxHeat: maxHeat).rawValue)"
    }

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

                HStack(spacing: 8) {
                    RunFlowStat(title: "Base Bankroll", value: MoneyFormatter.format(bankrollCents + selectedContact.bankrollAdjustmentCents))
                    RunFlowStat(title: "Chips", value: "\(max(0, chips + selectedContact.chipsAdjustment))")
                    RunFlowStat(title: "Heat", value: contactHeatText)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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

                StartingContactDetailCard(contact: selectedContact)

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
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

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
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(contact.summary)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(nil)
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
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

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
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
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

    private var heatText: String {
        "\(heat)/\(maxHeat) \(HeatBand.band(for: heat, maxHeat: maxHeat).rawValue)"
    }

    var body: some View {
        RunFlowOverlay(accentColor: preview.isBossStage ? CasinoTheme.red : CasinoTheme.emerald) {
            VStack(spacing: 16) {
                Text(preview.isBossStage ? "Boss Scout Report" : "Scout Report")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(preview.isBossStage ? CasinoTheme.red : CasinoTheme.gold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stage \(preview.stageNumber): \(preview.handCount) hands")
                                .font(.title2.weight(.black))
                                .foregroundStyle(.white)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(preview.opponentName)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(preview.opponentSubtitle)
                                .font(.caption.weight(.black))
                                .foregroundStyle(CasinoTheme.gold.opacity(0.82))
                        }

                        Spacer()

                        Text("ANTE \(MoneyFormatter.format(preview.ante * 100))")
                            .font(.caption.weight(.black))
                            .foregroundStyle(CasinoTheme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(CasinoTheme.gold))
                    }

                    RunFlowDetailRow(title: "Clear", value: preview.primaryObjectiveSummary)
                    RunFlowDetailRow(title: "Wagers", value: "Min \(MoneyFormatter.format(preview.ante * 100)) / Max \(MoneyFormatter.format(preview.maxBetCents))")
                    RunFlowDetailRow(title: "Table Rule", value: preview.tableRule)
                    Text(preview.tableRuleDetail)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                    RunFlowDetailRow(title: "Reward", value: preview.stageNumber == 1 ? "+2 Chips, then Take 1 Reward" : "Final result")
                    RunFlowDetailRow(title: "Optional Bonus", value: "\(preview.secondaryObjectiveTitle) - \(preview.secondaryObjectiveReward)")
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
                .crookedPanel(
                    kind: preview.isBossStage ? .boss : .felt,
                    strokeColor: preview.isBossStage ? CrookedCasinoTheme.mutedRed : CrookedCasinoTheme.dirtyGold,
                    cornerRadius: 14
                )

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Chips", value: "\(chips)")
                    RunFlowStat(title: "Heat", value: heatText)
                }

                PrimaryRunFlowButton(title: "Enter Stage \(preview.stageNumber)", action: onEnterBattle)
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

    private var heatText: String {
        "\(heat)/\(maxHeat) \(HeatBand.band(for: heat, maxHeat: maxHeat).rawValue)"
    }

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
                    RunFlowDetailRow(title: "Result", value: result.reasonText)
                    RunFlowDetailRow(title: "Opponent", value: result.opponentName)
                    RunFlowDetailRow(title: "Started", value: MoneyFormatter.format(result.startingBankrollCents))
                    RunFlowDetailRow(title: "Ended", value: MoneyFormatter.format(result.endingBankrollCents))
                    RunFlowDetailRow(title: "Bankroll Change", value: MoneyFormatter.signed(result.bankrollChangeCents))
                    RunFlowDetailRow(title: "Clear Rule", value: result.objectiveDescription)
                    RunFlowDetailRow(title: "Progress", value: result.objectiveProgressText)
                    RunFlowDetailRow(title: "Heat Change", value: signedNumber(result.heatChange))
                    if result.chipsEarned > 0 {
                        RunFlowDetailRow(title: "Chips Earned", value: "+\(result.chipsEarned)")
                    }
                    RunFlowDetailRow(title: "Table Event", value: result.tableEventName)
                    RunFlowDetailRow(
                        title: "Optional",
                        value: result.secondaryObjectiveCompleted
                            ? "\(result.secondaryObjectiveTitle) complete"
                            : "\(result.secondaryObjectiveTitle) missed"
                    )
                    RunFlowDetailRow(title: "Main Build", value: result.buildArchetype)

                    if !result.triggeredModifierSummaries.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Modifier Activity")
                                .font(.caption.weight(.black))
                                .foregroundStyle(.white.opacity(0.58))
                                .textCase(.uppercase)

                            ForEach(result.triggeredModifierSummaries, id: \.self) { summary in
                                Text(summary)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.78))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .crookedPanel(kind: result.didWin ? .felt : .warning, strokeColor: accent, cornerRadius: 14)

                HStack(spacing: 8) {
                    RunFlowStat(title: "Bankroll", value: MoneyFormatter.format(bankrollCents))
                    RunFlowStat(title: "Heat", value: heatText)
                }

                PrimaryRunFlowButton(title: primaryActionTitle, action: onContinue)
            }
        }
    }

    private var primaryActionTitle: String {
        if result.didWin {
            return result.stageNumber == 1 ? "Take 1 Reward" : "Replay"
        }

        return "Replay"
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
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text("Buy one of three offers, reroll for 1 Chip, then continue.")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.62))
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                    }
                    .layoutPriority(1)

                    Spacer()

                    RunFlowStat(title: "Chips", value: "\(viewModel.state.runManager.chips)")
                        .frame(width: 112)
                }

                LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                    ForEach(viewModel.state.shopState.offers) { offer in
                        ShopOfferCard(
                            offer: offer,
                            ownedLevel: ownedLevel(for: offer),
                            canBuy: viewModel.canBuyShopOffer(offer),
                            attachmentTargetName: attachmentTargetName(for: offer),
                            blockedReason: viewModel.shopOfferBlockedReason(offer),
                            onBuy: { viewModel.buyShopOffer(offer) }
                        )
                    }
                }

                HStack(spacing: 8) {
                    Button(rerollButtonTitle) {
                        viewModel.rerollShop()
                    }
                    .buttonStyle(CompactShopButtonStyle(isPrimary: false))
                    .disabled(viewModel.state.runManager.chips < viewModel.state.shopState.rerollCostChips)

                    PrimaryRunFlowButton(title: nextStageButtonTitle, action: onContinue)
                }

                ShopInventorySection(
                    title: "Current Build \(viewModel.state.activeModifiers.count)/\(viewModel.state.activeModifierSlotLimit)",
                    instances: viewModel.state.activeModifiers,
                    emptyText: "Buy modifiers to build your engine."
                )

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
        viewModel.state.runManager.currentStageIndex + 1 >= viewModel.state.runManager.stages.count ? "Finish Run" : "Continue to Stage 2"
    }

    private var rerollButtonTitle: String {
        let cost = viewModel.state.shopState.rerollCostChips
        return "Reroll for \(cost) Chip\(cost == 1 ? "" : "s")"
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CrookedCasinoCard(
                kind: cardKind,
                eyebrow: kindText,
                title: title,
                description: summary,
                icon: cardIcon,
                footer: footerText,
                tags: cardTags,
                tapHint: "\(offer.priceChips)C",
                isCompact: true
            )

            HStack(spacing: 6) {
                Button(buyButtonTitle, action: onBuy)
                    .buttonStyle(CompactShopButtonStyle(isPrimary: true))
                    .disabled(!canBuy || offer.isSoldOut)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(5)
        .crookedPanel(kind: .felt, strokeColor: offer.isSoldOut ? CrookedCasinoTheme.dirtyGold : CrookedCasinoTheme.paper.opacity(0.46), cornerRadius: 14)
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
            return Modifier.definition(id: offer.contentID)?.shopMechanicText ?? "No data."
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

        return modifier.tags.map(\.displayName).sorted().prefix(3).joined(separator: " - ")
    }

    private var cardTags: [String] {
        var result = ["Cost \(offer.priceChips)"]

        if offer.kind == .modifier,
           let modifier = Modifier.definition(id: offer.contentID) {
            result.append(modifier.verticalSliceArchetype.rawValue)
            result.append(modifier.rarity.displayName)
            result.append(modifier.heatImpactText)
        } else if let tags {
            result.append(contentsOf: tags.components(separatedBy: " - "))
        }

        if let ownedLevel {
            result.append(ownedLevel >= 2 ? "Level \(ownedLevel)" : "Owned")
        }

        return result
    }

    private var footerText: String? {
        if offer.isSoldOut {
            if let ownedLevel {
                return ownedLevel >= 2 ? "Owned - Level \(ownedLevel)" : "Owned"
            }

            return "Bought"
        }

        if let attachmentTargetName {
            return "Attaches to \(attachmentTargetName)"
        }

        if let blockedReason {
            return blockedReason
        }

        return nil
    }

    private var buyButtonTitle: String {
        if offer.isSoldOut {
            if let ownedLevel, ownedLevel >= 2 {
                return "Level \(ownedLevel)"
            }

            return "Owned"
        }

        return "Buy"
    }

    private var cardKind: CrookedCardFrameKind {
        if offer.kind == .modifier,
           let modifier = Modifier.definition(id: offer.contentID) {
            return CrookedCardFrameKind(modifierRarity: modifier.rarity)
        }

        switch offer.kind {
        case .modifier:
            return .common
        case .consumable:
            return .uncommon
        case .attachment:
            return .rare
        case .bossRelic:
            return .boss
        }
    }

    private var cardIcon: CrookedDoodleIcon {
        switch offer.kind {
        case .modifier:
            if let modifier = Modifier.definition(id: offer.contentID) {
                if modifier.tags.contains(.shoeVision) || modifier.tags.contains(.shoeControl) || modifier.tags.contains(.cardSculpting) {
                    return .shoe
                }

                if modifier.tags.contains(.economy) {
                    return .chip
                }

                if modifier.tags.contains(.boss) {
                    return .skull
                }
            }

            return .spark
        case .consumable:
            return .chip
        case .attachment:
            return .hand
        case .bossRelic:
            return .crown
        }
    }

    private var kindText: String {
        if offer.kind == .modifier,
           let modifier = Modifier.definition(id: offer.contentID) {
            return modifier.verticalSliceArchetype.rawValue.uppercased()
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
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(modifier.shopMechanicText)
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.58))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                if !instance.attachedIDs.isEmpty {
                                    Text(instance.attachedIDs.compactMap { Attachment.definition(id: $0)?.name }.joined(separator: ", "))
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(CasinoTheme.gold.opacity(0.78))
                                        .lineLimit(1)
                                } else {
                                    Text(modifier.tags.map(\.displayName).sorted().prefix(3).joined(separator: " - "))
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.48))
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            Spacer()
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
                CrookedStickerShape(cornerRadius: 9)
                    .fill(backgroundColor)
            )
            .overlay(
                CrookedStickerShape(cornerRadius: 9)
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
            CrookedCasinoTheme.tableBackground
                .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        content
                            .padding(18)
                            .frame(maxWidth: min(proxy.size.width - 28, 460))
                            .crookedPanel(kind: .felt, strokeColor: accentColor, cornerRadius: 22)
                            .scaleEffect(didAppear ? 1 : 0.96)
                            .opacity(didAppear ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height, alignment: .center)
                    .padding(.vertical, 14)
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
        .crookedPanel(kind: .felt, strokeColor: CrookedCasinoTheme.paper.opacity(0.50), cornerRadius: 10)
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
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(CrookedCasinoButtonStyle(tone: .gold))
    }
}
