import XCTest
@testable import LinguaFloatCore

final class PromptBuilderTests: XCTestCase {
    func testBuildsSingleTargetPromptFromSettings() {
        let preferences = TranslationPreferences(
            sourceLanguage: .auto,
            targetLanguage: .japanese,
            mode: .formal,
            multiLanguageOutput: false
        )

        let prompt = PromptBuilder.prompt(for: "你好。", preferences: preferences)

        XCTAssertTrue(prompt.contains("Detect the source language automatically."))
        XCTAssertTrue(prompt.contains("Target language: Japanese."))
        XCTAssertTrue(prompt.contains("Use a professional and formal tone."))
        XCTAssertTrue(prompt.contains("Return only Japanese text."))
        XCTAssertTrue(prompt.hasSuffix("你好。"))
    }

    func testBuildsMultiLanguagePromptWithRequiredLabels() {
        let preferences = TranslationPreferences(
            sourceLanguage: .chinese,
            targetLanguage: .english,
            mode: .natural,
            multiLanguageOutput: true
        )

        let prompt = PromptBuilder.prompt(for: "我想预约明天。", preferences: preferences)

        XCTAssertTrue(prompt.contains("The source language is Chinese."))
        XCTAssertTrue(prompt.contains("English:"))
        XCTAssertTrue(prompt.contains("Chinese:"))
        XCTAssertTrue(prompt.contains("Japanese:"))
        XCTAssertTrue(prompt.contains("Korean:"))
    }

    func testSingleNonEnglishTargetPromptForbidsEnglishFallback() {
        let preferences = TranslationPreferences(
            sourceLanguage: .chinese,
            targetLanguage: .korean,
            mode: .natural,
            multiLanguageOutput: false
        )

        let prompt = PromptBuilder.prompt(for: "明天见。", preferences: preferences)

        XCTAssertTrue(prompt.contains("Target language: Korean."))
        XCTAssertTrue(prompt.contains("Return only Korean text."))
        XCTAssertTrue(prompt.contains("Do not output English unless the target language is English."))
    }
}
