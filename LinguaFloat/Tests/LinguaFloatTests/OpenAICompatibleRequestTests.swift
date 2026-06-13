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
            let body = try Self.requestBodyData(from: request)
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

        RecordingURLProtocol.requestHandler = { _ in
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

    private static func requestBodyData(from request: URLRequest) throws -> Data {
        if let httpBody = request.httpBody {
            return httpBody
        }
        let stream = try XCTUnwrap(request.httpBodyStream)
        stream.open()
        defer { stream.close() }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count < 0 {
                throw stream.streamError ?? CocoaError(.fileReadUnknown)
            }
            if count == 0 {
                break
            }
            data.append(buffer, count: count)
        }
        return data
    }
}
