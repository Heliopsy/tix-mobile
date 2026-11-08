# Design

## Secrets decide, never fail

Each channel's job starts with `scripts/release-secrets.sh`, which reads the channel's secrets from the
environment and writes `true` or `false` to a step output. The rest of the channel's steps are conditional on it.
None of the channel's own secrets set is a notice (the channel is not set up); some set, or its own set but a
shared one missing (the App Store Connect key, the Android keystore), is a warning naming what is missing. The
script never fails, so a repository without store accounts releases exactly what it does today.

## One tool for both stores

fastlane uploads to Google Play (`supply`) and TestFlight (`pilot`). `supply` reads the metadata tree F-Droid
also reads, so one set of store text serves both. Ruby is installed only in the jobs that upload, from
`Gemfile.lock`, through `.github/actions/fastlane`.

## iOS signing: manual secrets, not match

fastlane match keeps certificates in a separate encrypted git repository or bucket with its own passphrase. That
earns its keep for a team sharing identities; for one maintainer it is another repository to create and another
secret to lose. The distribution certificate (`.p12`) and App Store provisioning profile go in as base64 secrets,
the same shape as the Android keystore. The `ios ipa` lane imports them into a throwaway keychain, switches the
Runner target's Release configuration to manual signing on the runner only (the committed project keeps
automatic signing for local builds), fills the team and profile into `ios/ExportOptions.plist`, and runs
`just build-ipa`. The App Store Connect API key uploads; it also notarises macOS, so it is shared.

## macOS notarisation in shell

`scripts/macos-notarize.sh` imports the Developer ID certificate into its own keychain, re-signs nested
frameworks and dylibs deepest first and then the app with `Release.entitlements`, the hardened runtime and a
secure timestamp, submits with `notarytool --wait`, and staples. No `--deep` signing: it would give every
nested library the app's entitlements. The zip asset keeps its name.

## Store changelog

`scripts/store-changelog.sh` cuts the version's section out of `CHANGELOG.md`, drops links and hashes, and
writes at most 500 characters to `changelogs/<versionCode>.txt` at upload time. Nothing is committed, so
release-please stays the only writer of release text.

## The F-Droid build

There is no non-free dependency, so the F-Droid build is not a Gradle product flavour. Flavours would force
`--flavor` onto every Android command, and Flutter's `default-flavor` applies to every platform, so iOS and macOS
would need matching schemes. Instead APKs drop AGP's dependency metadata (`includeInApk = false`, bundles keep
it for Play), CI scans every APK's dex for Play services, Firebase, Play Core and similar, and the recipe builds
plain `flutter build apk --split-per-abi`. Its version codes come from the `+N` release-please increments in
`pubspec.yaml`, plus Flutter's per-ABI offset, so F-Droid's update checker can read them from the source.

libtix is AGPL Go built from source. The hook already reuses a tix checkout it finds in its cache, so the recipe
puts the `tix` srclib there and installs Go from go.dev with its checksum.

## Flathub

The app id stays `red.tix.tix_mobile`, which the GTK application already uses. Renaming it would move every
Linux user's data directory and break window matching for the existing desktop entry. The metainfo lives with
the other Linux packaging files and is installed with the bundle. Its releases come from `CHANGELOG.md` through
`scripts/metainfo-releases.py`, which the Flatpak build runs on the tagged source. Flathub builds offline, so
the manifest is an input to flatpak-flutter, which generates the Flutter SDK and pub sources, plus a list of
tix's Go modules unpacked as `vendor/`.

## Merge queue

The queue rebases, so a release commit keeps its subject, but other entries can sit above it in a group. The
release-files check now asks for the last commit that changed the manifest instead of `HEAD`, and only while
that version has no tag, so a replayed old release commit still fails.
