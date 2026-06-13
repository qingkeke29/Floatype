# Local And Custom API Model Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Settings-only model source configuration for local Ollama models and custom OpenAI-compatible API models.

**Architecture:** Keep `LocalModelProvider` as the floating panel boundary. Add settings-backed model source configuration, a focused OpenAI-compatible provider, and a router provider that rebuilds the active concrete provider from `AppSettings` so Settings changes affect future translations without putting model switching into the floating panel.

**Tech Stack:** Swift 6 / SwiftPM, AppKit, URLSession, XCTest, local shell build scripts.

---

### File Structure

- Modify: `Sources/LinguaFloatCore/Settings/AppSettings.swift`
  - Persist model source and source-specific configuration.
  - Keep old Ollama keys compatible with existing users and tests.
- Create: `Sources/LinguaFloatCore/Models/ModelSource.swift`
  - Define the two supported sources and UI labels.
- Create: `Sources/LinguaFloatCore/Settings/ModelConfigurationValidator.swift`
  - Validate selected-source settings without depending on AppKit controls.
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift`
  - Encode/decode OpenAI-compatible request, streaming, non-streaming, and error payloads.
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleEndpoint.swift`
  - Normalize custom API URL values to a chat completions endpoint.
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleStreamParser.swift`
  - Parse SSE `data:` streaming chunks and `[DONE]`.
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleProvider.swift`
  - Translate through OpenAI-compatible chat completions.
- Create: `Sources/LinguaFloatCore/LocalModel/SettingsBackedModelProvider.swift`
  - Implement `LocalModelProvider` by selecting Ollama or custom API from `AppSettings`.
- Modify: `Sources/LinguaFloatCore/App/AppEnvironment.swift`
  - Use `SettingsBackedModelProvider` instead of constructing `OllamaProvider` directly.
- Modify: `Sources/LinguaFloatCore/Settings/SettingsViewController.swift`
  - Add Settings-only source selector, local model refresh, custom API fields, validation, and test connection.
- Modify: `Sources/LinguaFloatCore/Models/ProviderStatus.swift`
  - Add source-neutral display text for custom API failures while preserving existing local messages where possible.
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelViewModel.swift`
  - Use provider display values so the panel shows `Ollama · model` or `API · model`.
- Modify: `README.md`
  - Document local Ollama and custom OpenAI-compatible API configuration.
- Test: `Tests/LinguaFloatTests/AppSettingsTests.swift`
  - Add settings persistence/default tests.
- Test: `Tests/LinguaFloatTests/OpenAICompatibleEndpointTests.swift`
  - Add URL normalization tests.
- Test: `Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift`
  - Add request body/header tests.
- Test: `Tests/LinguaFloatTests/OpenAICompatibleStreamParserTests.swift`
  - Add streaming and non-streaming parsing tests.
- Test: `Tests/LinguaFloatTests/ModelConfigurationValidatorTests.swift`
  - Add selected-source validation tests.
- Test: `Tests/LinguaFloatTests/SettingsBackedModelProviderTests.swift`
  - Add router/provider source selection tests.

### Task 1: Persist Model Source Configuration

**Files:**
- Create: `Sources/LinguaFloatCore/Models/ModelSource.swift`
- Modify: `Sources/LinguaFloatCore/Settings/AppSettings.swift`
- Modify: `Tests/LinguaFloatTests/AppSettingsTests.swift`

- [ ] **Step 1: Write failing settings tests**

Append these tests to `Tests/LinguaFloatTests/AppSettingsTests.swift`:

```swift
func testDefaultModelSourceIsLocalOllama() {
    let suiteName = "LinguaFloatModelSourceDefaultTest-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)

    let settings = AppSettings(defaults: defaults)

    XCTAssertEqual(settings.modelSource, .localOllama)
    XCTAssertEqual(settings.localOllamaModel, "qwen3.5:9b")
    XCTAssertEqual(settings.activeModelDisplayName, "Ollama · qwen3.5:9b")
}

func testPersistsCustomAPIConfiguration() {
    let suiteName = "LinguaFloatCustomAPISettingsTest-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let settings = AppSettings(defaults: defaults)

    settings.modelSource = .customAPI
    settings.customAPIURLString = "https://api.deepseek.com"
    settings.customAPIKey = "secret-key"
    settings.customAPIModel = "deepseek-chat"

    let reloaded = AppSettings(defaults: defaults)
    XCTAssertEqual(reloaded.modelSource, .customAPI)
    XCTAssertEqual(reloaded.customAPIURLString, "https://api.deepseek.com")
    XCTAssertEqual(reloaded.customAPIKey, "secret-key")
    XCTAssertEqual(reloaded.customAPIModel, "deepseek-chat")
    XCTAssertEqual(reloaded.activeModelDisplayName, "API · deepseek-chat")
}

func testDefaultModelRemainsAliasForLocalOllamaModel() {
    let suiteName = "LinguaFloatDefaultModelAliasTest-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let settings = AppSettings(defaults: defaults)

    settings.defaultModel = "qwen2.5:7b"

    XCTAssertEqual(settings.localOllamaModel, "qwen2.5:7b")
    XCTAssertEqual(settings.defaultModel, "qwen2.5:7b")
}
```

- [ ] **Step 2: Run tests and verify red**

Run:

```bash
swift test --filter AppSettingsTests --jobs 1
```

Expected: compile fails because `ModelSource`, `modelSource`, `localOllamaModel`, `customAPIURLString`, `customAPIKey`, `customAPIModel`, and `activeModelDisplayName` do not exist.

- [ ] **Step 3: Add `ModelSource`**

Create `Sources/LinguaFloatCore/Models/ModelSource.swift`:

```swift
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
```

- [ ] **Step 4: Extend `AppSettings`**

In `Sources/LinguaFloatCore/Settings/AppSettings.swift`, add these properties after `ollamaBaseURL`:

```swift
public var modelSource: ModelSource {
    get { ModelSource(rawValue: defaults.string(forKey: Keys.modelSource) ?? "") ?? .localOllama }
    set { defaults.set(newValue.rawValue, forKey: Keys.modelSource) }
}

