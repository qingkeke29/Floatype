# Floatype（浮译）

Floatype（浮译） is an open-source native macOS floating AI input layer.

It is not meant to be another standalone translation app. The goal is to let you keep typing in the app you already use, open a small floating panel when needed, and turn your input into the language, tone, and output format configured in Settings.

Floatype is local-first. It can use a local Ollama model, or a user-configured OpenAI-compatible chat completions API. It does not provide a cloud service, account system, analytics, ads, crash upload SDKs, sync, or translation history.

## Download

Download the latest ready-to-use macOS app from GitHub Releases:

[Download Floatype-macOS-v0.3.0.zip](https://github.com/qingkeke29/Floatype/releases/latest/download/Floatype-macOS-v0.3.0.zip)

Unzip it, move `Floatype.app` to Applications, then open it from Finder. This build is self-signed, so macOS may ask you to confirm before opening.

## What It Does

- Opens a native AppKit floating panel from the menu bar or global shortcut.
- Lets you type source text in a real macOS text view with normal IME composition behavior.
- Sends confirmed text asynchronously to the configured model provider.
- Outputs the Settings-selected target language: English, Chinese, Japanese, Korean, French, German, or Spanish.
- Supports translation modes: normal, natural, formal, and casual.
- Supports multi-language output with English / Chinese / Japanese / Korean sections.
- Adapts the floating panel labels, placeholders, hints, and status copy to the selected source language.
- Inserts the chosen result back into the previously focused app through Accessibility, with clipboard fallback when direct insertion is unavailable.

## Settings-Driven Language Control

Floatype keeps translation behavior in Settings instead of on the floating panel.

Settings control:

- source language: auto, Chinese, English, Japanese, Korean, French, German, Spanish
- target language: all supported non-auto target languages, filtered by source language
- translation mode: normal, natural, formal, casual
- multi-language output
- model source: local Ollama or custom OpenAI-compatible API
- global shortcut
- auto-translation delay

The floating panel is intentionally lightweight: type, preview, choose, insert.

## Model Sources

### Local Ollama

Use this when you want local-first behavior. Install Ollama, pull a compatible model, then select it in Floatype Settings.

The default local model name is:

```bash
ollama pull qwen3.5:9b
```

You can also enter another installed Ollama model manually.

### Custom API

Use this when you want to connect Floatype to an OpenAI-compatible `/v1/chat/completions` endpoint. Settings accept:

- API URL
- API Key
- model name

Floatype does not operate or proxy a remote service. Your configured provider receives the text you choose to translate.

## Privacy

Floatype has no account system and no telemetry pipeline.

Local mode sends input only to your configured Ollama service. Custom API mode sends input to the API endpoint you configure. Floatype itself does not collect, sync, upload, or store translation history.

## Build From Source

The Swift package lives in [`LinguaFloat`](LinguaFloat/).

```bash
cd LinguaFloat
swift test --jobs 1
scripts/build.sh
```

The build script creates:

```text
/Users/wanghaixu/Applications/Floatype.app
```

## Current Release

Latest release: [Floatype v0.3.0](https://github.com/qingkeke29/Floatype/releases/tag/v0.3.0)

Release package SHA-256:

```text
f50778912bbab49c53b608614dfd3272be87c6435a2715c4308a48e5244960dd
```

## Requirements

- macOS 14 or newer
- Apple Silicon recommended
- Xcode command line tools / Xcode for building from source
- Swift 6 compatible toolchain
- Ollama if using the local model source

## License

MIT. See [`LICENSE`](LICENSE).
