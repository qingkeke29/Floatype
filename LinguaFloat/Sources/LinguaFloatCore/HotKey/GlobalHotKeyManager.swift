import Carbon.HIToolbox
import Foundation

public struct GlobalHotKeyShortcut: Equatable {
    public let displayName: String
    public let keyCode: UInt32
    public let modifiers: UInt32
    public let id: UInt32
    public let storageValue: String

    public init(
        displayName: String,
        keyCode: UInt32,
        modifiers: UInt32,
        id: UInt32 = 1,
        storageValue: String
    ) {
        self.displayName = displayName
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.id = id
        self.storageValue = storageValue
    }

    public static let defaultShortcut = GlobalHotKeyShortcut(
        displayName: "Command + Z",
        keyCode: UInt32(kVK_ANSI_Z),
        modifiers: UInt32(cmdKey),
        id: 1,
        storageValue: "command+z"
    )

    public static var defaultShortcuts: [GlobalHotKeyShortcut] {
        [defaultShortcut]
    }

    public static var defaultDisplaySummary: String {
        defaultShortcuts.map(\.displayName).joined(separator: " / ")
    }

    public static func fromStorageValue(_ value: String) -> GlobalHotKeyShortcut? {
        let parts = value
            .split(separator: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        guard parts.count == 2 else {
            return nil
        }

        let components = parts.compactMap(HotKeyComponent.init(storageName:))
        guard components.count == 2 else {
            return nil
        }
        return HotKeyRecorder.shortcut(from: components[0], and: components[1])
    }
}

public enum HotKeyModifier: String, CaseIterable, Equatable {
    case command
    case control
    case option
    case shift

    public var displayName: String {
        switch self {
        case .command:
            return "Command"
        case .control:
            return "Control"
        case .option:
            return "Option"
        case .shift:
            return "Shift"
        }
    }

    public var storageName: String {
        rawValue
    }

    public var carbonModifier: UInt32 {
        switch self {
        case .command:
            return UInt32(cmdKey)
        case .control:
            return UInt32(controlKey)
        case .option:
            return UInt32(optionKey)
        case .shift:
            return UInt32(shiftKey)
        }
    }

    public init?(storageName: String) {
        switch storageName {
        case "cmd", "command":
            self = .command
        case "ctrl", "control":
            self = .control
        case "alt", "option":
            self = .option
        case "shift":
            self = .shift
        default:
            return nil
        }
    }

    public init?(keyCode: UInt16) {
        switch Int(keyCode) {
        case kVK_Command, kVK_RightCommand:
            self = .command
        case kVK_Control, kVK_RightControl:
            self = .control
        case kVK_Option, kVK_RightOption:
            self = .option
        case kVK_Shift, kVK_RightShift:
            self = .shift
        default:
            return nil
        }
    }
}

public enum HotKeyKey: String, CaseIterable, Equatable {
    case a
    case b
    case c
    case d
    case e
    case f
    case g
    case h
    case i
    case j
    case k
    case l
    case m
    case n
    case o
    case p
    case q
    case r
    case s
    case t
    case u
    case v
    case w
    case x
    case y
    case z
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case space
    case `return`
    case tab
    case escape

    public var displayName: String {
        switch self {
        case .zero:
            return "0"
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .space:
            return "Space"
        case .return:
            return "Return"
        case .tab:
            return "Tab"
        case .escape:
            return "Escape"
        default:
            return rawValue.uppercased()
        }
    }

    public var storageName: String {
        switch self {
        case .zero:
            return "0"
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        default:
            return rawValue
        }
    }