public var localOllamaModel: String {
    get {
        let value = defaults.string(forKey: Keys.defaultModel) ?? ModelDefaults.ollamaModel
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? ModelDefaults.ollamaModel : value
    }
    set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.defaultModel) }
}
```

Replace the existing `defaultModel` property with this compatibility alias:

```swift
public var defaultModel: String {
    get { localOllamaModel }
    set { localOllamaModel = newValue }
}
```

Add these custom API properties after `defaultModel`:

```swift
public var customAPIURLString: String {
    get { defaults.string(forKey: Keys.customAPIURLString) ?? "" }
    set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.customAPIURLString) }
}

public var customAPIKey: String {
    get { defaults.string(forKey: Keys.customAPIKey) ?? "" }
    set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.customAPIKey) }
}

public var customAPIModel: String {
    get { defaults.string(forKey: Keys.customAPIModel) ?? "" }
    set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.customAPIModel) }
}

public var activeModelName: String {
    switch modelSource {
    case .localOllama:
        return localOllamaModel
    case .customAPI:
        return customAPIModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "未设置模型"
            : customAPIModel
    }
}

public var activeModelDisplayName: String {
    "\(modelSource.modelLabelPrefix) · \(activeModelName)"
}
```

Add these defaults in `registerDefaults()`:

```swift
Keys.modelSource: ModelSource.localOllama.rawValue,
Keys.customAPIURLString: "",
Keys.customAPIKey: "",
Keys.customAPIModel: "",
```

Add these keys to `Keys`:

```swift
static let modelSource = "modelSource"
static let customAPIURLString = "customAPIURLString"
static let customAPIKey = "customAPIKey"
static let customAPIModel = "customAPIModel"
```

- [ ] **Step 5: Verify green**

Run:

```bash
swift test --filter AppSettingsTests --jobs 1
```

Expected: all `AppSettingsTests` pass.

- [ ] **Step 6: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/Models/ModelSource.swift Sources/LinguaFloatCore/Settings/AppSettings.swift Tests/LinguaFloatTests/AppSettingsTests.swift
git commit -m "Add model source settings"
```

### Task 2: Add OpenAI-Compatible Endpoint And Request Models

**Files:**
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleEndpoint.swift`
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift`
- Create: `Tests/LinguaFloatTests/OpenAICompatibleEndpointTests.swift`
- Create: `Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift`

- [ ] **Step 1: Write failing endpoint tests**

Create `Tests/LinguaFloatTests/OpenAICompatibleEndpointTests.swift`:

```swift
import Foundation
import XCTest
@testable import LinguaFloatCore

final class OpenAICompatibleEndpointTests: XCTestCase {
    func testUsesChatCompletionsEndpointAsEntered() throws {
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com/v1/chat/completions")

        XCTAssertEqual(endpoint.absoluteString, "https://api.example.com/v1/chat/completions")
    }

    func testAppendsChatCompletionsToV1BaseURL() throws {
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com/v1")

        XCTAssertEqual(endpoint.absoluteString, "https://api.example.com/v1/chat/completions")
    }

    func testAppendsV1ChatCompletionsToPlainBaseURL() throws {
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com")

        XCTAssertEqual(endpoint.absoluteString, "https://api.example.com/v1/chat/completions")
    }

    func testRejectsInvalidURL() {
        XCTAssertThrowsError(try OpenAICompatibleEndpoint.normalized(from: "not a url"))
    }
}
```

- [ ] **Step 2: Write failing request tests**

Create `Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift`:

```swift
import Foundation
import XCTest
@testable import LinguaFloatCore

final class OpenAICompatibleRequestTests: XCTestCase {
    func testChatRequestUsesTranslationPromptAndStreaming() throws {
        let request = OpenAIChatCompletionRequest(
            model: "deepseek-chat",
            messages: [
                OpenAIChatMessage(role: "user", content: TranslationStyle.natural.prompt(for: "你好。"))
            ],
            stream: true,
            temperature: 0.1,
            maxTokens: 512
        )

        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let messages = try XCTUnwrap(json["messages"] as? [[String: String]])

        XCTAssertEqual(json["model"] as? String, "deepseek-chat")
        XCTAssertEqual(json["stream"] as? Bool, true)
        XCTAssertEqual(json["temperature"] as? Double, 0.1)
        XCTAssertEqual(json["max_tokens"] as? Int, 512)
        XCTAssertEqual(messages.first?["role"], "user")
        XCTAssertEqual(messages.first?["content"], TranslationStyle.natural.prompt(for: "你好。"))
    }
}
```

- [ ] **Step 3: Run tests and verify red**

Run:

```bash
swift test --filter OpenAICompatibleEndpointTests --jobs 1
swift test --filter OpenAICompatibleRequestTests --jobs 1
```

Expected: compile fails because endpoint and request types do not exist.

