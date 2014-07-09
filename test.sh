#!/bin/bash

XCPRETTY=`which xcpretty`
BUILD_DIR=`pwd`/build

set -e

function run_tests { # scheme, sdk, destination, Debug/Release
    echo "======="
    echo xcodebuild -project Nimble.xcodeproj -scheme $1 -destination="$3" -configuration $4 -sdk $2 clean build test
    echo "======="
    osascript -e 'tell app "iOS Simulator" to quit'
    if [ -z "$XCPRETTY" ]; then
        xcodebuild -project Nimble.xcodeproj -scheme $1 -destination="$3" -configuration $4 -sdk $2 clean build test
    else
        set -o pipefail && xcodebuild -project Nimble.xcodeproj -scheme $1 -destination="$3" -configuration $4 -sdk $2 clean build test | $XCPRETTY -c
    fi
}

function test_latest {
    echo "Running LATEST iOS and OSX"
    run_tests 'Nimble-iOS' 'iphonesimulator8.0' "name=iPhone Retina (4-inch),OS=8.0", 'Debug'
    run_tests 'Nimble-OSX' 'macosx' "build", 'Debug'
}

function test_full {
    echo "Running ALL iOS and OSX"

    run_tests 'Nimble-iOS' 'iphonesimulator8.0' "name=iPhone Retina (4-inch),OS=8.0", 'Debug'
    run_tests 'Nimble-OSX' 'macosx' "build", 'Debug'

    run_tests 'Nimble-iOS' 'iphonesimulator8.0' "name=iPhone Retina (4-inch),OS=7.1", 'Debug'
    run_tests 'Nimble-iOS' 'iphonesimulator8.0' "name=iPhone Retina (4-inch),OS=8.0", 'Release'
    run_tests 'Nimble-iOS' 'iphonesimulator8.0' "name=iPhone Retina (4-inch),OS=7.1", 'Release'
    run_tests 'Nimble-OSX' 'macosx' "build", 'Release'
}

function main {
    if [ ! -z "$XCPRETTY" ]; then
        echo "XCPretty found. Use 'XCPRETTY= $0' if you want to disable."
    fi

    case "$1" in
        full)
            test_full
            ;;
        *)
            test_latest
            ;;
    esac
}

main $@

