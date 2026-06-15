import XCTest
@testable import LinguaFloatCore

final class TranslationSettingsTests: XCTestCase {
    func testDefaultTranslationSettingsPreserveEnglishOnlyBehavior() {
        let settings = isolatedSettings()

        XCTAssertEqual(settings.sourceLanguage, .auto)
        XCTAssertEqual(settings.targetLanguage, .english)
        XCTAssertEqual(settings.translationMode, .natural)
        XCTAssertFalse(settings.multiLanguageOutput)
        XCTAssertTrue(settings.command1UseChineseEnabled)
        XCTAssertTrue(settings.command2UseEnglishEnabled)
        XCTAssertTrue(settings.command3UseSettingsDefaultEnabled)
        XCTAssertTrue(settings.commandShiftMToggleMultiLanguageEnabled)
        XCTAssertEqual(settings.translationSettingsSummary, "Auto → English · Natural")
    }

    func testPersistsTranslationSettings() {
        let suiteName = "LinguaFloatTranslationSettingsPersistence-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        settings.sourceLanguage = .japanese
        settings.targetLanguage = .german
        settings.translationMode = .formal
        settings.multiLanguageOutput = true
        settings.command1UseChineseEnabled = false
        settings.commandShiftMToggleMultiLanguageEnabled = false

        let reloaded = AppSettings(defaults: defaults)
        XCTAssertEqual(reloaded.sourceLanguage, .japanese)
        XCTAssertEqual(reloaded.targetLanguage, .german)
        XCTAssertEqual(reloaded.translationMode, .formal)
        XCTAssertTrue(reloaded.multiLanguageOutput)
        XCTAssertFalse(reloaded.command1UseChineseEnabled)
        XCTAssertTrue(reloaded.command2UseEnglishEnabled)
        XCTAssertTrue(reloaded.command3UseSettingsDefaultEnabled)
        XCTAssertFalse(reloaded.commandShiftMToggleMultiLanguageEnabled)
        XCTAssertEqual(reloaded.translationSettingsSummary, "Japanese → German · Formal · Multi")
    }

    func testDefaultStyleRemainsCompatibilityAliasForTranslationMode() {
        let settings = isolatedSettings()

        settings.defaultStyle = .casual
        XCTAssertEqual(settings.translationMode, .casual)
        XCTAssertEqual(settings.defaultStyle, .casual)

        settings.translationMode = .normal
        XCTAssertEqual(settings.defaultStyle, .accurate)
    }

    func testTargetLanguageCannotPersistAutoDetection() {
        let settings = isolatedSettings()

        settings.targetLanguage = .auto

        XCTAssertEqual(settings.targetLanguage, .english)
    }

    func testTargetLanguageOptionsExcludeAutoAndSourceLanguage() {
        XCTAssertEqual(
            TranslationLanguage.targetOptions(forSource: .chinese),
            [.english, .japanese, .korean, .french, .german, .spanish]
        )
        XCTAssertEqual(
            TranslationLanguage.targetOptions(forSource: .english),
            [.chinese, .japanese, .korean, .french, .german, .spanish]
        )
        XCTAssertEqual(
            TranslationLanguage.targetOptions(forSource: .auto),
            TranslationLanguage.targetOptions(forSource: .chinese)
        )
    }

    func testTargetLanguageDisplayNamesFollowSourceLanguage() {
        XCTAssertEqual(TranslationLanguage.english.targetDisplayName(forSource: .chinese), "英语")
        XCTAssertEqual(TranslationLanguage.japanese.targetDisplayName(forSource: .chinese), "日语")
        XCTAssertEqual(TranslationLanguage.japanese.targetDisplayName(forSource: .english), "Japanese")
        XCTAssertEqual(TranslationLanguage.chinese.targetDisplayName(forSource: .english), "Chinese")
        XCTAssertEqual(TranslationLanguage.korean.targetDisplayName(forSource: .auto), "韩语")
    }

    private func isolatedSettings() -> AppSettings {
        let suiteName = "LinguaFloatTranslationSettings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return AppSettings(defaults: defaults)
    }
}
