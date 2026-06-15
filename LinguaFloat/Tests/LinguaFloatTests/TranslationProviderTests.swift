import XCTest
@testable import LinguaFloatCore

final class TranslationProviderTests: XCTestCase {
    func testLocalProviderCanUseSettingsDrivenTranslationInterface() {
        let provider: TranslationProvider = OllamaProvider()

        XCTAssertEqual(provider.providerName, "Ollama")
    }
}
