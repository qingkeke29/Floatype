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
}
