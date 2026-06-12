import AppKit
import ApplicationServices
import Foundation

public enum TextInsertionResult: Equatable {
    case inserted
    case copiedRequiresManualPaste
    case rejected(String)
    case failed(String)
}

public final class TextInsertionService {
    private let keyboardEventService: KeyboardEventSending
    private let accessibilityPermissionService: AccessibilityPermissionChecking

    public init(
        keyboardEventService: KeyboardEventSending,
        accessibilityPermissionService: AccessibilityPermissionChecking
    ) {
        self.keyboardEventService = keyboardEventService
        self.accessibilityPermissionService = accessibilityPermissionService
    }

    @MainActor
    public func insert(text: String, into snapshot: FocusSnapshot?) async -> TextInsertionResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .rejected("没有可写入的内容。")
        }

        let isTrusted = accessibilityPermissionService.isTrusted(prompt: true)
        AppLogger.insertion.info("Accessibility trust before insertion: \(isTrusted, privacy: .public)")
        guard isTrusted else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            return .copiedRequiresManualPaste
        }

        if let snapshot {
            NSRunningApplication(processIdentifier: snapshot.applicationPID)?
                .activate(options: [])
            try? await Task.sleep(nanoseconds: 180_000_000)

            if let focusedElement = snapshot.focusedElement {
                switch tryAccessibilityInsert(text: text, element: focusedElement) {
                case .inserted:
                    return .inserted
                case .rejected(let message):
                    return .rejected(message)
                case .failed:
                    break
                case .copiedRequiresManualPaste:
                    break
                }
            }
        }

        return await pasteWithClipboardRestore(text: text)
    }

    private func tryAccessibilityInsert(text: String, element: AXUIElement) -> TextInsertionResult {
        guard isEditableTextElement(element) else {
            return .failed("Focused element is not an editable text element.")
        }
        guard !isSecureTextElement(element) else {
            return .rejected("当前输入框是受保护或密码输入框，Floatype（浮译）不会写入。")
        }

        let selectedTextResult = AXUIElementSetAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            text as CFTypeRef
        )

        return Self.verifiedAccessibilityInsertResult(
            setSelectedTextResult: selectedTextResult,
            valueAfterInsert: textValue(of: element),
            insertedText: text
        )
    }

    static func verifiedAccessibilityInsertResult(
        setSelectedTextResult: AXError,
        valueAfterInsert: String?,
        insertedText: String
    ) -> TextInsertionResult {
        guard setSelectedTextResult == .success else {
            return .failed("Accessibility selected text insert failed.")
        }
        guard let valueAfterInsert else {
            return .inserted
        }
        guard valueAfterInsert.contains(insertedText) else {
            return .failed("Accessibility selected text insert did not change the focused element.")
        }
        return .inserted
    }

    private func isEditableTextElement(_ element: AXUIElement) -> Bool {
        var roleRef: CFTypeRef?
        let roleResult = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        guard roleResult == .success, let role = roleRef as? String else {
            return false
        }

        let editableRoles = [
            kAXTextFieldRole as String,
            kAXTextAreaRole as String,
            "AXComboBox"
        ]
        return editableRoles.contains(role)
    }

    private func textValue(of element: AXUIElement) -> String? {
        var valueRef: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef)
        guard valueResult == .success else {
            return nil
        }
        return valueRef as? String
    }

    private func isSecureTextElement(_ element: AXUIElement) -> Bool {
        var roleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        _ = AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subroleRef)
        let combined = [roleRef as? String, subroleRef as? String]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
        return combined.contains("secure") || combined.contains("password")
    }

    @MainActor
    private func pasteWithClipboardRestore(text: String) async -> TextInsertionResult {
        let snapshot = PasteboardSnapshot.capture()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        keyboardEventService.sendCommandV()
        try? await Task.sleep(nanoseconds: 300_000_000)
        snapshot.restore()
        return .inserted
    }
}
