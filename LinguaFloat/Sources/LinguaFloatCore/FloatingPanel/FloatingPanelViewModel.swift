import Foundation

struct FloatingPanelState: Equatable {
    var chineseText: String = ""
    var englishText: String = ""
    var selectedOutput: OutputSelection = .english
    var style: TranslationStyle = .natural
    var providerStatus: ProviderStatus = .checking
    var statusText: String = "等待输入"
    var modelName: String = ModelDefaults.ollamaModel
    var settingsSummary: String = "Auto → English · Natural"
    var isMultiLanguageOutput: Bool = false
    var panelTitle: String = "浮译"
    var sourceTitle: String = "中文原文"
    var sourcePlaceholder: String = "输入中文..."
    var resultTitle: String = "英文结果"
    var resultPlaceholder: String = "英文结果将在这里生成"
    var bottomHint: String = "↑↓ 选择 · ↩ 填入 · Esc 取消 · Tab 重新翻译"
    var settingsTooltip: String = "设置"
    var retryTitle: String = "重新检测"
    var installCommandTitle: String = "复制安装命令"
    var stopTitle: String = "停止"
    var isGenerating: Bool = false
    var errorMessage: String?
}

private struct FloatingPanelCopy {
    let panelTitle: String
    let sourceTitle: String
    let sourcePlaceholder: String
    let bottomHint: String
    let settingsTooltip: String
    let retryTitle: String
    let installCommandTitle: String
    let stopTitle: String
    let waiting: String
    let composing: String
    let translating: String
    let complete: String
    let failed: String
    let installCommandCopied: String
    let multiLanguageOn: String
    let multiLanguageOff: String
    let checking: String
    let available: String
    let serviceUnavailable: String
    let modelMissing: String
    let loading: String

