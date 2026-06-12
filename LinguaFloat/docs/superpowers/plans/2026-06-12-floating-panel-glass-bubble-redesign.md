# Floating Panel Glass Bubble Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved glass bubble floating panel redesign with two selectable outputs, no bilingual option in the panel flow, a circular gear settings button, and clean content labels.

**Architecture:** Keep the existing AppKit `NSPanel` and `FloatingPanelViewController` structure. The model-level output navigation becomes two-state (`chinese` and `english`), while the view controller owns the new glass bubble layout and selected-box styling.

**Tech Stack:** Swift 6 / SwiftPM, AppKit, XCTest, local shell build scripts.

---

### Task 1: Convert Output Navigation To Two States

**Files:**
- Modify: `Tests/LinguaFloatTests/OutputSelectionNavigationTests.swift`
- Modify: `Tests/LinguaFloatTests/FloatingPanelViewModelTests.swift`
- Modify: `Sources/LinguaFloatCore/Models/OutputSelection.swift`
- Modify: `Sources/LinguaFloatCore/Settings/AppSettings.swift`

- [ ] **Step 1: Write failing navigation tests**

Replace the existing three-state navigation assertions with two-state assertions:

```swift
func testNextSelectionCyclesBetweenChineseAndEnglishOnly() {
    XCTAssertEqual(OutputSelection.chinese.next, .english)
    XCTAssertEqual(OutputSelection.english.next, .chinese)
}

func testPreviousSelectionCyclesBetweenChineseAndEnglishOnly() {
    XCTAssertEqual(OutputSelection.chinese.previous, .english)
    XCTAssertEqual(OutputSelection.english.previous, .chinese)
}
```

- [ ] **Step 2: Write failing saved-default migration test**

Update `FloatingPanelViewModelTests` so a previously saved `.bilingual` default opens as `.english`:

```swift
func testMigratesBilingualDefaultSelectionToEnglishWhenPanelOpens() {
    let provider = StubProvider()
    let defaults = UserDefaults(suiteName: "FloatingPanelViewModelTests.\(UUID().uuidString)")!
    defaults.removePersistentDomain(forName: defaultsSuiteName(defaults))
    let settings = AppSettings(defaults: defaults)
    settings.defaultOutputSelection = .bilingual
    let viewModel = FloatingPanelViewModel(provider: provider, settings: settings)

    viewModel.resetForOpen()

    XCTAssertEqual(viewModel.state.selectedOutput, .english)
}
```

Use the existing helper pattern in the test file for cleaning suite defaults instead of introducing a new dependency.

- [ ] **Step 3: Run tests and verify red**

Run:

```bash
swift test --filter OutputSelectionNavigationTests --jobs 1
swift test --filter FloatingPanelViewModelTests --jobs 1
```

Expected: navigation tests fail because `.english.next` still returns `.bilingual`; view model test fails because `.bilingual` is still preserved.

- [ ] **Step 4: Implement two-state selectable outputs**

Keep `OutputSelection.bilingual` available for decoding old settings and composing legacy values, but change `next` and `previous` so `.bilingual` normalizes back into `.english`:

```swift
public var next: OutputSelection {
    switch self {
    case .chinese:
        return .english
    case .english, .bilingual:
        return .chinese
    }
}

public var previous: OutputSelection {
    switch self {
    case .chinese, .bilingual:
        return .english
    case .english:
        return .chinese
    }
}

public var panelSelection: OutputSelection {
    self == .bilingual ? .english : self
}
```

Update `AppSettings.defaultOutputSelection` getter and setter to normalize `.bilingual` to `.english` for the panel:

```swift
public var defaultOutputSelection: OutputSelection {
    get { (OutputSelection(rawValue: defaults.string(forKey: Keys.defaultOutputSelection) ?? "") ?? .english).panelSelection }
    set { defaults.set(newValue.panelSelection.rawValue, forKey: Keys.defaultOutputSelection) }
}
```

- [ ] **Step 5: Verify green**

Run:

```bash
swift test --filter OutputSelectionNavigationTests --jobs 1
swift test --filter FloatingPanelViewModelTests --jobs 1
```

Expected: both filtered test runs pass.

### Task 2: Remove Bilingual Commands From The Floating Panel

**Files:**
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelCommand.swift`
- Modify: `Sources/LinguaFloatCore/FloatingPanel/ChineseTextView.swift`
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelController.swift`
- Modify: `README.md`

- [ ] **Step 1: Remove the command case and handlers**

