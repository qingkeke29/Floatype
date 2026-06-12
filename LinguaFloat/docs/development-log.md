# Floatype（浮译） Development Log

## 2026-06-10 Environment Check

- `uname -m`: `arm64`
- `sw_vers`: macOS 26.5.1, build 25F80
- `xcode-select -p`: `/Applications/Xcode.app/Contents/Developer`
- `swift --version`: Apple Swift 6.3.2, target arm64-apple-macosx26.0
- `xcodebuild -version`: Xcode 26.5, build 17F42
- `command -v ollama`: `/Users/wanghaixu/.local/bin/ollama`
- `curl http://127.0.0.1:11434/api/tags`: Ollama is reachable. Installed models include `qwen2.5:7b`, `qwen2.5:3b`, `glm-5.1:cloud`, `qwen3.5:9b`, and `qwen3.5:latest`.

Note: `qwen3.5:9b` was listed by Ollama during this check, so LinguaFloat now uses it as the default local model.

## 2026-06-10 20:32:23 Environment Check

```text
$ uname -m
arm64

$ sw_vers
ProductName:		macOS
ProductVersion:		26.5.1
BuildVersion:		25F80

$ xcode-select -p
/Applications/Xcode.app/Contents/Developer

$ swift --version
Apple Swift version 6.3.2 (swiftlang-6.3.2.1.108 clang-2100.1.1.101)
Target: arm64-apple-macosx26.0

$ xcodebuild -version
Xcode 26.5
Build version 17F42

$ command -v ollama
/usr/local/bin/ollama

$ curl http://127.0.0.1:11434/api/tags
{"models":[{"name":"qwen2.5:7b","model":"qwen2.5:7b","modified_at":"2026-06-05T12:44:41.355370838+08:00","size":4683087332,"digest":"845dbda0ea48ed749caafd9e6037047aa19acfcfd82e704d7ca97d631a0b697e","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"7.6B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":3584},"capabilities":["completion","tools"]},{"name":"qwen2.5:3b","model":"qwen2.5:3b","modified_at":"2026-06-05T04:48:35.087174489+08:00","size":1929912432,"digest":"357c53fb659c5076de1d65ccb0b397446227b71a42be9d1603d46168015c9e4b","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"3.1B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":2048},"capabilities":["completion","tools"]},{"name":"glm-5.1:cloud","model":"glm-5.1:cloud","remote_model":"glm-5.1","remote_host":"https://ollama.com:443","modified_at":"2026-04-21T21:18:01.522141188+08:00","size":327,"digest":"59472abf9d0aab2eb1b0106ba1c1f59266a00ed41f63d2a2b1db082e7346b982","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":"","context_length":202752},"capabilities":["completion","tools","thinking"]},{"name":"qwen3.5:9b","model":"qwen3.5:9b","modified_at":"2026-04-16T22:25:02.755951897+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]},{"name":"qwen3.5:latest","model":"qwen3.5:latest","modified_at":"2026-04-16T19:44:18.349145861+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]}]}```

## 2026-06-11 23:38:18 Environment Check

```text
$ uname -m
arm64

$ sw_vers
ProductName:		macOS
ProductVersion:		26.5.1
BuildVersion:		25F80

$ xcode-select -p
/Applications/Xcode.app/Contents/Developer

$ swift --version
Apple Swift version 6.3.2 (swiftlang-6.3.2.1.108 clang-2100.1.1.101)
Target: arm64-apple-macosx26.0

$ xcodebuild -version
Xcode 26.5
Build version 17F42

$ command -v ollama
/usr/local/bin/ollama

$ curl http://127.0.0.1:11434/api/tags
{"models":[{"name":"qwen2.5:7b","model":"qwen2.5:7b","modified_at":"2026-06-05T12:44:41.355370838+08:00","size":4683087332,"digest":"845dbda0ea48ed749caafd9e6037047aa19acfcfd82e704d7ca97d631a0b697e","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"7.6B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":3584},"capabilities":["completion","tools"]},{"name":"qwen2.5:3b","model":"qwen2.5:3b","modified_at":"2026-06-05T04:48:35.087174489+08:00","size":1929912432,"digest":"357c53fb659c5076de1d65ccb0b397446227b71a42be9d1603d46168015c9e4b","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"3.1B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":2048},"capabilities":["completion","tools"]},{"name":"glm-5.1:cloud","model":"glm-5.1:cloud","remote_model":"glm-5.1","remote_host":"https://ollama.com:443","modified_at":"2026-04-21T21:18:01.522141188+08:00","size":327,"digest":"59472abf9d0aab2eb1b0106ba1c1f59266a00ed41f63d2a2b1db082e7346b982","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":"","context_length":202752},"capabilities":["completion","tools","thinking"]},{"name":"qwen3.5:9b","model":"qwen3.5:9b","modified_at":"2026-04-16T22:25:02.755951897+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]},{"name":"qwen3.5:latest","model":"qwen3.5:latest","modified_at":"2026-04-16T19:44:18.349145861+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]}]}```

