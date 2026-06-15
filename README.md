# Floatype（浮译）

Floatype（浮译） is an open-source native macOS floating bilingual input panel for Chinese-to-English writing workflows.

The app is local-first: it can translate with a local Ollama model, and it can also use a user-configured OpenAI-compatible chat completions API. Floatype does not provide a cloud service, account system, analytics, ads, crash upload SDKs, sync, or translation history.

## Download

Download the latest ready-to-use macOS app from GitHub Releases:

[Download Floatype-macOS-v0.3.0.zip](https://github.com/qingkeke29/Floatype/releases/latest/download/Floatype-macOS-v0.3.0.zip)

Unzip it, move `Floatype.app` to Applications, then open it from Finder. This build is self-signed, so macOS may ask you to confirm before opening.

## Source

The Swift package lives in [`LinguaFloat`](LinguaFloat/).

```bash
cd LinguaFloat
swift test --jobs 1
scripts/build.sh
```

## Features

- Native AppKit floating panel.
- Chinese input with marked text / candidate composition support.
- Streaming English output.
- Settings-only model source configuration.
- Local Ollama and custom OpenAI-compatible API support.
- Clipboard fallback when Accessibility insertion is unavailable.

## Requirements

- macOS 14 or newer
- Apple Silicon recommended
- Xcode command line tools / Xcode
- Swift 6 toolchain compatible with SwiftPM
- Ollama if using the local model source

## License

MIT. See [`LICENSE`](LICENSE).
