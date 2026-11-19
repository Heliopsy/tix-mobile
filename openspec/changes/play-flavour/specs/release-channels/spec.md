# release-channels

## MODIFIED Requirements

### Requirement: APKs carry no non-free code

Every oss Android build in CI SHALL fail if an APK contains code from Google Play services, Firebase, the Play Core libraries or the other proprietary SDKs F-Droid rejects. APKs SHALL NOT carry AGP's encrypted dependency metadata.

#### Scenario: Non-free dependency added

- **WHEN** a pull request adds a dependency that pulls in Play services to the oss build
- **THEN** the Android build fails naming the package

## ADDED Requirements

### Requirement: Separate Play and oss flavours

Android SHALL build as two Gradle flavours of one app with the same application id, signing and version codes: `oss` for the APKs on GitHub releases and the F-Droid build, and `play` for the Google Play App Bundle. Play Core SHALL be a dependency of the play flavour only. Release file names SHALL stay `tix-mobile-X.Y.Z-android-ABI.apk` and `tix-mobile-X.Y.Z-android.aab`.

#### Scenario: Release

- **WHEN** a release builds Android
- **THEN** the APKs come from the oss flavour and pass the non-free check, and the App Bundle comes from the play flavour

#### Scenario: F-Droid

- **WHEN** F-Droid builds a release that has the flavours
- **THEN** it builds the oss flavour with `TIX_DISTRIBUTION=fdroid`
