# Floatype（浮译） / 双语浮板

Floatype（浮译） is a native macOS floating bilingual input panel designed to work alongside normal Chinese input methods such as 豆包输入法. It does not modify the input method, read candidate windows, use OCR, or send text to cloud AI services.

## Download

Download the latest ready-to-use macOS app from GitHub Releases:

[Download Floatype-macOS-v0.2.0.zip](https://github.com/qingkeke29/Floatype/releases/latest/download/Floatype-macOS-v0.2.0.zip)

Unzip it, move `Floatype.app` to Applications, then open it from Finder. This build is self-signed, so macOS may ask you to confirm before opening.

## What v1 Does

- Opens a floating AppKit `NSPanel` with the configured global shortcut, defaulting to Command + Z, or from the menu bar item.
- Lets the user type Chinese into a real `NSTextView`, preserving marked text and candidate composition behavior.
- Debounces confirmed Chinese text for about 700 ms before translating.
- Uses the model source configured in Settings: local Ollama or a custom OpenAI-compatible API.
- Streams English into an editable `NSTextView`.
- Inserts Chinese or English output into the app that was focused before the panel opened.
- Falls back to clipboard paste while preserving pasteboard item data when direct Accessibility insertion is unavailable.

## Requirements

- macOS 14 or newer
- Apple Silicon recommended
- Xcode command line tools / Xcode
- Swift 6 toolchain compatible with SwiftPM
- Ollama if you use the local model source

## Model Sources

Floatype supports two model sources configured from Settings only:

- Local Ollama: use a local or LAN Ollama URL and choose an installed model from the refreshable model list, or type a model name manually.
- Custom API: use an OpenAI-compatible chat completions API by entering API URL, API Key, and model name.

The floating panel shows the active source/model but does not change model settings. Use the gear button or menu bar Settings window to change source, URL, key, or model.

For local Ollama, the app still runs if Ollama or `qwen3.5:9b` is missing. It will show the missing service/model state and let you copy:

```bash
ollama pull qwen3.5:9b
```

## Build

```bash
cd /Users/wanghaixu/Documents/610/LinguaFloat
scripts/check_environment.sh
scripts/build.sh
```

The signed app bundle is created at:

```text
/Users/wanghaixu/Applications/Floatype.app
```

A convenience link is also created at `.build/Floatype.app`.

## Run

```bash
cd /Users/wanghaixu/Documents/610/LinguaFloat
scripts/run.sh
```

You can also open `~/Applications/Floatype.app` or `.build/Floatype.app` from Finder after building.

## Test

```bash
cd /Users/wanghaixu/Documents/610/LinguaFloat
swift test --jobs 1
```

The suite covers:

- Ollama NDJSON stream parsing, including half-line buffering and malformed JSON
- Translation prompt generation for all four styles
- Markdown/quote cleanup without damaging internal punctuation or newlines
- Pasteboard snapshot and restore for text and multiple data types
- Debounce behavior

## Privacy

本地模式下，输入内容只会发送到本机的 Ollama 服务，不会发送到 Floatype（浮译）的服务器。本应用不提供云端服务器。

Floatype（浮译） does not include analytics, ads, crash upload SDKs, user accounts, sync, or translation history. Logs must not include source text or translated text; they may record status, error type, timing, and character counts.

## Accessibility Permission

Floatype（浮译） needs macOS Accessibility permission to insert selected output back into the previously focused app. Without permission, translation still works and the selected result is copied to the clipboard so you can paste manually.

The app refuses to write into secure/password-like fields and does not read the previous app's input contents.

## Keyboard

- Command + Z: default shortcut to open or close the floating panel
- Settings can record a custom shortcut by pressing one modifier key and one normal key in sequence; use the shortcut by pressing both keys at the same time.
- Command + 1: use Chinese
- Command + 2: use English
- Up / Down: choose Chinese or English output
- Return or Command + Return: insert the currently selected output
- Escape: cancel
- Tab: translate immediately while editing Chinese
- Command + R: retry translation
- Command + .: stop generation

## Known v1 Limits

- Shortcut recording supports one modifier key plus one normal key. Chord-only shortcuts such as Command + Shift are not supported.
- MLX support is represented by a provider placeholder and is not implemented.
- The app does not automatically download large models.
- Rich text insertion is not implemented; selected output is plain text.
- Some applications may reject direct Accessibility text insertion, in which case Floatype（浮译） uses the clipboard paste fallback and restores the original pasteboard snapshot afterward.
