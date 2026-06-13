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
