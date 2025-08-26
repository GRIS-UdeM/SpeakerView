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
xcrun altool --notarize-app -t osx -f "$NAME.zip" --primary-bundle-id "$MACOSX_BUNDLE_ID" -u "$MACOSX_APPLE_ID" -p "$MACOSX_APPLE_PASSWORD" --output-format xml > /tmp/notarize-app.xml
rm -f "$NAME.zip"
NUUID=`/usr/libexec/PlistBuddy -c 'Print :notarization-upload:RequestUUID' /tmp/notarize-app.xml`
if [ -z "${NUUID}" ]; then
    cat /tmp/notarize-app.xml
    die "* error: no RequestUUID found in upload response"
fi
echo "RequestUUID: ${NUUID}"

echo "Waiting for notarization to complete..."
while true; do
    xcrun altool --notarization-info ${NUUID} -u "$MACOSX_APPLE_ID" -p "$MACOSX_APPLE_PASSWORD" --output-format xml > /tmp/notarize-info.xml
    NSTAT=`/usr/libexec/PlistBuddy -c 'Print :notarization-info:Status' /tmp/notarize-info.xml`
    echo "  `date "+%H:%M:%S"` ${NSTAT}"
    if [ -z "${NUUID}" ]; then
        cat /tmp/notarize-info.xml
        die "* error: no Status found in info response"
    fi

    if [ "${NSTAT}" == "invalid" ]; then
        cat /tmp/notarize-info.xml
        die "* error: error notarizing app"
    fi

    if [ "${NSTAT}" == "success" ]; then
        break
    fi
    sleep 30s
done

echo "Stapling ticket to app..."
xcrun stapler staple "$NAME"

rm /tmp/notarize-*.xml
