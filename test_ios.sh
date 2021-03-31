#!/bin/bash

set -ex

cd ./example/ios

flutter pub get
gem install cocoapods
pod install

# Build and test
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd -destination "platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.4" build test
