import SwiftUI

struct ShoeView: View {
    let cardsRemaining: Int
    let previewCards: [Card]
    let visibility: ShoeVisibilityState
    let isRevealSuppressed: Bool
    let shoeImpact: ShoeImpact
    let dealTrigger: UUID?
    let dealCardCount: Int
    var isCompact = false

    @State private var dealtCards: [ShoeDealtCard] = []
    @State private var impactPulse = false
    @State private var securityScan = false

    private var activeReveal: ActiveShoeReveal? {
        visibility.activeReveal
    }

    private var isRevealed: Bool {
        visibility.isRevealActive
    }

    private var visibleRevealCount: Int {
        visibility.revealedCards.count
    }

    private var isLocked: Bool {
        visibility.isSuppressed || isRevealSuppressed
    }

    var body: some View {
        ZStack {
            shoeShadow
            shoeBody
            shoeDashboard
            dealAnimationLayer
            ShoeModificationAnimation(impact: shoeImpact)
        }
        .frame(height: isCompact ? 126 : 154)
        .scaleEffect(isCompact ? 0.86 : 1.0)
        .scaleEffect(impactPulse ? 1.025 : 1.0)
        .rotationEffect(.degrees(shoeImpact == .shuffled && impactPulse ? -1.2 : 0))
        .animation(.spring(response: 0.24, dampingFraction: 0.55), value: impactPulse)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dealer shoe, \(cardsRemaining) cards remaining")
        .onAppear {
            securityScan = true
        }
        .onChange(of: dealTrigger) { _, _ in
            runDealAnimation()
        }
        .onChange(of: shoeImpact) { _, newValue in
            guard newValue != .none else {
                return
            }

            impactPulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                impactPulse = false
            }
        }
    }

    private var shoeDashboard: some View {
        ShoeWindowDashboard(
            cardsRemaining: cardsRemaining,
            visibility: visibility,
            activeReveal: activeReveal,
            isLocked: isLocked,
            securityScanPhase: securityScan,
            isCompact: isCompact
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var shoeShadow: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(Color.black.opacity(0.42))
            .frame(height: 122)
            .offset(y: 18)
            .blur(radius: 14)
    }

    private var shoeBody: some View {
        Color.clear
            .crookedPanel(kind: isLocked ? .warning : .felt, strokeColor: borderColor, cornerRadius: 26)
            .shadow(color: glowColor, radius: isRevealed || isLocked ? 20 : 10, y: 8)
    }

    private var cardExitSlot: some View {
        HStack {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.black.opacity(0.62))
                    .frame(width: 88, height: 34)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(CasinoTheme.gold.opacity(0.54), lineWidth: 1)
                    )

                Capsule()
                    .fill(CasinoTheme.gold.opacity(0.72))
                    .frame(width: 62, height: 4)
                    .blur(radius: 0.4)
            }
            .offset(x: 2, y: 24)
        }
        .padding(.horizontal, 20)
    }

    private var dealAnimationLayer: some View {
        ZStack {
            ForEach(dealtCards) { dealtCard in
                ShoeFlyingCard(card: dealtCard.card, sequenceIndex: dealtCard.sequenceIndex)
            }
        }
    }

    private var shoeFooter: some View {
        HStack(spacing: 8) {
            if isLocked {
                shoeStatusPill(activeReveal?.lockedReason ?? "Reveal locked", color: CasinoTheme.red, icon: "lock.fill")
            } else if isRevealed {
                shoeStatusPill(activeReveal?.title ?? "Reveal \(visibleRevealCount)", color: CasinoTheme.gold, icon: "eye.fill")
            } else {
                shoeStatusPill("Hidden shoe", color: .white.opacity(0.62), icon: "rectangle.stack.fill")
            }

            if let message = shoeImpact.message {
                shoeStatusPill(message, color: shoeImpact.isPositive ? CasinoTheme.emerald : CasinoTheme.red, icon: shoeImpactIcon)
            }

            Spacer()
        }
    }

    private var bodyColors: [Color] {
        if isLocked {
            return [
                Color(red: 0.18, green: 0.02, blue: 0.03),
                Color(red: 0.04, green: 0.015, blue: 0.02),
                Color.black
            ]
        }

        if isRevealed {
            return [
                CasinoTheme.neonBlue.opacity(0.34),
                CasinoTheme.feltDark.opacity(0.78),
                Color.black.opacity(0.82)
            ]
        }

        return [
            Color(red: 0.10, green: 0.08, blue: 0.10),
            Color(red: 0.03, green: 0.025, blue: 0.035),
            Color.black.opacity(0.96)
        ]
    }

    private var borderColor: Color {
        if isLocked {
            return CasinoTheme.red.opacity(0.78)
        }

        return isRevealed ? CasinoTheme.neonBlue.opacity(0.78) : CasinoTheme.gold.opacity(0.58)
    }

    private var glowColor: Color {
        if isLocked {
            return CasinoTheme.red.opacity(0.26)
        }

        return isRevealed ? CasinoTheme.neonBlue.opacity(0.28) : CasinoTheme.gold.opacity(0.12)
    }

    private var labelColor: Color {
        isLocked ? CasinoTheme.red : CasinoTheme.gold
    }

    private var shoeImpactIcon: String {
        switch shoeImpact {
        case .injectedCards:
            return "plus.circle.fill"
        case .removedCards:
            return "flame.fill"
        case .shuffled:
            return "shuffle"
        case .reordered:
            return "arrow.up.arrow.down.circle.fill"
        case .none:
            return "sparkles"
        }
    }

    private func shoeStatusPill(_ text: String, color: Color, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .lineLimit(1)
            .textCase(.uppercase)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color.opacity(0.13)))
            .overlay(Capsule().stroke(color.opacity(0.24), lineWidth: 1))
    }

    private func runDealAnimation() {
        guard dealCardCount > 0 else {
            return
        }

        dealtCards.removeAll()

        for index in 0..<min(dealCardCount, 6) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.12) {
                let card = previewCards.indices.contains(index) ? previewCards[index] : nil
                let dealtCard = ShoeDealtCard(card: card, sequenceIndex: index)
                dealtCards.append(dealtCard)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.58) {
                    dealtCards.removeAll { $0.id == dealtCard.id }
                }
            }
        }
    }
}

