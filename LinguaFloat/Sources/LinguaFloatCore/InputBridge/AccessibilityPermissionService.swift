import AppKit
import ApplicationServices
import Foundation

public protocol AccessibilityPermissionChecking: AnyObject {
    func isTrusted(prompt: Bool) -> Bool

    @MainActor
    func openSystemSettings()
}

public final class AccessibilityPermissionService: AccessibilityPermissionChecking {
    public init() {}

    public func isTrusted(prompt: Bool = false) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    @MainActor
    public func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
