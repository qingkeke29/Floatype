import XCTest
@testable import LinguaFloatCore

final class LanguageRouterTests: XCTestCase {
    func testRoutesSingleTargetOutput() {
        let preferences = TranslationPreferences(
            sourceLanguage: .auto,
            targetLanguage: .spanish,
            mode: .normal,
            multiLanguageOutput: false
        )

        let route = LanguageRouter.route(for: preferences)

        XCTAssertEqual(route.sourceLanguage, .auto)
        XCTAssertEqual(route.outputLanguages, [.spanish])
        XCTAssertEqual(route.primaryTargetLanguage, .spanish)
    }

    func testRoutesMultiLanguageOutputToFixedDisplayLanguages() {
        let preferences = TranslationPreferences(
            sourceLanguage: .korean,
            targetLanguage: .french,
            mode: .casual,
            multiLanguageOutput: true
        )

        let route = LanguageRouter.route(for: preferences)

        XCTAssertEqual(route.sourceLanguage, .korean)
        XCTAssertEqual(route.outputLanguages, [.english, .chinese, .japanese, .korean])
        XCTAssertEqual(route.primaryTargetLanguage, .english)
    }
}
