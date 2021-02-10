#!/bin/bash

set -ex

cd ./example/ios

flutter upgrade
flutter pub get
pod install

# Build and test
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd -destination "iPhone 12 Pro Max,OS=14.4" build test
