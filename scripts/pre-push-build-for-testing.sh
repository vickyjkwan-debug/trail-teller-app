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

echo "pre-push: iOS Simulator destination unavailable on this machine."
echo "pre-push: skipping local build-for-testing gate to avoid false failures."
echo "pre-push: CI on GitHub still runs iOS simulator checks."
echo "pre-push: install iOS platform/runtimes in Xcode to restore full local gate."

if [[ "${PREPUSH_REQUIRE_BUILD:-0}" == "1" ]]; then
  echo "pre-push: PREPUSH_REQUIRE_BUILD=1 is set, so failing instead of skipping."
  exit 70
fi

exit 0
