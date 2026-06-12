import Foundation
import XCTest
@testable import LinguaFloatCore

final class OllamaRequestTests: XCTestCase {
    func testChatRequestDisablesThinkingForTranslation() throws {
        let request = OllamaChatRequest(
            model: "qwen3.5:9b",
            messages: [
                OllamaChatMessage(role: "user", content: TranslationStyle.natural.prompt(for: "你好。"))
            ],
            stream: true,
            options: OllamaOptions(temperature: 0.1, numPredict: 64)
        )

        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["think"] as? Bool, false)
    }
}
