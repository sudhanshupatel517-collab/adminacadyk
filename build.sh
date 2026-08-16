#!/bin/bash
set -e

echo '=== Installing Flutter SDK ==='
if [ ! -d 'flutter' ]; then
  git clone -b stable https://github.com/flutter/flutter.git --depth 1
fi

export PATH="$PATH:$(pwd)/flutter/bin"

flutter --version

echo '=== Getting Dependencies ==='
flutter pub get

echo '=== Building Flutter Web for Production ==='
flutter build web --release --no-wasm-dry-run

echo '=== Build Complete! Output located in build/web ==='
