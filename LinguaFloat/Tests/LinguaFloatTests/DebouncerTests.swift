import XCTest
@testable import LinguaFloatCore

final class DebouncerTests: XCTestCase {
    func testConsecutiveInputOnlyRunsLastTask() async throws {
        let debouncer = Debouncer()
        let recorder = ValueRecorder()

        debouncer.schedule(after: 0.05) {
            await recorder.append(1)
        }
        debouncer.schedule(after: 0.05) {
            await recorder.append(2)
        }
        debouncer.schedule(after: 0.05) {
            await recorder.append(3)
        }

        try await Task.sleep(nanoseconds: 160_000_000)

        let result = await recorder.snapshot()
        XCTAssertEqual(result, [3])
    }
}

private actor ValueRecorder {
    private var values: [Int] = []

    func append(_ value: Int) {
        values.append(value)
    }

    func snapshot() -> [Int] {
        values
    }
}
