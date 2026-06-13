# Local And Custom API Model Design

## Goal

Let Floatype support two translation model sources that are configured only in Settings:

- Local Ollama models
- Custom OpenAI-compatible API models

The floating panel should use the saved configuration and display the active source/model, but it should not allow users to change model source, URL, API key, or model name from the panel.

## Settings Behavior

Settings adds a model source selector with two choices: "本地 Ollama" and "自定义 API". The default remains "本地 Ollama" so existing local-model users keep the current behavior.

For local Ollama, Settings keeps the Ollama URL field, defaulting to `http://127.0.0.1:11434`. It adds a model picker backed by `/api/tags` and a refresh action that reads installed models from the configured Ollama service. The user can also type a model name manually when the model is on a remote Ollama server or has not been pulled yet.

For custom API, Settings shows API URL, API Key, and model name fields. The API is treated as OpenAI-compatible. API Key is optional at the storage layer, but requests include `Authorization: Bearer <key>` whenever the field is non-empty.

The custom API URL field accepts either a chat completions endpoint or a base URL:

- URLs ending in `/chat/completions` are used as entered.
- URLs ending in `/v1` are normalized by appending `/chat/completions`.
- Other URLs are normalized by appending `/v1/chat/completions`.

Settings includes a connection test for the currently selected source. Local mode tests the Ollama service and selected model. Custom API mode sends a lightweight chat completion request using the configured URL, key, and model. Save validates required fields for the selected source and keeps invalid values visible with an inline message instead of silently closing.

## Provider Architecture

AppSettings persists a model source enum plus source-specific configuration:

- local Ollama URL
- local Ollama model
- custom API URL
- custom API key
- custom API model

The app builds the active provider from the saved model source when launching. Local mode uses the existing Ollama provider. Custom API mode uses a new OpenAI-compatible provider that supports streaming chat completions and maps API errors to user-facing provider statuses.

The provider interface remains the boundary used by the floating panel. The panel should not know how Settings stores API keys or how each provider constructs requests.

## Floating Panel Behavior

The floating panel continues to open directly into the writing workflow. It shows the active provider/model in the existing model label, for example `Ollama · qwen3.5:9b` or `API · deepseek-chat`.

The panel does not include source switching, model switching, URL editing, API key editing, or a shortcut to cycle models. The gear button remains the path to Settings.

If the active source is unavailable, the panel shows a clear status message:

- local service unavailable
- local model missing
- custom API URL unavailable
- API key rejected
- custom model rejected or unavailable

The panel must not display the API key or include it in copyable error text.

## Request Behavior

Ollama mode keeps the current `/api/chat` streaming request, prompt generation, markdown cleanup, cancellation, and status flow.

Custom API mode sends the same translation prompt through an OpenAI-compatible chat completions request. It prefers streaming responses so the English output can appear progressively. If the endpoint returns a non-streaming completion, the provider can still display the final text after the response completes.

Both providers use the same translation style prompt and the same final translation sanitizer. Logs must never include source text, translated text, API keys, or full request bodies.

## Error Handling

Invalid or empty required fields are caught in Settings before save for the selected source. Runtime failures are surfaced through ProviderStatus and should be short enough to fit the floating panel status area.

Local model refresh failures leave the existing selected model untouched and show an inline Settings message. Custom API test failures also leave saved settings untouched until the user explicitly saves valid-looking values.

Changing settings should affect new panel openings and future translations. If the panel is already open, the app can require closing and reopening the panel for source changes to take effect in this version.

## Verification

Automated tests should cover:

- model source defaulting to local Ollama
- persistence of local and custom API settings
- local model list parsing from Ollama `/api/tags`
- OpenAI-compatible request body shape
- Authorization header inclusion only when an API key is present
- streaming custom API response parsing
- non-streaming custom API response parsing
- Settings validation for required fields

Existing tests for translation prompts, Ollama request `think: false`, output selection, pasteboard restore, hotkey settings, and panel behavior should continue to pass.

Manual verification should confirm:

- local mode can refresh installed Ollama models
- local mode can save a manually typed model
- custom API mode saves URL, key, and model from Settings only
- the floating panel displays the active source/model but cannot change them
- translation works through local Ollama
- translation works through a configured OpenAI-compatible API
- failed API key or wrong model produces a clear error without exposing secrets
