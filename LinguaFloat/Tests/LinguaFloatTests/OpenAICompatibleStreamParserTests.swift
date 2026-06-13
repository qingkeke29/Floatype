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
