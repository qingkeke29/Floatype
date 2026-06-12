import Foundation

public enum OllamaStreamEvent: Equatable {
    case content(String)
    case done
    case error(String)
    case malformedLine(String)
}

public struct OllamaStreamParser {
    private var buffer = ""
    private let decoder = JSONDecoder()

    public init() {}

    public mutating func feed(_ data: Data) -> [OllamaStreamEvent] {
        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else {
            return []
        }

        buffer += text
        var events: [OllamaStreamEvent] = []

        while let newlineRange = buffer.range(of: "\n") {
            let rawLine = String(buffer[..<newlineRange.lowerBound])
            buffer.removeSubrange(...newlineRange.lowerBound)
            events.append(contentsOf: parseLine(rawLine))
        }

        return events
    }

    public mutating func finish() -> [OllamaStreamEvent] {
        guard !buffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            buffer = ""
            return []
        }
        let remaining = buffer
        buffer = ""
        return parseLine(remaining)
    }

    private func parseLine(_ rawLine: String) -> [OllamaStreamEvent] {
        let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else {
            return []
        }
        guard let data = line.data(using: .utf8) else {
            return [.malformedLine("invalid utf8")]
        }

        do {
            let chunk = try decoder.decode(OllamaChatStreamChunk.self, from: data)
            var events: [OllamaStreamEvent] = []
            if let error = chunk.error, !error.isEmpty {
                events.append(.error(error))
            }
            if let content = chunk.message?.content, !content.isEmpty {
                events.append(.content(content))
            }
            if chunk.done == true {
                events.append(.done)
            }
            return events
        } catch {
            return [.malformedLine(String(describing: type(of: error)))]
        }
    }
}
