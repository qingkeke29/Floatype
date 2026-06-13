# Floatype v0.1.0

Initial public binary download.

## Highlights

- macOS menu bar utility with a floating bilingual input panel.
- Chinese input area that preserves normal input method behavior.
- Local Ollama translation with streaming English output.
- One-step insertion back into the previously focused app.
- Clipboard fallback when Accessibility insertion is unavailable.
- Local-first privacy posture: no Floatype cloud server, account, analytics, ads, sync, or translation history.

## Intended Use

Floatype is designed for Chinese-first writing workflows where you want fast English output without sending drafts to a cloud translation service. Typical uses include English emails, work messages, overseas community replies, product notes, short social posts, and quick bilingual drafting.

## Install

1. Download `Floatype-macOS-v0.1.0.zip`.
2. Unzip it.
3. Move `Floatype.app` to Applications.
4. Open it from Finder.
5. Start Ollama and install the recommended model:

```bash
ollama pull qwen3.5:9b
```

## Notes

This is a self-signed macOS build, so macOS may ask you to confirm before opening it. Accessibility permission is optional for translation, but required for automatic insertion into other apps.
