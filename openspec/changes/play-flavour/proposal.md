# Proposal

## Why

The Google Play build never checked for updates. Play's in-app update API lives in Google's Play Core library,
which `scripts/fdroid-check.sh` rejects, and the Play bundle and the APKs for GitHub, Obtainium and F-Droid came out
of one Gradle build, so adding Play Core anywhere meant adding it everywhere. People on Play only learnt of a new
version when Play itself got round to it.

## What Changes

- Android gets two Gradle product flavours of the same app, same application id `red.tix.tix_mobile`, same signing
  and the same version codes: `oss` (the APKs on GitHub releases and Obtainium, and what F-Droid builds) and `play`
  (the App Bundle for Google Play). Play Core (`com.google.android.play:app-update`) is a `playImplementation`
  dependency used only from `android/app/src/play/`.
- The play flavour answers a `tix/play-update` MethodChannel from Kotlin with AppUpdateManager: whether an update
  is available and its version code, and a start that runs a FLEXIBLE in-app update where Play allows one, else
  opens the Play listing. `src/oss/` has a stand-in with the same members that answers null. No Dart plugin.
- Dart picks the distribution from `--dart-define=TIX_DISTRIBUTION=github|fdroid|play`. The Play build uses the
  `store` update mode backed by Play's answer, with Play wording; F-Droid stays off; the GitHub APK is unchanged.
  The channel client is behind a constant, so it is compiled out of everything but the Play build.
- Notifications reuse the once-per-version notice; the Play version code maps back to the version, so it is once
  per version code. Tapping it starts Play's flexible update (or opens the listing).
- Android's background update worker asks AppUpdateManager in the play flavour and hands the answer to the
  headless Dart run in its link, so Play installs are notified while the app is closed too.
- `just build-apk` and `just build-fdroid` build `--flavor oss`, `just build-aab` builds `--flavor play`. Release
  file names stay the same. CI also builds the play bundle on main (and on pull requests touching Android or the
  update code). The F-Droid recipe builds oss.

## Impact

- Capabilities: `self-update`, `release-channels`.
- Code: `android/app/build.gradle.kts`, `android/app/src/{oss,play}/kotlin/.../update/PlayUpdate.kt`,
  `MainActivity.kt`, `widgets/Receivers.kt`, `lib/src/data/update/{play_feed,updater}.dart`,
  `lib/src/core/update/{play_updates,updates,update_notice}.dart`, the update panel, Settings and `DesktopHost`,
  `lib/main.dart`, l10n.
- Build: `justfile`, `.github/build-matrix.json`, `.github/workflows/{ci,release}.yaml`,
  `fdroid/red.tix.tix_mobile.yml`, `scripts/fdroid-check.sh` (comment only).
- Docs: `docs/releasing.md`, `docs/architecture.md`, `docs/development.md`, `README.md`.
- Every Android `flutter run` and `flutter build` now names a flavour (`--flavor oss` for day-to-day work).
