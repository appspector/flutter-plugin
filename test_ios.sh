#!/bin/bash

set -ex

cd ./example/ios

flutter pub get
pod install
xcodebuild -workspace ./Runner.xcworkspace -scheme Runner -configuration "Debug" -sdk iphonesimulator -destination "id=497E24C9-BD0D-40FB-9C7E-FFE007C787FF" build test
