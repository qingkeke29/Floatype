import Foundation

public enum OpenAICompatibleStreamEvent: Equatable {
    case content(String)
    case done
    case error(String)
    case malformedLine
}

public struct OpenAICompatibleStreamParser {
    private var buffer = Data()
    private let decoder = JSONDecoder()

    public init() {}

    public mutating func feed(_ data: Data) -> [OpenAICompatibleStreamEvent] {
        buffer.append(data)
        var events: [OpenAICompatibleStreamEvent] = []

        while let newlineRange = buffer.firstRange(of: Data([0x0A])) {
            let lineData = buffer.subdata(in: buffer.startIndex..<newlineRange.lowerBound)
            buffer.removeSubrange(buffer.startIndex...newlineRange.lowerBound)
            events.append(contentsOf: parseLine(lineData))
        }

        return events
    }

    public mutating func finish() -> [OpenAICompatibleStreamEvent] {
        guard !buffer.isEmpty else {
            return []
        }
        let line = buffer
        buffer.removeAll()
        return parseLine(line)
    }

    private func parseLine(_ lineData: Data) -> [OpenAICompatibleStreamEvent] {
        let rawLine = String(decoding: lineData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawLine.isEmpty else {
            return []
        }
        guard rawLine.hasPrefix("data:") else {
            return []
        }

        let payload = rawLine.dropFirst("data:".count).trimmingCharacters(in: .whitespacesAndNewlines)
        if payload == "[DONE]" {
            return [.done]
        }

        guard let data = payload.data(using: .utf8) else {
            return [.malformedLine]
        }

        if let apiError = try? decoder.decode(OpenAIErrorResponse.self, from: data) {
            return [.error(apiError.error.message)]
        }

        guard let decoded = try? decoder.decode(OpenAIChatCompletionResponse.self, from: data) else {
            return [.malformedLine]
        }

        var events: [OpenAICompatibleStreamEvent] = []
        if let content = decoded.firstDeltaContent, !content.isEmpty {
            events.append(.content(content))
        }
        if decoded.choices.contains(where: { $0.finishReason != nil }) {
            events.append(.done)
        }
        return events
    }
}
