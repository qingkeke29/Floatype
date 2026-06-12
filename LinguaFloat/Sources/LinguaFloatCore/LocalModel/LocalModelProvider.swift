import Foundation

public protocol LocalModelProvider: AnyObject {
    var providerName: String { get }
    var currentModel: String { get set }

    func checkAvailability() async -> ProviderStatus
    func listModels() async throws -> [LocalModelInfo]
    func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String
    func cancelCurrentRequest()
}
