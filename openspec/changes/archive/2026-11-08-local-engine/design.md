# Design: local engine

## Getting libtix into builds

**Choice: a Flutter build hook** (`hook/build.dart`, native assets, enabled by default on stable).
The hook receives the target OS, architecture, Android API level, Apple SDK and deployment version and
the C compiler Flutter found, builds libtix for exactly that, and emits a `CodeAsset`. Flutter then
puts it where each platform loads native code from (`jniLibs`, a framework in `Frameworks/`, the Linux
bundle's `lib/`, beside the Windows executable) and resolves `@Native` functions to it, including under
`flutter test` and `dart run`.

The alternative, `just` recipes plus Gradle tasks, an Xcode build phase, CMake installs and a
Frameworks embed, needs five integrations to keep in step and a manual step before `flutter run`. The
hook is one Dart file that every Flutter entry point runs.

- **Pin.** `tix.lock` holds the commit SHA and the version stamped into the library. The hook, the CI
  cache keys and `just engine-notices` read it.
- **Source.** A shallow `git fetch` of that commit into `~/.cache/tix-mobile/libtix/src/<sha>`
  (`%LOCALAPPDATA%` on Windows). tix's `internal/notices/gen` must run inside the tix module, which a
  module-cache copy from `go mod download` cannot do.
- **Cache.** Each build lands in `.../<sha>/<target>/` with its `NOTICES.json`. A hit is a file copy, so
  `flutter run` costs nothing after the first build per target. Concurrent hooks (one per ABI) write
  to scratch directories and rename into place.
- **Without Go.** The hook prints why it skipped and bundles nothing; the app falls back to
  `UnavailableLocalTixEngine` and says local databases are not in this build. `hooks: user_defines:
  tix_mobile: engine: required` makes that an error, `off` skips the build. Hooks see only a filtered
  environment, so a variable cannot switch this; CI instead checks every artifact with
  `scripts/engine-check.sh`.

### Per platform

| Platform | Go build | Loaded as |
| --- | --- | --- |
| Android | `c-shared`, NDK clang `--target=<triple><api>`, `-z max-page-size=16384`, SONAME `libtix.so` | `lib/<abi>/libtix.so` |
| iOS | `c-archive`, then linked into a dylib with `-force_load`, CoreFoundation, Security, `-lresolv` | `libtix.framework`, embedded |
| macOS | `c-shared` per architecture, install name `@rpath/libtix.dylib` | `libtix.framework` in `Contents/Frameworks` |
| Linux | `c-shared` with Flutter's clang or the default cc | `lib/libtix.so` |
| Windows | `c-shared` with mingw-w64 gcc (cgo cannot use MSVC) | `libtix.dll` beside the executable |

iOS deviates from linking the xcframework statically and using `DynamicLibrary.process()`: Flutter's
hooks do not support static linking, and Go has no `c-shared` mode for iOS. Linking the archive into a
dynamic library keeps every `Tix*` symbol and lets Flutter wrap it as a framework, which the App Store
accepts.

## The binding

`FfiLocalTixEngine` declares the seven functions with `@Native` and `@DefaultAsset`. Every call runs
in `Isolate.run`; request strings are allocated with `malloc` and freed in the same isolate; every
answer is decoded and released with `TixFree`; `{"error":{"code","message"}}` becomes a
`TixException` with the same kinds the HTTP client uses. `load()` calls `TixVersion` once: an
unresolvable asset throws `ArgumentError`, and the provider falls back to the stub. Local instances
are enabled whenever the engine loads; `TIX_LOCAL_INSTANCES=true|false` still overrides.

Tokens are minted with `ttl: never`: the token only reaches a loopback port of a file the app already
owns, and a 90-day expiry would silently break a local instance.

## Files

SQLite needs a real path and writes `-wal` and `-shm` beside the database.

- **Linux, Windows:** the picked or saved file is used in place.
- **Android, iOS:** the pickers hand over a copy in a cache directory (iOS imports with security
  scoped access handled by the picker), so **Import** copies it into the documents folder under a
  unique name and opens that. New databases are created there too.
- **macOS:** the App Sandbox grants access to the picked file only, not to siblings it would create,
  and not across launches without security-scoped bookmarks. Until native bookmark and related-item
  support exists, macOS imports like the phones do.
- **Export** stops the instance's engine (closing the last connection checkpoints the WAL into the
  file), hands the file to the share sheet (phones) or a save dialog (macOS), and restarts the engine
  if it was running.

The connect screen and the instances screen say which model applies: "Import a database file" and
"Copy kept in the app" versus "The file stays where it is".

## Lifecycle

Phones (`Platform.isAndroid || Platform.isIOS`, a platform service) stop every engine gracefully on
`paused` and restart them on `resumed`, asking for the port they had so the session's base URL stays
valid. If that port is taken the engine starts on another, `LocalEngines.moved` fires and the session
rebuilds against the new address. Suspend and resume are serialised so a quick round trip cannot
interleave. Desktops keep running when minimised and stop on exit as before.

## Licences

Flutter's own collector registers every block of `NOTICES.Z`, and the tool builds that from the whole
package graph. `TixBinding` replaces `ServicesBinding.initLicenses` (without calling super, on
purpose) with a collector that:

- keeps blocks for runtime packages, the closure of `dependencies` from `dart pub deps --json`,
  generated into `lib/src/core/licences/packages.g.dart` by `just gen` and checked by `just gen-check`;
- drops dev-only package names from each block and a block left with none, keeping names that are no
  pub package (the engine's components);
- drops CC0, Unlicense and 0BSD texts, recognised by SPDX id or text; anything unrecognised is kept;
- adds the Go modules libtix links for this ABI from `assets/licenses/libtix.json`, the per-target
  `NOTICES.json` files merged by `just engine-notices`, when the engine is bundled.

`hooks` and `code_assets` are `dependencies` because the hook needs them; they are in the runtime set
by that rule though no code of theirs ships.

## Sizes

libtix carries the whole server: 32 to 34 MB per target, stripped. Android stores it uncompressed so
the loader maps it from the APK; the download is compressed by the store. Measured sizes per artifact
are in the pull request.
