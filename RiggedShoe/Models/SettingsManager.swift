import Foundation

final class SettingsManager: ObservableObject {
    private enum Keys {
        static let musicVolume = "riggedShoe.settings.musicVolume"
        static let sfxVolume = "riggedShoe.settings.sfxVolume"
        static let isMusicMuted = "riggedShoe.settings.isMusicMuted"
        static let isSFXMuted = "riggedShoe.settings.isSFXMuted"
        static let isHapticsEnabled = "riggedShoe.settings.isHapticsEnabled"
        static let isReduceMotionEnabled = "riggedShoe.settings.isReduceMotionEnabled"
    }

    @Published var musicVolume: Double {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: Keys.musicVolume)
        }
    }

    @Published var sfxVolume: Double {
        didSet {
            UserDefaults.standard.set(sfxVolume, forKey: Keys.sfxVolume)
        }
    }

    @Published var isMusicMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMusicMuted, forKey: Keys.isMusicMuted)
        }
    }

    @Published var isSFXMuted: Bool {
        didSet {
            UserDefaults.standard.set(isSFXMuted, forKey: Keys.isSFXMuted)
        }
    }

    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: Keys.isHapticsEnabled)
        }
    }

    @Published var isReduceMotionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isReduceMotionEnabled, forKey: Keys.isReduceMotionEnabled)
        }
    }

    init() {
        self.musicVolume = UserDefaults.standard.object(forKey: Keys.musicVolume) as? Double ?? 0.65
        self.sfxVolume = UserDefaults.standard.object(forKey: Keys.sfxVolume) as? Double ?? 0.80
        self.isMusicMuted = UserDefaults.standard.bool(forKey: Keys.isMusicMuted)
        self.isSFXMuted = UserDefaults.standard.bool(forKey: Keys.isSFXMuted)
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: Keys.isHapticsEnabled) as? Bool ?? true
        self.isReduceMotionEnabled = UserDefaults.standard.bool(forKey: Keys.isReduceMotionEnabled)
    }

    func restoreDefaults() {
        musicVolume = 0.65
        sfxVolume = 0.80
        isMusicMuted = false
        isSFXMuted = false
        isHapticsEnabled = true
        isReduceMotionEnabled = false
    }
}