private struct ShoeWindowDashboard: View {
    let cardsRemaining: Int
    let visibility: ShoeVisibilityState
    let activeReveal: ActiveShoeReveal?
    let isLocked: Bool
    let securityScanPhase: Bool
    let isCompact: Bool

    private var revealedCards: [ShoeRevealCard] {
        visibility.revealedCards
    }

    private var isRevealActive: Bool {
        !revealedCards.isEmpty
    }

    var body: some View {
        GeometryReader { proxy in
            let revealCount = revealedCards.count
            let horizontalPadding = isCompact ? CGFloat(10) : CGFloat(12)
            let leftWidth = revealCount >= 4 ? CGFloat(70) : CGFloat(82)
            let rightWidth = revealCount >= 4 ? CGFloat(58) : CGFloat(70)
            let spacing = isCompact ? CGFloat(6) : CGFloat(8)

            ZStack {
                if isRevealActive {
                    revealField
                }

                VStack(spacing: isCompact ? 3 : 5) {
                    HStack(alignment: .center, spacing: spacing) {
                        ShoeHiddenStackZone(isLocked: isLocked)
                            .frame(width: leftWidth)

                        ShoeRevealLane(cards: revealedCards)
                            .frame(maxWidth: .infinity)
                            .frame(height: isCompact ? 70 : 80)
                            .layoutPriority(2)

                        ShoeMetadataZone(
                            cardsRemaining: cardsRemaining,
                            activeReveal: activeReveal,
                            isLocked: isLocked
                        )
                        .frame(width: rightWidth)
                    }

                    ShoeLeanZone(activeReveal: activeReveal, isLocked: isLocked)
                        .frame(height: isCompact ? 21 : 24)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, isCompact ? 8 : 10)
                .frame(width: proxy.size.width, height: proxy.size.height)

                if isLocked {
                    lockedOverlay
                }
            }
        }
    }

