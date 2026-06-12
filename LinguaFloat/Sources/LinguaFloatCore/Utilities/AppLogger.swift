import Foundation
import OSLog

public enum AppLogger {
    public static let app = Logger(subsystem: "com.linguafloat.app", category: "app")
    public static let model = Logger(subsystem: "com.linguafloat.app", category: "model")
    public static let insertion = Logger(subsystem: "com.linguafloat.app", category: "insertion")

    public static func logTranslationFailure(inputLength: Int, error: Error) {
        model.error("Translation failed. Input length: \(inputLength, privacy: .public). Error: \(String(describing: type(of: error)), privacy: .public)")
    }
}
