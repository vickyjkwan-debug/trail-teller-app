#!/usr/bin/env bash
set -euo pipefail

PROJECT="TrailTeller.xcodeproj"
SCHEME="TrailTeller"
CONFIGURATION="Debug"

SHOW_DESTINATIONS_CMD=(
  xcodebuild
  -project "$PROJECT"
  -scheme "$SCHEME"
  -showdestinations
)

BUILD_CMD=(
  xcodebuild
  -project "$PROJECT"
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  build-for-testing
  CODE_SIGNING_ALLOWED=NO
)

DESTINATIONS="$("${SHOW_DESTINATIONS_CMD[@]}")"

if grep -q "platform:iOS Simulator" <<<"$DESTINATIONS"; then
  echo "pre-push: running build-for-testing on iOS Simulator"
  "${BUILD_CMD[@]}" -destination "generic/platform=iOS Simulator"
  exit 0
fi

if grep -q "platform:macOS" <<<"$DESTINATIONS"; then
  echo "pre-push: iOS Simulator destination unavailable on this machine."
  echo "pre-push: falling back to macOS build-for-testing so push is not blocked."
  echo "pre-push: install iOS platform/runtimes in Xcode to restore full local iOS gate."
  "${BUILD_CMD[@]}" -destination "generic/platform=macOS"
  exit 0
fi

echo "pre-push: no supported destination found for scheme '$SCHEME'."
echo "$DESTINATIONS"
exit 70
