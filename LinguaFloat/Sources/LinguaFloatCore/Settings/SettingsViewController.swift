import AppKit

@MainActor
final class SettingsViewController: NSViewController {
    private let settings: AppSettings
    private let permissionService: AccessibilityPermissionService
    private let modelField = NSTextField()
    private let baseURLField = NSTextField()
    private let stylePopup = NSPopUpButton()
    private let delayField = NSTextField()
    private let permissionLabel = NSTextField(labelWithString: "")
    private let hotKeyValueLabel = NSTextField(labelWithString: "")
    private let hotKeyMessageLabel = NSTextField(labelWithString: "")
    private let recordHotKeyButton = NSButton(title: "录制快捷键", target: nil, action: nil)
    private let resetHotKeyButton = NSButton(title: "恢复默认", target: nil, action: nil)
    private var hotKeyRecorder = HotKeyRecorder()
    private var hotKeyRecordingStep = 0
    private var hotKeyEventMonitor: Any?
    var onHotKeyChanged: ((GlobalHotKeyShortcut) -> Void)?

    init(settings: AppSettings, permissionService: AccessibilityPermissionService) {
        self.settings = settings
        self.permissionService = permissionService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        buildLayout()
        loadValues()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        updatePermissionLabel()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        finishHotKeyRecording()
    }

    private func buildLayout() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 24, bottom: 22, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        let title = NSTextField(labelWithString: "Floatype（浮译）设置")
        title.font = .boldSystemFont(ofSize: 20)
        stack.addArrangedSubview(title)

        let privacy = NSTextField(wrappingLabelWithString: "本地模式下，输入内容只会发送到本机的 Ollama 服务，不会发送到 Floatype（浮译）的服务器。本应用不提供云端服务器。")
        privacy.textColor = .secondaryLabelColor
        stack.addArrangedSubview(privacy)

        stack.addArrangedSubview(makeRow("默认模型", modelField))
        stack.addArrangedSubview(makeRow("Ollama 地址", baseURLField))

        stylePopup.addItems(withTitles: TranslationStyle.allCases.map(\.displayName))
        stack.addArrangedSubview(makeRow("默认翻译风格", stylePopup))

        stack.addArrangedSubview(makeRow("自动翻译延迟", delayField))

        stack.addArrangedSubview(makeHotKeySection())

        permissionLabel.textColor = .secondaryLabelColor
        stack.addArrangedSubview(permissionLabel)

        let permissionButtons = NSStackView()
        permissionButtons.orientation = .horizontal
        permissionButtons.spacing = 8
        let openSettings = NSButton(title: "打开系统设置", target: self, action: #selector(openAccessibilitySettings))
        let recheck = NSButton(title: "重新检测权限", target: self, action: #selector(recheckPermission))
        permissionButtons.addArrangedSubview(openSettings)
        permissionButtons.addArrangedSubview(recheck)
        stack.addArrangedSubview(permissionButtons)

        let saveButton = NSButton(title: "保存", target: self, action: #selector(save))
        saveButton.bezelStyle = .rounded
        stack.addArrangedSubview(saveButton)
    }

    private func makeHotKeySection() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 6

        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 8

        let label = NSTextField(labelWithString: "全局快捷键")
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 110).isActive = true

        hotKeyValueLabel.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        hotKeyValueLabel.textColor = .labelColor
        hotKeyValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true

        recordHotKeyButton.target = self
        recordHotKeyButton.action = #selector(startHotKeyRecording)
        resetHotKeyButton.target = self
        resetHotKeyButton.action = #selector(resetHotKey)

        for item in [label, hotKeyValueLabel, recordHotKeyButton, resetHotKeyButton] {
            row.addArrangedSubview(item)
        }
        stack.addArrangedSubview(row)

        hotKeyMessageLabel.font = .systemFont(ofSize: 12)
        hotKeyMessageLabel.textColor = .secondaryLabelColor
        hotKeyMessageLabel.lineBreakMode = .byWordWrapping
        let messageIndent = NSStackView()
        messageIndent.orientation = .horizontal
        let spacer = NSView()
        spacer.widthAnchor.constraint(equalToConstant: 110).isActive = true
        messageIndent.addArrangedSubview(spacer)
        messageIndent.addArrangedSubview(hotKeyMessageLabel)
        stack.addArrangedSubview(messageIndent)

        return stack
    }