- [ ] **Step 4: Add endpoint normalizer**

Create `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleEndpoint.swift`:

```swift
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
              components.host != nil else {
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
```

- [ ] **Step 5: Add OpenAI-compatible models**

Create `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift`:

```swift
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
```

- [ ] **Step 6: Verify green**

Run:

```bash
swift test --filter OpenAICompatibleEndpointTests --jobs 1
swift test --filter OpenAICompatibleRequestTests --jobs 1
```

Expected: both filtered test runs pass.

- [ ] **Step 7: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/LocalModel/OpenAICompatibleEndpoint.swift Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift Tests/LinguaFloatTests/OpenAICompatibleEndpointTests.swift Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift
git commit -m "Add OpenAI-compatible API request models"
```

### Task 3: Parse Streaming And Non-Streaming OpenAI Responses

**Files:**
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleStreamParser.swift`
- Modify: `Tests/LinguaFloatTests/OpenAICompatibleStreamParserTests.swift`
- Modify: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift`

- [ ] **Step 1: Write failing parser tests**

Create `Tests/LinguaFloatTests/OpenAICompatibleStreamParserTests.swift`:

```swift
import Foundation
import XCTest
@testable import LinguaFloatCore

final class OpenAICompatibleStreamParserTests: XCTestCase {
    func testParsesStreamingContentTokens() {
        var parser = OpenAICompatibleStreamParser()
        let payload = """
        data: {"choices":[{"delta":{"role":"assistant","content":"Hello"},"finish_reason":null}]}

        data: {"choices":[{"delta":{"content":" world"},"finish_reason":null}]}

        data: [DONE]

        """

        let events = parser.feed(Data(payload.utf8))

        XCTAssertEqual(events, [.content("Hello"), .content(" world"), .done])
    }

    func testBuffersPartialLines() {
        var parser = OpenAICompatibleStreamParser()

        XCTAssertEqual(parser.feed(Data("data: {\"choices\":[{\"delta\":{\"content\":\"Hel".utf8)), [])
        XCTAssertEqual(parser.feed(Data("lo\"},\"finish_reason\":null}]}\n\n".utf8)), [.content("Hello")])
    }

    func testParsesStreamingError() {
        var parser = OpenAICompatibleStreamParser()
        let payload = """
        data: {"error":{"message":"bad key","type":"authentication_error","code":"invalid_api_key"}}

        """

        XCTAssertEqual(parser.feed(Data(payload.utf8)), [.error("bad key")])
    }

    func testParsesNonStreamingResponseContent() throws {
        let data = Data("""
        {"choices":[{"message":{"role":"assistant","content":"Final answer"},"finish_reason":"stop"}]}
        """.utf8)

        let decoded = try JSONDecoder().decode(OpenAIChatCompletionResponse.self, from: data)

        XCTAssertEqual(decoded.firstMessageContent, "Final answer")
    }
}
```

- [ ] **Step 2: Run tests and verify red**

Run:

```bash
swift test --filter OpenAICompatibleStreamParserTests --jobs 1
```

Expected: compile fails because `OpenAICompatibleStreamParser`, stream events, and `firstMessageContent` do not exist.

- [ ] **Step 3: Add response convenience**

Append this extension to `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift`:

```swift
public extension OpenAIChatCompletionResponse {
    var firstMessageContent: String? {
        choices.compactMap { $0.message?.content }.first
    }

    var firstDeltaContent: String? {
        choices.compactMap { $0.delta?.content }.first
    }
}
```

- [ ] **Step 4: Add stream parser**

Create `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleStreamParser.swift`:

```swift
import Foundation

public enum OpenAICompatibleStreamEvent: Equatable {
    case content(String)
    case done
    case error(String)
    case malformedLine
}

public struct OpenAICompatibleStreamParser {
    private var buffer = Data()
    private let decoder = JSONDecoder()

    public init() {}

    public mutating func feed(_ data: Data) -> [OpenAICompatibleStreamEvent] {
        buffer.append(data)
        var events: [OpenAICompatibleStreamEvent] = []

        while let newlineRange = buffer.firstRange(of: Data([0x0A])) {
            let lineData = buffer.subdata(in: buffer.startIndex..<newlineRange.lowerBound)
            buffer.removeSubrange(buffer.startIndex...newlineRange.lowerBound)
            events.append(contentsOf: parseLine(lineData))
        }

        return events
    }

    public mutating func finish() -> [OpenAICompatibleStreamEvent] {
        guard !buffer.isEmpty else {
            return []
        }
        let line = buffer
        buffer.removeAll()
        return parseLine(line)
    }

