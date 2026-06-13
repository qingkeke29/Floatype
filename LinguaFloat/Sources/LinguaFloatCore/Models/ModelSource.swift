import Foundation

public enum ModelSource: String, CaseIterable, Codable, Equatable {
    case localOllama
    case customAPI

    public var displayName: String {
        switch self {
        case .localOllama:
            return "本地 Ollama"
        case .customAPI:
            return "自定义 API"
        }
    }

    public var modelLabelPrefix: String {
        switch self {
        case .localOllama:
            return "Ollama"
        case .customAPI:
            return "API"
        }
    }
}
