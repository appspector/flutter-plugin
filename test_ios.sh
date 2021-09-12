#!/bin/bash

set -ex

cd ./example/ios

gem install cocoapods
flutter pub get
flutter build ios
pod install

# Build and test
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd -destination "platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.4" build test
