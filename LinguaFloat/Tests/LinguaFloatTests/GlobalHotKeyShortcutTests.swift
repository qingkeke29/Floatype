import Carbon.HIToolbox
import XCTest
@testable import LinguaFloatCore

final class GlobalHotKeyShortcutTests: XCTestCase {
    func testDefaultShortcutIsCommandZ() {
        XCTAssertEqual(GlobalHotKeyShortcut.defaultShortcut.displayName, "Command + Z")
        XCTAssertEqual(GlobalHotKeyShortcut.defaultShortcut.modifiers, UInt32(cmdKey))
        XCTAssertEqual(GlobalHotKeyShortcut.defaultShortcut.keyCode, UInt32(kVK_ANSI_Z))
    }

    func testDefaultShortcutsOnlyRegistersConfiguredShortcut() {
        let names = GlobalHotKeyShortcut.defaultShortcuts.map(\.displayName)

        XCTAssertEqual(names, ["Command + Z"])
    }

    func testDisplaySummaryListsAllRegisteredShortcuts() {
        XCTAssertEqual(
            GlobalHotKeyShortcut.defaultDisplaySummary,
            "Command + Z"
        )
    }

    func testShortcutCanBeRecordedByPressingModifierThenKey() throws {
        var recorder = HotKeyRecorder()

        XCTAssertNil(try recorder.record(.modifier(.command)))
        let shortcut = try XCTUnwrap(recorder.record(.key(.j)))

        XCTAssertEqual(shortcut.displayName, "Command + J")
        XCTAssertEqual(shortcut.modifiers, UInt32(cmdKey))
        XCTAssertEqual(shortcut.keyCode, UInt32(kVK_ANSI_J))
    }

    func testShortcutCanBeRecordedByPressingKeyThenModifier() throws {
        var recorder = HotKeyRecorder()

        XCTAssertNil(try recorder.record(.key(.space)))
        let shortcut = try XCTUnwrap(recorder.record(.modifier(.option)))

        XCTAssertEqual(shortcut.displayName, "Option + Space")
        XCTAssertEqual(shortcut.storageValue, "option+space")
    }

    func testRecorderRejectsTwoNormalKeys() throws {
        var recorder = HotKeyRecorder()

        XCTAssertNil(try recorder.record(.key(.a)))
        XCTAssertThrowsError(try recorder.record(.key(.b)))
    }
}
