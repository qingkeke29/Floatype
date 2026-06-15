import Foundation

public final class SettingsBackedModelProvider: LocalModelProvider {
    private let settings: AppSettings
    private var cachedSignature = ""
    private var cachedProvider: LocalModelProvider?

    public init(settings: AppSettings) {
        self.settings = settings
    }

    public var providerName: String {
        settings.modelSource.modelLabelPrefix
    }

    public var currentModel: String {
        get { settings.activeModelName }
        set {
            switch settings.modelSource {
            case .localOllama:
                settings.localOllamaModel = newValue
            case .customAPI:
                settings.customAPIModel = newValue
            }
        }
    }

    public var displayName: String {
        settings.activeModelDisplayName
    }

    public func checkAvailability() async -> ProviderStatus {
        await activeProvider().checkAvailability()
    }

    public func listModels() async throws -> [LocalModelInfo] {
        try await activeProvider().listModels()
    }

    public func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        try await activeProvider().translate(text: text, style: style, onToken: onToken)
    }

    public func translate(
        text: String,
        preferences: TranslationPreferences,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        try await activeProvider().translate(text: text, preferences: preferences, onToken: onToken)
    }

    public func cancelCurrentRequest() {
        cachedProvider?.cancelCurrentRequest()
    }

    private func activeProvider() -> LocalModelProvider {
        let signature = providerSignature()
        if let cachedProvider, cachedSignature == signature {
            return cachedProvider
        }

        cachedProvider?.cancelCurrentRequest()
        let provider: LocalModelProvider
        switch settings.modelSource {
        case .localOllama:
            provider = OllamaProvider(baseURL: settings.ollamaBaseURL, currentModel: settings.localOllamaModel)
        case .customAPI:
            if let endpoint = try? OpenAICompatibleEndpoint.normalized(from: settings.customAPIURLString) {
                provider = OpenAICompatibleProvider(
                    endpoint: endpoint,
                    apiKey: settings.customAPIKey,
                    currentModel: settings.customAPIModel
                )
            } else {
                provider = InvalidModelProvider(
                    providerName: "API",
                    currentModel: settings.activeModelName,
                    message: "API URL 无效。"
                )
            }
        }

        cachedSignature = signature
        cachedProvider = provider
        return provider
    }

    private func providerSignature() -> String {
        [
            settings.modelSource.rawValue,
            settings.ollamaBaseURL.absoluteString,
            settings.localOllamaModel,
            settings.customAPIURLString,
            settings.customAPIKey,
            settings.customAPIModel
        ].joined(separator: "|")
    }
}

private final class InvalidModelProvider: LocalModelProvider {
    let providerName: String
    var currentModel: String
    private let message: String

    init(providerName: String, currentModel: String, message: String) {
        self.providerName = providerName
        self.currentModel = currentModel
        self.message = message
    }

    func checkAvailability() async -> ProviderStatus {
        .failed(message)
    }

    func listModels() async throws -> [LocalModelInfo] {
        []
    }

    func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        throw OpenAICompatibleProviderError.invalidConfiguration(message)
    }

    func cancelCurrentRequest() {}
}
