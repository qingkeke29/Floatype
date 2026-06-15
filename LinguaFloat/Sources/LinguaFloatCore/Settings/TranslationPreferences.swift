import Foundation

public enum TranslationLanguage: String, CaseIterable, Codable, Equatable {
    case auto
    case chinese
    case english
    case japanese
    case korean
    case french
    case german
    case spanish

    public var displayName: String {
        switch self {
        case .auto:
            return "Auto"
        case .chinese:
            return "Chinese"
        case .english:
            return "English"
        case .japanese:
            return "Japanese"
        case .korean:
            return "Korean"
        case .french:
            return "French"
        case .german:
            return "German"
        case .spanish:
            return "Spanish"
        }
    }

    public var settingsDisplayName: String {
        switch self {
        case .auto:
            return "自动检测"
        case .chinese:
            return "中文"
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Español"
        }
    }

    public static func targetOptions(forSource sourceLanguage: TranslationLanguage) -> [TranslationLanguage] {
        let resolvedSource = sourceLanguage == .auto ? TranslationLanguage.chinese : sourceLanguage
        return allCases.filter { language in
            language != .auto && language != resolvedSource
        }
    }

    public func targetDisplayName(forSource sourceLanguage: TranslationLanguage) -> String {
        let resolvedSource = sourceLanguage == .auto ? TranslationLanguage.chinese : sourceLanguage
        switch resolvedSource {
        case .chinese, .auto:
            return chineseTargetDisplayName
        default:
            return displayName
        }
    }

    public var resultTitle: String {
        resultTitle(forSource: .chinese)
    }

    public func resultTitle(forSource sourceLanguage: TranslationLanguage) -> String {
        let resolvedSource = sourceLanguage == .auto ? TranslationLanguage.chinese : sourceLanguage
        switch resolvedSource {
        case .english:
            return "\(displayName) Result"
        case .japanese:
            return "\(japaneseResultLanguageName)結果"
        case .korean:
            return "\(koreanResultLanguageName) 결과"
        case .french:
            return "Résultat en \(frenchResultLanguageName)"
        case .german:
            return "\(germanResultLanguageName)-Ergebnis"
        case .spanish:
            return "Resultado en \(spanishResultLanguageName)"
        case .chinese, .auto:
            return chineseResultTitle
        }
    }

    public func resultPlaceholder(forSource sourceLanguage: TranslationLanguage) -> String {
        let title = resultTitle(forSource: sourceLanguage)
        let resolvedSource = sourceLanguage == .auto ? TranslationLanguage.chinese : sourceLanguage
        switch resolvedSource {
        case .english:
            return "\(title) will appear here"
        case .japanese:
            return "\(title)がここに表示されます"
        case .korean:
            return "\(title)가 여기에 표시됩니다"
        case .french:
            return "\(title) s'affichera ici"
        case .german:
            return "\(title) wird hier angezeigt"
        case .spanish:
            return "\(title) aparecerá aquí"
        case .chinese, .auto:
            return "\(title)将在这里生成"
        }
    }

    private var chineseResultTitle: String {
        switch self {
        case .auto:
            return "结果"
        case .chinese:
            return "中文结果"
        case .english:
            return "英文结果"
        case .japanese:
            return "日语结果"
        case .korean:
            return "韩语结果"
        case .french:
            return "法语结果"
        case .german:
            return "德语结果"
        case .spanish:
            return "西班牙语结果"
        }
    }

    private var japaneseResultLanguageName: String {
        switch self {
        case .auto:
            return "自動"
        case .chinese:
            return "中国語"
        case .english:
            return "英語"
        case .japanese:
            return "日本語"
        case .korean:
            return "韓国語"
        case .french:
            return "フランス語"
        case .german:
            return "ドイツ語"
        case .spanish:
            return "スペイン語"
        }
    }

    private var koreanResultLanguageName: String {
        switch self {
        case .auto:
            return "자동"
        case .chinese:
            return "중국어"
        case .english:
            return "영어"
        case .japanese:
            return "일본어"
        case .korean:
            return "한국어"
        case .french:
            return "프랑스어"
        case .german:
            return "독일어"
        case .spanish:
            return "스페인어"
        }
    }

    private var frenchResultLanguageName: String {
        switch self {
        case .auto:
            return "langue détectée"
        case .chinese:
            return "chinois"
        case .english:
            return "anglais"
        case .japanese:
            return "japonais"
        case .korean:
            return "coréen"
        case .french:
            return "français"
        case .german:
            return "allemand"
        case .spanish:
            return "espagnol"
        }
    }

    private var germanResultLanguageName: String {
        switch self {
        case .auto:
            return "Auto"
        case .chinese:
            return "Chinesisch"
        case .english:
            return "Englisch"
        case .japanese:
            return "Japanisch"
        case .korean:
            return "Koreanisch"
        case .french:
            return "Französisch"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Spanisch"
        }
    }

    private var spanishResultLanguageName: String {
        switch self {
        case .auto:
            return "idioma detectado"
        case .chinese:
            return "chino"
        case .english:
            return "inglés"
        case .japanese:
            return "japonés"
        case .korean:
            return "coreano"
        case .french:
            return "francés"
        case .german:
            return "alemán"
        case .spanish:
            return "español"
        }
    }

    private var chineseTargetDisplayName: String {
        switch self {
        case .auto:
            return "自动检测"
        case .chinese:
            return "中文"
        case .english:
            return "英语"
        case .japanese:
            return "日语"
        case .korean:
            return "韩语"
        case .french:
            return "法语"
        case .german:
            return "德语"
        case .spanish:
            return "西班牙语"
        }
    }
}

public enum TranslationMode: String, CaseIterable, Codable, Equatable {
    case normal
    case natural
    case formal
    case casual

    public var displayName: String {
        switch self {
        case .normal:
            return "Normal"
        case .natural:
            return "Natural"
        case .formal:
            return "Formal"
        case .casual:
            return "Casual"
        }
    }

    public var settingsDisplayName: String {
        switch self {
        case .normal:
            return "普通"
        case .natural:
            return "自然"
        case .formal:
            return "正式"
        case .casual:
            return "口语"
        }
    }

    public var legacyStyle: TranslationStyle {
        switch self {
        case .normal:
            return .accurate
        case .natural:
            return .natural
        case .formal:
            return .formal
        case .casual:
            return .casual
        }
    }

    public init(legacyStyle: TranslationStyle) {
        switch legacyStyle {
        case .accurate:
            self = .normal
        case .natural:
            self = .natural
        case .formal:
            self = .formal
        case .casual:
            self = .casual
        }
    }
}

public struct TranslationPreferences: Equatable {
    public let sourceLanguage: TranslationLanguage
    public let targetLanguage: TranslationLanguage
    public let mode: TranslationMode
    public let multiLanguageOutput: Bool

    public init(
        sourceLanguage: TranslationLanguage,
        targetLanguage: TranslationLanguage,
        mode: TranslationMode,
        multiLanguageOutput: Bool
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.mode = mode
        self.multiLanguageOutput = multiLanguageOutput
    }
}