    public var carbonKeyCode: UInt32 {
        switch self {
        case .a:
            return UInt32(kVK_ANSI_A)
        case .b:
            return UInt32(kVK_ANSI_B)
        case .c:
            return UInt32(kVK_ANSI_C)
        case .d:
            return UInt32(kVK_ANSI_D)
        case .e:
            return UInt32(kVK_ANSI_E)
        case .f:
            return UInt32(kVK_ANSI_F)
        case .g:
            return UInt32(kVK_ANSI_G)
        case .h:
            return UInt32(kVK_ANSI_H)
        case .i:
            return UInt32(kVK_ANSI_I)
        case .j:
            return UInt32(kVK_ANSI_J)
        case .k:
            return UInt32(kVK_ANSI_K)
        case .l:
            return UInt32(kVK_ANSI_L)
        case .m:
            return UInt32(kVK_ANSI_M)
        case .n:
            return UInt32(kVK_ANSI_N)
        case .o:
            return UInt32(kVK_ANSI_O)
        case .p:
            return UInt32(kVK_ANSI_P)
        case .q:
            return UInt32(kVK_ANSI_Q)
        case .r:
            return UInt32(kVK_ANSI_R)
        case .s:
            return UInt32(kVK_ANSI_S)
        case .t:
            return UInt32(kVK_ANSI_T)
        case .u:
            return UInt32(kVK_ANSI_U)
        case .v:
            return UInt32(kVK_ANSI_V)
        case .w:
            return UInt32(kVK_ANSI_W)
        case .x:
            return UInt32(kVK_ANSI_X)
        case .y:
            return UInt32(kVK_ANSI_Y)
        case .z:
            return UInt32(kVK_ANSI_Z)
        case .zero:
            return UInt32(kVK_ANSI_0)
        case .one:
            return UInt32(kVK_ANSI_1)
        case .two:
            return UInt32(kVK_ANSI_2)
        case .three:
            return UInt32(kVK_ANSI_3)
        case .four:
            return UInt32(kVK_ANSI_4)
        case .five:
            return UInt32(kVK_ANSI_5)
        case .six:
            return UInt32(kVK_ANSI_6)
        case .seven:
            return UInt32(kVK_ANSI_7)
        case .eight:
            return UInt32(kVK_ANSI_8)
        case .nine:
            return UInt32(kVK_ANSI_9)
        case .space:
            return UInt32(kVK_Space)
        case .return:
            return UInt32(kVK_Return)
        case .tab:
            return UInt32(kVK_Tab)
        case .escape:
            return UInt32(kVK_Escape)
        }
    }

    public init?(storageName: String) {
        switch storageName {
        case "0":
            self = .zero
        case "1":
            self = .one
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        case "8":
            self = .eight
        case "9":
            self = .nine
        case "enter", "return":
            self = .return
        case "esc", "escape":
            self = .escape
        default:
            self.init(rawValue: storageName)
        }
    }

    public init?(keyCode: UInt16) {
        switch Int(keyCode) {
        case kVK_ANSI_A:
            self = .a
        case kVK_ANSI_B:
            self = .b
        case kVK_ANSI_C:
            self = .c
        case kVK_ANSI_D:
            self = .d
        case kVK_ANSI_E:
            self = .e
        case kVK_ANSI_F:
            self = .f
        case kVK_ANSI_G:
            self = .g
        case kVK_ANSI_H:
            self = .h
        case kVK_ANSI_I:
            self = .i
        case kVK_ANSI_J:
            self = .j
        case kVK_ANSI_K:
            self = .k
        case kVK_ANSI_L:
            self = .l
        case kVK_ANSI_M:
            self = .m
        case kVK_ANSI_N:
            self = .n
        case kVK_ANSI_O:
            self = .o
        case kVK_ANSI_P:
            self = .p
        case kVK_ANSI_Q:
            self = .q
        case kVK_ANSI_R:
            self = .r
        case kVK_ANSI_S:
            self = .s
        case kVK_ANSI_T:
            self = .t
        case kVK_ANSI_U:
            self = .u
        case kVK_ANSI_V:
            self = .v
        case kVK_ANSI_W:
            self = .w
        case kVK_ANSI_X:
            self = .x
        case kVK_ANSI_Y:
            self = .y
        case kVK_ANSI_Z:
            self = .z
        case kVK_ANSI_0:
            self = .zero
        case kVK_ANSI_1:
            self = .one
        case kVK_ANSI_2:
            self = .two
        case kVK_ANSI_3:
            self = .three
        case kVK_ANSI_4:
            self = .four
        case kVK_ANSI_5:
            self = .five
        case kVK_ANSI_6:
            self = .six
        case kVK_ANSI_7:
            self = .seven
        case kVK_ANSI_8:
            self = .eight
        case kVK_ANSI_9:
            self = .nine
        case kVK_Space:
            self = .space
        case kVK_Return:
            self = .return
        case kVK_Tab:
            self = .tab
        case kVK_Escape:
            self = .escape
        default:
            return nil
        }
    }
}

public enum HotKeyComponent: Equatable {
    case modifier(HotKeyModifier)
    case key(HotKeyKey)

    public var displayName: String {
        switch self {
        case .modifier(let modifier):
            return modifier.displayName
        case .key(let key):
            return key.displayName
        }
    }

    public var storageName: String {
        switch self {
        case .modifier(let modifier):
            return modifier.storageName
        case .key(let key):
            return key.storageName
        }
    }

    public init?(storageName: String) {
        if let modifier = HotKeyModifier(storageName: storageName) {
            self = .modifier(modifier)
            return
        }
        if let key = HotKeyKey(storageName: storageName) {
            self = .key(key)
            return
        }
        return nil
    }
}

public enum HotKeyRecorderError: LocalizedError, Equatable {
    case duplicateKey
    case invalidPair

