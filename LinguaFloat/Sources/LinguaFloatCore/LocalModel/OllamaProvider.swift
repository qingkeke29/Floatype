import Foundation

public enum OllamaProviderError: LocalizedError, Equatable {
    case invalidBaseURL
    case httpStatus(Int)
    case streamError(String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "Invalid Ollama base URL."
        case .httpStatus(let status):
            return "Ollama returned HTTP \(status)."
        case .streamError(let message):
            return message
        case .cancelled:
            return "Translation cancelled."
        }
    }
}

public final class OllamaProvider: LocalModelProvider {
    public let providerName = "Ollama"
    public var currentModel: String

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder = JSONEncoder()
    private let lock = NSLock()
    private var activeTask: Task<String, Error>?
    private var activeRequestID: UUID?

    public init(
        baseURL: URL = URL(string: "http://127.0.0.1:11434")!,
        currentModel: String = ModelDefaults.ollamaModel,
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL
        self.currentModel = currentModel
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 600
        self.session = session ?? URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func checkAvailability() async -> ProviderStatus {
        do {
            let models = try await listModels()
            return models.contains { $0.name == currentModel } ? .available : .modelMissing(currentModel)
        } catch {
            return .serviceUnavailable
        }
    }

    public func listModels() async throws -> [LocalModelInfo] {
        let url = baseURL.appendingPathComponent("api/tags")
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw OllamaProviderError.httpStatus(http.statusCode)
        }
        let decoded = try decoder.decode(OllamaTagsResponse.self, from: data)
        return decoded.models.map { LocalModelInfo(name: $0.name, modifiedAt: $0.modifiedAt, size: $0.size) }
    }

    public func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        cancelCurrentRequest()

        let model = currentModel
        let url = baseURL.appendingPathComponent("api/chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(
            OllamaChatRequest(
                model: model,
                messages: [
                    OllamaChatMessage(role: "user", content: style.prompt(for: text))
                ],
                stream: true,
                options: OllamaOptions(temperature: 0.1, numPredict: 512)
            )
        )

        let requestID = UUID()
        let runningTask = Task<String, Error> { [session] in
            var parser = OllamaStreamParser()
            var accumulated = ""
            let (bytes, response) = try await session.bytes(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw OllamaProviderError.httpStatus(http.statusCode)
            }

            for try await byte in bytes {
                if Task.isCancelled {
                    throw OllamaProviderError.cancelled
                }
                let events = parser.feed(Data([byte]))
                for event in events {
                    switch event {
                    case .content(let token):
                        accumulated += token
                        onToken(token)
                    case .done:
                        return StringSanitizer.cleanTranslation(accumulated)
                    case .error(let message):
                        throw OllamaProviderError.streamError(message)
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
                    throw OllamaProviderError.streamError(message)
                case .malformedLine:
                    continue
                }
            }

            return StringSanitizer.cleanTranslation(accumulated)
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
