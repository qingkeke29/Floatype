import XCTest
@testable import LinguaFloatCore

final class TranslationPromptTests: XCTestCase {
    func testStylesGenerateDifferentPrompts() {
        let text = "我明天下午去学校。"
        let prompts = TranslationStyle.allCases.map { $0.prompt(for: text) }

        XCTAssertEqual(Set(prompts).count, TranslationStyle.allCases.count)
    }

    func testPromptIncludesOriginalChineseExactly() {
        let text = "我明天下午去学校处理这件事情。"

        XCTAssertTrue(TranslationStyle.natural.prompt(for: text).hasSuffix(text))
    }

    func testPromptRequiresEnglishOnlyOutput() {
        for style in TranslationStyle.allCases {
            XCTAssertTrue(style.prompt(for: "你好").contains("Output only the English translation."))
        }
    }

    func testPromptForbidsNounAndTermExplanations() {
        for style in TranslationStyle.allCases {
            XCTAssertTrue(
                style.prompt(for: "豆包输入法很好用。")
                    .contains("Do not explain nouns, terms, names, or proper nouns.")
            )
        }
    }
}
