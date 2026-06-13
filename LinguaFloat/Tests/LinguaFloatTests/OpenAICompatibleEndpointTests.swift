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
