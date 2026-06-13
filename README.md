# Floatype（浮译）

Floatype（浮译） is a native macOS floating bilingual input panel for people who often write Chinese first and then need polished English.

This repository is for public downloads and usage notes only. The source code is not included and is not open source.

## What It Does

- Opens a lightweight floating panel from the macOS menu bar or a global shortcut.
- Lets you type Chinese with your normal input method.
- Sends confirmed text to your local Ollama service.
- Streams English translation results back into the panel.
- Inserts either the Chinese original or the English result back into the app you were using.
- Falls back to clipboard paste when direct insertion is unavailable.

## Use Cases

Floatype is useful when you think and draft in Chinese, but need to produce natural English quickly:

- writing English emails and work messages
- replying in overseas chat apps or communities
- posting English comments, product notes, and short updates
- polishing Chinese drafts into more natural English
- keeping sensitive drafts local while using a local model
- switching between Chinese input and English output without changing your normal input method

## Privacy

In local mode, Floatype sends text only to the Ollama service running on your own Mac, for example `http://127.0.0.1:11434`. It does not provide a Floatype cloud server, user account, analytics, ads, sync, or translation history.

## Requirements

- macOS 14 or newer
- Apple Silicon recommended
- Ollama installed and running locally
- Recommended model: `qwen3.5:9b`

Install the recommended model:

```bash
ollama pull qwen3.5:9b
```

## Download

Download the latest macOS app from the [Releases](../../releases) page.

After downloading:

1. Unzip `Floatype-macOS.zip`.
2. Move `Floatype.app` to your Applications folder.
3. Open Floatype from Finder.
4. Grant Accessibility permission if you want Floatype to insert text back into other apps automatically.

Because this is a self-signed build, macOS may ask for confirmation the first time you open it.

## Keyboard

- `Command + Z`: open or close the floating panel by default
- `Command + 1`: use Chinese
- `Command + 2`: use English
- `Return`: insert the selected result
- `Escape`: cancel
- `Tab`: translate immediately

## License

Floatype is proprietary software. You may download and use the published app build, but the source code is not open source. See [LICENSE.txt](LICENSE.txt).
