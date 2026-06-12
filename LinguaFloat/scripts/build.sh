#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift build --jobs 1 -c debug

BIN_DIR="$(swift build -c debug --show-bin-path)"
APP_DIR="${FLOATYPE_APP_DIR:-$HOME/Applications/Floatype.app}"
APP_LINK_DIR="$ROOT_DIR/.build/Floatype.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

if [[ "$APP_DIR" != *.app ]]; then
  echo "FLOATYPE_APP_DIR must end with .app: $APP_DIR" >&2
  exit 1
fi

rm -rf "$APP_DIR" "$APP_LINK_DIR" "$ROOT_DIR/.build/LinguaFloat.app"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BIN_DIR/LinguaFloat" "$MACOS_DIR/Floatype"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/Floatype.icns" "$RESOURCES_DIR/Floatype.icns"
cp -R "$ROOT_DIR/Resources/Assets.xcassets" "$RESOURCES_DIR/Assets.xcassets"
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"
xattr -cr "$APP_DIR"
xattr -c "$APP_DIR"
codesign \
  --force \
  --deep \
  --sign - \
  --requirements '=designated => identifier "com.linguafloat.app"' \
  "$APP_DIR"
xattr -cr "$APP_DIR"
xattr -c "$APP_DIR"
codesign --verify --deep --strict "$APP_DIR"
ln -s "$APP_DIR" "$APP_LINK_DIR"

echo "Built $APP_DIR"
echo "Linked $APP_LINK_DIR"
