import Foundation

public struct OllamaTagsResponse: Decodable {
    public let models: [OllamaModelResponse]
}

public struct OllamaModelResponse: Decodable {
    public let name: String
    public let modifiedAt: Date?
    public let size: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case modifiedAt = "modified_at"
        case size
    }
}

public struct OllamaChatRequest: Encodable {
    public let model: String
    public let messages: [OllamaChatMessage]
    public let stream: Bool
    public let think: Bool
    public let options: OllamaOptions

    public init(
        model: String,
        messages: [OllamaChatMessage],
        stream: Bool,
        think: Bool = false,
        options: OllamaOptions
    ) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.think = think
        self.options = options
    }
}

public struct OllamaChatMessage: Codable {
    public let role: String
    public let content: String
}

public struct OllamaOptions: Encodable {
    public let temperature: Double
    public let numPredict: Int

    enum CodingKeys: String, CodingKey {
        case temperature
        case numPredict = "num_predict"
    }
}

public struct OllamaChatStreamChunk: Decodable {
    public let message: OllamaChatMessage?
    public let done: Bool?
    public let error: String?
}
