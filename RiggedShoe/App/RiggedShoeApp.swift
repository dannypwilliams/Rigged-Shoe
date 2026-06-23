import SwiftUI

@main
struct RiggedShoeApp: App {
    init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--reset-run") {
            RunPersistenceManager.clear()
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
