import XCTest
import ApplicationServices
@testable import LinguaFloatCore

final class TextInsertionServiceTests: XCTestCase {
    func testDoesNotReportInsertedWhenAccessibilityPermissionIsMissing() async {
        let keyboard = MockKeyboardEventSender()
        let permissions = MockAccessibilityPermissionChecker(isTrusted: false)
        let service = TextInsertionService(
            keyboardEventService: keyboard,
            accessibilityPermissionService: permissions
        )

        let result = await service.insert(text: "hello", into: nil)

        XCTAssertEqual(result, .copiedRequiresManualPaste)
        XCTAssertFalse(keyboard.didSendCommandV)
        XCTAssertEqual(permissions.prompts, [true])
    }

    func testTreatsAccessibilitySuccessWithoutInsertedValueAsFailed() {
        let result = TextInsertionService.verifiedAccessibilityInsertResult(
            setSelectedTextResult: .success,
            valueAfterInsert: "",
            insertedText: "hello"
        )

        XCTAssertEqual(result, .failed("Accessibility selected text insert did not change the focused element."))
    }
}

private final class MockKeyboardEventSender: KeyboardEventSending {
    var didSendCommandV = false

    func sendCommandV() {
        didSendCommandV = true
    }
}

private final class MockAccessibilityPermissionChecker: AccessibilityPermissionChecking {
    let trusted: Bool
    var prompts: [Bool] = []

    init(isTrusted: Bool) {
        self.trusted = isTrusted
    }

    func isTrusted(prompt: Bool) -> Bool {
        prompts.append(prompt)
        return trusted
    }

    @MainActor
    func openSystemSettings() {}
}