    private var revealField: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(CasinoTheme.neonBlue.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(CasinoTheme.neonBlue.opacity(0.18), lineWidth: 1)
            )
            .accessibilityHidden(true)
    }

    private var lockedOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.black.opacity(0.28))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            CasinoTheme.red.opacity(0.42),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50)
                .rotationEffect(.degrees(-12))
                .offset(x: securityScanPhase ? 130 : -130)
                .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: securityScanPhase)
        }
        .accessibilityHidden(true)
    }
}

private struct ShoeHiddenStackZone: View {
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 0) {
                Text("RIGGED")
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .foregroundStyle(labelColor.opacity(0.74))
                    .tracking(0.8)
                    .frame(height: 9, alignment: .bottom)

                Text("SHOE")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(labelColor)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .frame(height: 21, alignment: .top)
                    .shadow(color: labelColor.opacity(0.24), radius: 8)
            }

            ZStack {
                DealerShoeView(state: isLocked ? .angry : .idle, isCompact: true)
                    .frame(width: 76, height: 58)
                    .scaleEffect(isLocked ? 0.96 : 1.0)
                    .opacity(isLocked ? 0.72 : 1)
            }
            .frame(width: 74, height: 58, alignment: .leading)
        }
        .accessibilityHidden(true)
    }

    private var labelColor: Color {
        isLocked ? CasinoTheme.red : CasinoTheme.gold
    }

    private func faceDownCard(at index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.08, green: 0.065, blue: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(labelColor.opacity(0.36), lineWidth: 1)
                )

            if index == 4 {
                Text("RS")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(labelColor.opacity(0.82))
            }
        }
        .frame(width: 42, height: 58)
        .rotationEffect(.degrees(-5 + Double(index) * 1.35))
        .offset(x: CGFloat(index) * 6, y: CGFloat(index) * -1)
        .shadow(color: .black.opacity(0.22), radius: 3, y: 3)
        .zIndex(Double(index))
        .opacity(isLocked ? 0.56 : 1)
    }
}

private struct ShoeRevealLane: View {
    let cards: [ShoeRevealCard]

    var body: some View {
        GeometryReader { proxy in
            if cards.isEmpty {
                Color.clear
            } else {
                let spacing = cardSpacing(for: cards.count)
                let availableWidth = max(1, proxy.size.width)
                let rawWidth = (availableWidth - spacing * CGFloat(max(0, cards.count - 1))) / CGFloat(max(1, cards.count))
                let cardWidth = min(44, max(22, rawWidth))
                let cardHeight = min(proxy.size.height - 16, cardWidth * 1.42)

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(cards) { revealCard in
                        VStack(spacing: 2) {
                            Text(revealCard.destinationLabel ?? "#\(revealCard.orderIndex)")
                                .font(.system(size: max(6.5, cardWidth * 0.24), weight: .black, design: .rounded))
                                .foregroundStyle(CasinoTheme.gold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .frame(height: 10)

                            revealedShoeCard(revealCard, width: cardWidth, height: cardHeight)
                        }
                        .offset(y: revealYOffset(for: revealCard.orderIndex))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.scale(scale: 0.94).combined(with: .opacity))
            }
        }
    }

    private func revealedShoeCard(_ revealCard: ShoeRevealCard, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: max(6, width * 0.22), style: .continuous)
                .fill(revealCard.isObstructed ? Color.white.opacity(0.70) : Color.white.opacity(0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: max(6, width * 0.22), style: .continuous)
                        .stroke(revealCard.isObstructed ? CasinoTheme.gold.opacity(0.66) : CasinoTheme.neonBlue.opacity(0.76), lineWidth: 1)
                )

            if revealCard.isObstructed {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: max(8, width * 0.28), weight: .black))
                    .foregroundStyle(.black.opacity(0.44))
            } else {
                Text(revealCard.displayedText)
                    .font(.system(size: valueFontSize(for: revealCard.displayedText, width: width), weight: .black, design: .rounded))
                    .foregroundStyle(textColor(for: revealCard))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }
        }
        .frame(width: width, height: height)
        .shadow(color: CasinoTheme.neonBlue.opacity(revealCard.isObstructed ? 0.12 : 0.32), radius: 7, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revealAccessibilityLabel(for: revealCard))
    }

    private func valueFontSize(for text: String, width: CGFloat) -> CGFloat {
        if text.count >= 3 {
            return max(8.5, width * 0.34)
        }

        return max(10, width * 0.43)
    }

    private func textColor(for revealCard: ShoeRevealCard) -> Color {
        guard let card = revealCard.actualCard else {
            return .black
        }

        switch revealCard.precision {
        case .colorOnly:
            return card.suit.isRed ? CasinoTheme.red : .black
        case .hidden:
            return .black.opacity(0.74)
        case .rankOnly, .valueAndSuit:
            return card.suit.isRed ? Color.red : Color.black
        }
    }

    private func cardSpacing(for count: Int) -> CGFloat {
        count >= 5 ? 3 : count >= 4 ? 4 : 7
    }

    private func revealYOffset(for orderIndex: Int) -> CGFloat {
        let offsets: [CGFloat] = [1, -3, 1, -2, 2]
        return offsets.indices.contains(orderIndex - 1) ? offsets[orderIndex - 1] : 0
    }

    private func revealAccessibilityLabel(for revealCard: ShoeRevealCard) -> String {
        var fragments = ["Revealed shoe card \(revealCard.orderIndex)", revealCard.displayedText]

        if let destination = revealCard.destination,
           revealCard.destinationKnowledge != .none {
            fragments.append(destination.displayName)
        }

        return fragments.joined(separator: ", ")
    }
}

