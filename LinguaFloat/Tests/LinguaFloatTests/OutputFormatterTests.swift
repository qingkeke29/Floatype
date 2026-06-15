import XCTest
@testable import LinguaFloatCore

final class OutputFormatterTests: XCTestCase {
    func testSingleLanguageOutputUsesCleanTranslation() {
        let preferences = TranslationPreferences(
            sourceLanguage: .auto,
            targetLanguage: .english,
            mode: .natural,
            multiLanguageOutput: false
        )

        let output = OutputFormatter.format("\"Hello there\"", preferences: preferences)

        XCTAssertEqual(output, "Hello there")
    }

    func testMultiLanguageOutputPreservesRequiredLabels() {
        let preferences = TranslationPreferences(
            sourceLanguage: .auto,
            targetLanguage: .english,
            mode: .natural,
            multiLanguageOutput: true
        )
        let raw = """
        English: Hello
        Chinese: 你好
        Japanese: こんにちは
        Korean: 안녕하세요
        """

        let output = OutputFormatter.format(raw, preferences: preferences)

        XCTAssertTrue(output.contains("English: Hello"))
        XCTAssertTrue(output.contains("Chinese: 你好"))
        XCTAssertTrue(output.contains("Japanese: こんにちは"))
        XCTAssertTrue(output.contains("Korean: 안녕하세요"))
    }

    func testMultiLanguageOutputWrapsUnlabeledFallback() {
        let preferences = TranslationPreferences(
            sourceLanguage: .auto,
            targetLanguage: .english,
            mode: .natural,
            multiLanguageOutput: true
        )

        let output = OutputFormatter.format("Hello", preferences: preferences)

        XCTAssertEqual(
            output,
            """
            English: Hello
            Chinese:
            Japanese:
            Korean:
            """
        )
    }
}