    private func parseLine(_ lineData: Data) -> [OpenAICompatibleStreamEvent] {
        let rawLine = String(decoding: lineData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawLine.isEmpty else {
            return []
        }
        guard rawLine.hasPrefix("data:") else {
            return []
        }

        let payload = rawLine.dropFirst("data:".count).trimmingCharacters(in: .whitespacesAndNewlines)
        if payload == "[DONE]" {
            return [.done]
        }

        guard let data = payload.data(using: .utf8) else {
            return [.malformedLine]
        }

        if let apiError = try? decoder.decode(OpenAIErrorResponse.self, from: data) {
            return [.error(apiError.error.message)]
        }

        guard let decoded = try? decoder.decode(OpenAIChatCompletionResponse.self, from: data) else {
            return [.malformedLine]
        }

        var events: [OpenAICompatibleStreamEvent] = []
        if let content = decoded.firstDeltaContent, !content.isEmpty {
            events.append(.content(content))
        }
        if decoded.choices.contains(where: { $0.finishReason != nil }) {
            events.append(.done)
        }
        return events
    }
}
```

- [ ] **Step 5: Verify green**

Run:

```bash
swift test --filter OpenAICompatibleStreamParserTests --jobs 1
```

Expected: all parser tests pass.

- [ ] **Step 6: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/LocalModel/OpenAICompatibleModels.swift Sources/LinguaFloatCore/LocalModel/OpenAICompatibleStreamParser.swift Tests/LinguaFloatTests/OpenAICompatibleStreamParserTests.swift
git commit -m "Parse OpenAI-compatible streaming responses"
```

### Task 4: Implement OpenAI-Compatible Provider Translation

**Files:**
- Create: `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleProvider.swift`
- Modify: `Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift`

- [ ] **Step 1: Add failing provider request tests**

Append this URL protocol and tests to `Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift`:

```swift
final class RecordingURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            XCTFail("Missing request handler")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension OpenAICompatibleRequestTests {
    func testProviderBuildsAuthorizationHeaderOnlyWhenKeyIsPresent() throws {
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com")
        let providerWithKey = OpenAICompatibleProvider(endpoint: endpoint, apiKey: "abc123", currentModel: "model")
        let providerWithoutKey = OpenAICompatibleProvider(endpoint: endpoint, apiKey: "", currentModel: "model")

        XCTAssertEqual(providerWithKey.authorizationHeaderValue, "Bearer abc123")
        XCTAssertNil(providerWithoutKey.authorizationHeaderValue)
    }

    func testTranslateSendsBearerTokenAndParsesNonStreamingResponse() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RecordingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com")
        let provider = OpenAICompatibleProvider(
            endpoint: endpoint,
            apiKey: "abc123",
            currentModel: "deepseek-chat",
            session: session
        )

        RecordingURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/v1/chat/completions")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer abc123")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            let body = try XCTUnwrap(request.httpBody)
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(json["model"] as? String, "deepseek-chat")
            let response = HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
            let data = Data(#"{"choices":[{"message":{"role":"assistant","content":"Hello"},"finish_reason":"stop"}]}"#.utf8)
            return (response, data)
        }

        let result = try await provider.translate(text: "你好", style: .natural) { _ in }

        XCTAssertEqual(result, "Hello")
    }

    func testTranslateMapsHTTPErrorMessage() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RecordingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let endpoint = try OpenAICompatibleEndpoint.normalized(from: "https://api.example.com")
        let provider = OpenAICompatibleProvider(endpoint: endpoint, apiKey: "bad", currentModel: "model", session: session)

        RecordingURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: endpoint, statusCode: 401, httpVersion: nil, headerFields: nil)!
            let data = Data(#"{"error":{"message":"invalid api key","type":"authentication_error","code":"invalid_api_key"}}"#.utf8)
            return (response, data)
        }

        do {
            _ = try await provider.translate(text: "你好", style: .natural) { _ in }
            XCTFail("Expected translation to throw")
        } catch {
            XCTAssertEqual(error.localizedDescription, "invalid api key")
        }
    }
}
```

- [ ] **Step 2: Run tests and verify red**

Run:

```bash
swift test --filter OpenAICompatibleRequestTests --jobs 1
```

Expected: compile fails because `OpenAICompatibleProvider` does not exist.

- [ ] **Step 3: Implement provider translation**

Create `Sources/LinguaFloatCore/LocalModel/OpenAICompatibleProvider.swift`:

```swift
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
```

- [ ] **Step 4: Verify green**

Run:

```bash
swift test --filter OpenAICompatibleRequestTests --jobs 1
```

Expected: all OpenAI-compatible request/provider tests pass.

- [ ] **Step 5: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/LocalModel/OpenAICompatibleProvider.swift Tests/LinguaFloatTests/OpenAICompatibleRequestTests.swift
git commit -m "Implement custom API translation provider"
```

### Task 5: Add Settings-Backed Provider Router

**Files:**
- Create: `Sources/LinguaFloatCore/LocalModel/SettingsBackedModelProvider.swift`
- Modify: `Sources/LinguaFloatCore/App/AppEnvironment.swift`
- Create: `Tests/LinguaFloatTests/SettingsBackedModelProviderTests.swift`
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelViewModel.swift`

- [ ] **Step 1: Write failing router tests**

Create `Tests/LinguaFloatTests/SettingsBackedModelProviderTests.swift`:

```swift
import Foundation
import XCTest
@testable import LinguaFloatCore

final class SettingsBackedModelProviderTests: XCTestCase {
    func testUsesLocalOllamaDisplayByDefault() {
        let suiteName = "LinguaFloatProviderRouterLocalTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)

        let provider = SettingsBackedModelProvider(settings: settings)

        XCTAssertEqual(provider.providerName, "Ollama")
        XCTAssertEqual(provider.currentModel, "qwen3.5:9b")
        XCTAssertEqual(provider.displayName, "Ollama · qwen3.5:9b")
    }

    func testUsesCustomAPIDisplayAfterSettingsChange() {
        let suiteName = "LinguaFloatProviderRouterCustomTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let settings = AppSettings(defaults: defaults)
        let provider = SettingsBackedModelProvider(settings: settings)

        settings.modelSource = .customAPI
        settings.customAPIURLString = "https://api.example.com"
        settings.customAPIModel = "deepseek-chat"

        XCTAssertEqual(provider.providerName, "API")
        XCTAssertEqual(provider.currentModel, "deepseek-chat")
        XCTAssertEqual(provider.displayName, "API · deepseek-chat")
    }
}
```

- [ ] **Step 2: Run tests and verify red**

Run:

```bash
swift test --filter SettingsBackedModelProviderTests --jobs 1
```

Expected: compile fails because `SettingsBackedModelProvider` and `displayName` do not exist.

- [ ] **Step 3: Add provider router**

Create `Sources/LinguaFloatCore/LocalModel/SettingsBackedModelProvider.swift`:

```swift
import Foundation

public final class SettingsBackedModelProvider: LocalModelProvider {
    private let settings: AppSettings
    private var cachedSignature = ""
    private var cachedProvider: LocalModelProvider?

    public init(settings: AppSettings) {
        self.settings = settings
    }

    public var providerName: String {
        settings.modelSource.modelLabelPrefix
    }

    public var currentModel: String {
        get { settings.activeModelName }
        set {
            switch settings.modelSource {
            case .localOllama:
                settings.localOllamaModel = newValue
            case .customAPI:
                settings.customAPIModel = newValue
            }
        }
    }

    public var displayName: String {
        settings.activeModelDisplayName
    }

    public func checkAvailability() async -> ProviderStatus {
        await activeProvider().checkAvailability()
    }

    public func listModels() async throws -> [LocalModelInfo] {
        try await activeProvider().listModels()
    }

    public func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        try await activeProvider().translate(text: text, style: style, onToken: onToken)
    }

    public func cancelCurrentRequest() {
        cachedProvider?.cancelCurrentRequest()
    }

    private func activeProvider() -> LocalModelProvider {
        let signature = providerSignature()
        if let cachedProvider, cachedSignature == signature {
            return cachedProvider
        }

        cachedProvider?.cancelCurrentRequest()
        let provider: LocalModelProvider
        switch settings.modelSource {
        case .localOllama:
            provider = OllamaProvider(baseURL: settings.ollamaBaseURL, currentModel: settings.localOllamaModel)
        case .customAPI:
            if let endpoint = try? OpenAICompatibleEndpoint.normalized(from: settings.customAPIURLString) {
                provider = OpenAICompatibleProvider(
                    endpoint: endpoint,
                    apiKey: settings.customAPIKey,
                    currentModel: settings.customAPIModel
                )
            } else {
                provider = InvalidModelProvider(
                    providerName: "API",
                    currentModel: settings.activeModelName,
                    message: "API URL 无效。"
                )
            }
        }

        cachedSignature = signature
        cachedProvider = provider
        return provider
    }

    private func providerSignature() -> String {
        [
            settings.modelSource.rawValue,
            settings.ollamaBaseURL.absoluteString,
            settings.localOllamaModel,
            settings.customAPIURLString,
            settings.customAPIKey,
            settings.customAPIModel
        ].joined(separator: "|")
    }
}

private final class InvalidModelProvider: LocalModelProvider {
    let providerName: String
    var currentModel: String
    private let message: String

    init(providerName: String, currentModel: String, message: String) {
        self.providerName = providerName
        self.currentModel = currentModel
        self.message = message
    }

    func checkAvailability() async -> ProviderStatus {
        .failed(message)
    }

    func listModels() async throws -> [LocalModelInfo] {
        []
    }

    func translate(
        text: String,
        style: TranslationStyle,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        throw OpenAICompatibleProviderError.invalidConfiguration(message)
    }

    func cancelCurrentRequest() {}
}
```

- [ ] **Step 4: Update app environment**

In `Sources/LinguaFloatCore/App/AppEnvironment.swift`, replace:

```swift
self.modelProvider = OllamaProvider(baseURL: settings.ollamaBaseURL, currentModel: settings.defaultModel)
```

with:

```swift
self.modelProvider = SettingsBackedModelProvider(settings: settings)
```

- [ ] **Step 5: Update panel model display**

In `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelViewModel.swift`, add this helper:

```swift
private var providerDisplayName: String {
    if let routedProvider = provider as? SettingsBackedModelProvider {
        return routedProvider.displayName
    }
    return "\(provider.providerName) · \(provider.currentModel)"
}
```

Replace both uses of `modelName: provider.currentModel` with:

```swift
modelName: providerDisplayName
```

- [ ] **Step 6: Verify green**

Run:

```bash
swift test --filter SettingsBackedModelProviderTests --jobs 1
swift test --filter FloatingPanelViewModelTests --jobs 1
```

Expected: both filtered test runs pass.

- [ ] **Step 7: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/LocalModel/SettingsBackedModelProvider.swift Sources/LinguaFloatCore/App/AppEnvironment.swift Sources/LinguaFloatCore/FloatingPanel/FloatingPanelViewModel.swift Tests/LinguaFloatTests/SettingsBackedModelProviderTests.swift
git commit -m "Route translations by model source settings"
```

### Task 6: Add Settings Validation

**Files:**
- Create: `Sources/LinguaFloatCore/Settings/ModelConfigurationValidator.swift`
- Create: `Tests/LinguaFloatTests/ModelConfigurationValidatorTests.swift`

- [ ] **Step 1: Write failing validation tests**

Create `Tests/LinguaFloatTests/ModelConfigurationValidatorTests.swift`:

```swift
import Foundation
import XCTest
@testable import LinguaFloatCore

final class ModelConfigurationValidatorTests: XCTestCase {
    func testValidatesLocalModelName() {
        let result = ModelConfigurationValidator.validate(
            source: .localOllama,
            ollamaURL: "http://127.0.0.1:11434",
            localModel: "",
            customAPIURL: "",
            customAPIModel: ""
        )

        XCTAssertEqual(result, .failure("请选择或输入本地模型。"))
    }

