import Foundation
import XCTest
@testable import LinguaFloatCore

@MainActor
final class FloatingPanelViewModelTests: XCTestCase {
    func testMigratesBilingualDefaultSelectionToEnglishWhenPanelOpens() {
        let suiteName = "LinguaFloatViewModelSelectionTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)
        settings.defaultOutputSelection = .bilingual
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        viewModel.resetForOpen()

        XCTAssertEqual(viewModel.state.selectedOutput, .english)
    }

    func testTranslationUsesSettingsPreferences() async {
        let suiteName = "LinguaFloatViewModelPreferencesTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)
        settings.sourceLanguage = .chinese
        settings.targetLanguage = .japanese
        settings.translationMode = .formal
        settings.multiLanguageOutput = true
        let provider = StubLocalModelProvider()
        let viewModel = FloatingPanelViewModel(provider: provider, settings: settings)

        viewModel.resetForOpen()
        try? await Task.sleep(nanoseconds: 60_000_000)
        viewModel.updateChineseText("你好", hasMarkedText: false)
        viewModel.translateIfReady(force: true, hasMarkedText: false)
        try? await Task.sleep(nanoseconds: 60_000_000)

        XCTAssertEqual(
            provider.lastPreferences,
            TranslationPreferences(
                sourceLanguage: .chinese,
                targetLanguage: .japanese,
                mode: .formal,
                multiLanguageOutput: true
            )
        )
        XCTAssertEqual(viewModel.state.englishText, "English: Hello\nChinese: 你好\nJapanese: こんにちは\nKorean: 안녕하세요")
        XCTAssertTrue(viewModel.state.settingsSummary.contains("Chinese → Japanese"))
    }

    func testToggleMultiLanguageModeUpdatesSettingsWhenEnabled() {
        let settings = isolatedSettings()
        settings.multiLanguageOutput = false
        settings.commandShiftMToggleMultiLanguageEnabled = true
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        viewModel.toggleMultiLanguageOutput()

        XCTAssertTrue(settings.multiLanguageOutput)
        XCTAssertTrue(viewModel.state.settingsSummary.contains("Multi"))
    }

    func testToggleMultiLanguageModeCanBeDisabled() {
        let settings = isolatedSettings()
        settings.multiLanguageOutput = false
        settings.commandShiftMToggleMultiLanguageEnabled = false
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        viewModel.toggleMultiLanguageOutput()

        XCTAssertFalse(settings.multiLanguageOutput)
    }

    func testResultTitleFollowsTargetLanguage() {
        let settings = isolatedSettings()
        settings.targetLanguage = .japanese
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        XCTAssertEqual(viewModel.state.resultTitle, "日语结果")
    }

    func testResultPlaceholderFollowsTargetLanguage() {
        let settings = isolatedSettings()
        settings.targetLanguage = .korean
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        XCTAssertEqual(viewModel.state.resultPlaceholder, "韩语结果将在这里生成")
    }

    func testResultTitleUsesMultiLanguageTitleWhenEnabled() {
        let settings = isolatedSettings()
        settings.targetLanguage = .japanese
        settings.multiLanguageOutput = true
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        XCTAssertEqual(viewModel.state.resultTitle, "多语言结果")
    }

    func testPanelCopyFollowsEnglishSourceLanguage() {
        let settings = isolatedSettings()
        settings.sourceLanguage = .english
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        XCTAssertEqual(viewModel.state.panelTitle, "Floatype")
        XCTAssertEqual(viewModel.state.sourceTitle, "English Source")
        XCTAssertEqual(viewModel.state.sourcePlaceholder, "Type English here...")
        XCTAssertEqual(viewModel.state.bottomHint, "↑↓ Select · ↩ Insert · Esc Cancel · Tab Translate again")
    }

    func testPanelCopyFollowsKoreanSourceLanguage() {
        let settings = isolatedSettings()
        settings.sourceLanguage = .korean
        settings.targetLanguage = .english
        let viewModel = FloatingPanelViewModel(provider: StubLocalModelProvider(), settings: settings)

        XCTAssertEqual(viewModel.state.sourceTitle, "한국어 원문")
        XCTAssertEqual(viewModel.state.sourcePlaceholder, "한국어를 입력하세요...")
        XCTAssertEqual(viewModel.state.statusText, "입력 대기")
    }

    private func isolatedSettings() -> AppSettings {
        let suiteName = "LinguaFloatViewModelSettings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return AppSettings(defaults: defaults)
    }
}

private final class StubLocalModelProvider: LocalModelProvider {
    var providerName = "Stub"
    var currentModel = "stub-model"

    func checkAvailability() async -> ProviderStatus {
        .available
    }

    func listModels() async throws -> [LocalModelInfo] {
        []
    }

    func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        ""
    }

    var lastPreferences: TranslationPreferences?

    func translate(
        text: String,
        preferences: TranslationPreferences,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        lastPreferences = preferences
        let output = "English: Hello\nChinese: 你好\nJapanese: こんにちは\nKorean: 안녕하세요"
        onToken(output)
        return output
    }

    func cancelCurrentRequest() {}
}