    static func make(for language: TranslationLanguage) -> FloatingPanelCopy {
        switch language == .auto ? TranslationLanguage.chinese : language {
        case .english:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "English Source",
                sourcePlaceholder: "Type English here...",
                bottomHint: "↑↓ Select · ↩ Insert · Esc Cancel · Tab Translate again",
                settingsTooltip: "Settings",
                retryTitle: "Retry",
                installCommandTitle: "Copy install command",
                stopTitle: "Stop",
                waiting: "Waiting",
                composing: "Composing",
                translating: "Translating",
                complete: "Translation complete",
                failed: "Translation failed",
                installCommandCopied: "Install command copied",
                multiLanguageOn: "Multi-language output on",
                multiLanguageOff: "Multi-language output off",
                checking: "Checking model",
                available: "Model ready",
                serviceUnavailable: "Ollama not running",
                modelMissing: "Model missing",
                loading: "Loading model"
            )
        case .japanese:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "日本語原文",
                sourcePlaceholder: "日本語を入力...",
                bottomHint: "↑↓ 選択 · ↩ 挿入 · Esc キャンセル · Tab 再翻訳",
                settingsTooltip: "設定",
                retryTitle: "再確認",
                installCommandTitle: "インストールコマンドをコピー",
                stopTitle: "停止",
                waiting: "入力待ち",
                composing: "変換中",
                translating: "翻訳中",
                complete: "翻訳完了",
                failed: "翻訳失敗",
                installCommandCopied: "インストールコマンドをコピーしました",
                multiLanguageOn: "多言語出力オン",
                multiLanguageOff: "多言語出力オフ",
                checking: "モデル確認中",
                available: "モデル使用可",
                serviceUnavailable: "Ollamaが未起動",
                modelMissing: "モデル未インストール",
                loading: "モデル待機中"
            )
        case .korean:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "한국어 원문",
                sourcePlaceholder: "한국어를 입력하세요...",
                bottomHint: "↑↓ 선택 · ↩ 입력 · Esc 취소 · Tab 다시 번역",
                settingsTooltip: "설정",
                retryTitle: "다시 확인",
                installCommandTitle: "설치 명령 복사",
                stopTitle: "중지",
                waiting: "입력 대기",
                composing: "조합 중",
                translating: "번역 중",
                complete: "번역 완료",
                failed: "번역 실패",
                installCommandCopied: "설치 명령이 복사되었습니다",
                multiLanguageOn: "다국어 출력 켜짐",
                multiLanguageOff: "다국어 출력 꺼짐",
                checking: "모델 확인 중",
                available: "모델 사용 가능",
                serviceUnavailable: "Ollama가 실행 중이 아님",
                modelMissing: "모델 미설치",
                loading: "모델 대기 중"
            )
        case .french:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "Texte français",
                sourcePlaceholder: "Saisissez le français...",
                bottomHint: "↑↓ Choisir · ↩ Insérer · Esc Annuler · Tab Retraduire",
                settingsTooltip: "Réglages",
                retryTitle: "Réessayer",
                installCommandTitle: "Copier la commande",
                stopTitle: "Arrêter",
                waiting: "En attente",
                composing: "Composition",
                translating: "Traduction",
                complete: "Traduction terminée",
                failed: "Échec de traduction",
                installCommandCopied: "Commande copiée",
                multiLanguageOn: "Sortie multilingue activée",
                multiLanguageOff: "Sortie multilingue désactivée",
                checking: "Vérification du modèle",
                available: "Modèle disponible",
                serviceUnavailable: "Ollama non lancé",
                modelMissing: "Modèle absent",
                loading: "Chargement du modèle"
            )
        case .german:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "Deutscher Text",
                sourcePlaceholder: "Deutsch eingeben...",
                bottomHint: "↑↓ Auswählen · ↩ Einfügen · Esc Abbrechen · Tab Neu übersetzen",
                settingsTooltip: "Einstellungen",
                retryTitle: "Erneut prüfen",
                installCommandTitle: "Installationsbefehl kopieren",
                stopTitle: "Stoppen",
                waiting: "Warten auf Eingabe",
                composing: "Zusammensetzen",
                translating: "Übersetzen",
                complete: "Übersetzung fertig",
                failed: "Übersetzung fehlgeschlagen",
                installCommandCopied: "Installationsbefehl kopiert",
                multiLanguageOn: "Mehrsprachige Ausgabe an",
                multiLanguageOff: "Mehrsprachige Ausgabe aus",
                checking: "Modell wird geprüft",
                available: "Modell verfügbar",
                serviceUnavailable: "Ollama läuft nicht",
                modelMissing: "Modell fehlt",
                loading: "Warte auf Modell"
            )
        case .spanish:
            return FloatingPanelCopy(
                panelTitle: "Floatype",
                sourceTitle: "Texto en español",
                sourcePlaceholder: "Escribe en español...",
                bottomHint: "↑↓ Elegir · ↩ Insertar · Esc Cancelar · Tab Retraducir",
                settingsTooltip: "Ajustes",
                retryTitle: "Revisar",
                installCommandTitle: "Copiar comando",
                stopTitle: "Detener",
                waiting: "Esperando",
                composing: "Componiendo",
                translating: "Traduciendo",
                complete: "Traducción completa",
                failed: "Error de traducción",
                installCommandCopied: "Comando copiado",
                multiLanguageOn: "Salida multilingüe activada",
                multiLanguageOff: "Salida multilingüe desactivada",
                checking: "Comprobando modelo",
                available: "Modelo disponible",
                serviceUnavailable: "Ollama no está en ejecución",
                modelMissing: "Modelo no instalado",
                loading: "Esperando modelo"
            )
        case .chinese, .auto:
            return FloatingPanelCopy(
                panelTitle: "浮译",
                sourceTitle: "中文原文",
                sourcePlaceholder: "输入中文...",
                bottomHint: "↑↓ 选择 · ↩ 填入 · Esc 取消 · Tab 重新翻译",
                settingsTooltip: "设置",
                retryTitle: "重新检测",
                installCommandTitle: "复制安装命令",
                stopTitle: "停止",
                waiting: "等待输入",
                composing: "正在组词",
                translating: "正在翻译",
                complete: "翻译完成",
                failed: "翻译失败",
                installCommandCopied: "已复制安装命令",
                multiLanguageOn: "多语言输出已开启",
                multiLanguageOff: "多语言输出已关闭",
                checking: "检查模型",
                available: "模型可用",
                serviceUnavailable: "Ollama 未运行",
                modelMissing: "模型未安装",
                loading: "等待模型"
            )
        }
    }

    func text(for status: ProviderStatus) -> String {
        switch status {
        case .checking:
            return checking
        case .available:
            return available
        case .serviceUnavailable:
            return serviceUnavailable
        case .modelMissing:
            return modelMissing
        case .loading:
            return loading
        case .generating:
            return translating
        case .failed:
            return failed
        }
    }
}

@MainActor
final class FloatingPanelViewModel {
    var onStateChange: ((FloatingPanelState) -> Void)?

    private let provider: LocalModelProvider
    private let settings: AppSettings
    private let debouncer = Debouncer()
    private var generationID = 0
    private var lastTranslatedSource = ""
    private var isPanelOpen = false
    private(set) var state: FloatingPanelState

