import Foundation

public enum StringSanitizer {
    public static func cleanTranslation(_ input: String) -> String {
        var value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        value = stripMarkdownFence(value)
        value = stripSingleLayerQuotes(value)
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func stripMarkdownFence(_ input: String) -> String {
        var value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.hasPrefix("```") else {
            return value
        }

        var lines = value.components(separatedBy: .newlines)
        if let first = lines.first, first.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("```") {
            lines.removeFirst()
        }
        if let last = lines.last, last.trimmingCharacters(in: .whitespacesAndNewlines) == "```" {
            lines.removeLast()
        }
        value = lines.joined(separator: "\n")
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func stripSingleLayerQuotes(_ input: String) -> String {
        guard input.count >= 2 else {
            return input
        }

        let quotePairs: [(Character, Character)] = [
            ("\"", "\""),
            ("'", "'"),
            ("“", "”"),
            ("‘", "’")
        ]

        guard let first = input.first, let last = input.last else {
            return input
        }

        for pair in quotePairs where first == pair.0 && last == pair.1 {
            let inner = input.dropFirst().dropLast()
            if !inner.contains("\n\"") && !inner.contains("\"\n") {
                return String(inner)
            }
        }

        return input
    }
}
