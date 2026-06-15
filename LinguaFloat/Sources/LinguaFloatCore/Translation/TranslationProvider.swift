import Foundation

public protocol TranslationProvider: AnyObject {
    var providerName: String { get }
    var currentModel: String { get set }

    func checkAvailability() async -> ProviderStatus
    func listModels() async throws -> [LocalModelInfo]
    func translate(
        text: String,
        preferences: TranslationPreferences,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String
    func cancelCurrentRequest()
}
