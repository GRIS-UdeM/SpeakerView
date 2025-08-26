#!/bin/bash

die() {
	echo "$@" >/dev/stderr
	exit 1
}

if [ -z "$MACOSX_SIGNATURE_IDENTITY" -o -z "$MACOSX_BUNDLE_ID" -o -z "$MACOSX_APPLE_ID" -o -z "$MACOSX_APPLE_PASSWORD" ]; then
	die "Missing required variable"
fi

NAME=$(basename "$1")
WORKDIR=$(dirname "$1")

if [ -n "$2" ]; then
	ENTITLEMENTS="--entitlements $2"
else
	ENTITLEMENTS=""
fi

cd "$WORKDIR"
rm -f /tmp/notarize-*.xml

echo "Signing..."
codesign -vvv --force --deep --strict --sign "$MACOSX_SIGNATURE_IDENTITY" --options runtime $ENTITLEMENTS --timestamp "$NAME" \
	|| die "Failed to sign app"

echo "Uploading for notarization..."
zip -r "$NAME.zip" "$NAME"
xcrun notarytool submit "$NAME.zip" \
              --team-id "62PMMWH49Z" \
              --apple-id "glanelepine@gmail.com" \
              --password "$MACOSX_APPLE_PASSWORD" \
              --progress \
              --wait

echo "Stapling ticket to app..."
xcrun stapler staple "$NAME"

#rm /tmp/notarize-*.xml
