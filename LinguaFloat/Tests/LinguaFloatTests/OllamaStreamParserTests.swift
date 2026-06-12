import Foundation
import XCTest
@testable import LinguaFloatCore

final class OllamaStreamParserTests: XCTestCase {
    func testParsesContentTokensAndDoneAcrossMultipleLines() {
        var parser = OllamaStreamParser()
        let payload = """
        {"message":{"role":"assistant","content":"I'd "},"done":false}
        {"message":{"role":"assistant","content":"go."},"done":false}
        {"done":true}

        """

        let events = parser.feed(Data(payload.utf8))

        XCTAssertEqual(events, [.content("I'd "), .content("go."), .done])
    }

    func testBuffersHalfLineUntilNewlineArrives() {
        var parser = OllamaStreamParser()

        let first = parser.feed(Data(#"{"message":{"role":"assistant","content":"Hello"}"#.utf8))
        let second = parser.feed(Data(#","done":false}"#.utf8))
        let third = parser.feed(Data("\n".utf8))

        XCTAssertTrue(first.isEmpty)
        XCTAssertTrue(second.isEmpty)
        XCTAssertEqual(third, [.content("Hello")])
    }

    func testDoneTrueIsReturned() {
        var parser = OllamaStreamParser()

        let events = parser.feed(Data((#"{"done":true}"# + "\n").utf8))

        XCTAssertEqual(events, [.done])
    }

    func testMalformedJSONDoesNotCrash() {
        var parser = OllamaStreamParser()

        let events = parser.feed(Data("{not json}\n".utf8))

        XCTAssertEqual(events.count, 1)
        guard case .malformedLine = events[0] else {
            return XCTFail("Expected malformedLine event")
        }
    }
}
