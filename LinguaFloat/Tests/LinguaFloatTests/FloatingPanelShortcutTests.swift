import AppKit
import Carbon.HIToolbox
import XCTest
@testable import LinguaFloatCore

@MainActor
final class FloatingPanelShortcutTests: XCTestCase {
    func testCommand3DispatchesSettingsDefaultOutputCommand() {
        let textView = PlaceholderTextView(frame: .zero)
        var receivedCommand: FloatingPanelCommand?
        textView.commandHandler = { command in
            receivedCommand = command
            return true
        }

        textView.keyDown(with: keyEvent(key: "3", keyCode: UInt16(kVK_ANSI_3), modifiers: .command))

        XCTAssertEqual(receivedCommand, .useSettingsDefault)
    }

    func testCommandShiftMDispatchesMultiLanguageToggleCommand() {
        let textView = PlaceholderTextView(frame: .zero)
        var receivedCommand: FloatingPanelCommand?
        textView.commandHandler = { command in
            receivedCommand = command
            return true
        }

        textView.keyDown(with: keyEvent(key: "m", keyCode: UInt16(kVK_ANSI_M), modifiers: [.command, .shift]))

        XCTAssertEqual(receivedCommand, .toggleMultiLanguageOutput)
    }

    private func keyEvent(
        key: String,
        keyCode: UInt16,
        modifiers: NSEvent.ModifierFlags
    ) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifiers,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: key,
            charactersIgnoringModifiers: key,
            isARepeat: false,
            keyCode: keyCode
        )!
    }
}
