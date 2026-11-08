# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# tix-mobile, the Flutter client for tix.
#
# `just check` is the fast pre-push gate.
# `just ci`    runs everything CI runs that this host can run.
#
# CI calls these recipes rather than inlining commands, so the two cannot
# drift. If a workflow step grows a command, it belongs here instead.

set shell := ["bash", "-euo", "pipefail", "-c"]
set windows-shell := ["bash", "-euo", "pipefail", "-c"]

# The coverage floor. Start at 80 and only ever raise it: every run prints the
# headroom left above it, so a slow decline shows up before it turns CI red.
cov_min := "80"

app := "tix-mobile"
# The version stamped into package names. The release workflow sets VERSION
# from the tag; anywhere else it is whatever git describe says.
version := env("VERSION", `git describe --tags --always --dirty 2>/dev/null || echo dev`)
# Extra flags for every `flutter build`, e.g. the release workflow's
# --build-name/--build-number from scripts/build-version.sh.
build_args := env("BUILD_ARGS", "")

# Generated Dart, excluded from formatting and coverage. Kept in step with
# scripts/coverage.sh and codecov.yml.
generated := '(\.g\.dart|\.freezed\.dart|\.gr\.dart|\.mocks\.dart|\.config\.dart)$|^lib/l10n/.*\.dart$|^lib/generated/'

tool := "scripts/tool.sh run"

# List the recipes.
default:
    @just --list --unsorted

# ---------------------------------------------------------------- setup

# Install the pinned toolchain from .tool-versions, fetch packages and precache this host's engines.
[group('setup')]
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v asdf >/dev/null 2>&1; then
      while read -r plugin _; do
        [ -n "$plugin" ] || continue
        asdf plugin list 2>/dev/null | grep -qx "$plugin" || asdf plugin add "$plugin"
      done < .tool-versions
      asdf install
    else
      echo "asdf not found: install the versions in .tool-versions by hand" >&2
    fi
    flutter --disable-analytics >/dev/null 2>&1 || true
    flutter pub get
    case "$(uname -s)" in
      Linux)  flutter precache --android --linux ;;
      Darwin) flutter precache --android --ios --macos ;;
      *)      flutter precache --android --windows ;;
    esac
    echo "done. \`just doctor\` shows anything still missing for a platform."

# Install the system packages a Linux desktop build needs (Debian/Ubuntu, uses sudo).
[group('setup')]
setup-linux:
    sudo apt-get update -q
    sudo apt-get install -y -q --no-install-recommends clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libsecret-1-dev

# flutter doctor -v.
[group('setup')]
doctor:
    flutter doctor -v

# Fetch packages (flutter pub get).
[group('dev')]
get:
    flutter pub get

# Run the app; arguments go to flutter run (e.g. `just run -d linux`).
[group('dev')]
run *ARGS:
    flutter run {{ARGS}}

# Run build_runner once.
[group('dev')]
gen:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! grep -qE '^\s+build_runner:' pubspec.yaml; then
      echo "build_runner is not in pubspec.yaml, nothing to generate"
      exit 0
    fi
    dart run build_runner build

# Regenerate the app icons and launch screens (needs rsvg-convert, ImageMagick).
[group('dev')]
icons:
    scripts/icons.sh

# Run build_runner in watch mode.
[group('dev')]
gen-watch:
    dart run build_runner watch

# Generate the localizations from the ARB files.
[group('dev')]
l10n:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f l10n.yaml ] && ! grep -qE '^\s+generate:\s*true' pubspec.yaml; then
      echo "no l10n.yaml and no flutter.generate in pubspec.yaml, nothing to generate"
      exit 0
    fi
    flutter gen-l10n

# Regenerate code and localizations and fail if anything committed differs.
[group('gates')]
gen-check: gen l10n
    #!/usr/bin/env bash
    set -euo pipefail
    # Untracked files count too: a generated file nobody committed is the same
    # drift as a stale one, and git diff alone cannot see it.
    changed=$(git status --porcelain --untracked-files=all -- lib test)
    if [ -n "$changed" ]; then
      echo "generated code is out of date; run \`just gen l10n\` and commit:" >&2
      echo "$changed" >&2
      git --no-pager diff --stat -- lib test >&2
      exit 1
    fi
    echo "generated code is up to date"

# Format the Dart sources, generated code excepted.
[group('dev')]
fmt:
    git ls-files -co --exclude-standard '*.dart' | grep -vE '{{generated}}' | xargs -r dart format

# Fail if any Dart source is not formatted.
[group('gates')]
fmt-check:
    git ls-files -co --exclude-standard '*.dart' | grep -vE '{{generated}}' | xargs -r dart format --output=none --set-exit-if-changed

# Both analyzers, failing on infos. `flutter analyze` does not run analyzer
# plugins (riverpod_lint is one, declared under `plugins:` in
# analysis_options.yaml); `dart analyze` does, so it runs too.
[doc("flutter analyze and dart analyze (for analyzer plugins), failing on infos.")]
[group('gates')]
analyze:
    flutter analyze --fatal-infos --fatal-warnings
    dart analyze --fatal-infos

