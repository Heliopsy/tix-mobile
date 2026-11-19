# Tasks

## 1. Spec

- [x] 1.1 `self-update` and `release-channels` deltas

## 2. Android

- [x] 2.1 `oss` and `play` product flavours; Play Core as `playImplementation`; All files access in oss only
- [x] 2.2 `PlayUpdate.kt` in `src/play` (AppUpdateManager: info, flexible start, listing fallback, install on
  download) and a null stand-in in `src/oss`
- [x] 2.3 `UpdateWorker` adds Play's answer to its link in the play flavour

## 3. Dart

- [x] 3.1 `TIX_DISTRIBUTION` and `Distribution`; `store` mode for play, off for fdroid
- [x] 3.2 `PlayReleaseFeed`, version code to version, `ChannelPlayUpdates` behind a constant, `LinkPlayUpdates`
  for the headless run
- [x] 3.3 `Updates.openStore` for the panel and the notification tap; Play wording in four languages

## 4. Build and release

- [x] 4.1 `just build-apk`/`build-fdroid` build oss, `just build-aab` builds play; `package-android` keeps the names
- [x] 4.2 `release.yaml` and the CI matrix (play bundle on main and on Android or update changes)
- [x] 4.3 F-Droid recipe builds oss, across the change

## 5. Docs and tests

- [x] 5.1 `docs/releasing.md` (artifacts, Play Core terms, F-Droid), `docs/architecture.md`, `docs/development.md`,
  README
- [x] 5.2 Unit tests for mode selection per distribution, the channel contract, the feed, notice once per version
  code; widget tests for the panel, Settings and the notification tap
