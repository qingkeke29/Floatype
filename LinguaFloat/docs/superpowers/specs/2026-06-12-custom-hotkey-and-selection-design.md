# Custom Hotkey And Selection Design

## Goal

Let the user set the global LinguaFloat shortcut by pressing two keys one after another in settings, while using the chosen shortcut by pressing those two keys at the same time. Add keyboard selection inside the floating panel so Up and Down choose Chinese, English, or bilingual output, and Return inserts the selected output into the previously focused app.

## Shortcut Behavior

The default global shortcut is Command + Z. Settings shows a shortcut recorder with three states: idle, waiting for the first key, and waiting for the second key. The user clicks record, presses one key, then presses the second key. One key must be a modifier key: Command, Control, Option, or Shift. The other key must be a normal key supported by Carbon global hotkeys, such as letters, numbers, Space, Return, Tab, or Escape. The recorded shortcut is saved immediately after the second valid key and the app re-registers the global shortcut without requiring a restart.

If the user records an invalid pair, such as two normal letters or two modifier-only keys, settings keeps the previous shortcut and displays a short validation message. A reset button restores Command + Z.

## Floating Panel Behavior

The panel keeps three output choices: Chinese, English, and bilingual. Up and Down move the selection between these choices. The selected choice has a darker visual treatment. Return inserts the currently selected output into the app that was focused before the panel opened. Existing mouse clicks and Command + 1/2/3 shortcuts stay available.

## Implementation Shape

Shortcut parsing and display lives with the hotkey model. AppSettings persists a single shortcut instead of using a hard-coded shortcut list. GlobalHotKeyManager registers the shortcut from settings and exposes the registered display text for the menu bar. SettingsViewController owns the lightweight recorder UI and asks AppDelegate to re-register the hotkey after a settings save.

Floating panel selection remains driven by FloatingPanelViewModel.selectedOutput. The view controller adds keyboard handling for Up, Down, and Return, and updates the three output buttons with a darker style for the selected output.

## Verification

Tests cover the default Command + Z shortcut, shortcut persistence, valid and invalid two-key recordings, and selection cycling. Manual verification covers recording a new shortcut in settings, using it from another app, selecting output with Up and Down, and inserting with Return.
