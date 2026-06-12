import AppKit
import ApplicationServices
import Foundation

public final class FocusCaptureService {
    public init() {}

    public func capture() -> FocusSnapshot? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        let focusedElement = copyFocusedElement()
        return FocusSnapshot(
            applicationPID: app.processIdentifier,
            bundleIdentifier: app.bundleIdentifier,
            localizedName: app.localizedName,
            focusedElement: focusedElement
        )
    }

    private func copyFocusedElement() -> AXUIElement? {
        let system = AXUIElementCreateSystemWide()
        var focusedApplication: CFTypeRef?
        let appResult = AXUIElementCopyAttributeValue(
            system,
            kAXFocusedApplicationAttribute as CFString,
            &focusedApplication
        )

        guard appResult == .success, let focusedApplication else {
            return nil
        }

        var focusedElement: CFTypeRef?
        let elementResult = AXUIElementCopyAttributeValue(
            focusedApplication as! AXUIElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )

        guard elementResult == .success, let focusedElement else {
            return nil
        }

        return (focusedElement as! AXUIElement)
    }
}
