import AppKit

@MainActor
final class FloatingPanelViewController: NSViewController, NSTextViewDelegate {
    private enum MockupStyle {
        static let panelCornerRadius: CGFloat = 26
        static let boxCornerRadius: CGFloat = 20
        static let boxHorizontalInset: CGFloat = 14
        static let boxVerticalInset: CGFloat = 13
        static let labelBottomSpacing: CGFloat = 6
        static let statusFrame = NSRect(x: 338, y: 14, width: 67, height: 26)
        static let footerFrame = NSRect(x: 0, y: 247, width: 420, height: 13)
        static let panelText = NSColor(
            calibratedRed: 23 / 255,
            green: 32 / 255,
            blue: 51 / 255,
            alpha: 1
        )
        static let secondaryText = NSColor(
            calibratedRed: 100 / 255,
            green: 116 / 255,
            blue: 139 / 255,
            alpha: 1
        )
        static let gearText = NSColor(
            calibratedRed: 71 / 255,
            green: 85 / 255,
            blue: 105 / 255,
            alpha: 1
        )
        static let selectedText = NSColor(
            calibratedRed: 37 / 255,
            green: 99 / 255,
            blue: 235 / 255,
            alpha: 1
        )
        static let statusText = NSColor(
            calibratedRed: 52 / 255,
            green: 199 / 255,
            blue: 89 / 255,
            alpha: 1
        )
        static let panelFill = NSColor.white.withAlphaComponent(0.76)
        static let panelBorder = NSColor.white.withAlphaComponent(0.84)
        static let gearFill = NSColor.white.withAlphaComponent(0.58)
        static let gearBorder = NSColor(
            calibratedRed: 226 / 255,
            green: 232 / 255,
            blue: 240 / 255,
            alpha: 0.88
        )
        static let statusFill = NSColor(
            calibratedRed: 99 / 255,
            green: 102 / 255,
            blue: 241 / 255,
            alpha: 0.11
        )
        static let boxFill = NSColor.white.withAlphaComponent(0.66)
        static let boxBorder = NSColor(
            calibratedRed: 226 / 255,
            green: 232 / 255,
            blue: 240 / 255,
            alpha: 0.92
        )
        static let selectedFill = NSColor(
            calibratedRed: 239 / 255,
            green: 246 / 255,
            blue: 255 / 255,
            alpha: 0.98
        )
        static let selectedBorder = NSColor(
            calibratedRed: 96 / 255,
            green: 165 / 255,
            blue: 250 / 255,
            alpha: 0.92
        )
        static let selectedShadow = NSColor(
            calibratedRed: 37 / 255,
            green: 99 / 255,
            blue: 235 / 255,
            alpha: 0.16
        )
        static let separator = NSColor(
            calibratedRed: 209 / 255,
            green: 213 / 255,
            blue: 219 / 255,
            alpha: 0.95
        )
    }

    private let viewModel: FloatingPanelViewModel
    private let settingsWindowController: SettingsWindowController
    private var commandHandler: ((FloatingPanelCommand) -> Bool)?

    private let titleLabel = NSTextField(labelWithString: "浮译")
    private let statusPill = NSView()
    private let statusDot = NSView()
    private let statusLabel = NSTextField(labelWithString: ProviderStatus.checking.displayText)
    private let modelLabel = NSTextField(labelWithString: ModelDefaults.ollamaModel)
    private let chineseTextView = ChineseTextView(frame: .zero)
    private let englishTextView = EnglishTextView(frame: .zero)
    private let settingsButton = NSButton(title: "", target: nil, action: nil)
    private let statusActionButton = NSButton(title: "重新检测", target: nil, action: nil)
    private let stopButton = NSButton(title: "停止", target: nil, action: nil)
    private let bottomHintLabel = NSTextField(labelWithString: "↑↓ 选择 · ↩ 填入 · Esc 取消 · Tab 重新翻译")
    private var chineseBox: NSBox?
    private var englishBox: NSBox?
    private var chineseSectionLabel: NSTextField?
    private var englishSectionLabel: NSTextField?