    public var errorDescription: String? {
        switch self {
        case .duplicateKey:
            return "两个键不能相同。"
        case .invalidPair:
            return "快捷键需要一个修饰键和一个普通键。"
        }
    }
}

public struct HotKeyRecorder {
    private var firstComponent: HotKeyComponent?

    public init() {}

    public mutating func reset() {
        firstComponent = nil
    }

    public mutating func record(_ component: HotKeyComponent) throws -> GlobalHotKeyShortcut? {
        guard let firstComponent else {
            self.firstComponent = component
            return nil
        }

        guard firstComponent != component else {
            self.firstComponent = nil
            throw HotKeyRecorderError.duplicateKey
        }

        self.firstComponent = nil
        guard let shortcut = Self.shortcut(from: firstComponent, and: component) else {
            throw HotKeyRecorderError.invalidPair
        }
        return shortcut
    }

    public static func shortcut(from first: HotKeyComponent, and second: HotKeyComponent) -> GlobalHotKeyShortcut? {
        let modifier: HotKeyModifier
        let key: HotKeyKey
        switch (first, second) {
        case (.modifier(let firstModifier), .key(let secondKey)):
            modifier = firstModifier
            key = secondKey
        case (.key(let firstKey), .modifier(let secondModifier)):
            modifier = secondModifier
            key = firstKey
        default:
            return nil
        }

        return GlobalHotKeyShortcut(
            displayName: "\(modifier.displayName) + \(key.displayName)",
            keyCode: key.carbonKeyCode,
            modifiers: modifier.carbonModifier,
            id: 1,
            storageValue: "\(modifier.storageName)+\(key.storageName)"
        )
    }
}

public enum GlobalHotKeyError: LocalizedError {
    case eventHandlerInstallFailed(OSStatus)
    case registrationFailed(OSStatus)
    case allRegistrationsFailed([OSStatus])

    public var errorDescription: String? {
        switch self {
        case .eventHandlerInstallFailed(let status):
            return "快捷键事件处理器注册失败：\(status)"
        case .registrationFailed(let status):
            return "全局快捷键注册失败，可能已被系统或其他应用占用：\(status)"
        case .allRegistrationsFailed(let statuses):
            return "全局快捷键注册失败：\(statuses.map(String.init).joined(separator: ", "))"
        }
    }
}

public final class GlobalHotKeyManager {
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandlerRef: EventHandlerRef?
    private var handler: (() -> Void)?
    public private(set) var registeredShortcuts: [GlobalHotKeyShortcut] = []

    public init() {}

    deinit {
        unregister()
    }

    public func registerDefaultOptionSpace(handler: @escaping () -> Void) throws {
        try registerDefaultShortcuts(handler: handler)
    }

    public func registerDefaultShortcuts(handler: @escaping () -> Void) throws {
        try register(shortcuts: GlobalHotKeyShortcut.defaultShortcuts, handler: handler)
    }

    public func register(shortcut: GlobalHotKeyShortcut, handler: @escaping () -> Void) throws {
        try register(shortcuts: [shortcut], handler: handler)
    }

    public func register(shortcuts: [GlobalHotKeyShortcut], handler: @escaping () -> Void) throws {
        unregister()
        self.handler = handler

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else {
                    return noErr
                }
                let manager = Unmanaged<GlobalHotKeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                manager.handler?()
                return noErr
            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard installStatus == noErr else {
            throw GlobalHotKeyError.eventHandlerInstallFailed(installStatus)
        }

        var failures: [OSStatus] = []

        for shortcut in shortcuts {
            var ref: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: fourCharCode("LFLT"), id: shortcut.id)
            let registerStatus = RegisterEventHotKey(
                shortcut.keyCode,
                shortcut.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &ref
            )
            if registerStatus == noErr, let ref {
                hotKeyRefs.append(ref)
                registeredShortcuts.append(shortcut)
            } else {
                failures.append(registerStatus)
            }
        }

        guard !hotKeyRefs.isEmpty else {
            unregister()
            throw GlobalHotKeyError.allRegistrationsFailed(failures)
        }
    }

    public var registeredShortcutSummary: String {
        if registeredShortcuts.isEmpty {
            return GlobalHotKeyShortcut.defaultDisplaySummary
        }
        return registeredShortcuts.map(\.displayName).joined(separator: " / ")
    }

    public func unregister() {
        for hotKeyRef in hotKeyRefs {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRefs.removeAll()
        registeredShortcuts.removeAll()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
        handler = nil
    }
}

private func fourCharCode(_ string: String) -> OSType {
    var result: UInt32 = 0
    for scalar in string.unicodeScalars.prefix(4) {
        result = (result << 8) + UInt32(scalar.value)
    }
    return result
}
