import XCTest
@testable import LinguaFloatCore

final class StringSanitizerTests: XCTestCase {
    func testRemovesMarkdownCodeFence() {
        let input = """
        ```text
        I will go to school tomorrow afternoon.
        ```
        """

        XCTAssertEqual(StringSanitizer.cleanTranslation(input), "I will go to school tomorrow afternoon.")
    }

    func testRemovesSingleLayerQuotes() {
        XCTAssertEqual(StringSanitizer.cleanTranslation("\"Hello there.\""), "Hello there.")
    }

    func testDoesNotDestroyInternalQuotes() {
        let input = #"She said "hello" and left."#

        XCTAssertEqual(StringSanitizer.cleanTranslation(input), input)
    }

    func testPreservesNewlines() {
        let input = "Line one.\nLine two."

        XCTAssertEqual(StringSanitizer.cleanTranslation(input), input)
    }
}
