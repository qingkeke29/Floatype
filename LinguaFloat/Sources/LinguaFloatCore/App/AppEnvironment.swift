import Foundation

@MainActor
public final class AppEnvironment {
    public let settings: AppSettings
    public let modelProvider: LocalModelProvider
    public let accessibilityPermissionService: AccessibilityPermissionService
    public let focusCaptureService: FocusCaptureService
    public let textInsertionService: TextInsertionService
    public let keyboardEventService: KeyboardEventService
    public let settingsWindowController: SettingsWindowController
    public let floatingPanelController: FloatingPanelController
    public let statusItemController: StatusItemController
    public let hotKeyManager: GlobalHotKeyManager

    public init(settings: AppSettings = .shared) {
        self.settings = settings
        self.modelProvider = OllamaProvider(baseURL: settings.ollamaBaseURL, currentModel: settings.defaultModel)
        self.accessibilityPermissionService = AccessibilityPermissionService()
        self.focusCaptureService = FocusCaptureService()
        self.keyboardEventService = KeyboardEventService()
        self.textInsertionService = TextInsertionService(
            keyboardEventService: keyboardEventService,
            accessibilityPermissionService: accessibilityPermissionService
        )
        self.settingsWindowController = SettingsWindowController(settings: settings, permissionService: accessibilityPermissionService)
        self.floatingPanelController = FloatingPanelController(
            settings: settings,
            provider: modelProvider,
            focusCaptureService: focusCaptureService,
            textInsertionService: textInsertionService,
            settingsWindowController: settingsWindowController
        )
        self.statusItemController = StatusItemController(
            panelController: floatingPanelController,
            settingsWindowController: settingsWindowController,
            provider: modelProvider
        )
        self.hotKeyManager = GlobalHotKeyManager()
    }
}
