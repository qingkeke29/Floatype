import AppKit
import Carbon.HIToolbox

class PlaceholderTextView: NSTextView {
    var placeholder: String = "" {
        didSet { needsDisplay = true }
    }
    var commandHandler: ((FloatingPanelCommand) -> Bool)?

    override var string: String {
        didSet { needsDisplay = true }
    }

    override func didChangeText() {
        super.didChangeText()
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard string.isEmpty, !placeholder.isEmpty else {
            return
        }

        let inset = textContainerInset
        let rect = NSRect(
            x: inset.width + 4,
            y: inset.height,
            width: bounds.width - inset.width * 2 - 8,
            height: 24
        )
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.placeholderTextColor
        ]
        placeholder.draw(in: rect, withAttributes: attributes)
    }

    override func keyDown(with event: NSEvent) {
        let normalizedFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let commandPressed = normalizedFlags.contains(.command)
        let shiftPressed = normalizedFlags.contains(.shift)
        let key = event.charactersIgnoringModifiers?.lowercased()

        if commandPressed {
            switch key {
            case "1":
                if commandHandler?(.useChinese) == true { return }
            case "2":
                if commandHandler?(.useEnglish) == true { return }
            case "3":
                if commandHandler?(.useSettingsDefault) == true { return }
            case "m" where shiftPressed:
                if commandHandler?(.toggleMultiLanguageOutput) == true { return }
            case "\r":
                if commandHandler?(.commitSelected) == true { return }
            case "r":
                if commandHandler?(.retry) == true { return }
            case ".":
                if commandHandler?(.stop) == true { return }
            default:
                break
            }
        }

        if event.keyCode == 53, commandHandler?(.cancel) == true {
            return
        }
        if event.keyCode == UInt16(kVK_UpArrow), !hasMarkedText(), commandHandler?(.selectPreviousOutput) == true {
            return
        }
        if event.keyCode == UInt16(kVK_DownArrow), !hasMarkedText(), commandHandler?(.selectNextOutput) == true {
            return
        }
        if event.keyCode == UInt16(kVK_Return), !hasMarkedText(), commandHandler?(.commitSelected) == true {
            return
        }
        if event.keyCode == 48, commandHandler?(.translateNow) == true {
            return
        }

        super.keyDown(with: event)
    }
}

final class ChineseTextView: PlaceholderTextView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        placeholder = "使用豆包输入中文..."
        isEditable = true
        isSelectable = true
        allowsUndo = true
        isRichText = false
        importsGraphics = false
        font = .systemFont(ofSize: 16)
        textContainerInset = NSSize(width: 12, height: 10)
        backgroundColor = .textBackgroundColor
        insertionPointColor = .controlAccentColor
    }
}
