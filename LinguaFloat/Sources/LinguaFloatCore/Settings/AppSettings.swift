import AppKit
import Foundation

public final class AppSettings {
    public static let shared = AppSettings()

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
        migratePreviousDefaults()
    }

    public var ollamaBaseURL: URL {
        get {
            URL(string: defaults.string(forKey: Keys.ollamaBaseURL) ?? "http://127.0.0.1:11434")
                ?? URL(string: "http://127.0.0.1:11434")!
        }
        set { defaults.set(newValue.absoluteString, forKey: Keys.ollamaBaseURL) }
    }

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

    public var defaultModel: String {
        get { localOllamaModel }
        set { localOllamaModel = newValue }
    }

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

    public var sourceLanguage: TranslationLanguage {
        get { TranslationLanguage(rawValue: defaults.string(forKey: Keys.sourceLanguage) ?? "") ?? .auto }
        set { defaults.set(newValue.rawValue, forKey: Keys.sourceLanguage) }
    }

    public var targetLanguage: TranslationLanguage {
        get {
            let language = TranslationLanguage(rawValue: defaults.string(forKey: Keys.targetLanguage) ?? "") ?? .english
            return language == .auto ? .english : language
        }
        set {
            defaults.set((newValue == .auto ? TranslationLanguage.english : newValue).rawValue, forKey: Keys.targetLanguage)
        }
    }

    public var translationMode: TranslationMode {
        get {
            if let rawValue = defaults.string(forKey: Keys.translationMode),
               let mode = TranslationMode(rawValue: rawValue) {
                return mode
            }
            let legacy = TranslationStyle(rawValue: defaults.string(forKey: Keys.defaultStyle) ?? "") ?? .natural
            return TranslationMode(legacyStyle: legacy)
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.translationMode)
            defaults.set(newValue.legacyStyle.rawValue, forKey: Keys.defaultStyle)
        }
    }

    public var multiLanguageOutput: Bool {
        get { defaults.bool(forKey: Keys.multiLanguageOutput) }
        set { defaults.set(newValue, forKey: Keys.multiLanguageOutput) }
    }

    public var translationPreferences: TranslationPreferences {
        TranslationPreferences(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            mode: translationMode,
            multiLanguageOutput: multiLanguageOutput
        )
    }

    public var translationSettingsSummary: String {
        [
            "\(sourceLanguage.displayName) → \((targetLanguage == .auto ? TranslationLanguage.english : targetLanguage).displayName)",
            translationMode.displayName,
            multiLanguageOutput ? "Multi" : nil
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    public var command1UseChineseEnabled: Bool {
        get { defaults.bool(forKey: Keys.command1UseChineseEnabled) }
        set { defaults.set(newValue, forKey: Keys.command1UseChineseEnabled) }
    }

    public var command2UseEnglishEnabled: Bool {
        get { defaults.bool(forKey: Keys.command2UseEnglishEnabled) }
        set { defaults.set(newValue, forKey: Keys.command2UseEnglishEnabled) }
    }

    public var command3UseSettingsDefaultEnabled: Bool {
        get { defaults.bool(forKey: Keys.command3UseSettingsDefaultEnabled) }
        set { defaults.set(newValue, forKey: Keys.command3UseSettingsDefaultEnabled) }
    }

    public var commandShiftMToggleMultiLanguageEnabled: Bool {
        get { defaults.bool(forKey: Keys.commandShiftMToggleMultiLanguageEnabled) }
        set { defaults.set(newValue, forKey: Keys.commandShiftMToggleMultiLanguageEnabled) }
    }

    public var defaultStyle: TranslationStyle {
        get { translationMode.legacyStyle }
        set { translationMode = TranslationMode(legacyStyle: newValue) }
    }

    public var defaultOutputSelection: OutputSelection {
        get {
            (OutputSelection(rawValue: defaults.string(forKey: Keys.defaultOutputSelection) ?? "") ?? .english)
                .panelSelection
        }
        set { defaults.set(newValue.panelSelection.rawValue, forKey: Keys.defaultOutputSelection) }
    }

    public var autoTranslateEnabled: Bool {
        get { defaults.bool(forKey: Keys.autoTranslateEnabled) }
        set { defaults.set(newValue, forKey: Keys.autoTranslateEnabled) }
    }

    public var autoTranslateDelay: TimeInterval {
        get { defaults.double(forKey: Keys.autoTranslateDelay) }
        set { defaults.set(max(0.2, min(newValue, 3.0)), forKey: Keys.autoTranslateDelay) }
    }

    public var preserveNewlines: Bool {
        get { defaults.bool(forKey: Keys.preserveNewlines) }
        set { defaults.set(newValue, forKey: Keys.preserveNewlines) }
    }

    public var openPanelOnLaunch: Bool {
        get { defaults.bool(forKey: Keys.openPanelOnLaunch) }
        set { defaults.set(newValue, forKey: Keys.openPanelOnLaunch) }
    }

    public var globalHotKeyShortcut: GlobalHotKeyShortcut {
        get {
            let value = defaults.string(forKey: Keys.globalHotKeyShortcut)
                ?? GlobalHotKeyShortcut.defaultShortcut.storageValue
            return GlobalHotKeyShortcut.fromStorageValue(value) ?? GlobalHotKeyShortcut.defaultShortcut
        }
        set { defaults.set(newValue.storageValue, forKey: Keys.globalHotKeyShortcut) }
    }

    public var lastPanelFrame: NSRect? {
        get {
            guard let string = defaults.string(forKey: Keys.lastPanelFrame) else {
                return nil
            }
            let rect = NSRectFromString(string)
            return rect.isEmpty ? nil : rect
        }
        set {
            if let newValue {
                defaults.set(NSStringFromRect(newValue), forKey: Keys.lastPanelFrame)
            } else {
                defaults.removeObject(forKey: Keys.lastPanelFrame)
            }
        }
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.ollamaBaseURL: "http://127.0.0.1:11434",
            Keys.modelSource: ModelSource.localOllama.rawValue,
            Keys.defaultModel: ModelDefaults.ollamaModel,
            Keys.customAPIURLString: "",
            Keys.customAPIKey: "",
            Keys.customAPIModel: "",
            Keys.sourceLanguage: TranslationLanguage.auto.rawValue,
            Keys.targetLanguage: TranslationLanguage.english.rawValue,
            Keys.translationMode: TranslationMode.natural.rawValue,
            Keys.multiLanguageOutput: false,
            Keys.defaultStyle: TranslationStyle.natural.rawValue,
            Keys.defaultOutputSelection: OutputSelection.english.rawValue,
            Keys.autoTranslateEnabled: true,
            Keys.autoTranslateDelay: 0.7,
            Keys.preserveNewlines: true,
            Keys.openPanelOnLaunch: false,
            Keys.globalHotKeyShortcut: GlobalHotKeyShortcut.defaultShortcut.storageValue,
            Keys.command1UseChineseEnabled: true,
            Keys.command2UseEnglishEnabled: true,
            Keys.command3UseSettingsDefaultEnabled: true,
            Keys.commandShiftMToggleMultiLanguageEnabled: true
        ])
    }

    private func migratePreviousDefaults() {
        if defaults.string(forKey: Keys.defaultModel) == "translategemma:4b" {
            defaults.set(ModelDefaults.ollamaModel, forKey: Keys.defaultModel)
        }
    }

    private enum Keys {
        static let ollamaBaseURL = "ollamaBaseURL"
        static let modelSource = "modelSource"
        static let defaultModel = "defaultModel"
        static let customAPIURLString = "customAPIURLString"
        static let customAPIKey = "customAPIKey"
        static let customAPIModel = "customAPIModel"
        static let sourceLanguage = "sourceLanguage"
        static let targetLanguage = "targetLanguage"
        static let translationMode = "translationMode"
        static let multiLanguageOutput = "multiLanguageOutput"
        static let defaultStyle = "defaultStyle"
        static let defaultOutputSelection = "defaultOutputSelection"
        static let autoTranslateEnabled = "autoTranslateEnabled"
        static let autoTranslateDelay = "autoTranslateDelay"
        static let preserveNewlines = "preserveNewlines"
        static let openPanelOnLaunch = "openPanelOnLaunch"
        static let globalHotKeyShortcut = "globalHotKeyShortcut"
        static let lastPanelFrame = "lastPanelFrame"
        static let command1UseChineseEnabled = "command1UseChineseEnabled"
        static let command2UseEnglishEnabled = "command2UseEnglishEnabled"
        static let command3UseSettingsDefaultEnabled = "command3UseSettingsDefaultEnabled"
        static let commandShiftMToggleMultiLanguageEnabled = "commandShiftMToggleMultiLanguageEnabled"
    }
}
