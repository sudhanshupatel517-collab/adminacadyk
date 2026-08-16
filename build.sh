#!/bin/bash
set -e

echo '=== Checking Build Output ==='
git config --global --add safe.directory "*" || true

if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
  echo '✅ Production Flutter Web release bundle found in build/web.'
  echo '=== Ready for Instant Vercel Deployment! ==='
  exit 0
fi

echo '=== Flutter SDK Build Required ==='
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz -o /tmp/flutter.tar.xz
tar -xf /tmp/flutter.tar.xz -C /tmp/
export PATH="$PATH:/tmp/flutter/bin"
flutter config --no-analytics
flutter precache --web
flutter pub get
flutter build web --release --no-wasm-dry-run
