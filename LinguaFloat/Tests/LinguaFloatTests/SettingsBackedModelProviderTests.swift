import Foundation
import XCTest
@testable import LinguaFloatCore

final class SettingsBackedModelProviderTests: XCTestCase {
    func testUsesLocalOllamaDisplayByDefault() {
        let suiteName = "LinguaFloatProviderRouterLocalTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        let provider = SettingsBackedModelProvider(settings: settings)

        XCTAssertEqual(provider.providerName, "Ollama")
        XCTAssertEqual(provider.currentModel, "qwen3.5:9b")
        XCTAssertEqual(provider.displayName, "Ollama · qwen3.5:9b")
    }

    func testUsesCustomAPIDisplayAfterSettingsChange() {
        let suiteName = "LinguaFloatProviderRouterCustomTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)
        let provider = SettingsBackedModelProvider(settings: settings)

        settings.modelSource = .customAPI
        settings.customAPIURLString = "https://api.example.com"
        settings.customAPIModel = "deepseek-chat"

        XCTAssertEqual(provider.providerName, "API")
        XCTAssertEqual(provider.currentModel, "deepseek-chat")
        XCTAssertEqual(provider.displayName, "API · deepseek-chat")
    }
}
