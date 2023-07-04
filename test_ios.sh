#!/bin/bash

set -ex

cd ./example/ios

flutter pub get
pod install

# Build and test
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd -destination "platform=iOS Simulator,name=iPhone 13 Pro Max,OS=16.2" build test
