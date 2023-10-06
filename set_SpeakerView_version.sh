#!/bin/sh

# Developer: Gaël Lane Lépine

#==============================================================================
export USAGE="usage: set_Speaker_version <version>"
export VERSION=""

#==============================================================================
# Parse args

# POSITIONAL=()
while [[ $# -gt 0 ]]
do
VERSION="$1"
shift

done

if [[ "$VERSION" == "" ]];then
	echo "Missing version number"
	echo -e "$USAGE"
	exit 1
fi

#==============================================================================
# Set SpeakerView version in files

sed -i "s/const APP_VERSION = .*/const APP_VERSION = \"$VERSION\"/g" scripts/SpeakerView.gd || exit 1
sed -i "s/application\/file_version=.*/application\/file_version=\"$VERSION\"/g" export_presets.cfg || exit 1
sed -i "s/application\/product_version=.*/application\/product_version=\"$VERSION\"/g" export_presets.cfg || exit 1
