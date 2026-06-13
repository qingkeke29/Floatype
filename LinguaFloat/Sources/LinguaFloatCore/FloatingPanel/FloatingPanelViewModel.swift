import Foundation

struct FloatingPanelState: Equatable {
    var chineseText: String = ""
    var englishText: String = ""
    var selectedOutput: OutputSelection = .english
    var style: TranslationStyle = .natural
    var providerStatus: ProviderStatus = .checking
    var statusText: String = "等待输入"
    var modelName: String = ModelDefaults.ollamaModel
    var isGenerating: Bool = false
    var errorMessage: String?
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
        self.state = FloatingPanelState(
            selectedOutput: settings.defaultOutputSelection,
            style: settings.defaultStyle,
            modelName: Self.providerDisplayName(for: provider)
        )
    }

    func resetForOpen() {
        generationID += 1
        provider.cancelCurrentRequest()
        debouncer.cancel()
        isPanelOpen = true
        lastTranslatedSource = ""
        state = FloatingPanelState(
            selectedOutput: settings.defaultOutputSelection,
            style: settings.defaultStyle,
            providerStatus: state.providerStatus,
            statusText: "等待输入",
            modelName: providerDisplayName,
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
        state.statusText = ProviderStatus.checking.displayText
        emit()

        Task {
            let status = await provider.checkAvailability()
            guard isPanelOpen || status != .checking else {
                return
            }
            state.providerStatus = status
            if state.chineseText.isEmpty {
                state.statusText = status == .available ? "等待输入" : status.displayText
            } else if status != .available {
                state.statusText = status.displayText
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
            state.statusText = "等待输入"
            emit()
            return
        }

        if hasMarkedText {
            state.statusText = "正在组词"
            emit()
            return
        }

        guard settings.autoTranslateEnabled else {
            state.statusText = "等待输入"
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
        emit()
        translateIfReady(force: true, hasMarkedText: false)
    }

    func translateIfReady(force: Bool, hasMarkedText: Bool) {
        guard isPanelOpen else {
            return
        }
        if hasMarkedText {
            state.statusText = "正在组词"
            emit()
            return
        }
        let source = state.chineseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else {
            state.statusText = "等待输入"
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
        state.statusText = state.englishText.isEmpty ? "等待输入" : "翻译完成"
        emit()
    }

    func selectedTextForInsertion() -> String {
        state.selectedOutput.composedText(
            chinese: state.chineseText.trimmingCharacters(in: .whitespacesAndNewlines),
            english: state.englishText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func installCommandCopied() {
        state.statusText = "已复制安装命令"
        emit()
    }

    private func startTranslation(_ source: String) {
        generationID += 1
        let currentGenerationID = generationID
        provider.cancelCurrentRequest()
        state.englishText = ""
        state.errorMessage = nil
        state.isGenerating = true
        state.statusText = "正在翻译"
        state.providerStatus = .generating
        emit()

        Task {
            do {
                let final = try await provider.translate(text: source, style: state.style) { [weak self] token in
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
                state.statusText = "翻译完成"
                emit()
            } catch {
                guard generationID == currentGenerationID else {
                    return
                }
                AppLogger.logTranslationFailure(inputLength: source.count, error: error)
                state.isGenerating = false
                state.providerStatus = .failed(error.localizedDescription)
                state.statusText = "翻译失败"
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

    private static func providerDisplayName(for provider: LocalModelProvider) -> String {
        if let routedProvider = provider as? SettingsBackedModelProvider {
            return routedProvider.displayName
        }
        return "\(provider.providerName) · \(provider.currentModel)"
    }

}
