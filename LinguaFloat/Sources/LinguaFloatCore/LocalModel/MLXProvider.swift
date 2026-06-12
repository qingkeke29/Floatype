import Foundation

public final class MLXProvider: LocalModelProvider {
    public let providerName = "MLX"
    public var currentModel: String

    public init(currentModel: String = "future-mlx-model") {
        self.currentModel = currentModel
    }

    public func checkAvailability() async -> ProviderStatus {
        .failed("MLX provider is reserved for a future local-model implementation.")
    }

    public func listModels() async throws -> [LocalModelInfo] {
        []
    }

    public func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        throw OllamaProviderError.streamError("MLX provider is not implemented in v1.")
    }

    public func cancelCurrentRequest() {}
}
