import XCTest
@testable import LinguaFloatCore

final class OutputSelectionNavigationTests: XCTestCase {
    func testNextSelectionCyclesBetweenChineseAndEnglishOnly() {
        XCTAssertEqual(OutputSelection.chinese.next, .english)
        XCTAssertEqual(OutputSelection.english.next, .chinese)
    }

    func testPreviousSelectionCyclesBetweenChineseAndEnglishOnly() {
        XCTAssertEqual(OutputSelection.chinese.previous, .english)
        XCTAssertEqual(OutputSelection.english.previous, .chinese)
    }

}
