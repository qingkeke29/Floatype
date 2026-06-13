import Foundation
import XCTest
@testable import LinguaFloatCore

final class AppSettingsTests: XCTestCase {
    func testDefaultModelUsesInstalledQwen35NineB() {
        let suiteName = "LinguaFloatSettingsTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let settings = AppSettings(defaults: defaults)

        XCTAssertEqual(settings.defaultModel, "qwen3.5:9b")
    }

    func testMigratesPreviousTranslategemmaDefaultToQwen35NineB() {
        let suiteName = "LinguaFloatSettingsMigrationTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set("translategemma:4b", forKey: "defaultModel")

        let settings = AppSettings(defaults: defaults)

        XCTAssertEqual(settings.defaultModel, "qwen3.5:9b")
    }

    func testFloatingPanelDoesNotOpenOnLaunchByDefault() {
        let suiteName = "LinguaFloatNoOpenPanelOnLaunchTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let settings = AppSettings(defaults: defaults)

        XCTAssertFalse(settings.openPanelOnLaunch)
    }

    func testDefaultGlobalHotKeyIsCommandZ() {
        let suiteName = "LinguaFloatDefaultHotKeyTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let settings = AppSettings(defaults: defaults)

        XCTAssertEqual(settings.globalHotKeyShortcut.displayName, "Command + Z")
    }

    func testPersistsCustomGlobalHotKey() {
        let suiteName = "LinguaFloatCustomHotKeyTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        settings.globalHotKeyShortcut = GlobalHotKeyShortcut(
            displayName: "Control + K",
            keyCode: 40,
            modifiers: 4096,
            id: 1,
            storageValue: "control+k"
        )

        let reloaded = AppSettings(defaults: defaults)
        XCTAssertEqual(reloaded.globalHotKeyShortcut.displayName, "Control + K")
        XCTAssertEqual(reloaded.globalHotKeyShortcut.storageValue, "control+k")
    }

    func testMigratesBilingualDefaultOutputSelectionToEnglish() {
        let suiteName = "LinguaFloatDefaultOutputSelectionMigrationTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(OutputSelection.bilingual.rawValue, forKey: "defaultOutputSelection")

        let settings = AppSettings(defaults: defaults)

        XCTAssertEqual(settings.defaultOutputSelection, .english)
    }

    func testDefaultModelSourceIsLocalOllama() {
        let suiteName = "LinguaFloatModelSourceDefaultTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let settings = AppSettings(defaults: defaults)

        XCTAssertEqual(settings.modelSource, .localOllama)
        XCTAssertEqual(settings.localOllamaModel, "qwen3.5:9b")
        XCTAssertEqual(settings.activeModelDisplayName, "Ollama · qwen3.5:9b")
    }

    func testPersistsCustomAPIConfiguration() {
        let suiteName = "LinguaFloatCustomAPISettingsTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        settings.modelSource = .customAPI
        settings.customAPIURLString = "https://api.deepseek.com"
        settings.customAPIKey = "secret-key"
        settings.customAPIModel = "deepseek-chat"

        let reloaded = AppSettings(defaults: defaults)
        XCTAssertEqual(reloaded.modelSource, .customAPI)
        XCTAssertEqual(reloaded.customAPIURLString, "https://api.deepseek.com")
        XCTAssertEqual(reloaded.customAPIKey, "secret-key")
        XCTAssertEqual(reloaded.customAPIModel, "deepseek-chat")
        XCTAssertEqual(reloaded.activeModelDisplayName, "API · deepseek-chat")
    }

    func testDefaultModelRemainsAliasForLocalOllamaModel() {
        let suiteName = "LinguaFloatDefaultModelAliasTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        settings.defaultModel = "qwen2.5:7b"

        XCTAssertEqual(settings.localOllamaModel, "qwen2.5:7b")
        XCTAssertEqual(settings.defaultModel, "qwen2.5:7b")
    }
}
