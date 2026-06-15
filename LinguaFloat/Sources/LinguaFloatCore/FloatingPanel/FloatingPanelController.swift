import AppKit

public enum FloatingPanelActivationPlan {
    public static let focusRetryDelays: [TimeInterval] = [0, 0.08, 0.25]
}

@MainActor
public final class FloatingPanelController: NSObject, NSWindowDelegate {
    private let settings: AppSettings
    private let provider: LocalModelProvider
    private let focusCaptureService: FocusCaptureService
    private let textInsertionService: TextInsertionService
    private let settingsWindowController: SettingsWindowController
    private let viewModel: FloatingPanelViewModel
    private var panel: FloatingPanel?
    private var viewController: FloatingPanelViewController?
    private var focusSnapshot: FocusSnapshot?

    public init(
        settings: AppSettings,
        provider: LocalModelProvider,
        focusCaptureService: FocusCaptureService,
        textInsertionService: TextInsertionService,
        settingsWindowController: SettingsWindowController
    ) {
        self.settings = settings
        self.provider = provider
        self.focusCaptureService = focusCaptureService
        self.textInsertionService = textInsertionService
        self.settingsWindowController = settingsWindowController
        self.viewModel = FloatingPanelViewModel(provider: provider, settings: settings)
        super.init()
    }

    public func togglePanel() {
        if panel?.isVisible == true {
            cancel()
        } else {
            showPanel()
        }
    }

    public func showPanel() {
        focusSnapshot = focusCaptureService.capture()
        let panel = ensurePanel()
        viewModel.resetForOpen()
        viewController?.resetEditorText()

        positionPanel(panel)
        scheduleActivationRetries(for: panel)
    }

    private func scheduleActivationRetries(for panel: FloatingPanel) {
        for delay in FloatingPanelActivationPlan.focusRetryDelays {
            if delay == 0 {
                activateAndFocus(panel)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak panel] in
                    guard let self, let panel, self.panel === panel, panel.isVisible else {
                        return
                    }
                    self.activateAndFocus(panel)
                }
            }
        }
    }

    private func activateAndFocus(_ panel: FloatingPanel) {
        NSApp.unhide(nil)
        NSApp.activate()
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        panel.orderFrontRegardless()
        panel.makeKeyAndOrderFront(nil)
        panel.makeMain()
        viewController?.focusChineseEditor()
    }

    public func checkModelStatus() {
        viewModel.checkAvailability()
    }

    public var isPanelVisible: Bool {
        panel?.isVisible == true
    }

    public func saveFrame() {
        if let panel {
            settings.lastPanelFrame = panel.frame
        }
    }

    public func windowWillClose(_ notification: Notification) {
        saveFrame()
        viewModel.panelDidClose()
    }

    private func ensurePanel() -> FloatingPanel {
        if let panel {
            return panel
        }

        let frame = settings.lastPanelFrame.map {
            NSRect(origin: $0.origin, size: FloatingPanelLayoutMetrics.defaultSize)
        } ?? NSRect(origin: .zero, size: FloatingPanelLayoutMetrics.defaultSize)
        let panel = FloatingPanel(frame: frame)
        let controller = FloatingPanelViewController(
            viewModel: viewModel,
            settingsWindowController: settingsWindowController
        ) { [weak self] command in
            self?.handle(command) ?? false
        }
        panel.contentViewController = controller
        panel.commandHandler = { [weak self] command in
            self?.handle(command) ?? false
        }
        panel.hasMarkedTextProvider = { [weak controller] in
            controller?.hasMarkedText() ?? false
        }
        panel.delegate = self
        self.panel = panel
        self.viewController = controller
        return panel
    }

    private func positionPanel(_ panel: FloatingPanel) {
        if settings.lastPanelFrame != nil {
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
            ?? NSScreen.main
        guard let screen = targetScreen else {
            panel.center()
            return
        }

        let visible = screen.visibleFrame
        let size = panel.frame.size
        let origin = NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.midY - size.height / 2
        )
        panel.setFrameOrigin(origin)
    }

    private func handle(_ command: FloatingPanelCommand) -> Bool {
        switch command {
        case .useChinese:
            guard settings.command1UseChineseEnabled else {
                return false
            }
            viewModel.setSelectedOutput(.chinese)
            commitSelected()
            return true
        case .useEnglish:
            guard settings.command2UseEnglishEnabled else {
                return false
            }
            viewModel.setSelectedOutput(.english)
            commitSelected()
            return true
        case .useSettingsDefault:
            guard settings.command3UseSettingsDefaultEnabled else {
                return false
            }
            viewModel.useSettingsDefaultOutput()
            commitSelected()
            return true
        case .toggleMultiLanguageOutput:
            guard settings.commandShiftMToggleMultiLanguageEnabled else {
                return false
            }
            viewModel.toggleMultiLanguageOutput()
            return true
        case .selectPreviousOutput:
            viewModel.selectPreviousOutput()
            return true
        case .selectNextOutput:
            viewModel.selectNextOutput()
            return true
        case .commitSelected:
            commitSelected()
            return true
        case .cancel:
            cancel()
            return true
        case .translateNow:
            viewModel.translateIfReady(force: true, hasMarkedText: viewController?.hasMarkedText() ?? false)
            return true
        case .retry:
            viewModel.translateIfReady(force: true, hasMarkedText: viewController?.hasMarkedText() ?? false)
            return true
        case .stop:
            viewModel.stopTranslation()
            return true
        }
    }

    private func commitSelected() {
        let text = viewModel.selectedTextForInsertion()
        let snapshot = focusSnapshot
        panel?.orderOut(nil)
        viewModel.panelDidClose()

        Task { @MainActor in
            let result = await textInsertionService.insert(text: text, into: snapshot)
            switch result {
            case .inserted:
                break
            case .copiedRequiresManualPaste:
                showAccessibilityPermissionAlert()
            case .rejected(let message), .failed(let message):
                showInformationalAlert("无法写入", message)
            }
            focusSnapshot = nil
        }
    }

    private func cancel() {
        panel?.orderOut(nil)
        viewModel.panelDidClose()
        focusSnapshot = nil
    }

    private func showInformationalAlert(_ title: String, _ message: String) {
        NSApp.activate()
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    private func showAccessibilityPermissionAlert() {
        NSApp.activate()
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "内容已复制到剪贴板。要让 Floatype（浮译）自动写回原输入栏，请在系统设置里允许 Floatype（浮译）使用辅助功能，然后回到原输入栏再试一次。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "稍后")
        if alert.runModal() == .alertFirstButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
