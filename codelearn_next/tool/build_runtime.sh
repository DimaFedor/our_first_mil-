#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"
flutter pub get
flutter gen-l10n
dart run tool/validate_content.dart
dart compile js -O2 tool/practice_worker.dart -o assets/runtime/practice_worker.js
npm ci --prefix tool/runtime --ignore-scripts
npm run build --prefix tool/runtime
