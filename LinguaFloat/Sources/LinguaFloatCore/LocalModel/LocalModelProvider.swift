import Foundation

public protocol LocalModelProvider: TranslationProvider {
    func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String
}

public extension LocalModelProvider {
    func translate(
        text: String,
        preferences: TranslationPreferences,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        let translated = try await translate(
            text: text,
            style: preferences.mode.legacyStyle,
            onToken: onToken
        )
        return OutputFormatter.format(translated, preferences: preferences)
    }
}
