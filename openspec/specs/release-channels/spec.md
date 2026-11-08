# release-channels Specification

## Purpose
How a tagged release reaches people beyond its GitHub assets: the release pull request through the merge queue, TestFlight, a notarised macOS download, Google Play, F-Droid and Flathub, each switched on by its secrets alone.

## Requirements

### Requirement: Channels without secrets are skipped

Each store channel of the release workflow SHALL run only when every secret it needs exists. A channel with none
of its own secrets SHALL be skipped with a notice, and one with only some SHALL be skipped with a warning that
names the missing secrets. A skipped channel SHALL NOT fail the release or hold back the GitHub release.

#### Scenario: No store accounts

- **WHEN** a release runs in a repository with none of the store secrets
- **THEN** every GitHub release asset is published and each store step reports a skip notice

#### Scenario: Half-finished setup

- **WHEN** the iOS certificate secret is set but the provisioning profile secret is not
- **THEN** the iOS job builds unsigned and warns that `IOS_PROFILE_BASE64` is missing

### Requirement: Release pull requests go through the merge queue

When the release GitHub App's credentials exist, release-please SHALL open and update the release pull request
with the App's token, so its required checks run without approval and it can be merged by the merge queue
without an admin.

#### Scenario: App configured

- **WHEN** a push to main updates the release pull request and the App credentials exist
- **THEN** the pull request's checks start on their own

### Requirement: Release files check accepts a queued release commit

The release-files check SHALL pass when the last commit that changed the manifest is the release commit for the
manifest's version and that version has no tag yet, even when other commits sit above it. A manifest naming a
version that is tagged SHALL still have to match the newest tag.

#### Scenario: Release commit below another pull request

- **WHEN** a merge group holds the release commit for 0.5.0 and another pull request above it, and v0.5.0 is not
  tagged
- **THEN** the release-files check passes

### Requirement: iOS releases reach TestFlight

With the iOS signing secrets and the App Store Connect API key, the release SHALL build an App Store signed IPA
that carries libtix and upload it to TestFlight. Without them it SHALL build the app unsigned as a workflow
artifact. No iOS file SHALL be attached to the GitHub release.

#### Scenario: Signed build

- **WHEN** a release runs with every iOS secret set
- **THEN** a signed IPA with libtix is uploaded to TestFlight

### Requirement: The macOS download is notarised

With a Developer ID certificate and the App Store Connect API key, the macOS app SHALL be signed with the
hardened runtime, notarised and stapled before it is zipped. Without them it SHALL stay ad-hoc signed.

#### Scenario: Notarised zip

- **WHEN** a release runs with the macOS signing secrets
- **THEN** the zip asset holds an app that `spctl` accepts and that carries a stapled ticket

### Requirement: Google Play internal track

With `PLAY_SERVICE_ACCOUNT_JSON` and a release-signed App Bundle, the release SHALL upload the bundle to the
internal track after the GitHub release is published, with the store text from `fastlane/metadata/android` and
a changelog made from the version's `CHANGELOG.md` section, at most 500 characters.

#### Scenario: Debug-signed bundle

- **WHEN** the Play secret exists but the Android keystore secret does not
- **THEN** the upload is skipped with a warning instead of failing

### Requirement: Store text in four languages

Store listing text SHALL exist in English, Bulgarian, French and German, within Google Play's limits of 30
characters for the title and 80 for the short description, and SHALL claim only what the README states.

#### Scenario: Limits

- **WHEN** any locale's title or short description is measured in characters
- **THEN** it is within the limit

### Requirement: APKs carry no non-free code

Every Android build in CI SHALL fail if an APK contains code from Google Play services, Firebase, the Play Core
libraries or the other proprietary SDKs F-Droid rejects. APKs SHALL NOT carry AGP's encrypted dependency
metadata.

#### Scenario: Non-free dependency added

- **WHEN** a pull request adds a dependency that pulls in Play services
- **THEN** the Android build fails naming the package

### Requirement: Linux bundles carry AppStream metadata

The Linux bundle SHALL install AppStream metainfo for `red.tix.tix_mobile` that passes `appstreamcli validate`,
with one release entry per `CHANGELOG.md` version, and a Flatpak manifest SHALL build the app and libtix from
source.

#### Scenario: Release listed

- **WHEN** the metainfo releases are regenerated after release-please writes 0.5.0 to the changelog
- **THEN** the metainfo lists 0.5.0 with its date
