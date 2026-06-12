import AppKit
import Foundation

public struct PasteboardSnapshot: Equatable {
    public struct Item: Equatable {
        public var values: [(type: String, data: Data)]

        public init(values: [(type: String, data: Data)]) {
            self.values = values
        }

        public static func == (lhs: Item, rhs: Item) -> Bool {
            guard lhs.values.count == rhs.values.count else {
                return false
            }
            return zip(lhs.values, rhs.values).allSatisfy { left, right in
                left.type == right.type && left.data == right.data
            }
        }
    }

    public var items: [Item]

    public init(items: [Item]) {
        self.items = items
    }

    public static func capture(from pasteboard: NSPasteboard = .general) -> PasteboardSnapshot {
        guard let pasteboardItems = pasteboard.pasteboardItems else {
            return PasteboardSnapshot(items: [])
        }

        let items: [Item] = pasteboardItems.map { item in
            let values = item.types.compactMap { type -> (String, Data)? in
                guard let data = item.data(forType: type) else {
                    return nil
                }
                return (type.rawValue, data)
            }
            return Item(values: values)
        }

        return PasteboardSnapshot(items: items)
    }

    public func restore(to pasteboard: NSPasteboard = .general) {
        pasteboard.clearContents()
        let restoredItems = items.map { snapshotItem in
            let item = NSPasteboardItem()
            for value in snapshotItem.values {
                item.setData(value.data, forType: NSPasteboard.PasteboardType(value.type))
            }
            return item
        }
        pasteboard.writeObjects(restoredItems)
    }
}
