import AppKit

@MainActor
public final class SettingsWindowController: NSWindowController {
    private let settings: AppSettings
    private let permissionService: AccessibilityPermissionService
    private let settingsViewController: SettingsViewController

    public var onHotKeyChanged: ((GlobalHotKeyShortcut) -> Void)? {
        get { settingsViewController.onHotKeyChanged }
        set { settingsViewController.onHotKeyChanged = newValue }
    }

    public init(settings: AppSettings, permissionService: AccessibilityPermissionService) {
        self.settings = settings
        self.permissionService = permissionService
        self.settingsViewController = SettingsViewController(settings: settings, permissionService: permissionService)
        let window = NSWindow(contentViewController: settingsViewController)
        window.title = "Floatype（浮译）设置"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 520, height: 460))
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func showWindow(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
    }
}
