# Floatype（浮译） / macOS Floating AI Input Layer

Floatype（浮译） is a native macOS AppKit app that adds a floating AI language layer on top of normal text input.

It works with existing apps and existing input methods. It does not replace your input method, inspect candidate windows, use OCR, or install a keyboard extension. The panel is a normal macOS floating window with real `NSTextView` input and output areas.

## Download

Download the latest ready-to-use macOS app from GitHub Releases:

[Download Floatype-macOS-v0.3.0.zip](https://github.com/qingkeke29/Floatype/releases/latest/download/Floatype-macOS-v0.3.0.zip)

Unzip it, move `Floatype.app` to Applications, then open it from Finder. This build is self-signed, so macOS may ask you to confirm before opening.

## Product Intent

Floatype is moving toward a system-level AI input language control layer.

The current app focuses on a small, practical loop:

1. Open the floating panel from the menu bar or global shortcut.
2. Type or paste source text.
3. Let the configured model generate the Settings-selected target language.
4. Review or edit the output.
5. Insert the selected text back into the app that was focused before the panel opened.

## User-Facing Behavior

- The floating panel keeps the original two-column structure: source input on the left, model output on the right.
- Translation behavior is driven by Settings, not by language controls on the floating panel.
- The result column title and placeholder follow the configured target language.
- The panel's main copy follows the configured source language when possible.
- Multi-language output displays sections for English, Chinese, Japanese, and Korean.
- If Accessibility insertion is unavailable, Floatype copies the selected result to the clipboard and lets the user paste manually.

## Settings

Settings control:

- model source: local Ollama or custom API
- local Ollama URL and model name
- custom OpenAI-compatible API URL, API Key, and model name
- source language: auto, Chinese, English, Japanese, Korean, French, German, Spanish
- target language: supported target languages excluding auto and the current source language
- translation mode: normal, natural, formal, casual
- multi-language output
- auto-translation delay
- global shortcut

The target-language menu changes with the source language:

- Source Chinese or Auto: target names appear in Chinese, such as 英语、日语、韩语.
- Source English: target names appear in English, such as Chinese, Japanese, Korean.
- Other source languages use matching localized panel copy where available.

## Translation Pipeline

The translation system is split into small modules:

- `Settings/TranslationPreferences.swift`: source language, target language, translation mode, and multi-language output.
- `Router/LanguageRouter.swift`: resolves single-target and multi-language output routes.
- `Translation/PromptBuilder.swift`: builds prompts from Settings.
- `Translation/OutputFormatter.swift`: normalizes single-language and multi-language output.
- `Translation/TranslationProvider.swift`: shared provider interface for current and future providers.
- `LocalModel/OllamaProvider.swift`: local Ollama implementation.
- `LocalModel/OpenAICompatibleProvider.swift`: OpenAI-compatible custom API implementation.
- `LocalModel/MLXProvider.swift`: placeholder reserved for future local MLX support.

Existing core services remain in place:

- `FloatingPanel`
- `OllamaProvider`
- `TextInsertionService`

## Prompt Behavior

For single-target translation, prompts include:

- source-language instruction
- translation mode instruction
- explicit target language
- instruction to return only the target language
- guardrail preventing English fallback when the target language is not English
- guardrails against explanations, markdown, quote wrapping, and unrelated commentary

For multi-language output, the model is asked to return exactly these labeled sections:

```text
English:
Chinese:
Japanese:
Korean:
```

## Model Sources

### Local Ollama

Local mode uses the configured Ollama endpoint, defaulting to:

```text
http://127.0.0.1:11434
```

The default model name is:

```bash
ollama pull qwen3.5:9b
```

The Settings window can refresh installed Ollama models, and the model name can also be typed manually.

If Ollama is unavailable or the model is missing, the app shows a non-crashing status and keeps the panel usable.

### Custom API

Custom API mode uses an OpenAI-compatible chat completions endpoint. Configure:

- API URL
- API Key
- model name

The app sends streaming chat completion requests and parses both streaming and non-streaming responses.

## Privacy

Floatype does not provide cloud translation infrastructure. It has no user accounts, analytics, ads, sync, crash upload SDKs, or translation history.

Local Ollama mode sends input to your configured Ollama service. Custom API mode sends input to your configured API endpoint. Logs should not include source text or translated text; status, error type, timing, and character counts are acceptable.

## Accessibility Permission

Floatype needs macOS Accessibility permission to insert selected output back into the previously focused app.

Without Accessibility permission:

- translation still works
- selected output is copied to the clipboard
- the user can paste manually

Floatype refuses to write into secure/password-like fields and does not read the previous app's input contents.

## Keyboard

- Global shortcut: configurable in Settings, defaulting to Command + Z.
- Up / Down: switch selected output.
- Return or Command + Return: insert selected output.
- Escape: cancel.
- Tab: translate immediately while editing.
- Command + R: retry.
- Command + .: stop generation.

The older floating-panel shortcut toggle section was removed from Settings. The panel still preserves existing command handling internally for compatibility.

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

A convenience link is also created at:

```text
LinguaFloat/.build/Floatype.app
```

## Run

```bash
cd /Users/wanghaixu/Documents/610/LinguaFloat
scripts/run.sh
```

## Test

```bash
cd /Users/wanghaixu/Documents/610/LinguaFloat
swift test --jobs 1
```

The test suite covers:

- Settings persistence and compatibility aliases
- language routing
- prompt generation
- output formatting
- floating panel view model behavior
- keyboard command dispatch
- model source settings
- Ollama and OpenAI-compatible request/stream parsing
- pasteboard snapshot and restore
- text insertion fallback behavior
- debounce behavior

## Release Package

Latest packaged release:

[Floatype v0.3.0](https://github.com/qingkeke29/Floatype/releases/tag/v0.3.0)

Download asset:

```text
Floatype-macOS-v0.3.0.zip
```

SHA-256:

```text
f50778912bbab49c53b608614dfd3272be87c6435a2715c4308a48e5244960dd
```

## Known Limits

- The app is self-signed, so macOS may require manual confirmation before first launch.
- MLX support is reserved but not implemented.
- Rich text insertion is not implemented; selected output is plain text.
- Some applications may reject direct Accessibility insertion. In that case, Floatype uses clipboard fallback and restores the previous pasteboard snapshot afterward.
- The app does not automatically download large models.
