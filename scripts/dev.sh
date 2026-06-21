#!/bin/bash
set -euo pipefail

# Builds and runs a local dev build of BetterMaccy.
#
# Signs with the same Developer ID identity as distribution builds so the
# macOS Accessibility grant (required for paste) carries over — ad-hoc
# signatures change on every rebuild and silently lose the grant. The raw
# xcodebuild output also fails to launch outright: the prebuilt Sparkle
# framework keeps its original Team ID, which library validation rejects,
# so its nested binaries are re-signed here too.

cd "$(dirname "$0")/.."

IDENTITY="Developer ID Application: José Miranda (L228C8LS8X)"

# DEV_BUILD forces the clipboard menu bar icon so the dev instance is
# visually distinguishable from the installed release build.
xcodebuild -project BetterMaccy.xcodeproj -scheme BetterMaccy -configuration Release \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) DEV_BUILD' \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES build

APP=$(find ~/Library/Developer/Xcode/DerivedData/BetterMaccy-*/Build/Products/Release -maxdepth 1 -name BetterMaccy.app | head -1)

SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
for target in \
  "$SPARKLE/Versions/B/XPCServices/Downloader.xpc" \
  "$SPARKLE/Versions/B/XPCServices/Installer.xpc" \
  "$SPARKLE/Versions/B/Autoupdate" \
  "$SPARKLE/Versions/B/Updater.app" \
  "$SPARKLE" \
  "$APP"; do
  codesign --force --preserve-metadata=entitlements --sign "$IDENTITY" "$target"
done

codesign --verify --deep --strict "$APP"

pkill -x BetterMaccy 2>/dev/null && sleep 1 || true
open "$APP"
echo "Running dev build: $APP"
echo "Switch back with: pkill -x BetterMaccy && open /Applications/BetterMaccy.app"
