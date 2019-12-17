#!/usr/bin/env bash

flutter upgrade

cd example
flutter clean
cd ..

flutter pub publish && echo "Project was successfully published" || echo "Project wasn't published"