    func testValidatesLocalURL() {
        let result = ModelConfigurationValidator.validate(
            source: .localOllama,
            ollamaURL: "bad url",
            localModel: "qwen3.5:9b",
            customAPIURL: "",
            customAPIModel: ""
        )

        XCTAssertEqual(result, .failure("Ollama 地址无效。"))
    }

    func testValidatesCustomAPIURLAndModel() {
        let missingURL = ModelConfigurationValidator.validate(
            source: .customAPI,
            ollamaURL: "http://127.0.0.1:11434",
            localModel: "qwen3.5:9b",
            customAPIURL: "",
            customAPIModel: "deepseek-chat"
        )
        let missingModel = ModelConfigurationValidator.validate(
            source: .customAPI,
            ollamaURL: "http://127.0.0.1:11434",
            localModel: "qwen3.5:9b",
            customAPIURL: "https://api.example.com",
            customAPIModel: ""
        )

        XCTAssertEqual(missingURL, .failure("API URL 不能为空。"))
        XCTAssertEqual(missingModel, .failure("自定义 API 模型不能为空。"))
    }

    func testAcceptsValidCustomAPISettings() {
        let result = ModelConfigurationValidator.validate(
            source: .customAPI,
            ollamaURL: "http://127.0.0.1:11434",
            localModel: "qwen3.5:9b",
            customAPIURL: "https://api.example.com/v1",
            customAPIModel: "deepseek-chat"
        )

        XCTAssertEqual(result, .success)
    }
}
```

- [ ] **Step 2: Run tests and verify red**

Run:

```bash
swift test --filter ModelConfigurationValidatorTests --jobs 1
```

Expected: compile fails because `ModelConfigurationValidator` does not exist.

- [ ] **Step 3: Add validator**

Create `Sources/LinguaFloatCore/Settings/ModelConfigurationValidator.swift`:

```swift
import Foundation

public enum ModelConfigurationValidationResult: Equatable {
    case success
    case failure(String)
}

public enum ModelConfigurationValidator {
    public static func validate(
        source: ModelSource,
        ollamaURL: String,
        localModel: String,
        customAPIURL: String,
        customAPIModel: String
    ) -> ModelConfigurationValidationResult {
        switch source {
        case .localOllama:
            guard isValidHTTPURL(ollamaURL) else {
                return .failure("Ollama 地址无效。")
            }
            guard !localModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure("请选择或输入本地模型。")
            }
            return .success
        case .customAPI:
            guard !customAPIURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure("API URL 不能为空。")
            }
            guard (try? OpenAICompatibleEndpoint.normalized(from: customAPIURL)) != nil else {
                return .failure("API URL 无效。")
            }
            guard !customAPIModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure("自定义 API 模型不能为空。")
            }
            return .success
        }
    }

    private static func isValidHTTPURL(_ rawValue: String) -> Bool {
        guard let url = URL(string: rawValue.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              url.host != nil else {
            return false
        }
        return true
    }
}
```

- [ ] **Step 4: Verify green**

Run:

```bash
swift test --filter ModelConfigurationValidatorTests --jobs 1
```

Expected: all validation tests pass.

- [ ] **Step 5: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/Settings/ModelConfigurationValidator.swift Tests/LinguaFloatTests/ModelConfigurationValidatorTests.swift
git commit -m "Validate model source settings"
```

