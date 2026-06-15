import Foundation

public enum PromptBuilder {
    public static func prompt(for text: String, preferences: TranslationPreferences) -> String {
        let route = LanguageRouter.route(for: preferences)
        return [
            sourceInstruction(for: route.sourceLanguage),
            modeInstruction(for: preferences.mode),
            outputInstruction(for: route, multiLanguageOutput: preferences.multiLanguageOutput),
            guardrails,
            text
        ].joined(separator: "\n")
    }

    private static func sourceInstruction(for language: TranslationLanguage) -> String {
        switch language {
        case .auto:
            return "Detect the source language automatically."
        default:
            return "The source language is \(language.displayName)."
        }
    }

    private static func modeInstruction(for mode: TranslationMode) -> String {
        switch mode {
        case .normal:
            return "Translate accurately while preserving meaning, names, numbers, URLs, and formatting."
        case .natural:
            return "Translate naturally and fluently while preserving the original meaning."
        case .formal:
            return "Use a professional and formal tone."
        case .casual:
            return "Use a concise, conversational tone suitable for everyday messaging."
        }
    }

    private static func outputInstruction(for route: TranslationRoute, multiLanguageOutput: Bool) -> String {
        if multiLanguageOutput {
            return """
            Output exactly these labeled sections, each on its own line:
            English:
            Chinese:
            Japanese:
            Korean:
            """
        }

        let target = route.primaryTargetLanguage
        return """
        Target language: \(target.displayName).
        Translate the user's text into \(target.displayName).
        Return only \(target.displayName) text.
        Do not output English unless the target language is English.
        """
    }

    private static var guardrails: String {
        """
        Do not explain nouns, terms, names, or proper nouns.
        Do not add parenthetical definitions, notes, alternatives, markdown, quotation marks, or unrelated commentary.
        """
    }
}