Delete `case useBilingual` from `FloatingPanelCommand`. Remove the `Command + 3` branch from `PlaceholderTextView.keyDown(with:)`. Remove the `.useBilingual` switch case from `FloatingPanelController.handle(_:)`.

- [ ] **Step 2: Update keyboard documentation**

In `README.md`, remove the `Command + 3` bilingual shortcut line and change the Up/Down line to:

```text
- Up / Down: choose Chinese or English output
```

- [ ] **Step 3: Compile-check the command removal**

Run:

```bash
swift test --jobs 1
```

Expected: the package compiles and all tests pass, confirming no stale `.useBilingual` references remain.

### Task 3: Implement The Glass Bubble View Layout

**Files:**
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanelViewController.swift`
- Modify: `Sources/LinguaFloatCore/FloatingPanel/FloatingPanel.swift`

- [ ] **Step 1: Replace output buttons with selectable box containers**

Remove `chineseButton`, `englishButton`, and `bilingualButton`. Add `NSBox` containers for the Chinese and English editor sections:

```swift
private var chineseBox: NSBox?
private var englishBox: NSBox?
```

Make `makeEditorSection(title:textView:)` return and store the `NSBox` for each section, with a clean label and no right-side inline hint.

- [ ] **Step 2: Restyle the top bar**

Keep title/model on the left. Replace the text settings button with a circular gear icon button immediately before `statusBadge`:

```swift
let settingsButton = NSButton(title: "⚙︎", target: self, action: #selector(openSettings))
settingsButton.bezelStyle = .texturedRounded
settingsButton.toolTip = "设置"
```

The top-right order is settings gear, status badge. The close action can remain accessible through Escape and the window behavior; do not add a visible close text button to the redesigned top bar.

- [ ] **Step 3: Apply glass and selected-box styling**

Use the existing `NSVisualEffectView` root, with a softer corner radius. Style each editor box as translucent white by default and apply the selected state to the matching box:

```swift
private func applySelectionStyle(to box: NSBox?, selected: Bool) {
    guard let box else { return }
    box.wantsLayer = true
    box.boxType = .custom
    box.borderWidth = 1
    box.cornerRadius = 20
    if selected {
        box.fillColor = NSColor.systemBlue.withAlphaComponent(0.10)
        box.borderColor = NSColor.systemBlue.withAlphaComponent(0.55)
        box.layer?.shadowColor = NSColor.systemBlue.withAlphaComponent(0.20).cgColor
        box.layer?.shadowOpacity = 1
        box.layer?.shadowRadius = 14
        box.layer?.shadowOffset = NSSize(width: 0, height: -4)
    } else {
        box.fillColor = NSColor.windowBackgroundColor.withAlphaComponent(0.48)
        box.borderColor = NSColor.separatorColor.withAlphaComponent(0.70)
        box.layer?.shadowOpacity = 0
    }
}
```

- [ ] **Step 4: Update bottom hint text**

Use a compact panel-level hint:

```swift
let hint = NSTextField(labelWithString: "↑↓ 选择 · ↩ 填入 · Esc 取消 · Tab 重新翻译")
```

- [ ] **Step 5: Adjust default panel dimensions**

Set the default frame closer to the mockup, while keeping resize support:

```swift
let frame = settings.lastPanelFrame ?? NSRect(x: 0, y: 0, width: 460, height: 360)
```

Keep `minSize` large enough for both editor boxes and the hint.

- [ ] **Step 6: Build-check the AppKit layout**

Run:

```bash
swift test --jobs 1
scripts/build.sh
```

Expected: tests pass, the app bundle builds, and signing verification in the build script succeeds.

### Task 4: Final Verification

**Files:**
- Read: `docs/superpowers/specs/2026-06-12-floating-panel-glass-bubble-redesign.md`

- [ ] **Step 1: Run full automated verification**

Run:

```bash
swift test --jobs 1
scripts/build.sh
codesign --verify --deep --strict --verbose=2 /Users/wanghaixu/Applications/Floatype.app
```

Expected: all commands exit 0.

- [ ] **Step 2: Manual UI checklist**

Launch the app and verify:

```bash
open /Users/wanghaixu/Applications/Floatype.app
```

Checklist:

- The panel uses the glass bubble layout.
- The bottom Chinese/English/bilingual buttons are gone.
- The top-right settings button is a circular gear immediately left of the status badge.
- The Chinese and English labels have no inline right-side hints.
- Up and Down switch between only the two boxes.
- The selected box uses the soft blue state.
- Return inserts the selected box content.