### Task 7: Update Settings UI

**Files:**
- Modify: `Sources/LinguaFloatCore/Settings/SettingsViewController.swift`

- [ ] **Step 1: Add Settings controls**

In `SettingsViewController`, add these properties near the existing fields:

```swift
private let sourcePopup = NSPopUpButton()
private let localModelCombo = NSComboBox()
private let refreshModelsButton = NSButton(title: "刷新模型", target: nil, action: nil)
private let customAPIURLField = NSTextField()
private let customAPIKeyField = NSSecureTextField()
private let customAPIModelField = NSTextField()
private let testConnectionButton = NSButton(title: "测试连接", target: nil, action: nil)
private let modelMessageLabel = NSTextField(labelWithString: "")
private var localModels: [LocalModelInfo] = []
```

Delete the existing `private let modelField = NSTextField()` property and replace all model field references with `localModelCombo`.

- [ ] **Step 2: Replace model rows in `buildLayout()`**

Replace:

```swift
stack.addArrangedSubview(makeRow("默认模型", modelField))
stack.addArrangedSubview(makeRow("Ollama 地址", baseURLField))
```

with:

```swift
sourcePopup.addItems(withTitles: ModelSource.allCases.map(\.displayName))
sourcePopup.target = self
sourcePopup.action = #selector(modelSourceChanged)
stack.addArrangedSubview(makeRow("模型来源", sourcePopup))

stack.addArrangedSubview(makeRow("Ollama 地址", baseURLField))

let localModelRow = NSStackView()
localModelRow.orientation = .horizontal
localModelRow.spacing = 8
localModelCombo.usesDataSource = false
localModelCombo.completes = true
localModelCombo.widthAnchor.constraint(greaterThanOrEqualToConstant: 170).isActive = true
refreshModelsButton.target = self
refreshModelsButton.action = #selector(refreshLocalModels)
localModelRow.addArrangedSubview(localModelCombo)
localModelRow.addArrangedSubview(refreshModelsButton)
stack.addArrangedSubview(makeRow("本地模型", localModelRow))

stack.addArrangedSubview(makeRow("API URL", customAPIURLField))
stack.addArrangedSubview(makeRow("API Key", customAPIKeyField))
stack.addArrangedSubview(makeRow("API 模型", customAPIModelField))

testConnectionButton.target = self
testConnectionButton.action = #selector(testModelConnection)
stack.addArrangedSubview(makeRow("连接测试", testConnectionButton))

modelMessageLabel.textColor = .secondaryLabelColor
modelMessageLabel.font = .systemFont(ofSize: 12)
stack.addArrangedSubview(modelMessageLabel)
```