    init(
        viewModel: FloatingPanelViewModel,
        settingsWindowController: SettingsWindowController,
        commandHandler: @escaping (FloatingPanelCommand) -> Bool
    ) {
        self.viewModel = viewModel
        self.settingsWindowController = settingsWindowController
        self.commandHandler = commandHandler
        super.init(nibName: nil, bundle: nil)
        self.viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSVisualEffectView()
        (view as? NSVisualEffectView)?.material = .hudWindow
        (view as? NSVisualEffectView)?.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = MockupStyle.panelCornerRadius
        view.layer?.masksToBounds = true
        view.layer?.borderWidth = 1
        view.layer?.borderColor = MockupStyle.panelBorder.cgColor
        buildLayout()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(chineseTextView)
    }

    func focusChineseEditor() {
        view.window?.makeFirstResponder(chineseTextView)
    }

    func resetEditorText() {
        chineseTextView.string = ""
        englishTextView.string = ""
        render(viewModel.state)
    }

    func hasMarkedText() -> Bool {
        chineseTextView.hasMarkedText()
    }

    private func buildLayout() {
        let separator = NSView()
        separator.wantsLayer = true
        separator.layer?.backgroundColor = MockupStyle.separator.cgColor
        separator.translatesAutoresizingMaskIntoConstraints = false

        let chineseSection = makeEditorSection(title: "中文原文", textView: chineseTextView)
        let englishSection = makeEditorSection(title: "英文结果", textView: englishTextView)
        let bottomBar = makeBottomBar()

        configureHeaderControls()
        for subview in [titleLabel, modelLabel, settingsButton, statusPill, separator, chineseSection, englishSection, bottomBar] {
            view.addSubview(subview)
        }

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.defaultSize.width),
            view.heightAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.defaultSize.height),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            modelLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 7),
            modelLabel.trailingAnchor.constraint(lessThanOrEqualTo: settingsButton.leadingAnchor, constant: -8),
            modelLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),

            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FloatingPanelLayoutMetrics.settingsButtonFrame.minX),
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: FloatingPanelLayoutMetrics.settingsButtonFrame.minY),
            settingsButton.widthAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.settingsButtonFrame.width),
            settingsButton.heightAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.settingsButtonFrame.height),

            statusPill.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MockupStyle.statusFrame.minX),
            statusPill.topAnchor.constraint(equalTo: view.topAnchor, constant: MockupStyle.statusFrame.minY),
            statusPill.widthAnchor.constraint(equalToConstant: MockupStyle.statusFrame.width),
            statusPill.heightAnchor.constraint(equalToConstant: MockupStyle.statusFrame.height),

            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.topAnchor.constraint(equalTo: view.topAnchor, constant: FloatingPanelLayoutMetrics.headerSeparatorY),
            separator.heightAnchor.constraint(equalToConstant: 1),

            chineseSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FloatingPanelLayoutMetrics.chineseBoxFrame.minX),
            chineseSection.topAnchor.constraint(equalTo: view.topAnchor, constant: FloatingPanelLayoutMetrics.chineseBoxFrame.minY),
            chineseSection.widthAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.chineseBoxFrame.width),
            chineseSection.heightAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.chineseBoxFrame.height),

            englishSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FloatingPanelLayoutMetrics.englishBoxFrame.minX),
            englishSection.topAnchor.constraint(equalTo: view.topAnchor, constant: FloatingPanelLayoutMetrics.englishBoxFrame.minY),
            englishSection.widthAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.englishBoxFrame.width),
            englishSection.heightAnchor.constraint(equalToConstant: FloatingPanelLayoutMetrics.englishBoxFrame.height),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MockupStyle.footerFrame.minX),
            bottomBar.topAnchor.constraint(equalTo: view.topAnchor, constant: MockupStyle.footerFrame.minY),
            bottomBar.widthAnchor.constraint(equalToConstant: MockupStyle.footerFrame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: MockupStyle.footerFrame.height)
        ])

        chineseTextView.delegate = self
        englishTextView.delegate = self
        chineseTextView.commandHandler = { [weak self] command in
            self?.commandHandler?(command) ?? false
        }
        englishTextView.commandHandler = chineseTextView.commandHandler

        settingsButton.target = self
        settingsButton.action = #selector(openSettings)
        statusActionButton.target = self
        statusActionButton.action = #selector(statusAction)
        stopButton.target = self
        stopButton.action = #selector(stopGenerating)
    }

    private func configureHeaderControls() {
        titleLabel.font = .boldSystemFont(ofSize: 13)
        titleLabel.textColor = MockupStyle.panelText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        modelLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        modelLabel.textColor = MockupStyle.secondaryText
        modelLabel.lineBreakMode = .byTruncatingMiddle
        modelLabel.translatesAutoresizingMaskIntoConstraints = false

        configureSettingsButton()
        configureStatusPill()
        configureAuxiliaryButton(statusActionButton)
        configureAuxiliaryButton(stopButton)
        statusActionButton.isHidden = true
        stopButton.isHidden = true
    }

    private func configureSettingsButton() {
        if let image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "设置") {
            settingsButton.image = image
            settingsButton.imageScaling = .scaleProportionallyDown
        } else {
            settingsButton.title = "⚙︎"
            settingsButton.font = .systemFont(ofSize: 13, weight: .medium)
        }
        settingsButton.isBordered = false
        settingsButton.bezelStyle = .regularSquare
        settingsButton.toolTip = "设置"
        settingsButton.wantsLayer = true
        settingsButton.layer?.cornerRadius = FloatingPanelLayoutMetrics.settingsButtonFrame.width / 2
        settingsButton.layer?.backgroundColor = MockupStyle.gearFill.cgColor
        settingsButton.layer?.borderWidth = 1
        settingsButton.layer?.borderColor = MockupStyle.gearBorder.cgColor
        settingsButton.contentTintColor = MockupStyle.gearText
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureStatusPill() {
        statusPill.wantsLayer = true
        statusPill.layer?.cornerRadius = MockupStyle.statusFrame.height / 2
        statusPill.layer?.backgroundColor = MockupStyle.statusFill.cgColor
        statusPill.translatesAutoresizingMaskIntoConstraints = false

        statusDot.wantsLayer = true
        statusDot.layer?.cornerRadius = 3
        statusDot.layer?.backgroundColor = MockupStyle.statusText.cgColor
        statusDot.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        statusLabel.alignment = .left
        statusLabel.textColor = MockupStyle.statusText
        statusLabel.lineBreakMode = .byTruncatingTail
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        statusPill.addSubview(statusDot)
        statusPill.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusDot.leadingAnchor.constraint(equalTo: statusPill.leadingAnchor, constant: 8),
            statusDot.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 6),
            statusDot.heightAnchor.constraint(equalToConstant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 5),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.trailingAnchor, constant: -6),
            statusLabel.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor, constant: -0.5)
        ])
    }

    private func configureAuxiliaryButton(_ button: NSButton) {
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 11, weight: .medium)
        button.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func makeEditorSection(title: String, textView: NSTextView) -> NSView {
        let box = NSBox()
        box.titlePosition = .noTitle
        box.boxType = .custom
        box.borderWidth = 1
        box.cornerRadius = 20
        box.contentViewMargins = NSSize(width: 0, height: 0)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.setContentHuggingPriority(.defaultLow, for: .horizontal)
        box.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        box.wantsLayer = true
        box.layer?.masksToBounds = false

        let content = NSView()
        content.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 10, weight: .heavy)
        label.textColor = MockupStyle.secondaryText
        label.alignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scrollView.documentView = textView

        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.frame = NSRect(x: 0, y: 0, width: 366, height: 43)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = MockupStyle.panelText

        content.addSubview(label)
        content.addSubview(scrollView)
        box.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: MockupStyle.boxHorizontalInset),
            content.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -MockupStyle.boxHorizontalInset),
            content.topAnchor.constraint(equalTo: box.topAnchor, constant: MockupStyle.boxVerticalInset),
            content.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -MockupStyle.boxVerticalInset),
            label.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            label.topAnchor.constraint(equalTo: content.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: MockupStyle.labelBottomSpacing),
            scrollView.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])

        if textView === chineseTextView {
            chineseBox = box
            chineseSectionLabel = label
        } else if textView === englishTextView {
            englishBox = box
            englishSectionLabel = label
        }
        return box
    }

    private func makeBottomBar() -> NSView {
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false

        bottomHintLabel.font = .systemFont(ofSize: 10)
        bottomHintLabel.textColor = MockupStyle.secondaryText
        bottomHintLabel.lineBreakMode = .byTruncatingTail
        bottomHintLabel.alignment = .center
        bottomHintLabel.translatesAutoresizingMaskIntoConstraints = false

        bar.addSubview(bottomHintLabel)
        NSLayoutConstraint.activate([
            bottomHintLabel.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            bottomHintLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            bottomHintLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bar.leadingAnchor, constant: 14),
            bottomHintLabel.trailingAnchor.constraint(lessThanOrEqualTo: bar.trailingAnchor, constant: -14)
        ])
        return bar
    }

    private func render(_ state: FloatingPanelState) {
        titleLabel.stringValue = state.panelTitle
        statusLabel.stringValue = state.statusText
        applyStatusBadgeStyle(for: state.providerStatus)
        modelLabel.stringValue = "\(state.modelName) · \(state.settingsSummary)"
        let canShowStatusAction = state.providerStatus == .serviceUnavailable || state.providerStatus.isModelMissing || {
            if case .failed = state.providerStatus { return true }
            return false
        }()
        statusActionButton.isHidden = !canShowStatusAction
        stopButton.isHidden = !state.isGenerating
        statusActionButton.title = state.providerStatus.isModelMissing ? state.installCommandTitle : state.retryTitle
        stopButton.title = state.stopTitle
        settingsButton.toolTip = state.settingsTooltip
        bottomHintLabel.stringValue = state.bottomHint

        if englishTextView.string != state.englishText {
            englishTextView.string = state.englishText
        }
        if chineseTextView.string != state.chineseText {
            chineseTextView.string = state.chineseText
        }
        chineseSectionLabel?.stringValue = state.sourceTitle
        englishSectionLabel?.stringValue = state.resultTitle
        chineseTextView.placeholder = state.sourcePlaceholder
        englishTextView.placeholder = state.resultPlaceholder

        let panelSelection = state.selectedOutput.panelSelection
        applySelectionStyle(to: chineseBox, label: chineseSectionLabel, selected: panelSelection == .chinese)
        applySelectionStyle(to: englishBox, label: englishSectionLabel, selected: panelSelection == .english)
    }

    private func applyStatusBadgeStyle(for providerStatus: ProviderStatus) {
        let color: NSColor
        switch providerStatus {
        case .failed, .serviceUnavailable:
            color = .systemRed
        case .modelMissing:
            color = .systemOrange
        case .generating, .checking, .loading:
            color = .controlAccentColor
        case .available:
            color = .systemGreen
        }
        statusLabel.textColor = color
        statusDot.layer?.backgroundColor = color.cgColor
        statusPill.layer?.backgroundColor = MockupStyle.statusFill.cgColor
    }

    private func applySelectionStyle(to box: NSBox?, label: NSTextField?, selected: Bool) {
        guard let box else {
            return
        }
        box.boxType = .custom
        box.borderWidth = 1
        box.cornerRadius = 20
        box.wantsLayer = true
        box.layer?.cornerRadius = 20
        box.layer?.masksToBounds = false
        if selected {
            box.fillColor = NSColor.systemBlue.withAlphaComponent(0.10)
            box.borderColor = NSColor.systemBlue.withAlphaComponent(0.55)
            label?.textColor = MockupStyle.selectedText
            box.layer?.shadowColor = NSColor.systemBlue.withAlphaComponent(0.20).cgColor
            box.layer?.shadowOpacity = 1
            box.layer?.shadowRadius = 14
            box.layer?.shadowOffset = CGSize(width: 0, height: -4)
        } else {
            box.fillColor = NSColor.windowBackgroundColor.withAlphaComponent(0.48)
            box.borderColor = NSColor.separatorColor.withAlphaComponent(0.70)
            label?.textColor = MockupStyle.secondaryText
            box.layer?.shadowOpacity = 0
            box.layer?.shadowRadius = 0
            box.layer?.shadowOffset = .zero
        }
    }

    func textDidChange(_ notification: Notification) {
        if notification.object as AnyObject? === chineseTextView {
            viewModel.updateChineseText(chineseTextView.string, hasMarkedText: chineseTextView.hasMarkedText())
        } else if notification.object as AnyObject? === englishTextView {
            viewModel.updateEnglishText(englishTextView.string)
        }
    }

    @objc private func statusAction() {
        if viewModel.state.providerStatus.isModelMissing {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString("ollama pull \(viewModel.state.modelName)", forType: .string)
            viewModel.installCommandCopied()
        } else {
            viewModel.checkAvailability()
        }
    }

    @objc private func stopGenerating() {
        _ = commandHandler?(.stop)
    }

    @objc private func openSettings() {
        settingsWindowController.showWindow(nil)
    }
}
