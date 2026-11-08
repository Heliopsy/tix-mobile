# Tasks

## Build

- [x] Pin tix in `tix.lock` and add Go to `.tool-versions`
- [x] `hook/build.dart`: build libtix per target from the pinned commit, cache it, emit a code asset
- [x] Skip without Go or a C compiler, with a message; `engine: required|off` user define
- [x] `just engine-*` recipes and `scripts/engine-check.sh`

## Binding

- [x] `FfiLocalTixEngine` over `@Native`, calls in `Isolate.run`, strings freed, errors mapped
- [x] Provider falls back to the stub; local instances on when the engine loads

## Platforms and files

- [x] Android network security config, uncompressed jniLibs
- [x] `NSAllowsLocalNetworking` on iOS and macOS; `network.server` in macOS release entitlements
- [x] Import on Android, iOS and macOS; in place on Linux and Windows
- [x] Export with the engine stopped and restarted
- [x] Stop engines in the background on phones, resume on the same port

## Licences

- [x] Runtime and dev-only package sets generated from `dart pub deps --json`
- [x] `TixBinding` filters Flutter's notices and adds the engine's Go modules
- [x] Merged engine notices asset, checked against `tix.lock` in CI

## CI and docs

- [x] Go and the libtix cache in CI and release jobs; artifact checks
- [x] Integration test against the real library
- [x] Development, architecture and releasing docs, README
