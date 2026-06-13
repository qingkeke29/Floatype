import Foundation

public enum OpenAICompatibleEndpointError: LocalizedError, Equatable {
    case invalidURL

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "API URL 无效。"
        }
    }
}

public enum OpenAICompatibleEndpoint {
    public static func normalized(from rawValue: String) throws -> URL {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              let host = components.host,
              !host.isEmpty else {
            throw OpenAICompatibleEndpointError.invalidURL
        }

        var path = components.path
        while path.hasSuffix("/") {
            path.removeLast()
        }

        if path.hasSuffix("/chat/completions") {
            components.path = path
        } else if path.hasSuffix("/v1") {
            components.path = path + "/chat/completions"
        } else {
            components.path = path + "/v1/chat/completions"
        }

        guard let url = components.url else {
            throw OpenAICompatibleEndpointError.invalidURL
        }
        return url
    }
}