    init(provider: LocalModelProvider, settings: AppSettings) {
        self.provider = provider
        self.settings = settings
        let copy = Self.panelCopy(for: settings)
        self.state = FloatingPanelState(
            selectedOutput: settings.defaultOutputSelection,
            style: settings.defaultStyle,
            statusText: copy.waiting,
            modelName: Self.providerDisplayName(for: provider),
            settingsSummary: settings.translationSettingsSummary,
            isMultiLanguageOutput: settings.multiLanguageOutput,
            panelTitle: copy.panelTitle,
            sourceTitle: copy.sourceTitle,
            sourcePlaceholder: copy.sourcePlaceholder,
            resultTitle: Self.resultTitle(for: settings),
            resultPlaceholder: Self.resultPlaceholder(for: settings),
            bottomHint: copy.bottomHint,
            settingsTooltip: copy.settingsTooltip,
            retryTitle: copy.retryTitle,
            installCommandTitle: copy.installCommandTitle,
            stopTitle: copy.stopTitle
        )
    }

    func resetForOpen() {
        generationID += 1
        provider.cancelCurrentRequest()
        debouncer.cancel()
        isPanelOpen = true
        lastTranslatedSource = ""
        let copy = Self.panelCopy(for: settings)
        state = FloatingPanelState(
            selectedOutput: settings.defaultOutputSelection,
            style: settings.defaultStyle,
            providerStatus: state.providerStatus,
            statusText: copy.waiting,
            modelName: providerDisplayName,
            settingsSummary: settings.translationSettingsSummary,
            isMultiLanguageOutput: settings.multiLanguageOutput,
            panelTitle: copy.panelTitle,
            sourceTitle: copy.sourceTitle,
            sourcePlaceholder: copy.sourcePlaceholder,
            resultTitle: Self.resultTitle(for: settings),
            resultPlaceholder: Self.resultPlaceholder(for: settings),
            bottomHint: copy.bottomHint,
            settingsTooltip: copy.settingsTooltip,
            retryTitle: copy.retryTitle,
            installCommandTitle: copy.installCommandTitle,
            stopTitle: copy.stopTitle,
            isGenerating: false,
            errorMessage: nil
        )
        emit()
        checkAvailability()
    }

    func panelDidClose() {
        isPanelOpen = false
        generationID += 1
        provider.cancelCurrentRequest()
        debouncer.cancel()
        state.isGenerating = false
        emit()
    }

    func checkAvailability() {
        state.providerStatus = .checking
        state.statusText = panelCopy.text(for: .checking)
        emit()

        Task {
            let status = await provider.checkAvailability()
            guard isPanelOpen || status != .checking else {
                return
            }
            state.providerStatus = status
            if state.chineseText.isEmpty {
                state.statusText = status == .available ? panelCopy.waiting : panelCopy.text(for: status)
            } else if status != .available {
                state.statusText = panelCopy.text(for: status)
            }
            emit()
        }
    }

    func updateChineseText(_ text: String, hasMarkedText: Bool) {
        state.chineseText = text
        state.errorMessage = nil
        emit()

        debouncer.cancel()
        guard isPanelOpen else {
            return
        }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            provider.cancelCurrentRequest()
            generationID += 1
            state.englishText = ""
            state.isGenerating = false
            state.statusText = panelCopy.waiting
            emit()
            return
        }

        if hasMarkedText {
            state.statusText = panelCopy.composing
            emit()
            return
        }

        guard settings.autoTranslateEnabled else {
            state.statusText = panelCopy.waiting
            emit()
            return
        }

