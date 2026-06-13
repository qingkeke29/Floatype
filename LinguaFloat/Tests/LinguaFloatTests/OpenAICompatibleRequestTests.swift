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
