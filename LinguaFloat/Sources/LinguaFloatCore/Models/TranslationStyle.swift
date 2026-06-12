import Foundation

public enum TranslationStyle: String, CaseIterable, Codable, Equatable {
    case accurate
    case natural
    case formal
    case casual

    public var displayName: String {
        switch self {
        case .accurate:
            return "准确"
        case .natural:
            return "自然"
        case .formal:
            return "正式"
        case .casual:
            return "口语"
        }
    }

    public var instruction: String {
        switch self {
        case .accurate:
            return """
            Translate the following Simplified Chinese text into accurate English.
            Preserve the original meaning, names, numbers, URLs and formatting.
            Do not add or remove information.
            Output only the English translation.
            """
        case .natural:
            return """
            Translate the following Simplified Chinese text into natural, fluent English.
            Avoid literal Chinese sentence structures when a more natural English expression exists.
            Preserve the original meaning.
            Output only the English translation.
            """
        case .formal:
            return """
            Translate the following Simplified Chinese text into professional and formal English.
            Preserve the original meaning.
            Do not make unsupported additions.
            Output only the English translation.
            """
        case .casual:
            return """
            Translate the following Simplified Chinese text into natural conversational English.
            Keep it concise and suitable for everyday messaging.
            Preserve the original meaning.
            Output only the English translation.
            """
        }
    }

    private var outputGuardrails: String {
        """
        Do not explain nouns, terms, names, or proper nouns.
        Do not add parenthetical definitions, notes, alternatives, markdown, quotation marks, or the original Chinese.
        """
    }

    public func prompt(for text: String) -> String {
        "\(instruction)\n\(outputGuardrails)\n\(text)"
    }
}
