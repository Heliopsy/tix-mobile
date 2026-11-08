# Local engine

## Why

Local instances were designed and wired up in multi-instance-tenants, but every build shipped
`UnavailableLocalTixEngine`. tix now exports itself as a C library (`embedded/libtix`), so the app can
run a `.db` file on every platform without a server. The Licenses page also lists every package in
the build graph, dev tools included (1636 blocks, 1.4 MB in 0.1.0), while missing the Go modules the
engine links in.

## What changes

- A Flutter build hook (`hook/build.dart`) builds libtix with Go from the tix commit pinned in
  `tix.lock`, for the platform and architecture being built, caches it, and bundles it as a code
  asset. Without Go the build still works and local databases are off.
- `FfiLocalTixEngine` implements `LocalTixEngine` over `dart:ffi`, off the UI isolate, and replaces
  the stub whenever the library loads. Local databases are on by default when it does.
- Linux and Windows open the picked file in place. Android, iOS and the sandboxed macOS app import a
  copy into the app's documents folder and export it through the share sheet or a save dialog.
- Engines stop while a phone app is in the background and restart, on the same port, on resume.
- Platform settings: loopback-only cleartext on Android, `NSAllowsLocalNetworking` on Apple
  platforms, `network.server` in the macOS release entitlements, uncompressed 16 KB aligned native
  libraries on Android.
- The Licenses page lists what ships: runtime Dart packages, the Flutter engine's components, tix and
  the Go modules it links for this target, and nothing whose licence asks for no notice.
- CI installs Go, caches libtix per target, runs an integration test against the real library and
  checks every build artifact carries it.

## Capabilities

- Modified: `local-instances`
- New: `licences`

## Impact

Each build grows by the library: about 32 MB uncompressed per Android ABI (stored uncompressed so it
can be mapped from the APK) and 34 MB on desktop. Builds need Go 1.27; Android also needs the NDK
Flutter already uses, Windows mingw-w64. New dependencies: `hooks`, `code_assets` (the build hook),
`ffi` (C strings), `share_plus` (export on phones).
