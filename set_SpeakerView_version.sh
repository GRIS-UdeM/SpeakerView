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

if [[ "$OSTYPE" == "darwin"* ]];then
	sed -i '' "s/const APP_VERSION: String = .*/const APP_VERSION: String = \"$VERSION\"/g" scripts/SpeakerView.gd || exit 1
	sed -i '' "s/application\/short_version=.*/application\/short_version=\"$VERSION\"/g" export_presets.cfg || exit 1
	sed -i '' "s/application\/version=.*/application\/version=\"$VERSION\"/g" export_presets.cfg || exit 1
elif [[ "$OSTYPE" == "msys" ]];then
	sed -i "s/const APP_VERSION: String = .*/const APP_VERSION: String = \"$VERSION\"/g" scripts/SpeakerView.gd || exit 1
	sed -i "s/application\/file_version=.*/application\/file_version=\"$VERSION\"/g" export_presets.cfg || exit 1
	sed -i "s/application\/product_version=.*/application\/product_version=\"$VERSION\"/g" export_presets.cfg || exit 1
fi
