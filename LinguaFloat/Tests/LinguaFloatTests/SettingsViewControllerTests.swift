import AppKit
import XCTest
@testable import LinguaFloatCore

@MainActor
final class SettingsViewControllerTests: XCTestCase {
    func testSettingsViewIncludesModelSourceControls() {
        let settings = isolatedSettings()
        let controller = SettingsViewController(
            settings: settings,
            permissionService: AccessibilityPermissionService()
        )

        controller.loadViewIfNeeded()

        let visibleText = collectVisibleText(from: controller.view)
        XCTAssertTrue(visibleText.contains("模型来源"))
        XCTAssertTrue(visibleText.contains("本地模型"))
        XCTAssertTrue(visibleText.contains("API URL"))
        XCTAssertTrue(visibleText.contains("API Key"))
        XCTAssertTrue(visibleText.contains("API 模型"))
        XCTAssertTrue(visibleText.contains("测试连接"))
    }

    private func isolatedSettings() -> AppSettings {
        let suiteName = "LinguaFloatSettingsViewControllerTest-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return AppSettings(defaults: defaults)
    }

    private func collectVisibleText(from view: NSView) -> Set<String> {
        var result = Set<String>()
        if let textField = view as? NSTextField, !textField.stringValue.isEmpty {
            result.insert(textField.stringValue)
        }
        if let button = view as? NSButton, !button.title.isEmpty {
            result.insert(button.title)
        }
        for subview in view.subviews {
            result.formUnion(collectVisibleText(from: subview))
        }
        return result
    }
}
