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
        XCTAssertTrue(visibleText.contains("源语言"))
        XCTAssertTrue(visibleText.contains("目标语言"))
        XCTAssertTrue(visibleText.contains("翻译模式"))
        XCTAssertTrue(visibleText.contains("多语言输出"))
        XCTAssertFalse(visibleText.contains("浮窗快捷键"))
        XCTAssertFalse(visibleText.contains("启用 Cmd + 1 使用中文"))
        XCTAssertFalse(visibleText.contains("启用 Cmd + 2 使用英文"))
        XCTAssertFalse(visibleText.contains("启用 Cmd + 3 使用 Settings 默认输出"))
        XCTAssertFalse(visibleText.contains("启用 Cmd + Shift + M 切换多语言输出"))
    }

    func testTargetLanguagePopupExcludesAutoAndUsesChineseLabelsByDefault() {
        let settings = isolatedSettings()
        settings.sourceLanguage = .auto
        let controller = SettingsViewController(
            settings: settings,
            permissionService: AccessibilityPermissionService()
        )

        controller.loadViewIfNeeded()

        let targetTitles = popupTitles(from: controller.view).first { titles in
            titles.contains("英语") && titles.contains("日语")
        } ?? []
        XCTAssertFalse(targetTitles.contains("自动检测"))
        XCTAssertEqual(targetTitles, ["英语", "日语", "韩语", "法语", "德语", "西班牙语"])
    }

    func testTargetLanguagePopupRefreshesWhenSourceLanguageChangesToEnglish() {
        let settings = isolatedSettings()
        settings.sourceLanguage = .chinese
        let controller = SettingsViewController(
            settings: settings,
            permissionService: AccessibilityPermissionService()
        )

        controller.loadViewIfNeeded()
        let sourcePopup = popupButtons(from: controller.view).first { popup in
            popup.itemTitles.contains("自动检测") && popup.itemTitles.contains("English")
        }
        sourcePopup?.selectItem(withTitle: "English")
        if let action = sourcePopup?.action {
            NSApp.sendAction(action, to: sourcePopup?.target, from: sourcePopup)
        }

        let targetTitles = popupTitles(from: controller.view).first { titles in
            titles.contains("Chinese") && titles.contains("Japanese")
        } ?? []
        XCTAssertFalse(targetTitles.contains("Auto"))
        XCTAssertFalse(targetTitles.contains("English"))
        XCTAssertEqual(targetTitles, ["Chinese", "Japanese", "Korean", "French", "German", "Spanish"])
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

    private func popupButtons(from view: NSView) -> [NSPopUpButton] {
        var result: [NSPopUpButton] = []
        if let popup = view as? NSPopUpButton {
            result.append(popup)
        }
        for subview in view.subviews {
            result.append(contentsOf: popupButtons(from: subview))
        }
        return result
    }

    private func popupTitles(from view: NSView) -> [[String]] {
        popupButtons(from: view).map(\.itemTitles)
    }
}
