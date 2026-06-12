import Foundation

public enum OutputSelection: String, CaseIterable, Codable, Equatable {
    case chinese
    case english
    case bilingual

    public var displayName: String {
        switch self {
        case .chinese:
            return "中文"
        case .english:
            return "English"
        case .bilingual:
            return "双语"
        }
    }

    public var next: OutputSelection {
        switch self {
        case .chinese:
            return .english
        case .english, .bilingual:
            return .chinese
        }
    }

    public var previous: OutputSelection {
        switch self {
        case .chinese, .bilingual:
            return .english
        case .english:
            return .chinese
        }
    }

    public var panelSelection: OutputSelection {
        self == .bilingual ? .english : self
    }

    public func composedText(chinese: String, english: String) -> String {
        switch self {
        case .chinese:
            return chinese
        case .english:
            return english
        case .bilingual:
            if chinese.isEmpty {
                return english
            }
            if english.isEmpty {
                return chinese
            }
            return chinese.hasSuffix("\n") ? chinese + english : chinese + "\n" + english
        }
    }
}
