import AppKit

@MainActor
public final class StatusItemController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let panelController: FloatingPanelController
    private let settingsWindowController: SettingsWindowController
    private let provider: LocalModelProvider
    private var hotKeyError: String?
    private var hotKeySummary = GlobalHotKeyShortcut.defaultDisplaySummary
    private let modelStatusItem = NSMenuItem(title: "模型状态：检查中", action: nil, keyEquivalent: "")

    public init(
        panelController: FloatingPanelController,
        settingsWindowController: SettingsWindowController,
        provider: LocalModelProvider
    ) {
        self.panelController = panelController
        self.settingsWindowController = settingsWindowController
        self.provider = provider
    }

    public func install() {
        statusItem.button?.title = AppPresentation.menuBarTitle
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        rebuildMenu()
    }

    public func setHotKeyError(_ message: String) {
        hotKeyError = message
        rebuildMenu()
    }

    public func setHotKeySummary(_ summary: String) {
        hotKeySummary = summary
        hotKeyError = nil
        rebuildMenu()
    }

    private func rebuildMenu() {
        menu.removeAllItems()
        menu.addItem(NSMenuItem(title: "打开 Floatype（浮译）", action: #selector(openPanel), keyEquivalent: ""))
        let hotKeyItem = NSMenuItem(title: "快捷键：\(hotKeySummary)", action: nil, keyEquivalent: "")
        hotKeyItem.isEnabled = false
        menu.addItem(hotKeyItem)
        modelStatusItem.title = "模型状态：\(provider.currentModel)"
        menu.addItem(modelStatusItem)
        menu.addItem(NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "检查 Ollama", action: #selector(checkOllama), keyEquivalent: ""))
        if let hotKeyError {
            let item = NSMenuItem(title: "快捷键：\(hotKeyError)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "关于 Floatype（浮译）", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items where item.action != nil {
            item.target = self
        }
    }

    @objc private func statusItemClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            guard let button = statusItem.button else {
                return
            }
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.maxY + 4), in: button)
        } else {
            panelController.showPanel()
        }
    }

    @objc private func openPanel() {
        panelController.showPanel()
    }

    @objc private func openSettings() {
        settingsWindowController.showWindow(nil)
    }

    @objc private func checkOllama() {
        panelController.checkModelStatus()
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Floatype（浮译）",
            .applicationVersion: "0.1.0",
            .credits: NSAttributedString(string: "本地优先的浮译输入工具。")
        ])
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