    private func makeRow(_ title: String, _ control: NSView) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 10
        let label = NSTextField(labelWithString: title)
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 110).isActive = true
        control.widthAnchor.constraint(greaterThanOrEqualToConstant: 260).isActive = true
        row.addArrangedSubview(label)
        row.addArrangedSubview(control)
        return row
    }

    private func loadValues() {
        modelField.stringValue = settings.defaultModel
        baseURLField.stringValue = settings.ollamaBaseURL.absoluteString
        delayField.stringValue = String(format: "%.1f", settings.autoTranslateDelay)
        let index = TranslationStyle.allCases.firstIndex(of: settings.defaultStyle) ?? 1
        stylePopup.selectItem(at: index)
        hotKeyValueLabel.stringValue = settings.globalHotKeyShortcut.displayName
        hotKeyMessageLabel.stringValue = "点击录制后依次按两个键；使用时同时按下。"
    }

    private func updatePermissionLabel() {
        permissionLabel.stringValue = permissionService.isTrusted(prompt: false)
            ? "辅助功能权限：已授权"
            : "辅助功能权限：未授权。未授权时可翻译并复制结果，但需要手动粘贴。"
    }

    @objc private func openAccessibilitySettings() {
        permissionService.openSystemSettings()
    }

    @objc private func recheckPermission() {
        updatePermissionLabel()
    }

    @objc private func startHotKeyRecording() {
        hotKeyRecorder.reset()
        hotKeyRecordingStep = 1
        hotKeyMessageLabel.textColor = .secondaryLabelColor
        hotKeyMessageLabel.stringValue = "请按第一个键"
        recordHotKeyButton.title = "录制中..."
        recordHotKeyButton.isEnabled = false
        installHotKeyEventMonitor()
    }

    @objc private func resetHotKey() {
        applyHotKey(GlobalHotKeyShortcut.defaultShortcut, message: "已恢复默认快捷键。")
    }

    @objc private func save() {
        settings.defaultModel = modelField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: baseURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
            settings.ollamaBaseURL = url
        }
        let styleIndex = stylePopup.indexOfSelectedItem
        if TranslationStyle.allCases.indices.contains(styleIndex) {
            settings.defaultStyle = TranslationStyle.allCases[styleIndex]
        }
        settings.autoTranslateDelay = Double(delayField.stringValue) ?? 0.7
        onHotKeyChanged?(settings.globalHotKeyShortcut)
        view.window?.close()
    }

    private func installHotKeyEventMonitor() {
        removeHotKeyEventMonitor()
        hotKeyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self else {
                return event
            }
            return self.handleHotKeyRecordingEvent(event)
        }
    }

    private func removeHotKeyEventMonitor() {
        if let hotKeyEventMonitor {
            NSEvent.removeMonitor(hotKeyEventMonitor)
            self.hotKeyEventMonitor = nil
        }
    }

    private func handleHotKeyRecordingEvent(_ event: NSEvent) -> NSEvent? {
        guard hotKeyRecordingStep > 0 else {
            return event
        }
        guard let component = hotKeyComponent(from: event) else {
            return event.type == .flagsChanged ? event : nil
        }

        do {
            if let shortcut = try hotKeyRecorder.record(component) {
                applyHotKey(shortcut, message: "已设置为 \(shortcut.displayName)。")
            } else {
                hotKeyRecordingStep = 2
                hotKeyMessageLabel.textColor = .secondaryLabelColor
                hotKeyMessageLabel.stringValue = "已选择 \(component.displayName)，请按第二个键"
            }
        } catch {
            hotKeyMessageLabel.textColor = .systemRed
            hotKeyMessageLabel.stringValue = error.localizedDescription
            finishHotKeyRecording()
        }
        return nil
    }

    private func hotKeyComponent(from event: NSEvent) -> HotKeyComponent? {
        switch event.type {
        case .keyDown:
            guard let key = HotKeyKey(keyCode: event.keyCode) else {
                return nil
            }
            return .key(key)
        case .flagsChanged:
            guard let modifier = HotKeyModifier(keyCode: event.keyCode),
                  isModifierCurrentlyPressed(modifier, in: event.modifierFlags) else {
                return nil
            }
            return .modifier(modifier)
        default:
            return nil
        }
    }

    private func isModifierCurrentlyPressed(_ modifier: HotKeyModifier, in flags: NSEvent.ModifierFlags) -> Bool {
        let normalized = flags.intersection(.deviceIndependentFlagsMask)
        switch modifier {
        case .command:
            return normalized.contains(.command)
        case .control:
            return normalized.contains(.control)
        case .option:
            return normalized.contains(.option)
        case .shift:
            return normalized.contains(.shift)
        }
    }

    private func applyHotKey(_ shortcut: GlobalHotKeyShortcut, message: String) {
        settings.globalHotKeyShortcut = shortcut
        hotKeyValueLabel.stringValue = shortcut.displayName
        hotKeyMessageLabel.textColor = .secondaryLabelColor
        hotKeyMessageLabel.stringValue = message
        onHotKeyChanged?(shortcut)
        finishHotKeyRecording()
    }

    private func finishHotKeyRecording() {
        hotKeyRecordingStep = 0
        recordHotKeyButton.title = "录制快捷键"
        recordHotKeyButton.isEnabled = true
        removeHotKeyEventMonitor()
    }
}
