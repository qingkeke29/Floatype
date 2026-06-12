import Foundation

public final class Debouncer {
    private var task: Task<Void, Never>?
    private let lock = NSLock()

    public init() {}

    deinit {
        cancel()
    }

    public func schedule(after delay: TimeInterval, operation: @escaping () async -> Void) {
        cancel()
        let nanoseconds = UInt64(max(delay, 0) * 1_000_000_000)
        let newTask = Task {
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                return
            }
            guard !Task.isCancelled else {
                return
            }
            await operation()
        }

        lock.lock()
        task = newTask
        lock.unlock()
    }

    public func cancel() {
        lock.lock()
        let current = task
        task = nil
        lock.unlock()
        current?.cancel()
    }
}
