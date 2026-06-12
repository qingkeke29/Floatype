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

    func cancelCurrentRequest() {}
}
