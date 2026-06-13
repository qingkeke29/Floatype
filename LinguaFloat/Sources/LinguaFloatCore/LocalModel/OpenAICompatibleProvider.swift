import Foundation

public enum OpenAICompatibleProviderError: LocalizedError, Equatable {
    case invalidConfiguration(String)
    case httpStatus(Int, String?)
    case streamError(String)
    case missingContent
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return message
        case .httpStatus(_, let message):
            return message ?? "自定义 API 请求失败。"
        case .streamError(let message):
            return message
        case .missingContent:
            return "自定义 API 没有返回翻译内容。"
        case .cancelled:
            return "Translation cancelled."
        }
    }
}

public final class OpenAICompatibleProvider: LocalModelProvider {
    public let providerName = "API"
    public var currentModel: String
    public let endpoint: URL

    private let apiKey: String
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let lock = NSLock()
    private var activeTask: Task<String, Error>?
    private var activeRequestID: UUID?

    public init(
        endpoint: URL,
        apiKey: String,
        currentModel: String,
        session: URLSession? = nil
    ) {
        self.endpoint = endpoint
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentModel = currentModel
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 600
        self.session = session ?? URLSession(configuration: configuration)
    }

    public var authorizationHeaderValue: String? {
        apiKey.isEmpty ? nil : "Bearer \(apiKey)"
    }

    public func checkAvailability() async -> ProviderStatus {
        currentModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .failed("自定义 API 模型未设置。")
            : .available
    }

    public func listModels() async throws -> [LocalModelInfo] {
        [LocalModelInfo(name: currentModel)]
    }

    public func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        cancelCurrentRequest()

        let model = currentModel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !model.isEmpty else {
            throw OpenAICompatibleProviderError.invalidConfiguration("自定义 API 模型未设置。")
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authorizationHeaderValue {
            request.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try encoder.encode(
            OpenAIChatCompletionRequest(
                model: model,
                messages: [
                    OpenAIChatMessage(role: "user", content: style.prompt(for: text))
                ],
                stream: true,
                temperature: 0.1,
                maxTokens: 512
            )
        )

        let requestID = UUID()
        let runningTask = Task<String, Error> { [session, decoder] in
            var parser = OpenAICompatibleStreamParser()
            var accumulated = ""
            var responseData = Data()
            let (bytes, response) = try await session.bytes(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                for try await byte in bytes {
                    responseData.append(byte)
                }
                let message = (try? decoder.decode(OpenAIErrorResponse.self, from: responseData))?.error.message
                throw OpenAICompatibleProviderError.httpStatus(http.statusCode, message)
            }

            for try await byte in bytes {
                if Task.isCancelled {
                    throw OpenAICompatibleProviderError.cancelled
                }
                let data = Data([byte])
                responseData.append(data)
                for event in parser.feed(data) {
                    switch event {
                    case .content(let token):
                        accumulated += token
                        onToken(token)
                    case .done:
                        return StringSanitizer.cleanTranslation(accumulated)
                    case .error(let message):
                        throw OpenAICompatibleProviderError.streamError(message)
                    case .malformedLine:
                        continue
                    }
                }
            }

            for event in parser.finish() {
                switch event {
                case .content(let token):
                    accumulated += token
                    onToken(token)
                case .done:
                    return StringSanitizer.cleanTranslation(accumulated)
                case .error(let message):
                    throw OpenAICompatibleProviderError.streamError(message)
                case .malformedLine:
                    continue
                }
            }

            if !accumulated.isEmpty {
                return StringSanitizer.cleanTranslation(accumulated)
            }

            if let decoded = try? decoder.decode(OpenAIChatCompletionResponse.self, from: responseData),
               let content = decoded.firstMessageContent {
                let cleaned = StringSanitizer.cleanTranslation(content)
                onToken(cleaned)
                return cleaned
            }

            throw OpenAICompatibleProviderError.missingContent
        }

        setActiveTask(runningTask, requestID: requestID)
        do {
            let value = try await runningTask.value
            clearTaskIfCurrent(requestID: requestID)
            return value
        } catch {
            clearTaskIfCurrent(requestID: requestID)
            throw error
        }
    }

    public func cancelCurrentRequest() {
        lock.lock()
        let current = activeTask
        activeTask = nil
        activeRequestID = nil
        lock.unlock()
        current?.cancel()
    }

    private func setActiveTask(_ task: Task<String, Error>, requestID: UUID) {
        lock.lock()
        activeTask = task
        activeRequestID = requestID
        lock.unlock()
    }

    private func clearTaskIfCurrent(requestID: UUID) {
        lock.lock()
        if activeRequestID == requestID {
            activeTask = nil
            activeRequestID = nil
        }
        lock.unlock()
    }
}