private struct ShoeMetadataZone: View {
    let cardsRemaining: Int
    let activeReveal: ActiveShoeReveal?
    let isLocked: Bool

    private var shoePercent: Int {
        Int((min(1.0, max(0.0, Double(cardsRemaining) / 312.0)) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            if let activeReveal {
                HStack(spacing: 4) {
                    Image(systemName: isLocked ? "lock.fill" : "eye.fill")
                        .font(.system(size: 8, weight: .black))

                    Text(activeReveal.title.uppercased())
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .tracking(0.7)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                .foregroundStyle(isLocked ? CasinoTheme.red : CasinoTheme.neonBlue)
            }

            VStack(alignment: .trailing, spacing: 0) {
                Text("\(cardsRemaining)")
                    .font(.system(size: 17, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .frame(height: 22, alignment: .center)

                Text("left")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.56))
                    .textCase(.uppercase)
                    .frame(height: 10, alignment: .center)
            }

            ProgressView(value: Double(shoePercent), total: 100)
                .progressViewStyle(.linear)
                .tint(isLocked ? CasinoTheme.red : CasinoTheme.gold)
                .frame(width: 56, height: 5)
                .background(Capsule().fill(.white.opacity(0.12)))
                .clipShape(Capsule())
                .accessibilityHidden(true)

            Text("Shoe: \(shoePercent)%")
                .font(.system(size: 7, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(height: 9, alignment: .center)

            if let status = statusText {
                Text(status)
                    .font(.system(size: 7.5, weight: .black, design: .rounded))
                    .foregroundStyle(isLocked ? CasinoTheme.red.opacity(0.88) : .white.opacity(0.66))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
        }
    }

    private var statusText: String? {
        guard let activeReveal else {
            return nil
        }

        if activeReveal.isSuppressed {
            return "Locked"
        }

        if activeReveal.remainingCharges > 0 {
            return activeReveal.remainingCharges == 1 ? "1 charge" : "\(activeReveal.remainingCharges) charges"
        }

        if let betCapMultiplierWhileActive = activeReveal.betCapMultiplierWhileActive {
            return "Cap \(betCapMultiplierWhileActive)x"
        }

        return nil
    }
}

private struct ShoeLeanZone: View {
    let activeReveal: ActiveShoeReveal?
    let isLocked: Bool

    private var favorability: ShoeFavorability? {
        guard activeReveal?.supportsFavorability == true,
              activeReveal?.isSuppressed == false else {
            return nil
        }

        return activeReveal?.favorability
    }

    var body: some View {
        HStack(spacing: 6) {
            if let favorability {
                Text(leanText(for: favorability))
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                ConfidenceMeter(
                    filledCount: confidence(for: favorability),
                    color: color(for: favorability)
                )
            } else if isLocked {
                Text("Reveal locked")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(CasinoTheme.red.opacity(0.86))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func leanText(for favorability: ShoeFavorability) -> String {
        switch favorability {
        case .lean(let betType), .strong(let betType):
            return "LEAN: \(betType.displayName.uppercased())"
        case .tieWatch:
            return "LEAN: TIE"
        case .noClearEdge:
            return "NO CLEAR EDGE"
        }
    }

    private func confidence(for favorability: ShoeFavorability) -> Int {
        switch favorability {
        case .noClearEdge:
            return 1
        case .lean:
            return 3
        case .tieWatch:
            return 4
        case .strong:
            return 5
        }
    }

    private func color(for favorability: ShoeFavorability) -> Color {
        switch favorability {
        case .lean(let betType), .strong(let betType):
            switch betType {
            case .player:
                return CasinoTheme.neonBlue
            case .banker:
                return CasinoTheme.red
            case .tie:
                return CasinoTheme.gold
            }
        case .tieWatch:
            return CasinoTheme.gold
        case .noClearEdge:
            return .white.opacity(0.36)
        }
    }
}

private struct ConfidenceMeter: View {
    let filledCount: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(index < filledCount ? color : .white.opacity(0.14))
                    .frame(width: 8, height: 7)
            }
        }
        .accessibilityLabel("Confidence \(filledCount) out of 5")
    }
}

struct ShoeCardStackView: View {
    let visibility: ShoeVisibilityState
    let isSuppressed: Bool

    var body: some View {
        ZStack {
            ForEach(0..<max(0, visibility.hiddenDisplayCount), id: \.self) { index in
                hiddenStackCard(at: index)
            }

            if !visibility.revealedCards.isEmpty {
                HStack(spacing: cardSpacing(for: visibility.revealedCards.count)) {
                    ForEach(visibility.revealedCards) { revealCard in
                        revealedShoeCard(revealCard, total: visibility.revealedCards.count)
                            .offset(y: revealYOffset(for: revealCard.orderIndex))
                    }
                }
                .frame(maxWidth: 198)
                .offset(x: 36, y: 29)
                .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .mask(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .padding(.vertical, 3)
        )
    }

    private func hiddenStackCard(at index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.08, green: 0.06, blue: 0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(CasinoTheme.gold.opacity(0.32), lineWidth: 1)
                )

            Text("RS")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(isSuppressed ? CasinoTheme.red.opacity(0.48) : CasinoTheme.gold.opacity(0.38))
        }
        .frame(width: 46, height: 62)
        .rotationEffect(.degrees(Double(index) * -1.2 - 2))
        .offset(x: CGFloat(index) * 8 - 82, y: CGFloat(index) * -2 + 31)
        .shadow(color: .black.opacity(0.20), radius: 3, y: 3)
        .opacity(isSuppressed ? 0.48 : 1)
        .zIndex(Double(index))
    }

    private func revealedShoeCard(_ revealCard: ShoeRevealCard, total: Int) -> some View {
        let width = total >= 5 ? CGFloat(34) : total >= 4 ? CGFloat(38) : CGFloat(44)
        let height = total >= 5 ? CGFloat(51) : total >= 4 ? CGFloat(56) : CGFloat(62)

        return ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(revealCard.isObstructed ? Color.white.opacity(0.72) : Color.white.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(revealCard.isObstructed ? CasinoTheme.gold.opacity(0.72) : CasinoTheme.neonBlue.opacity(0.70), lineWidth: 1)
                )

            if revealCard.isObstructed {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.32),
                                Color.black.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 2) {
                if let destinationLabel = revealCard.destinationLabel {
                    Text(destinationLabel)
                        .font(.system(size: 7, weight: .black, design: .rounded))
                        .foregroundStyle(CasinoTheme.neonBlue)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }

                Text(revealCard.displayedText)
                    .font(.system(size: revealCard.displayedText.count > 2 ? 11 : 14, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                    .foregroundStyle(textColor(for: revealCard))
            }
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(revealCard.isObstructed ? 1.0 : -1.2))
        .shadow(color: CasinoTheme.neonBlue.opacity(revealCard.isObstructed ? 0.16 : 0.34), radius: revealCard.isObstructed ? 5 : 9, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revealAccessibilityLabel(for: revealCard))
    }

    private func textColor(for revealCard: ShoeRevealCard) -> Color {
        guard let card = revealCard.actualCard else {
            return .black
        }

        switch revealCard.precision {
        case .colorOnly:
            return card.suit.isRed ? CasinoTheme.red : .black
        case .hidden:
            return .black.opacity(0.74)
        case .rankOnly, .valueAndSuit:
            return card.suit.isRed ? Color.red : Color.black
        }
    }

    private func cardSpacing(for count: Int) -> CGFloat {
        count >= 5 ? 3 : count >= 4 ? 4 : 8
    }

    private func revealYOffset(for orderIndex: Int) -> CGFloat {
        let offsets: [CGFloat] = [4, -2, 2, -3, 3]
        return offsets.indices.contains(orderIndex - 1) ? offsets[orderIndex - 1] : 0
    }

    private func revealAccessibilityLabel(for revealCard: ShoeRevealCard) -> String {
        var fragments = ["Revealed shoe card \(revealCard.orderIndex)", revealCard.displayedText]

        if let destination = revealCard.destination,
           revealCard.destinationKnowledge != .none {
            fragments.append(destination.displayName)
        }

        return fragments.joined(separator: ", ")
    }
}

struct ShoeRevealOverlay: View {
    let previewCards: [Card]
    let activeReveal: ActiveShoeReveal?
    let isRevealActive: Bool
    let isSuppressed: Bool
    let securityScanPhase: Bool

    var body: some View {
        ZStack {
            if isRevealActive {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(CasinoTheme.neonBlue.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(CasinoTheme.neonBlue.opacity(0.40), lineWidth: 1)
                    )

                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CasinoTheme.neonBlue.opacity(0.20), lineWidth: 1)
                        .frame(width: 120 + CGFloat(index * 36), height: 54 + CGFloat(index * 24))
                        .blur(radius: 0.2)
                }

                revealStatus

                if showsDestinationLegend {
                    revealLegend
                }
            }

            if isSuppressed {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black.opacity(0.40))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(CasinoTheme.red.opacity(0.52), lineWidth: 1)
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                CasinoTheme.red.opacity(0.48),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 52, height: 150)
                    .rotationEffect(.degrees(-12))
                    .offset(x: securityScanPhase ? 128 : -128)
                    .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: securityScanPhase)

                VStack(spacing: 5) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2.weight(.black))
                    Text("SURVEILLANCE")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
                .foregroundStyle(CasinoTheme.red)
                .shadow(color: CasinoTheme.red.opacity(0.42), radius: 8)
                .offset(y: -12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var revealStatus: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(activeReveal?.title.uppercased() ?? "REVEAL")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(CasinoTheme.neonBlue.opacity(0.80))
                .tracking(1.5)

            if let favorability = activeReveal?.favorability,
               activeReveal?.supportsFavorability == true {
                Text(favorability.displayText)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(favorabilityColor(favorability))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }

            if let statusText = activeReveal?.statusText,
               !statusText.isEmpty {
                Text(statusText)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

        }
        .frame(maxWidth: 126, alignment: .trailing)
        .offset(x: 78, y: -36)
    }

    private var revealLegend: some View {
        Text("P = Player   B = Banker")
            .font(.system(size: 7.5, weight: .black, design: .rounded))
            .foregroundStyle(.white.opacity(0.82))
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.42))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(CasinoTheme.neonBlue.opacity(0.24), lineWidth: 1)
                    )
            )
            .offset(x: 18, y: -4)
            .accessibilityHidden(true)
    }

    private var showsDestinationLegend: Bool {
        activeReveal?.cards.contains { $0.destinationLabel != nil } == true
    }

    private func favorabilityColor(_ favorability: ShoeFavorability) -> Color {
        switch favorability {
        case .strong(let betType), .lean(let betType):
            return betType == .tie ? CasinoTheme.gold : CasinoTheme.emerald
        case .tieWatch:
            return CasinoTheme.gold
        case .noClearEdge:
            return .white.opacity(0.70)
        }
    }
}