## 2026-06-12 12:51:17 Environment Check

```text
$ uname -m
arm64

$ sw_vers
ProductName:		macOS
ProductVersion:		26.5.1
BuildVersion:		25F80

$ xcode-select -p
/Applications/Xcode.app/Contents/Developer

$ swift --version
Apple Swift version 6.3.2 (swiftlang-6.3.2.1.108 clang-2100.1.1.101)
Target: arm64-apple-macosx26.0

$ xcodebuild -version
Xcode 26.5
Build version 17F42

$ command -v ollama
/usr/local/bin/ollama

$ curl http://127.0.0.1:11434/api/tags
{"models":[{"name":"qwen2.5:7b","model":"qwen2.5:7b","modified_at":"2026-06-05T12:44:41.355370838+08:00","size":4683087332,"digest":"845dbda0ea48ed749caafd9e6037047aa19acfcfd82e704d7ca97d631a0b697e","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"7.6B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":3584},"capabilities":["completion","tools"]},{"name":"qwen2.5:3b","model":"qwen2.5:3b","modified_at":"2026-06-05T04:48:35.087174489+08:00","size":1929912432,"digest":"357c53fb659c5076de1d65ccb0b397446227b71a42be9d1603d46168015c9e4b","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"3.1B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":2048},"capabilities":["completion","tools"]},{"name":"glm-5.1:cloud","model":"glm-5.1:cloud","remote_model":"glm-5.1","remote_host":"https://ollama.com:443","modified_at":"2026-04-21T21:18:01.522141188+08:00","size":327,"digest":"59472abf9d0aab2eb1b0106ba1c1f59266a00ed41f63d2a2b1db082e7346b982","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":"","context_length":202752},"capabilities":["completion","tools","thinking"]},{"name":"qwen3.5:9b","model":"qwen3.5:9b","modified_at":"2026-04-16T22:25:02.755951897+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]},{"name":"qwen3.5:latest","model":"qwen3.5:latest","modified_at":"2026-04-16T19:44:18.349145861+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]}]}```

## 2026-06-12 23:59:41 Environment Check

```text
$ uname -m
arm64

$ sw_vers
ProductName:		macOS
ProductVersion:		26.5.1
BuildVersion:		25F80

$ xcode-select -p
/Applications/Xcode.app/Contents/Developer

$ swift --version
Apple Swift version 6.3.2 (swiftlang-6.3.2.1.108 clang-2100.1.1.101)
Target: arm64-apple-macosx26.0

$ xcodebuild -version
Xcode 26.5
Build version 17F42

$ command -v ollama
/usr/local/bin/ollama

$ curl http://127.0.0.1:11434/api/tags
{"models":[{"name":"qwen2.5:7b","model":"qwen2.5:7b","modified_at":"2026-06-05T12:44:41.355370838+08:00","size":4683087332,"digest":"845dbda0ea48ed749caafd9e6037047aa19acfcfd82e704d7ca97d631a0b697e","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"7.6B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":3584},"capabilities":["completion","tools"]},{"name":"qwen2.5:3b","model":"qwen2.5:3b","modified_at":"2026-06-05T04:48:35.087174489+08:00","size":1929912432,"digest":"357c53fb659c5076de1d65ccb0b397446227b71a42be9d1603d46168015c9e4b","details":{"parent_model":"","format":"gguf","family":"qwen2","families":["qwen2"],"parameter_size":"3.1B","quantization_level":"Q4_K_M","context_length":32768,"embedding_length":2048},"capabilities":["completion","tools"]},{"name":"glm-5.1:cloud","model":"glm-5.1:cloud","remote_model":"glm-5.1","remote_host":"https://ollama.com:443","modified_at":"2026-04-21T21:18:01.522141188+08:00","size":327,"digest":"59472abf9d0aab2eb1b0106ba1c1f59266a00ed41f63d2a2b1db082e7346b982","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":"","context_length":202752},"capabilities":["completion","tools","thinking"]},{"name":"qwen3.5:9b","model":"qwen3.5:9b","modified_at":"2026-04-16T22:25:02.755951897+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]},{"name":"qwen3.5:latest","model":"qwen3.5:latest","modified_at":"2026-04-16T19:44:18.349145861+08:00","size":6594474711,"digest":"6488c96fa5faab64bb65cbd30d4289e20e6130ef535a93ef9a49f42eda893ea7","details":{"parent_model":"","format":"gguf","family":"qwen35","families":["qwen35"],"parameter_size":"9.7B","quantization_level":"Q4_K_M","context_length":262144,"embedding_length":4096},"capabilities":["vision","completion","tools","thinking"]}]}```