        debouncer.schedule(after: settings.autoTranslateDelay) { [weak self] in
            await MainActor.run {
                self?.translateIfReady(force: false, hasMarkedText: false)
            }
        }
    }

    func updateEnglishText(_ text: String) {
        state.englishText = text
        emit()
    }

    func setSelectedOutput(_ selection: OutputSelection) {
        state.selectedOutput = selection
        emit()
    }

    func selectPreviousOutput() {
        state.selectedOutput = state.selectedOutput.previous
        emit()
    }

    func selectNextOutput() {
        state.selectedOutput = state.selectedOutput.next
        emit()
    }

    func setStyle(_ style: TranslationStyle) {
        settings.defaultStyle = style
        state.style = style
        state.settingsSummary = settings.translationSettingsSummary
        state.resultTitle = Self.resultTitle(for: settings)
        state.resultPlaceholder = Self.resultPlaceholder(for: settings)
        emit()
        translateIfReady(force: true, hasMarkedText: false)
    }

    func useSettingsDefaultOutput() {
        state.selectedOutput = settings.defaultOutputSelection
        emit()
    }

    func toggleMultiLanguageOutput() {
        guard settings.commandShiftMToggleMultiLanguageEnabled else {
            return
        }
        settings.multiLanguageOutput.toggle()
        state.settingsSummary = settings.translationSettingsSummary
        state.isMultiLanguageOutput = settings.multiLanguageOutput
        state.resultTitle = Self.resultTitle(for: settings)
        state.resultPlaceholder = Self.resultPlaceholder(for: settings)
        state.statusText = settings.multiLanguageOutput ? panelCopy.multiLanguageOn : panelCopy.multiLanguageOff
        emit()
        translateIfReady(force: true, hasMarkedText: false)
    }

    func translateIfReady(force: Bool, hasMarkedText: Bool) {
        guard isPanelOpen else {
            return
        }
        if hasMarkedText {
            state.statusText = panelCopy.composing
            emit()
            return
        }
        let source = state.chineseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else {
            state.statusText = panelCopy.waiting
            emit()
            return
        }
        guard force || source != lastTranslatedSource else {
            return
        }
        guard state.providerStatus == .available else {
            checkAvailability()
            return
        }

        startTranslation(source)
    }

    func stopTranslation() {
        generationID += 1
        provider.cancelCurrentRequest()
        state.isGenerating = false
        state.statusText = state.englishText.isEmpty ? panelCopy.waiting : panelCopy.complete
        emit()
    }

    func selectedTextForInsertion() -> String {
        state.selectedOutput.composedText(
            chinese: state.chineseText.trimmingCharacters(in: .whitespacesAndNewlines),
            english: state.englishText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func installCommandCopied() {
        state.statusText = panelCopy.installCommandCopied
        emit()
    }

    private func startTranslation(_ source: String) {
        generationID += 1
        let currentGenerationID = generationID
        provider.cancelCurrentRequest()
        state.englishText = ""
        state.errorMessage = nil
        state.isGenerating = true
        state.statusText = panelCopy.translating
        state.providerStatus = .generating
        emit()

        Task {
            do {
                let preferences = settings.translationPreferences
                let final = try await provider.translate(text: source, preferences: preferences) { [weak self] token in
                    Task { @MainActor in
                        guard let self, self.generationID == currentGenerationID else {
                            return
                        }
                        self.state.englishText += token
                        self.emit()
                    }
                }

                guard generationID == currentGenerationID else {
                    return
                }
                lastTranslatedSource = source
                state.englishText = final
                state.isGenerating = false
                state.providerStatus = .available
                state.statusText = panelCopy.complete
                emit()
            } catch {
                guard generationID == currentGenerationID else {
                    return
                }
                AppLogger.logTranslationFailure(inputLength: source.count, error: error)
                state.isGenerating = false
                state.providerStatus = .failed(error.localizedDescription)
                state.statusText = panelCopy.failed
                state.errorMessage = error.localizedDescription
                emit()
            }
        }
    }

    private func emit() {
        onStateChange?(state)
    }

    private var providerDisplayName: String {
        Self.providerDisplayName(for: provider)
    }

    private var panelCopy: FloatingPanelCopy {
        Self.panelCopy(for: settings)
    }

    private static func providerDisplayName(for provider: LocalModelProvider) -> String {
        if let routedProvider = provider as? SettingsBackedModelProvider {
            return routedProvider.displayName
        }
        return "\(provider.providerName) · \(provider.currentModel)"
    }

    private static func resultTitle(for settings: AppSettings) -> String {
        return settings.multiLanguageOutput ? multiLanguageResultTitle(for: settings.sourceLanguage) : settings.targetLanguage.resultTitle(forSource: settings.sourceLanguage)
    }

    private static func resultPlaceholder(for settings: AppSettings) -> String {
        settings.multiLanguageOutput ? resultTitle(for: settings) : settings.targetLanguage.resultPlaceholder(forSource: settings.sourceLanguage)
    }

    private static func panelCopy(for settings: AppSettings) -> FloatingPanelCopy {
        FloatingPanelCopy.make(for: settings.sourceLanguage)
    }

    private static func multiLanguageResultTitle(for sourceLanguage: TranslationLanguage) -> String {
        switch sourceLanguage == .auto ? TranslationLanguage.chinese : sourceLanguage {
        case .english:
            return "Multi-language Result"
        case .japanese:
            return "多言語結果"
        case .korean:
            return "다국어 결과"
        case .french:
            return "Résultat multilingue"
        case .german:
            return "Mehrsprachiges Ergebnis"
        case .spanish:
            return "Resultado multilingüe"
        case .chinese, .auto:
            return "多语言结果"
        }
    }

}
