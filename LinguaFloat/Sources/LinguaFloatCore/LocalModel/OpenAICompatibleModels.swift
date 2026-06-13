import Foundation

public struct OpenAIChatCompletionRequest: Encodable {
    public let model: String
    public let messages: [OpenAIChatMessage]
    public let stream: Bool
    public let temperature: Double
    public let maxTokens: Int

    public init(
        model: String,
        messages: [OpenAIChatMessage],
        stream: Bool,
        temperature: Double,
        maxTokens: Int
    ) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case stream
        case temperature
        case maxTokens = "max_tokens"
    }
}

public struct OpenAIChatMessage: Codable, Equatable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct OpenAIChatCompletionResponse: Decodable {
    public let choices: [OpenAIChatCompletionChoice]
}

public struct OpenAIChatCompletionChoice: Decodable {
    public let message: OpenAIChatMessage?
    public let delta: OpenAIDeltaMessage?
    public let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case message
        case delta
        case finishReason = "finish_reason"
    }
}

public struct OpenAIDeltaMessage: Decodable, Equatable {
    public let role: String?
    public let content: String?
}

public struct OpenAIErrorResponse: Decodable {
    public let error: APIError

    public struct APIError: Decodable {
        public let message: String
        public let type: String?
        public let code: String?
    }
}
