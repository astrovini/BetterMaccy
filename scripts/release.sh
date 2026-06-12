#!/bin/bash
set -euo pipefail

# Builds, signs, notarizes, and packages Maccy for distribution.
#
# Prerequisites:
#   - "Developer ID Application" certificate in the keychain
#   - notarytool keychain profile: xcrun notarytool store-credentials maccy-notary ...
#
# Output: dist/Maccy-<version>.zip (notarized and stapled) and its sha256.

cd "$(dirname "$0")/.."

IDENTITY="Developer ID Application: José Miranda (L228C8LS8X)"
TEAM_ID="L228C8LS8X"
PROFILE="maccy-notary"
OUT=dist

VERSION=$(xcodebuild -project Maccy.xcodeproj -showBuildSettings -configuration Release 2>/dev/null \
  | awk '/MARKETING_VERSION/ { print $3; exit }')
echo "==> Building Maccy $VERSION"

rm -rf "$OUT"
mkdir -p "$OUT"

xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Release \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_IDENTITY="$IDENTITY" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  build

APP=$(find ~/Library/Developer/Xcode/DerivedData/Maccy-*/Build/Products/Release -maxdepth 1 -name Maccy.app | head -1)
cp -R "$APP" "$OUT/"

echo "==> Verifying signature"
codesign --verify --deep --strict "$OUT/Maccy.app"

ZIP="$OUT/Maccy-$VERSION.zip"
ditto -c -k --keepParent "$OUT/Maccy.app" "$ZIP"

echo "==> Notarizing (takes a few minutes)"
xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait

echo "==> Stapling notarization ticket"
xcrun stapler staple "$OUT/Maccy.app"

# Re-zip so the published archive contains the stapled app
rm "$ZIP"
ditto -c -k --keepParent "$OUT/Maccy.app" "$ZIP"

echo "==> Done: $ZIP"
shasum -a 256 "$ZIP"
