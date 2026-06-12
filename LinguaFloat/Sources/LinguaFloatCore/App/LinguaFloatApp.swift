import AppKit
import Foundation

public enum LinguaFloatApp {
    @MainActor private static var retainedDelegate: AppDelegate?

    @MainActor
    public static func run() {
        guard !anotherInstanceIsRunning() else {
            return
        }

        let app = NSApplication.shared
        let delegate = AppDelegate()
        retainedDelegate = delegate
        app.delegate = delegate
        app.run()
    }

    @MainActor
    private static func anotherInstanceIsRunning() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }

        let currentPID = ProcessInfo.processInfo.processIdentifier
        let existing = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .first { $0.processIdentifier != currentPID }

        existing?.activate(options: [])
        return existing != nil
    }
}
