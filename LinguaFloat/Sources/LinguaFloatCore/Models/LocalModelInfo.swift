import Foundation

public struct LocalModelInfo: Codable, Equatable {
    public var name: String
    public var modifiedAt: Date?
    public var size: Int64?

    public init(name: String, modifiedAt: Date? = nil, size: Int64? = nil) {
        self.name = name
        self.modifiedAt = modifiedAt
        self.size = size
    }
}
