import AppKit

final class EnglishTextView: PlaceholderTextView {
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
        placeholder = "英文结果将在这里生成"
        isEditable = true
        isSelectable = true
        allowsUndo = true
        isRichText = false
        importsGraphics = false
        font = .systemFont(ofSize: 16)
        textContainerInset = NSSize(width: 12, height: 10)
        backgroundColor = .textBackgroundColor
    }
}
