# CI/CD for TrailTeller

This repo now has a first-stage GitHub Actions setup for the iOS app. It is intentionally small: prove the app builds, run the tests, and keep deployment secrets out of the repo until you are ready for TestFlight.

## What Runs Now

The workflow lives at `.github/workflows/ios-ci.yml`.

It runs on:

- every push
- every pull request
- manual runs from the GitHub Actions tab

The job checks out the repo, selects Xcode 16.4 on a macOS 15 runner, and runs:

```sh
xcodebuild \
  -project TrailTeller.xcodeproj \
  -scheme TrailTeller \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  test \
  CODE_SIGNING_ALLOWED=NO
```

`CODE_SIGNING_ALLOWED=NO` keeps normal pull request CI from needing Apple signing certificates. If tests fail, the workflow uploads a `TrailTeller.xcresult` artifact that Xcode can open for details.

## Why The Shared Scheme Matters

GitHub checks out only committed files. Xcode schemes often start as local user files under `xcuserdata/`, which CI cannot rely on. The committed file at `TrailTeller.xcodeproj/xcshareddata/xcschemes/TrailTeller.xcscheme` makes the app, unit tests, and UI tests visible to GitHub Actions.

## How To Use It

1. Push this branch to GitHub.
2. Open the repository on GitHub.
3. Go to the Actions tab.
4. Open the `iOS CI` workflow run.
5. Treat a green check as "builds and tests pass on a clean Mac."

After the first green run, consider enabling branch protection in GitHub so pull requests cannot merge unless `iOS CI / Build and test` passes.

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