# Run the tests; arguments go to flutter test.
[group('test')]
test *ARGS:
    flutter test {{ARGS}}

# Tests with coverage, generated code excluded, into coverage/lcov.info.
[group('test')]
cover:
    #!/usr/bin/env bash
    set -euo pipefail
    flutter test --coverage --coverage-path=coverage/lcov.raw.info
    scripts/coverage.sh filter coverage/lcov.raw.info coverage/lcov.info
    if command -v genhtml >/dev/null 2>&1; then
      genhtml --quiet coverage/lcov.info -o coverage/html && echo "report: coverage/html/index.html"
    fi
    scripts/coverage.sh check coverage/lcov.info 0 | sed -n 1p

# Enforce the coverage floor (cov_min) against a fresh run.
[group('test')]
cover-check: cover cover-floor

# The floor against the coverage/lcov.info already on disk.
[group('test')]
cover-floor:
    scripts/coverage.sh check coverage/lcov.info {{cov_min}}

# ---------------------------------------------------------------- gates

# Every lint: Dart formatting and analysis, workflows, YAML, Markdown, shell.
[group('gates')]
lint: fmt-check analyze actionlint yamllint mdlint shellcheck

# Lint the GitHub workflows (shellchecks their run: blocks too).
[group('gates')]
actionlint:
    {{tool}} actionlint

# Lint every YAML file per .yamllint.yaml.
[group('gates')]
yamllint:
    {{tool}} yamllint .

# Specs get their own pass: they are prose and exempt from line length.
#
# CHANGELOG.md is release-please's output and arrives failing (two blank lines
# before each version); linting generated output teaches people to ignore the
# linter. .claude/ is written by `openspec init`, the platform folders by
# `flutter create`.
[doc("Lint the Markdown (openspec/ with its own config).")]
[group('gates')]
mdlint:
    {{tool}} markdownlint --ignore CHANGELOG.md --ignore openspec --ignore .claude --ignore .worktrees --ignore build --ignore .dart_tool --ignore android --ignore ios --ignore linux --ignore macos --ignore windows --ignore '**/node_modules' .
    {{tool}} markdownlint --config .markdownlint-specs.yaml openspec

# Shellcheck every tracked shell script.
[group('gates')]
shellcheck:
    #!/usr/bin/env bash
    set -euo pipefail
    mapfile -t files < <(git ls-files -co --exclude-standard '*.sh')
    [ "${#files[@]}" -gt 0 ] || { echo "no shell scripts"; exit 0; }
    {{tool}} shellcheck --severity=style "${files[@]}"

# REUSE compliance: every file has a licence, via its header or REUSE.toml.
[group('gates')]
reuse:
    {{tool}} reuse lint

# The history and not the tree: a credential committed and later removed is
# still published the moment it is pushed, so the working tree alone proves
# nothing. --all reaches every ref.
[doc("Scan the whole git history for secrets (gitleaks).")]
[group('gates')]
secrets:
    #!/usr/bin/env bash
    set -euo pipefail
    # A shallow clone would scan one commit, pass in a second and report
    # success having looked at almost nothing. Refuse instead.
    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
      echo "refusing to scan a shallow clone: this gate reads the whole history." >&2
      echo "in CI, give the checkout step fetch-depth: 0." >&2
      exit 1
    fi
    {{tool}} gitleaks git --log-opts=--all --config=.gitleaks.toml --redact --no-banner .

# Validate every OpenSpec change and spec, strictly.
[group('gates')]
spec:
    {{tool}} openspec validate --all --strict --no-interactive

# A rebase can carry a stale .release-please-manifest.json or CHANGELOG.md back
# onto main, and release-please then reads it as "that release never shipped"
# and proposes it again (it happened to tix). The manifest must name the newest
# tag, except on release-please's own branch, where it legitimately moves.
[doc("Fail if the release-please manifest disagrees with the newest tag.")]
[group('gates')]
release-files-check HEAD_REF="":
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{HEAD_REF}}" in release-please--*) echo "release-please branch, skipped"; exit 0;; esac
    got=$(sed -nE 's/.*"\.": *"([^"]+)".*/\1/p' .release-please-manifest.json)
    tag=$(git tag --list 'v[0-9]*' --sort=-v:refname | head -1)
    if [ -z "$tag" ]; then
      [ "$got" = "0.0.0" ] || { echo "no release tag exists, so the manifest must say 0.0.0, not $got" >&2; exit 1; }
      echo "no release yet and the manifest agrees"
      exit 0
    fi
    if [ "$got" != "${tag#v}" ]; then
      echo ".release-please-manifest.json says $got but the newest release is $tag; leave release files to release-please" >&2
      exit 1
    fi
    echo "release files match $tag"

# ---------------------------------------------------------------- build
#
# Every build recipe passes its arguments and BUILD_ARGS through to flutter
# build. Artifacts land where flutter puts them; the package-* recipes collect
# them into dist/ under release names.

