import AVFoundation
import Foundation

final class AudioManager: ObservableObject {
    @Published private(set) var currentMusicLayer: MusicLayer = .normalRun
    @Published private(set) var currentThemeID: CasinoThemeID = .lasVegas
    @Published private(set) var isTransitioning = false

    private let engine = AVAudioEngine()
    private let sfxPlayer = AVAudioPlayerNode()
    private let musicPlayer = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
    private var lastSFXTime: [SFXEvent: Date] = [:]
    private var isAudioAvailable = true

    private var isAudioDisabledForRuntime: Bool {
#if targetEnvironment(simulator)
        // The generated AVAudioEngine tones can deadlock CoreAudio cleanup in some simulator runtimes.
        // Keep the hooks active for UI state, but no-op playback locally so the app always launches.
        return true
#else
        return false
#endif
    }

    init() {
        guard let format, !isAudioDisabledForRuntime else {
            return
        }

        engine.attach(sfxPlayer)
        engine.attach(musicPlayer)
        engine.connect(sfxPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1
    }

    func transition(to layer: MusicLayer, settings: SettingsManager, themeID: CasinoThemeID = .lasVegas) {
        let targetLayer = settings.isMusicMuted || settings.musicVolume <= 0 ? MusicLayer.muted : layer
        guard currentMusicLayer != targetLayer
                || currentThemeID != themeID
                || musicPlayer.volume != Float(settings.musicVolume) else {
            return
        }

        currentMusicLayer = targetLayer
        currentThemeID = themeID
        isTransitioning = true

        guard !isAudioDisabledForRuntime, isAudioAvailable, startEngineIfNeeded() else {
            isTransitioning = false
            return
        }

        if targetLayer == .muted {
            musicPlayer.stop()
            isTransitioning = false
            return
        }

        musicPlayer.stop()
        musicPlayer.volume = Float(settings.musicVolume) * 0.18
        guard let buffer = musicBuffer(for: targetLayer, themeID: themeID) else {
            isTransitioning = false
            return
        }

        musicPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        musicPlayer.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.isTransitioning = false
        }
    }

    func play(_ event: SFXEvent, settings: SettingsManager) {
        guard !settings.isSFXMuted, settings.sfxVolume > 0 else {
            return
        }

        let now = Date()
        if let lastPlayed = lastSFXTime[event], now.timeIntervalSince(lastPlayed) < 0.045 {
            return
        }

        lastSFXTime[event] = now
        guard !isAudioDisabledForRuntime, isAudioAvailable, startEngineIfNeeded() else {
            return
        }

        let recipe = sfxRecipe(for: event)
        guard let buffer = toneBuffer(
            frequency: recipe.frequency,
            endFrequency: recipe.endFrequency,
            duration: recipe.duration,
            volume: Float(settings.sfxVolume) * recipe.volume
        ) else {
            return
        }

        sfxPlayer.scheduleBuffer(buffer)

        if !sfxPlayer.isPlaying {
            sfxPlayer.play()
        }
    }

    private func startEngineIfNeeded() -> Bool {
        guard !engine.isRunning else {
            return true
        }

        do {
            try engine.start()
            return true
        } catch {
            isAudioAvailable = false
            return false
        }
    }

    private func sfxRecipe(for event: SFXEvent) -> (frequency: Double, endFrequency: Double, duration: Double, volume: Float) {
        switch event {
        case .cardDeal:
            return (620, 420, 0.055, 0.20)
        case .chipGain:
            return (760, 1_140, 0.13, 0.24)
        case .chipLoss:
            return (260, 140, 0.16, 0.22)
        case .upgradeSelection:
            return (540, 980, 0.18, 0.24)
        case .bossIntro:
            return (130, 90, 0.34, 0.34)
        case .bossDefeat:
            return (220, 880, 0.42, 0.36)
        case .stageClear:
            return (440, 880, 0.26, 0.30)
        case .bigWin:
            return (860, 1_420, 0.30, 0.34)
        case .jackpot:
            return (980, 1_760, 0.48, 0.40)
        case .achievementUnlock:
            return (660, 1_240, 0.24, 0.28)
        case .runVictory:
            return (520, 1_320, 0.55, 0.38)
        }
    }

    private func musicBuffer(for layer: MusicLayer, themeID: CasinoThemeID) -> AVAudioPCMBuffer? {
        let baseFrequencies: [Double]

        switch layer {
        case .normalRun:
            baseFrequencies = [110, 165, 220]
        case .boss:
            baseFrequencies = [82, 123, 185]
        case .finalBoss:
            baseFrequencies = [55, 82, 110, 165]
        case .victory:
            baseFrequencies = [220, 277, 330, 440]
        case .muted:
            baseFrequencies = [0]
        }

        let frequencies = baseFrequencies.map { $0 * themePitchMultiplier(themeID) }
        return chordBuffer(frequencies: frequencies, duration: 2.4, volume: 0.12)
    }

    private func themePitchMultiplier(_ themeID: CasinoThemeID) -> Double {
        switch themeID {
        case .lasVegas:
            return 1.00
        case .macau:
            return 1.08
        case .monteCarlo:
            return 0.96
        case .underground:
            return 0.88
        case .cyber:
            return 1.18
        case .goldRoom:
            return 1.03
        }
    }

    private func toneBuffer(frequency: Double, endFrequency: Double, duration: Double, volume: Float) -> AVAudioPCMBuffer? {
        guard let format else {
            return nil
        }

        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        guard let channel = buffer.floatChannelData?[0] else {
            return buffer
        }

        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / Double(max(1, Int(frameCount) - 1))
            let frequencyAtFrame = frequency + (endFrequency - frequency) * progress
            let envelope = sin(progress * Double.pi)
            let sample = sin(2 * Double.pi * frequencyAtFrame * Double(frame) / format.sampleRate)
            channel[frame] = Float(sample * envelope) * volume
        }

        return buffer
    }

    private func chordBuffer(frequencies: [Double], duration: Double, volume: Float) -> AVAudioPCMBuffer? {
        guard let format else {
            return nil
        }

        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        guard let channel = buffer.floatChannelData?[0] else {
            return buffer
        }

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / format.sampleRate
            let progress = Double(frame) / Double(max(1, Int(frameCount) - 1))
            let pulse = 0.55 + 0.45 * sin(progress * Double.pi * 2)
            let sample = frequencies.reduce(0.0) { partial, frequency in
                partial + sin(2 * Double.pi * frequency * time)
            } / Double(max(1, frequencies.count))

            channel[frame] = Float(sample * pulse) * volume
        }

        return buffer
    }
}
