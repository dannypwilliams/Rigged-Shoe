import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var audioManager: AudioManager
    let analyticsLog: String
    let onReplayTutorial: () -> Void
    let onShowGlossary: () -> Void
    let onShowSupport: () -> Void
    let onResetProfile: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            CasinoTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack {
                    Text("Settings")
                        .font(.system(size: 34, weight: .black, design: .rounded))
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

                    VStack(spacing: 16) {
                    settingSlider(
                        title: "Music Volume",
                        value: $settings.musicVolume,
                        isMuted: $settings.isMusicMuted
                    )

                    settingSlider(
                        title: "SFX Volume",
                        value: $settings.sfxVolume,
                        isMuted: $settings.isSFXMuted
                    )

                    Toggle("Haptics", isOn: $settings.isHapticsEnabled)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .tint(CasinoTheme.gold)

                    Toggle("Reduce Motion", isOn: $settings.isReduceMotionEnabled)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .tint(CasinoTheme.gold)

                    HStack {
                        Text("Music Layer")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.62))

                        Spacer()

                        Text(audioManager.currentMusicLayer.displayName)
                            .font(.subheadline.monospacedDigit().weight(.black))
                            .foregroundStyle(CasinoTheme.gold)
                    }
                    }
                    .padding(16)
                    .neonPanel()

                    VStack(spacing: 10) {
                    settingsButton("Replay Tutorial", systemImage: "questionmark.circle.fill", action: onReplayTutorial)
                    settingsButton("Open Glossary", systemImage: "book.closed.fill", action: onShowGlossary)
                    settingsButton("Playtest Hub", systemImage: "testtube.2", action: onShowSupport)

                    ShareLink(item: analyticsLog.isEmpty ? "No Rigged Shoe analytics events yet." : analyticsLog) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Export Playtest Logs")
                            Spacer()
                        }
                        .font(.headline.weight(.black))
                        .foregroundStyle(.black)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(CasinoTheme.gold))
                    }

                    settingsButton("Restore Settings Defaults", systemImage: "arrow.counterclockwise") {
                        settings.restoreDefaults()
                    }
                    }
                    .padding(16)
                    .neonPanel(strokeColor: CasinoTheme.gold, opacity: 0.22)

                    VStack(alignment: .leading, spacing: 12) {
                    Text("Credits")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)

                    Text("Rigged Shoe. Built with SwiftUI. Current audio uses generated table tones and is ready for final casino assets.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.64))

                    Text(BuildInfo.versionText)
                        .font(.caption.monospacedDigit().weight(.black))
                        .foregroundStyle(.white.opacity(0.50))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .neonPanel(strokeColor: CasinoTheme.emerald, opacity: 0.20)

                    Button(role: .destructive, action: onResetProfile) {
                    Text("Reset Profile")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(CasinoTheme.red.opacity(0.72))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
    }

    private func settingSlider(title: String, value: Binding<Double>, isMuted: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    isMuted.wrappedValue.toggle()
                } label: {
                    Text(isMuted.wrappedValue ? "Muted" : "On")
                        .font(.caption.weight(.black))
                        .foregroundStyle(isMuted.wrappedValue ? .white.opacity(0.56) : .black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isMuted.wrappedValue ? Color.white.opacity(0.10) : CasinoTheme.gold)
                        )
                }
                .buttonStyle(.plain)
            }

            Slider(value: value, in: 0...1)
                .tint(CasinoTheme.gold)
                .disabled(isMuted.wrappedValue)
        }
    }

    private func settingsButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
            }
            .font(.headline.weight(.black))
            .foregroundStyle(.white)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.09)))
        }
        .buttonStyle(.plain)
    }
}
