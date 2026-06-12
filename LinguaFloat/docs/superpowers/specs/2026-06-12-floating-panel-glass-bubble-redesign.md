# Floating Panel Glass Bubble Redesign

## Goal

Redesign the Floatype floating panel to feel like a soft iOS-style/macOS glass bubble while keeping the current translation workflow fast and keyboard-first.

## Visual Direction

The panel uses the approved A direction: a frosted glass floating bubble with soft rounded corners, subtle shadow, and a calm translucent white surface. The interface should feel lighter and friendlier than the current utility panel without becoming decorative or busy.

The top bar keeps the app identity on the left and the status area on the right. A circular gear settings button sits immediately to the left of the status badge, such as "翻译完成". The settings control should be icon-only and visually lightweight.

## Layout

The bottom output buttons are removed. The panel contains only two selectable content areas:

- Chinese source box, labeled "中文原文"
- English result box, labeled "英文结果"

The labels are clean text labels only. They must not show inline right-side hints such as "选择", "输入", "↑↓", or "↩ 填入".

The current keyboard hint can remain as a small bottom hint line because it explains the panel-level shortcuts rather than decorating a specific content label.

## Selection Behavior

The bilingual output option is removed from the floating panel selection flow. Up and Down cycle only between the Chinese source box and the English result box.

The selected box receives the approved soft blue selected state: pale blue background, blue border, and subtle elevation. The unselected box remains translucent white. Return inserts the content from the currently selected box into the previously focused app.

Command shortcuts for choosing outputs should be updated or removed so they do not expose a bilingual option in the redesigned panel.

## Existing Behavior To Preserve

The redesign keeps the existing Chinese text editing behavior, marked text handling, translation streaming, status updates, retry/stop behavior, settings access, Escape cancel behavior, and insertion fallback behavior.

## Verification

Automated tests should cover two-way output selection after removing bilingual selection from the panel flow. Existing tests for translation, debouncing, pasteboard restore, insertion, hotkey settings, and panel activation should continue to pass.

Manual verification should confirm:

- The panel opens in the new glass bubble layout.
- The bottom Chinese/English/bilingual buttons are gone.
- Only Chinese and English boxes are selectable.
- Up and Down switch the selected box.
- The selected box uses the soft blue treatment.
- Return inserts the selected box content.
- The circular gear opens settings.