- [ ] **Step 3: Load values**

Update `loadValues()`:

```swift
sourcePopup.selectItem(at: ModelSource.allCases.firstIndex(of: settings.modelSource) ?? 0)
localModelCombo.stringValue = settings.localOllamaModel
baseURLField.stringValue = settings.ollamaBaseURL.absoluteString
customAPIURLField.stringValue = settings.customAPIURLString
customAPIKeyField.stringValue = settings.customAPIKey
customAPIModelField.stringValue = settings.customAPIModel
delayField.stringValue = String(format: "%.1f", settings.autoTranslateDelay)
let index = TranslationStyle.allCases.firstIndex(of: settings.defaultStyle) ?? 1
stylePopup.selectItem(at: index)
hotKeyValueLabel.stringValue = settings.globalHotKeyShortcut.displayName
hotKeyMessageLabel.stringValue = "点击录制后依次按两个键；使用时同时按下。"
updateModelSourceVisibility()
```

- [ ] **Step 4: Add source visibility helper**

Add:

```swift
private var selectedModelSource: ModelSource {
    let index = sourcePopup.indexOfSelectedItem
    return ModelSource.allCases.indices.contains(index) ? ModelSource.allCases[index] : .localOllama
}

private func updateModelSourceVisibility() {
    let isLocal = selectedModelSource == .localOllama
    baseURLField.isEnabled = isLocal
    localModelCombo.isEnabled = isLocal
    refreshModelsButton.isEnabled = isLocal
    customAPIURLField.isEnabled = !isLocal
    customAPIKeyField.isEnabled = !isLocal
    customAPIModelField.isEnabled = !isLocal
    modelMessageLabel.stringValue = isLocal
        ? "本地模式会读取 Ollama 已下载模型，也可以手动输入模型名。"
        : "自定义 API 使用 OpenAI-compatible /v1/chat/completions 格式。"
}

@objc private func modelSourceChanged() {
    updateModelSourceVisibility()
}
```

- [ ] **Step 5: Update save validation and persistence**

Replace the model/base URL part of `save()` with:

```swift
let source = selectedModelSource
let ollamaURLString = baseURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
let localModel = localModelCombo.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
let customAPIURL = customAPIURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
let customAPIModel = customAPIModelField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

let validation = ModelConfigurationValidator.validate(
    source: source,
    ollamaURL: ollamaURLString,
    localModel: localModel,
    customAPIURL: customAPIURL,
    customAPIModel: customAPIModel
)
if case .failure(let message) = validation {
    modelMessageLabel.textColor = .systemRed
    modelMessageLabel.stringValue = message
    return
}

settings.modelSource = source
settings.localOllamaModel = localModel
settings.customAPIURLString = customAPIURL
settings.customAPIKey = customAPIKeyField.stringValue
settings.customAPIModel = customAPIModel
if let url = URL(string: ollamaURLString) {
    settings.ollamaBaseURL = url
}
```

Keep the existing style, delay, hotkey callback, and close behavior after this block.

- [ ] **Step 6: Add local model refresh**

Add:

```swift
@objc private func refreshLocalModels() {
    guard let url = URL(string: baseURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        modelMessageLabel.textColor = .systemRed
        modelMessageLabel.stringValue = "Ollama 地址无效。"
        return
    }
    modelMessageLabel.textColor = .secondaryLabelColor
    modelMessageLabel.stringValue = "正在读取本地模型..."
    refreshModelsButton.isEnabled = false

    Task {
        let provider = OllamaProvider(baseURL: url, currentModel: localModelCombo.stringValue)
        do {
            let models = try await provider.listModels()
            await MainActor.run {
                localModels = models
                localModelCombo.removeAllItems()
                localModelCombo.addItems(withObjectValues: models.map(\.name))
                modelMessageLabel.textColor = .secondaryLabelColor
                modelMessageLabel.stringValue = models.isEmpty ? "没有读取到已下载模型。" : "已读取 \(models.count) 个模型。"
                refreshModelsButton.isEnabled = true
            }
        } catch {
            await MainActor.run {
                modelMessageLabel.textColor = .systemRed
                modelMessageLabel.stringValue = "读取 Ollama 模型失败。"
                refreshModelsButton.isEnabled = true
            }
        }
    }
}
```

- [ ] **Step 7: Add connection test**

Add:

