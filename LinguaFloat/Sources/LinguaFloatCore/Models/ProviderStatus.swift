import Foundation

public enum ProviderStatus: Equatable {
    case checking
    case available
    case serviceUnavailable
    case modelMissing(String)
    case loading
    case generating
    case failed(String)

    public var displayText: String {
        switch self {
        case .checking:
            return "检查模型"
        case .available:
            return "模型可用"
        case .serviceUnavailable:
            return "Ollama 未运行"
        case .modelMissing:
            return "模型未安装"
        case .loading:
            return "等待模型"
        case .generating:
            return "正在翻译"
        case .failed:
            return "翻译失败"
        }
    }

    public var detailText: String {
        switch self {
        case .checking:
            return "正在检查模型服务..."
        case .available:
            return "当前模型可用。"
        case .serviceUnavailable:
            return "Ollama 尚未运行，本地英文翻译暂不可用。"
        case .modelMissing(let model):
            return "未发现 \(model)"
        case .loading:
            return "首次加载模型可能需要更长时间。"
        case .generating:
            return "正在生成英文。"
        case .failed(let message):
            return message
        }
    }

    public var isModelMissing: Bool {
        if case .modelMissing = self {
            return true
        }
        return false
    }
}
