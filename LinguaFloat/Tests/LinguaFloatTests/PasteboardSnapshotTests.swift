import AppKit
import XCTest
@testable import LinguaFloatCore

final class PasteboardSnapshotTests: XCTestCase {
    func testCapturesAndRestoresPlainText() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("LinguaFloatPlainTextTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setString("original", forType: .string)

        let snapshot = PasteboardSnapshot.capture(from: pasteboard)
        pasteboard.clearContents()
        pasteboard.setString("replacement", forType: .string)
        snapshot.restore(to: pasteboard)

        XCTAssertEqual(pasteboard.string(forType: .string), "original")
    }

    func testCapturesAndRestoresMultipleTypes() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("LinguaFloatMultiTypeTest-\(UUID().uuidString)"))
        let item = NSPasteboardItem()
        item.setString("plain", forType: .string)
        item.setData(Data([1, 2, 3]), forType: NSPasteboard.PasteboardType("com.linguafloat.test"))
        pasteboard.clearContents()
        pasteboard.writeObjects([item])

        let snapshot = PasteboardSnapshot.capture(from: pasteboard)
        pasteboard.clearContents()
        snapshot.restore(to: pasteboard)

        XCTAssertEqual(pasteboard.string(forType: .string), "plain")
        XCTAssertEqual(
            pasteboard.pasteboardItems?.first?.data(forType: NSPasteboard.PasteboardType("com.linguafloat.test")),
            Data([1, 2, 3])
        )
    }
}
