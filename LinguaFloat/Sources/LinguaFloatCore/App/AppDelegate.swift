import AppKit
import Foundation

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let environment: AppEnvironment

    public override init() {
        self.environment = AppEnvironment()
        super.init()
    }

    public init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(AppPresentation.activationPolicy)
        installMainMenu()
        environment.statusItemController.install()
        environment.floatingPanelController.checkModelStatus()
        environment.settingsWindowController.onHotKeyChanged = { [weak self] shortcut in
            self?.registerGlobalHotKey(shortcut)
        }

        registerGlobalHotKey(environment.settings.globalHotKeyShortcut)

        if environment.settings.openPanelOnLaunch {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000)
                environment.floatingPanelController.showPanel()
            }
        }
    }

    private func registerGlobalHotKey(_ shortcut: GlobalHotKeyShortcut) {
        do {
            try environment.hotKeyManager.register(shortcut: shortcut) { [weak environment] in
                Task { @MainActor in
                    environment?.floatingPanelController.togglePanel()
                }
            }
            environment.statusItemController.setHotKeySummary(environment.hotKeyManager.registeredShortcutSummary)
        } catch {
            environment.statusItemController.setHotKeyError(error.localizedDescription)
            AppLogger.app.error("Global hotkey registration failed: \(String(describing: type(of: error)), privacy: .public)")
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        environment.hotKeyManager.unregister()
        environment.floatingPanelController.saveFrame()
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "Floatype（浮译）")
        appMenu.addItem(NSMenuItem(title: "关于 Floatype（浮译）", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(.separator())
        appMenu.addItem(NSMenuItem(title: "退出 Floatype（浮译）", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "编辑")
        editMenu.addItem(NSMenuItem(title: "撤销", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.addItem(NSMenuItem(title: "重做", action: Selector(("redo:")), keyEquivalent: "Z"))
        editMenu.addItem(.separator())
        editMenu.addItem(NSMenuItem(title: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "拷贝", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }
}
