# Tasks

## 1. Engine lifecycle

- [x] 1.1 Tests that fail if one-engine rules regress: local to remote, local to local, phone pause, launch
- [x] 1.2 `LocalEngines` idle timer, rest and wake, restart on the remembered address
- [x] 1.3 `LocalWakeInterceptor` on the session client of a local instance
- [x] 1.4 Idle timeout setting (default 10 minutes, never) on the settings screen
- [x] 1.5 Engine status stream and the Instances card: state, file, Stop

## 2. Open in place

- [x] 2.1 `Instance.inPlace` and `Instance.bookmark`
- [x] 2.2 `LocalFileAccess` service: kind, permission, browse, pick, open and close access
- [x] 2.3 Android channel, manifest overlay behind `tixAllFilesAccess`
- [x] 2.4 iOS and macOS channels: folder picker, bookmarks, iCloud download state; macOS entitlement
- [x] 2.5 `probeInPlace`, conflict copies and leftover `-wal` detection
- [x] 2.6 Connect screen advanced section with the warning, Android browser, fallback to import
- [x] 2.7 In-place engines rest when the app is hidden or paused, on every platform

## 3. Docs and checks

- [x] 3.1 English and Bulgarian strings
- [x] 3.2 `docs/architecture.md` and the README's local database line
- [x] 3.3 Linux integration test: idle stop and restart, no `-wal` left after a stop
