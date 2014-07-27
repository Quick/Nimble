#!/bin/sh

XCPRETTY= #`which xcpretty`
BUILD_DIR=`pwd`/build

set -e

function run_tests { # scheme, sdk, Debug/Release, destination
    echo "======="
    echo xcodebuild -project Nimble.xcodeproj -scheme $1 -destination "$4" -configuration $3 -sdk $2 clean build test -destination-timeout 5
    echo "======="
    osascript -e 'tell app "iOS Simulator" to quit'
    if [ -z "$XCPRETTY" ]; then
        xcodebuild -project Nimble.xcodeproj -scheme "Nimble-iOS" -configuration "Debug" -sdk "iphonesimulator8.0" -destination "name=iPhone 5s,OS=8.0" -destination-timeout 5 clean build test
    else
        set -o pipefail && xcodebuild $args | $XCPRETTY -c
    fi
}

function test {
    echo "Running ALL iOS and OSX"

    set -x
    osascript -e 'tell app "iOS Simulator" to quit'
    xcodebuild -project Nimble.xcodeproj -scheme "Nimble-iOS" -configuration "Debug" -sdk "iphonesimulator8.0" -destination "name=iPhone 5s,OS=8.0" -destination-timeout 5 build test

    osascript -e 'tell app "iOS Simulator" to quit'
    xcodebuild -project Nimble.xcodeproj -scheme "Nimble-OSX" -configuration "Debug" -sdk "macosx" -destination-timeout 5 build test
    set +x
}

function clean {
    rm -rf ~/Library/Developer/Xcode/DerivedData
}

function main {
    if [ ! -z "$XCPRETTY" ]; then
        echo "XCPretty found. Use 'XCPRETTY= $0' if you want to disable."
    fi

    case "$1" in
        clean) clean ;;
        *) test ;;
    esac
}

main $@

