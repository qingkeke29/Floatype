import Foundation

public enum OutputFormatter {
    public static func format(_ rawValue: String, preferences: TranslationPreferences) -> String {
        let cleaned = StringSanitizer.cleanTranslation(rawValue)
        guard preferences.multiLanguageOutput else {
            return cleaned
        }
        return normalizeMultiLanguageOutput(cleaned)
    }

    private static func normalizeMultiLanguageOutput(_ value: String) -> String {
        let requiredLabels = ["English:", "Chinese:", "Japanese:", "Korean:"]
        if requiredLabels.allSatisfy({ value.localizedCaseInsensitiveContains($0) }) {
            return value
        }

        return """
        English: \(value)
        Chinese:
        Japanese:
        Korean:
        """
    }
}
