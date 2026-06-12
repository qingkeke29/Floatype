#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$ROOT_DIR/docs/development-log.md"

{
  echo ""
  echo "## $(date '+%Y-%m-%d %H:%M:%S') Environment Check"
  echo ""
  echo '```text'
  echo "$ uname -m"
  uname -m
  echo ""
  echo "$ sw_vers"
  sw_vers
  echo ""
  echo "$ xcode-select -p"
  xcode-select -p
  echo ""
  echo "$ swift --version"
  swift --version
  echo ""
  echo "$ xcodebuild -version"
  xcodebuild -version
  echo ""
  echo "$ command -v ollama"
  command -v ollama || true
  echo ""
  echo "$ curl http://127.0.0.1:11434/api/tags"
  curl --max-time 5 http://127.0.0.1:11434/api/tags || true
  echo '```'
} >> "$LOG_FILE"

echo "Environment check appended to $LOG_FILE"
