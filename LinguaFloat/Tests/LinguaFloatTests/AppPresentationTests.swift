import AppKit
import XCTest
@testable import LinguaFloatCore

final class AppPresentationTests: XCTestCase {
    func testAppRunsAsMenuBarUtility() throws {
        let info = try loadInfoPlist()

        XCTAssertEqual(info["LSUIElement"] as? Bool, true)
        XCTAssertEqual(AppPresentation.activationPolicy, .accessory)
    }

    func testMenuBarTitleUsesShortChineseBrand() {
        XCTAssertEqual(AppPresentation.menuBarTitle, "浮译")
    }

    private func loadInfoPlist() throws -> [String: Any] {
        let testFile = URL(fileURLWithPath: #filePath)
        let packageRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let infoURL = packageRoot.appendingPathComponent("Resources/Info.plist")
        let data = try Data(contentsOf: infoURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return try XCTUnwrap(plist as? [String: Any])
    }
}
