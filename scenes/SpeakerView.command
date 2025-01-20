#!/bin/sh
echo -ne '\033c\033]0;SpeakerView\a'

function app_realpath() {
    SOURCE=$1
    while [ -h "$SOURCE" ]; do
        DIR=$(dirname "$SOURCE")
        SOURCE=$(readlink "$SOURCE")
        [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
    done
    echo "$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
}

BASE_PATH="$(app_realpath "${BASH_SOURCE[0]}")"
"$BASE_PATH/SpeakerView.app/Contents/MacOS/SpeakerView" "$@"

