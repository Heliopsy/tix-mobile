# Development

Everything a contributor runs goes through [just](https://just.systems/). This page lists the prerequisites per
operating system, every recipe, and the workflows that have more than one step: code generation, localisation,
running on emulators and desktops, and screenshots.

## Prerequisites

### Every platform

- [just](https://just.systems/) and a version manager that reads `.tool-versions`:
  [asdf](https://asdf-vm.com/) or [mise](https://mise.jdx.dev/). The file pins Flutter (which carries Dart), Go,
  just, actionlint and shellcheck.
- Go and git, for the embedded tix engine; see [The embedded engine](#the-embedded-engine). Optional: without Go
  the app builds and runs with local databases switched off.
- Git, and [Node.js](https://nodejs.org/) for the `openspec` CLI and markdownlint.

With asdf:

```sh
asdf plugin add flutter
asdf plugin add golang
asdf plugin add just
asdf install          # reads .tool-versions
```

With mise:

```sh
mise install          # mise reads .tool-versions without extra configuration
```

Then `just doctor` runs `flutter doctor` against the pinned toolchain and says what is still missing.

### Android

- The Android SDK with command-line tools, platform tools, and an emulator image, through Android Studio or
  `sdkmanager`.
- A JDK supported by the Android Gradle plugin the project uses. `just doctor` reports a mismatch.
- Accept the licences once: `flutter doctor --android-licenses`.
- The Android NDK, for the engine. Flutter installs the version it wants on the first Android build; the hook
  uses the same one, or `ANDROID_NDK_HOME` when Flutter offers none.

### iOS and macOS

- macOS with Xcode and its command-line tools, plus an iOS Simulator runtime for iOS work.
- CocoaPods for plugins that still need it.
- Signing for a real device needs an Apple developer team set in Xcode. CI does not sign iOS builds yet; see
  [releasing.md](releasing.md#ios).

### Linux

Flutter's desktop build dependencies, plus libsecret for the token store. On Debian and Ubuntu:

```sh
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libsecret-1-dev
```

At run time the token store needs a Secret Service provider, such as GNOME Keyring or KWallet, unlocked in the
session. Without one there is nowhere safe to keep the token, and the app does not fall back to a plain file.

### Windows

- Visual Studio 2022 with the **Desktop development with C++** workload.
- Developer Mode enabled, which Flutter needs for plugin symlinks.
- mingw-w64 `gcc` on `PATH` for the engine ([MSYS2](https://www.msys2.org/) or `winget install BrechtSanders.WinLibs`).
  cgo cannot use MSVC.

## Recipes

`just --list` prints the same list with one-line descriptions. Recipes that build or test take the toolchain from
`.tool-versions`, so local results match CI.

### Everyday

| Recipe | What it does |
| --- | --- |
| `just setup` | First-time setup: install the pinned toolchain from `.tool-versions`, fetch packages, precache this host's engines |
| `just setup-linux` | Install the system packages a Linux desktop build needs (Debian/Ubuntu, uses sudo) |
| `just get` | `flutter pub get` |
| `just run *ARGS` | `flutter run`, passing arguments through: `just run -d linux`, `just run -d emulator-5554` |
| `just gen` | Run `build_runner` once: Riverpod providers, JSON models, anything else annotated |
| `just gen-watch` | The same, rebuilding on every save |
| `just gen-check` | Fail if committed generated code differs from what `build_runner` produces |
| `just l10n` | Regenerate the localisation classes from `lib/l10n/*.arb` |
| `just fmt` | Format Dart sources |
| `just fmt-check` | Fail on unformatted Dart sources |
| `just analyze` | `flutter analyze` plus `dart analyze`, so analyzer plugins such as `riverpod_lint` run too |
| `just lint` | Every linter: Dart analysis plus the repository linters below |
| `just test` | The unit, widget and golden suite |
| `just cover` | Tests with a coverage report |
| `just cover-check` | Fail when coverage drops under the floor in [testing.md](testing.md#coverage) |
| `just cover-floor` | Apply the floor to the `coverage/lcov.info` already on disk |
| `just goldens` | Regenerate the component goldens on Linux; look at every changed image before committing |

### Builds

| Recipe | Output |
| --- | --- |
| `just build-apk` | Android APKs, one per ABI (`arm64-v8a`, `armeabi-v7a`, `x86_64`) |
| `just build-aab` | Android App Bundle |
| `just build-ios` | iOS app, unsigned unless signing is configured locally |
| `just build-ipa` | iOS archive for distribution; needs signing |
| `just build-linux` | Linux desktop bundle |
| `just build-macos` | macOS app |
| `just build-windows` | Windows desktop bundle |
| `just build-all` | Every target the current host can build |
| `just package-android` | Collect the per-ABI APKs and the AAB into `dist/` |
| `just package-linux ARCH` | Tar the Linux bundle into `dist/` (`x64` or `arm64`) |
| `just package-macos` | Zip the macOS app into `dist/` |
| `just package-windows` | Zip the Windows runner output into `dist/` |
| `just package-ios` | Zip the unsigned iOS app into `dist/`, for inspection only |
| `just checksums` | Write `dist/SHA256SUMS` over everything in `dist/` |

A host builds only its own desktop target: Linux on Linux, macOS and iOS on macOS, Windows on Windows. Android
builds anywhere.

### Toolchain and dependencies

| Recipe | What it does |
| --- | --- |
| `just doctor` | `flutter doctor -v` against the pinned toolchain |
| `just outdated` | Dependencies with newer versions available |
| `just upgrade` | Upgrade dependencies across major versions; review the diff |
| `just clean` | Remove build output and generated caches |

### Repository checks

| Recipe | What it does |
| --- | --- |
| `just actionlint` | Lint the GitHub Actions workflows |
| `just yamllint` | Lint YAML files |
| `just mdlint` | Lint Markdown with the repository's markdownlint configuration |
| `just reuse` | Check every file carries licence information (REUSE) |
| `just secrets` | Scan for committed secrets |
| `just spec` | Validate the OpenSpec specs and open changes |
| `just shellcheck` | Shellcheck every tracked shell script |
| `just release-files-check` | Fail if the release-please manifest disagrees with the newest tag |

### Gates

| Recipe | When |
| --- | --- |
| `just check` | Before every push. The fast set: formatting, generated code, analysis, tests, specs |
| `just ci` | Before asking for review on anything large. Every gate CI runs that can run locally |

### Engine

| Recipe | What it does |
| --- | --- |
| `just engine-version` | The tix version and commit `tix.lock` pins |
| `just engine-test` | Build libtix for this machine and run the integration test against it |
| `just engine-notices` | Regenerate `assets/licenses/libtix.json` from the pinned commit, every target |
| `just engine-notices-check` | Fail if that file does not match `tix.lock` |
| `just engine-check KIND PATHS` | Fail unless a build carries libtix (`android` APKs, an `aab`, a `bundle` directory) |
| `just engine-clean` | Remove the cached tix sources and libraries |

## The embedded engine

Local databases are served by tix itself, compiled into the app as a C library (libtix). `hook/build.dart`, a
Flutter build hook, builds it during every `flutter build`, `flutter run` and `flutter test`:

1. It reads the commit from `tix.lock` and fetches that commit of tix once, with `git`, into
   `~/.cache/tix-mobile/libtix/src/` (`%LOCALAPPDATA%\tix-mobile\libtix` on Windows).
2. It runs `go build -buildmode=c-shared` for the target Flutter is building, with the C compiler Flutter found
   (the NDK's clang for Android, Xcode's clang for Apple platforms, mingw-w64 gcc on Windows), and caches the
   library per commit and target. iOS builds a static archive and links it into a dynamic library, since Go has
   no shared mode for iOS.
3. Flutter bundles the result and `FfiLocalTixEngine` loads it.

The first build per target takes a minute or two; after that it is a copy. `just engine-clean` empties the cache.

**Without Go**, or without a C compiler for the target, the hook prints a line saying so and bundles nothing. The
app runs, and the add-instance screen says local databases are not in this build. To make a missing engine an
error, or to skip building it even with Go installed, set a user define in `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    tix_mobile:
      engine: required   # or: off
```

`--dart-define=TIX_LOCAL_INSTANCES=true` shows the local screens in a build without the engine (each attempt then
fails with the "no engine" message), and `=false` hides them in one with it.

**Bumping tix.** Change `commit` and `version` in `tix.lock`, then `just engine-notices` to regenerate the
licence notices of the Go modules libtix links, and commit both. CI fails while the notices are stale.

## Code generation

Riverpod providers, JSON models and other annotated code are generated by `build_runner`. Generated files
(`*.g.dart`, `*.freezed.dart`) are committed, so a clone builds without running the generator first, and
`just gen-check` fails in CI when they are stale.

The loop while working on providers or models:

```sh
just gen-watch     # in one terminal
just run -d linux  # in another
```

Never edit a generated file by hand. Change the source and regenerate.

`just gen` also writes `lib/src/core/licences/packages.g.dart`, the runtime and dev-only package sets the Licenses
page filters by, from `dart pub deps --json`. Adding or removing a dependency changes it.

## Localisation

Strings live in `lib/l10n/app_en.arb` (the template) and `lib/l10n/app_bg.arb`. To add one:

1. Add the key to `app_en.arb` with an `@key` entry carrying a `description` for translators, and placeholders if
   it takes any.
2. Add the Bulgarian translation under the same key in `app_bg.arb`.
3. Run `just l10n` and use the generated getter: `AppLocalizations.of(context).key`.

A string a user can read never appears as a literal in a widget. A key missing from `app_bg.arb` is a review
finding, not something to fix later; if you cannot translate it, say so in the pull request and the maintainer
will.

## Running

### Desktop

```sh
just run -d linux      # or -d macos, -d windows
```

The quickest loop for most work. Resize the window across 600 and 840 logical pixels to see the layout switch
between the phone, rail and two-pane forms.

### Android emulator

```sh
flutter emulators                         # list AVDs
flutter emulators --launch <avd-id>
just run -d emulator-5554
```

The emulator reaches the host's loopback at `10.0.2.2`, so a local `tix serve --listen 127.0.0.1:8080` is
`http://10.0.2.2:8080` inside it. Cleartext HTTP to `10.0.2.2` is allowed in debug builds only; release builds
allow it to `127.0.0.1`, the embedded engine, and nothing else.

### iOS Simulator

```sh
open -a Simulator
just run -d iPhone
```

The simulator shares the host's network, so `http://127.0.0.1:8080` works.

### A tix server to point it at

Run a throwaway server against its own database, never your real one. `tix demo seed` fills it with projects,
people, tasks and comments, which is also what screenshots are taken from:

```sh
dir=$(mktemp -d)
tix demo seed --db "$dir/tix.db"
tix token create dev --db "$dir/tix.db" --scope task:read --scope task:write --scope project:read
tix serve --db "$dir/tix.db" --listen 127.0.0.1:8080
```

A server started without `--db` serves your real store. See tix's
[features guide](https://github.com/heliopsy/tix/blob/main/docs/features.md) for what the demonstration data holds.

## Screenshots

Screenshots live in `screenshots/` at the repository root, with a `screenshots/README.md` that says what each one
shows. The rules:

- Taken from a real build against a demonstration server seeded for the purpose, never from mock-ups and never
  from a server holding real work.
- Named `<platform>-<form>-<screen>[-dark].png`, for example `android-phone-task-list.png` or
  `linux-desktop-task-detail-dark.png`, where form is `phone`, `tablet` or `desktop`.
- PNG, at the device's native resolution for phones and tablets, and a 1280 by 800 window for desktops.
- Retaken in the same pull request as a change that makes one wrong. A screenshot that no longer matches the app is
  worse than none.

Golden test images are a different thing and live with their tests; see [testing.md](testing.md#golden-tests).
