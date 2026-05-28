# CI/CD for TrailTeller

This repo now has a first-stage GitHub Actions setup for the iOS app. It is intentionally small: prove the app builds, run the tests, and keep deployment secrets out of the repo until you are ready for TestFlight.

## What Runs Now

The workflow lives at `.github/workflows/ios-ci.yml`.

It runs on:

- every push
- every pull request
- manual runs from the GitHub Actions tab

It now has two jobs:

- `build-and-unit-tests`:
  Runs on every push, pull request, and manual run. Executes unit tests only (fast path for PRs).
- `ui-tests`:
  Runs on pushes to `main` and manual runs. Executes UI tests (slower path).

Both jobs use Xcode 16.4 on a macOS 15 runner and target an iOS simulator destination.

### Unit test lane command

```sh
xcodebuild \
  -project TrailTeller.xcodeproj \
  -scheme TrailTeller \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  test \
  -only-testing:TrailTellerTests \
  CODE_SIGNING_ALLOWED=NO
```

### UI test lane command

```sh
xcodebuild \
  -project TrailTeller.xcodeproj \
  -scheme TrailTeller \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  test \
  -only-testing:TrailTellerUITests \
  CODE_SIGNING_ALLOWED=NO
```

`CODE_SIGNING_ALLOWED=NO` keeps CI from needing signing certificates for simulator test lanes. On failure, the workflow uploads result bundles (`TrailTeller-Unit.xcresult` or `TrailTeller-UI.xcresult`) that Xcode can open for details.

### Caching

The workflow restores/saves caches for:

- `.ci/DerivedData`
- `~/.swiftpm`
- `~/Library/Caches/org.swift.swiftpm`

The first run on a branch is usually slower (cache miss). Later runs with similar source/project state usually get faster.

## Why The Shared Scheme Matters

GitHub checks out only committed files. Xcode schemes often start as local user files under `xcuserdata/`, which CI cannot rely on. The committed file at `TrailTeller.xcodeproj/xcshareddata/xcschemes/TrailTeller.xcscheme` makes the app, unit tests, and UI tests visible to GitHub Actions.

## How To Use It

1. Push this branch to GitHub.
2. Open the repository on GitHub.
3. Go to the Actions tab.
4. Open the `iOS CI` workflow run.
5. Treat a green check as "builds and tests pass on a clean Mac."

After the first green run, consider enabling branch protection in GitHub so pull requests cannot merge unless `iOS CI / Build and unit tests` passes.

## What CD Needs Later

Continuous deployment for an iOS app usually means "archive and upload to TestFlight." That part needs Apple account material that should live in GitHub Secrets, not in the repository.

Before adding TestFlight deployment, gather:

- Apple Developer Program access
- an App Store Connect app record for the bundle ID `vkwan.trailteller`
- an App Store Connect API key
- signing setup, usually either manual certificates/profiles in secrets or Fastlane Match

A practical next step is a second workflow that runs only on tags or manual dispatch, archives the app, exports an `.ipa`, and uploads it to TestFlight. Keep that separate from pull request CI so normal contributors do not need signing secrets.

## Keeping Actions Fresh

`.github/dependabot.yml` asks Dependabot to open weekly pull requests when GitHub Actions versions need updates.

## Local Pre-Commit Hooks

This repo also includes `.pre-commit-config.yaml` for local guardrails before code reaches CI.

It runs:

- `swiftformat` on changed `.swift` files at commit time
- `swiftlint lint --strict` on changed `.swift` files at commit time
- `xcodebuild ... build-for-testing` on push (prefers iOS Simulator, falls back to macOS if simulator platform is unavailable)

Hook speed notes:

- `pre-commit` is configured with `fail_fast: true`, so it stops at the first failing hook.
- `swiftlint` runs in script-input-files mode on staged Swift files instead of broad repo linting.
- First run is usually slower than later runs.

Local Xcode platform note:

- The pre-push script is `scripts/pre-push-build-for-testing.sh`.
- It tries `generic/platform=iOS Simulator` first.
- If your local Xcode install does not have iOS Simulator destinations available, it skips the local build gate with a warning so your push is not blocked.
- CI still runs the iOS simulator lanes on GitHub macOS runners.
- Set `PREPUSH_REQUIRE_BUILD=1` to force the hook to fail instead of skip when iOS simulator is unavailable.

Install once on your machine:

```sh
brew install pre-commit swiftformat swiftlint
pre-commit install
pre-commit install --hook-type pre-push
```

Run manually any time:

```sh
pre-commit run --all-files
pre-commit run --hook-stage pre-push --all-files
```