```swift
@objc private func testModelConnection() {
    let source = selectedModelSource
    let validation = ModelConfigurationValidator.validate(
        source: source,
        ollamaURL: baseURLField.stringValue,
        localModel: localModelCombo.stringValue,
        customAPIURL: customAPIURLField.stringValue,
        customAPIModel: customAPIModelField.stringValue
    )
    if case .failure(let message) = validation {
        modelMessageLabel.textColor = .systemRed
        modelMessageLabel.stringValue = message
        return
    }

    modelMessageLabel.textColor = .secondaryLabelColor
    modelMessageLabel.stringValue = "正在测试连接..."
    testConnectionButton.isEnabled = false

    Task {
        let status: ProviderStatus
        switch source {
        case .localOllama:
            let provider = OllamaProvider(
                baseURL: URL(string: baseURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!,
                currentModel: localModelCombo.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            status = await provider.checkAvailability()
        case .customAPI:
            do {
                let endpoint = try OpenAICompatibleEndpoint.normalized(from: customAPIURLField.stringValue)
                let provider = OpenAICompatibleProvider(
                    endpoint: endpoint,
                    apiKey: customAPIKeyField.stringValue,
                    currentModel: customAPIModelField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                _ = try await provider.translate(text: "测试", style: .natural) { _ in }
                status = .available
            } catch {
                status = .failed(error.localizedDescription)
            }
        }

        await MainActor.run {
            switch status {
            case .available:
                modelMessageLabel.textColor = .secondaryLabelColor
                modelMessageLabel.stringValue = "连接测试通过。"
            default:
                modelMessageLabel.textColor = .systemRed
                modelMessageLabel.stringValue = status.detailText
            }
            testConnectionButton.isEnabled = true
        }
    }
}
```

- [ ] **Step 8: Compile-check Settings UI**

Run:

```bash
swift test --jobs 1
```

Expected: package compiles and all tests pass.

- [ ] **Step 9: Commit**

Run:

```bash
git add Sources/LinguaFloatCore/Settings/SettingsViewController.swift
git commit -m "Add model source controls to settings"
```

### Task 8: Update Status Text And Documentation

**Files:**
- Modify: `Sources/LinguaFloatCore/Models/ProviderStatus.swift`
- Modify: `README.md`

- [ ] **Step 1: Update provider status language**

In `Sources/LinguaFloatCore/Models/ProviderStatus.swift`, update `displayText` for source-neutral cases:

```swift
case .checking:
    return "检查模型"
case .available:
    return "模型可用"
case .loading:
    return "等待模型"
```

Update `detailText`:

```swift
case .checking:
    return "正在检查模型服务..."
case .available:
    return "当前模型可用。"
case .loading:
    return "首次加载模型可能需要更长时间。"
case .generating:
    return "正在生成英文。"
```

Keep `serviceUnavailable`, `modelMissing`, and `.failed(message)` unchanged because they already carry local or explicit error detail.

- [ ] **Step 2: Update source README**

In `README.md`, replace the local-only requirements section with:

```markdown
## Model Sources

Floatype supports two model sources configured from Settings only:

- Local Ollama: use a local or LAN Ollama URL and choose an installed model from the refreshable model list, or type a model name manually.
- Custom API: use an OpenAI-compatible chat completions API by entering API URL, API Key, and model name.

The floating panel shows the active source/model but does not change model settings. Use the gear button or menu bar Settings window to change source, URL, key, or model.
```

Keep the existing Ollama install command below this section.

- [ ] **Step 3: Verify docs**

Run:

```bash
rg -n "Ollama|自定义 API|OpenAI-compatible|API Key|模型来源" README.md Sources/LinguaFloatCore/Models/ProviderStatus.swift
```

Expected: source README documents both modes and provider status language is source-neutral.

- [ ] **Step 4: Commit**

```bash
git add Sources/LinguaFloatCore/Models/ProviderStatus.swift README.md
git commit -m "Document configurable model sources"
```

### Task 9: Full Verification

**Files:**
- Read: `docs/superpowers/specs/2026-06-13-local-and-custom-api-model-design.md`

- [ ] **Step 1: Run full automated verification**

Run:

```bash
swift test --jobs 1
scripts/build.sh
codesign --verify --deep --strict --verbose=2 /Users/wanghaixu/Applications/Floatype.app
```

Expected: all commands exit 0. `swift test` reports all tests passing, `scripts/build.sh` builds `/Users/wanghaixu/Applications/Floatype.app`, and `codesign` reports no error.

- [ ] **Step 2: Manual local mode checklist**

Launch:

```bash
open /Users/wanghaixu/Applications/Floatype.app
```

Checklist:

- Open Settings.
- Confirm default source is `本地 Ollama`.
- Confirm `Ollama 地址` is `http://127.0.0.1:11434`.
- Click `刷新模型`.
- Confirm downloaded Ollama models appear in the picker.
- Save a manually typed local model name.
- Open the floating panel.
- Confirm the panel shows `Ollama · <model>`.
- Confirm the panel does not allow source, URL, key, or model changes.

- [ ] **Step 3: Manual custom API checklist**

Use a known OpenAI-compatible test endpoint and key. Do not paste the key into logs or docs.

Checklist:

- Open Settings.
- Select `自定义 API`.
- Enter API URL, API Key, and model name.
- Click `测试连接`.
- Save.
- Open the floating panel.
- Confirm the panel shows `API · <model>`.
- Translate a short Chinese phrase.
- Confirm wrong API Key produces a clear error without displaying the key.
- Confirm wrong model produces a clear error without displaying the key.
- Confirm source/model/API fields still cannot be changed in the floating panel.

- [ ] **Step 4: Check repository state**

Run:

```bash
git status --short --branch
```

Expected: only unrelated pre-existing untracked release artifacts remain, or the worktree is clean if those artifacts were intentionally handled separately.
