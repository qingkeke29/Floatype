import Foundation

public struct TranslationRoute: Equatable {
    public let sourceLanguage: TranslationLanguage
    public let outputLanguages: [TranslationLanguage]

    public var primaryTargetLanguage: TranslationLanguage {
        outputLanguages.first ?? .english
    }
}

public enum LanguageRouter {
    public static let multiLanguageOutputs: [TranslationLanguage] = [
        .english,
        .chinese,
        .japanese,
        .korean
    ]

    public static func route(for preferences: TranslationPreferences) -> TranslationRoute {
        TranslationRoute(
            sourceLanguage: preferences.sourceLanguage,
            outputLanguages: preferences.multiLanguageOutput
                ? multiLanguageOutputs
                : [preferences.targetLanguage == .auto ? .english : preferences.targetLanguage]
        )
    }
}
