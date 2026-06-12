import XCTest
@testable import LinguaFloatCore

final class FloatingPanelActivationPlanTests: XCTestCase {
    func testFocusRetryDelaysReassertFocusAfterGlobalHotKeyReturns() {
        XCTAssertEqual(FloatingPanelActivationPlan.focusRetryDelays, [0, 0.08, 0.25])
    }
}
