import AppKit
import XCTest
@testable import LinguaFloatCore

final class FloatingPanelLayoutMetricsTests: XCTestCase {
    func testReferenceMockupGeometryMatchesPixelTarget() {
        XCTAssertEqual(FloatingPanelLayoutMetrics.defaultSize, NSSize(width: 420, height: 274))
        XCTAssertEqual(FloatingPanelLayoutMetrics.headerSeparatorY, 52)
        XCTAssertEqual(FloatingPanelLayoutMetrics.chineseBoxFrame, NSRect(x: 13, y: 63, width: 394, height: 82))
        XCTAssertEqual(FloatingPanelLayoutMetrics.englishBoxFrame, NSRect(x: 13, y: 154, width: 394, height: 82))
        XCTAssertEqual(FloatingPanelLayoutMetrics.settingsButtonFrame, NSRect(x: 305, y: 14, width: 26, height: 26))
    }
}