# Android APK (release). Signed when android/key.properties or ANDROID_KEYSTORE_PATH is set, debug-signed otherwise.
[group('build')]
build-apk *ARGS:
    flutter build apk --release --split-per-abi {{build_args}} {{ARGS}}

# Android App Bundle (release), signed as build-apk is.
[group('build')]
build-aab *ARGS:
    flutter build appbundle --release {{build_args}} {{ARGS}}

# iOS app without code signing (macOS only); proves it builds, installs nowhere.
[group('build')]
build-ios *ARGS:
    flutter build ios --release --no-codesign {{build_args}} {{ARGS}}

# Signed iOS archive for App Store Connect (CI only: needs certificates and ios/ExportOptions.plist).
[group('build')]
build-ipa *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    [ "$(uname -s)" = Darwin ] || { echo "build-ipa needs macOS" >&2; exit 1; }
    [ -f ios/ExportOptions.plist ] || { echo "build-ipa needs ios/ExportOptions.plist and signing set up; see release.yaml" >&2; exit 1; }
    flutter build ipa --release --export-options-plist=ios/ExportOptions.plist {{build_args}} {{ARGS}}

# Linux desktop bundle (release). Needs `just setup-linux` once.
[group('build')]
build-linux *ARGS:
    flutter build linux --release {{build_args}} {{ARGS}}

# macOS app (release, macOS only).
[group('build')]
build-macos *ARGS:
    flutter build macos --release {{build_args}} {{ARGS}}

# Windows app (release, Windows only).
[group('build')]
build-windows *ARGS:
    flutter build windows --release {{build_args}} {{ARGS}}

# Every target this host can build.
[group('build')]
build-all:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -s)" in
      Linux)  just build-apk; just build-aab; just build-linux ;;
      Darwin) just build-apk; just build-aab; just build-ios; just build-macos ;;
      *)      just build-apk; just build-aab; just build-windows ;;
    esac

# Collect the Android APK and AAB into dist/.
[group('package')]
package-android:
    #!/usr/bin/env bash
    set -euo pipefail
    # The same rule android/app/build.gradle.kts applies, so the name says
    # what the file is: a debug-signed build cannot update a store install.
    suffix=""
    if [ -z "${ANDROID_KEYSTORE_PATH:-}" ] && [ ! -f android/key.properties ]; then suffix="-debug-signed"; fi
    mkdir -p dist
    # One APK per ABI instead of a universal one, which carries all three
    # engines and is several times the size of what a phone needs.
    for abi in arm64-v8a armeabi-v7a x86_64; do
        cp "build/app/outputs/flutter-apk/app-${abi}-release.apk" "dist/{{app}}-{{version}}-android-${abi}${suffix}.apk"
    done
    cp build/app/outputs/bundle/release/app-release.aab "dist/{{app}}-{{version}}-android${suffix}.aab"
    ls -l dist

# Tar the Linux bundle into dist/ (ARCH is x64 or arm64).
[group('package')]
package-linux ARCH="x64":
    mkdir -p dist
    tar -C build/linux/{{ARCH}}/release/bundle -czf dist/{{app}}-{{version}}-linux-{{ARCH}}.tar.gz .
    ls -l dist

# Zip the macOS app into dist/, keeping its signature and symlinks intact.
[group('package')]
package-macos:
    mkdir -p dist
    ditto -c -k --sequesterRsrc --keepParent build/macos/Build/Products/Release/*.app dist/{{app}}-{{version}}-macos.zip
    ls -l dist

# Zip the Windows runner output into dist/.
[group('package')]
package-windows:
    mkdir -p dist
    cd build/windows/x64/runner/Release && 7z a -tzip -r ../../../../../dist/{{app}}-{{version}}-windows-x64.zip . >/dev/null
    ls -l dist

# Zip the unsigned iOS app into dist/ (an artifact to inspect, not to install).
[group('package')]
package-ios:
    mkdir -p dist
    ditto -c -k --sequesterRsrc --keepParent build/ios/iphoneos/Runner.app dist/{{app}}-{{version}}-ios-unsigned.zip
    ls -l dist

# Write dist/SHA256SUMS over everything in dist/.
[group('package')]
checksums:
    cd dist && rm -f SHA256SUMS && sha256sum -- * > SHA256SUMS && cat SHA256SUMS

# ---------------------------------------------------------------- maintenance

# Show outdated packages.
[group('maintenance')]
outdated:
    flutter pub outdated

# Upgrade packages across major versions (maintainers; review the diff).
[group('maintenance')]
upgrade:
    flutter pub upgrade --major-versions

# Remove build output, coverage and dist/.
[group('maintenance')]
clean:
    flutter clean
    rm -rf coverage dist

# ---------------------------------------------------------------- aggregates

# Fast pre-push gate: formatting, analysis, tests, specs.
[group('aggregate')]
check: fmt-check analyze test spec

# Everything CI runs that this host can run.
[group('aggregate')]
ci: fmt-check analyze gen-check spec actionlint yamllint mdlint shellcheck reuse secrets release-files-check cover-check build-all
