import AppKit
import ApplicationServices
import Foundation

public struct FocusSnapshot {
    public let applicationPID: pid_t
    public let bundleIdentifier: String?
    public let localizedName: String?
    public let focusedElement: AXUIElement?
    public let capturedAt: Date

    public init(
        applicationPID: pid_t,
        bundleIdentifier: String?,
        localizedName: String?,
        focusedElement: AXUIElement?,
        capturedAt: Date = Date()
    ) {
        self.applicationPID = applicationPID
        self.bundleIdentifier = bundleIdentifier
        self.localizedName = localizedName
        self.focusedElement = focusedElement
        self.capturedAt = capturedAt
    }
}
