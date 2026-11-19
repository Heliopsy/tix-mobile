# Design

## Flavours, not a Gradle property

A `-PtixDistribution=play` switch would have kept Flutter's output names and `flutter run` without `--flavor`, but
the Play Core dependency would sit on an ordinary `implementation` line behind an `if`, and F-Droid's source scanner
flags those. With product flavours it is `playImplementation`, which the scanner skips for flavours a recipe does
not build, and Gradle keeps the play sources out of oss by construction. The cost is `--flavor` on every Android
build and Flutter's flavoured output names, which `just package-android` maps back to the release names.

`default-flavor` in `pubspec.yaml` was not used: Flutter applies it to iOS and macOS too, which have no such
scheme.

## A Kotlin channel, not a Dart plugin

A pub plugin for in-app updates registers on every build through the generated plugin registrant and brings Play
Core with it; there is no clean way to drop it per flavour. A small `PlayUpdate` object per source set does the
same over a MethodChannel: the play one calls AppUpdateManager, the oss one answers null. On the Dart side
`ChannelPlayUpdates` is created only when the compile-time constant `TIX_DISTRIBUTION == 'play'`, so other builds
tree-shake it.

## Version codes

AppUpdateManager reports `availableVersionCode`, not a version name. The release build number is
`MAJOR*1000000 + MINOR*1000 + PATCH` (`scripts/build-version.sh`), so the code maps back to the version exactly,
which keeps the panel and notification text ("tix 0.21.0 is available") and the once-per-version notice. A
debug build with pubspec's small `+N` code maps to `0.0.N`, which is never newer; that is fine for a build Play
did not install. Play's `UPDATE_AVAILABLE` gates the offer, so a version still on the internal track is never
offered to production users.

## Background

The headless engine `home_widget` starts has no app channels, only plugins. In the play flavour `UpdateWorker`
asks AppUpdateManager itself (it needs a Context, not an Activity) with a 30 second limit and appends
`play=1|0&code=N` to its `tixwidget://update` link. `main.dart` turns that into `LinkPlayUpdates` for the run. A
run without the answer (the widget refresh, or Play not answering) is skipped before the three-hour limit is
recorded, so it does not starve the worker's own run.

## Flexible update

`start` re-reads AppUpdateInfo, starts a FLEXIBLE flow with `startUpdateFlowForResult(info, activity, options,
requestCode)` (FlutterActivity is not a ComponentActivity), and installs as soon as Play reports the download
finished; the person asked for it by tapping. A download that finished while the app was away installs on the next
resume. Where Play allows no flexible update it opens `market://details?id=red.tix.tix_mobile`, then the https
listing; Dart opens the https listing as a last resort.

## F-Droid transition

Releases up to v0.21.0 have no flavours, and `checkupdates` copies the newest build entry forward. The recipe passes
`--flavor oss` only when `build.gradle.kts` defines it and globs `output:` over both APK names, so the same lines
build the old and the new layout.
