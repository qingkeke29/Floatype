import AppKit
import Carbon.HIToolbox

final class FloatingPanel: NSPanel {
    var commandHandler: ((FloatingPanelCommand) -> Bool)?
    var hasMarkedTextProvider: (() -> Bool)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(frame: NSRect) {
        super.init(
            contentRect: frame,
            styleMask: [.titled, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )
        title = "Floatype（浮译）"
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        isFloatingPanel = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        level = .floating
        collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        hasShadow = true
        backgroundColor = .clear
        isOpaque = false
        minSize = FloatingPanelLayoutMetrics.defaultSize
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        standardWindowButton(.closeButton)?.isHidden = true
    }

    override func keyDown(with event: NSEvent) {
        let hasMarkedText = hasMarkedTextProvider?() ?? false
        if event.keyCode == UInt16(kVK_UpArrow), !hasMarkedText, commandHandler?(.selectPreviousOutput) == true {
            return
        }
        if event.keyCode == UInt16(kVK_DownArrow), !hasMarkedText, commandHandler?(.selectNextOutput) == true {
            return
        }
        if event.keyCode == UInt16(kVK_Return), !hasMarkedText, commandHandler?(.commitSelected) == true {
            return
        }
        super.keyDown(with: event)
    }
}
