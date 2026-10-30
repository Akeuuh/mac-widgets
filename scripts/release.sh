#!/bin/bash
# Usage: scripts/release.sh 0.1.0
# Prérequis : Xcode connecté au compte Apple Developer, et un profil notarytool
# enregistré via `xcrun notarytool store-credentials mac-widgets`.
set -euo pipefail

VERSION="$1"
NOTARY_PROFILE="${NOTARY_PROFILE:-mac-widgets}"
BUILD=build
DMG="$BUILD/MacWidgets-$VERSION.dmg"

rm -rf "$BUILD"
xcodegen generate
xcodebuild -project MacWidgets.xcodeproj -scheme MacWidgets -configuration Release \
    -archivePath "$BUILD/MacWidgets.xcarchive" MARKETING_VERSION="$VERSION" \
    -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath "$BUILD/MacWidgets.xcarchive" \
    -exportPath "$BUILD/export" -exportOptionsPlist scripts/ExportOptions.plist \
    -allowProvisioningUpdates

hdiutil create -volname "Mac Widgets" -srcfolder "$BUILD/export/MacWidgets.app" -ov -format UDZO "$DMG"
codesign -d --extract-certificates="$BUILD/cert" "$BUILD/export/MacWidgets.app"
codesign --sign "$(shasum "$BUILD/cert0" | cut -d' ' -f1)" --timestamp "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"

echo "sha256 $(shasum -a 256 "$DMG" | cut -d' ' -f1)"
echo "gh release create v$VERSION $DMG"
