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
              let host = url.host,
              !host.isEmpty else {
            return false
        }
        return true
    }
}