struct ShoeModificationAnimation: View {
    let impact: ShoeImpact

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            switch impact {
            case .none:
                EmptyView()
            case .injectedCards(let count):
                injectionAnimation(count: count)
            case .removedCards(let count):
                purgeAnimation(count: count)
            case .shuffled:
                shuffleAnimation
            case .reordered:
                shuffleAnimation
            }
        }
        .onAppear {
            run()
        }
        .onChange(of: impact) { _, _ in
            run()
        }
    }

    private func injectionAnimation(count: Int) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.94))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(CasinoTheme.emerald.opacity(0.72), lineWidth: 1)
                    )
                    .frame(width: 32, height: 46)
                    .offset(x: isAnimating ? -14 + CGFloat(index * 9) : -190, y: CGFloat(index * 4) - 8)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.52).delay(Double(index) * 0.035), value: isAnimating)
            }

            impactLabel("+\(count) cards", color: CasinoTheme.emerald, icon: "plus.circle.fill")
        }
    }

    private func purgeAnimation(count: Int) -> some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "flame.fill" : "xmark")
                    .font(.system(size: index.isMultiple(of: 2) ? 18 : 14, weight: .black))
                    .foregroundStyle(CasinoTheme.red.opacity(isAnimating ? 0.0 : 0.90))
                    .offset(x: CGFloat(index * 22) - 60, y: isAnimating ? -72 : -20)
                    .scaleEffect(isAnimating ? 1.45 : 0.74)
                    .animation(.easeOut(duration: 0.56).delay(Double(index) * 0.03), value: isAnimating)
            }

            impactLabel("-\(count) purged", color: CasinoTheme.red, icon: "flame.fill")
        }
    }

    private var shuffleAnimation: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(CasinoTheme.gold.opacity(isAnimating ? 0.0 : 0.42), lineWidth: 2)
                    .scaleEffect(isAnimating ? 1.10 + CGFloat(index) * 0.08 : 0.86)
                    .animation(.easeOut(duration: 0.58).delay(Double(index) * 0.08), value: isAnimating)
            }

            impactLabel("Shuffled", color: CasinoTheme.gold, icon: "shuffle")
        }
    }

    private func impactLabel(_ text: String, color: Color, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.black)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(color))
            .shadow(color: color.opacity(0.45), radius: 12)
            .scaleEffect(isAnimating ? 1.0 : 0.86)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: -66)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: isAnimating)
    }

    private func run() {
        guard impact != .none else {
            isAnimating = false
            return
        }

        isAnimating = false
        DispatchQueue.main.async {
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = false
        }
    }
}

private struct ShoeFlyingCard: View {
    let card: Card?
    let sequenceIndex: Int

    @State private var hasMoved = false

    var body: some View {
        CardView(card: nil, isFaceDown: true)
            .frame(width: 38)
            .rotationEffect(.degrees(hasMoved ? Double(sequenceIndex - 2) * 5 : -8))
            .offset(x: hasMoved ? 132 : 42, y: hasMoved ? 78 : 24)
            .opacity(hasMoved ? 0.0 : 1.0)
            .shadow(color: CasinoTheme.gold.opacity(0.40), radius: 12)
            .onAppear {
                withAnimation(.easeOut(duration: 0.48)) {
                    hasMoved = true
                }
            }
    }
}

private struct ShoeDealtCard: Identifiable, Equatable {
    let id = UUID()
    let card: Card?
    let sequenceIndex: Int
}
