# Releasing

Releases are cut by [release-please](https://github.com/googleapis/release-please) from Conventional Commits on
`main`. Nobody edits a version number or a changelog by hand.

## The flow

1. Pull requests merge to `main` with a Conventional Commit title. `fix:` is a patch, `feat:` a minor, and `feat!:`
   or a `BREAKING CHANGE:` footer a major.
2. The `release-please` workflow keeps one open release pull request that bumps the version in `pubspec.yaml`,
   updates `CHANGELOG.md`, and lists what will ship.
3. The release pull request goes through the merge queue like any other. Merging it tags the commit (`vX.Y.Z`)
   and creates the GitHub release as a draft.
4. The `release` workflow builds every artifact for that tag, attaches them, publishes the release, and then
   hands the builds to whichever stores are set up (see [Store channels](#store-channels)).

Merge agent branches with `--ff-only` so their commits land on `main` individually. release-please reads only a
merge commit's own subject, so the commits inside a `--no-ff` merge never reach the changelog.

## Version numbers

`pubspec.yaml` carries `version: X.Y.Z+N`. release-please owns `X.Y.Z`. The build number `N` becomes the Android
`versionCode` and the iOS `CFBundleVersion`, and must increase with every build a store sees.

## Artifacts

| Platform | File | Built on |
| --- | --- | --- |
| Android | APK, for sideloading | Linux |
| Android | AAB, for Google Play | Linux |
| Linux | `.tar.gz` of the desktop bundle | Linux |
| macOS | `.zip` of the app | macOS |
| Windows | `.zip` of the desktop bundle | Windows |

Every artifact carries the embedded tix engine (libtix), built from the commit `tix.lock` pins. The release jobs
install Go, build it through `hook/build.dart` and fail unless `just engine-check` finds it in each artifact; on
Android that also checks it is stored uncompressed and 16 KB aligned, which Google Play requires. To ship a newer
tix, change `tix.lock`, run `just engine-notices`, and commit both.

Every release also carries `SHA256SUMS` over all of them, and each artifact has a GitHub build provenance
attestation. With the [update signing key](#desktop-update-signing) set, `SHA256SUMS.sig` signs the checksums for
the desktop apps' self-update. Users verify with:

```sh
sha256sum --check --ignore-missing SHA256SUMS
gh attestation verify <file> --repo heliopsy/tix-mobile
```

Nothing iOS is attached to a release: an App Store signed IPA installs only through TestFlight or the App Store,
and an unsigned app installs nowhere.

## The release GitHub App

A pull request opened with the workflow's own `GITHUB_TOKEN` gets its checks held for approval, so the merge
queue cannot take it without an admin. release-please uses a GitHub App's token instead when two secrets exist,
and then the release pull request runs its checks and is enqueued like any other. Without the App it still
works, with the checks approved by hand (see [When a release goes wrong](#when-a-release-goes-wrong)).

Owner, once:

1. Create the App: **Settings → Developer settings → GitHub Apps → New GitHub App** on the account that owns the
   repository (for an organisation, the organisation's settings).
   - Name: anything unique, e.g. `tix-mobile-release`. Homepage: the repository URL.
   - Webhook: untick **Active**. The App never receives events.
   - Repository permissions:
     - **Contents: Read and write** (release branch, tags, draft releases)
     - **Pull requests: Read and write** (open and update the release pull request)
     - **Issues: Read and write** (release-please labels the pull request `autorelease: pending` through the
       issues API and creates the labels the first time)
     - **Metadata: Read-only** (mandatory)
     - Nothing else. No checks, workflows or actions permission is needed: release-please never touches
       `.github/workflows/`, and the release build is dispatched with `GITHUB_TOKEN`.
   - Where can this App be installed: **Only on this account**.
2. On the App's page, note the **Client ID** and **Generate a private key** (a `.pem` file downloads).
3. **Install App** → only select repositories → `heliopsy/tix-mobile`.
4. Repository secrets (**Settings → Secrets and variables → Actions**):

   | Secret | Value |
   | --- | --- |
   | `RELEASE_APP_CLIENT_ID` | The Client ID (`Iv23...`), not the numeric App ID |
   | `RELEASE_APP_PRIVATE_KEY` | The whole `.pem` file, header and footer lines included |

Verify: push anything to `main`. The `release-please` run no longer prints "No release App credentials", the
release pull request's author is `<app-name>[bot]`, and its checks start without an approval button. Enqueue it;
it merges without an admin. The `cla` check passes on its own because the CLA workflow skips release branches.

## Signing

### Android

Release builds are signed in CI from four repository secrets:

| Secret | Contents |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | The upload keystore (`.jks`), base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | The keystore's password |
| `ANDROID_KEY_ALIAS` | The alias of the key inside it |
| `ANDROID_KEY_PASSWORD` | The key's password |

Create a keystore once and keep the original somewhere safe outside the repository. Losing it means a Play listing
can no longer be updated with the same key.

```sh
keytool -genkeypair -v -keystore upload.jks -alias upload \
  -keyalg RSA -keysize 4096 -validity 10000
base64 -w0 upload.jks    # value for ANDROID_KEYSTORE_BASE64
```

A fork has none of these secrets, so it cannot produce a build signed with the project's key. That is the point:
an APK that updates an installed tix-mobile can only come from this repository.

### iOS and macOS

Both use the Apple Developer account and one App Store Connect API key; the steps are under
[TestFlight](#testflight-ios) and [macOS notarisation](#macos-notarisation). Until the secrets exist, iOS builds
unsigned and the macOS app is ad-hoc signed, so Gatekeeper warns on first launch.

### Windows

The Windows archive is not code-signed. SmartScreen warns on first launch; the checksum and provenance
attestation are the way to check a download.

### Desktop update signing

The Linux, Windows and macOS downloads update themselves (`docs/architecture.md`, Desktop updates). `SHA256SUMS`
from the same release only proves a download is intact, so the apps also want `SHA256SUMS.sig`: a raw 64-byte
Ed25519 signature over `SHA256SUMS`, made in the `publish` job by `scripts/update-sign.sh` with the
`UPDATE_SIGNING_KEY` secret. The apps check it against the public key pinned in
`lib/src/data/update/signing_key.dart` before they download anything else, and refuse to install without it.

Without the secret the release is published as before, without `SHA256SUMS.sig`, and the apps show the update
with a link to the release page. An app with no key pinned (`updateSigningPublicKey` empty, as it ships until the
steps below) does the same.

Owner, once (OpenSSL 3; on macOS use Homebrew's `openssl@3`, the system LibreSSL has no Ed25519):

1. Create the key, somewhere outside the repository, and keep the `.pem` offline:

   ```sh
   openssl genpkey -algorithm ed25519 -out tix-update-signing.pem
   ```

2. Store it as the secret (or paste the whole file, header and footer lines included, under **Settings → Secrets
   and variables → Actions**):

   ```sh
   gh secret set UPDATE_SIGNING_KEY --repo heliopsy/tix-mobile < tix-update-signing.pem
   ```

3. Print the public key as the app pins it, the base64 of its 32 raw bytes:

   ```sh
   openssl pkey -in tix-update-signing.pem -pubout -outform DER | tail -c 32 | base64
   ```

4. Put that string in `lib/src/data/update/signing_key.dart`, drop the TODO above it, and merge it as a `feat:`
   pull request:

   ```dart
   const updateSigningPublicKey = '<the 44 characters from step 3>';
   ```

| Secret | Value |
| --- | --- |
| `UPDATE_SIGNING_KEY` | The whole Ed25519 private key file in PEM, its `BEGIN PRIVATE KEY` and `END PRIVATE KEY` lines included |

The release that carries the pinned key is the first that can update itself; it installs the release after it.
Copies from before keep offering Download, so people update to that release by hand once.

Verify: the `publish` job's log says `signed dist/SHA256SUMS with the update key ...` with the key from step 3 and
no warning, the release lists `SHA256SUMS.sig`, and by hand:

```sh
openssl pkey -in tix-update-signing.pem -pubout -out tix-update-signing.pub.pem
openssl pkeyutl -verify -pubin -inkey tix-update-signing.pub.pem -rawin -in SHA256SUMS -sigfile SHA256SUMS.sig
```

prints `Signature Verified Successfully`. The job warns when the key pinned at the release's commit differs from
the secret's.

Rotating the key (lost, or leaked): create a new one, replace the secret and the pinned key in the same release.
Copies pinning the old key cannot verify anything signed with the new one and fall back to Download, so after a
rotation everyone updates by hand once. Losing the key without a leak is no emergency: releases go out unsigned
and the apps offer the download until a new key is pinned.

Self-update is off, and nothing is checked, in Flatpak (Flathub updates it), in builds made with
`--dart-define=TIX_SELF_UPDATE=false` (`flatpak/build.sh`, `just build-aab` for Google Play, the F-Droid recipe and
`just build-fdroid`), and on iOS. Android APKs from the release only show that a new version is out, and only when
the system package installer installed them; Play and F-Droid installs never check.

## When a release goes wrong

- **No artifacts on a release.** A tag created with the workflow's own `GITHUB_TOKEN` cannot start another
  workflow. Dispatch the `release` workflow by hand with the tag; it rebuilds an existing tag.
- **The release pull request's checks never run.** Without the [release App](#the-release-github-app), a pull
  request opened by `GITHUB_TOKEN` gets its checks held for approval. Approve only the runs whose head is the
  current commit (approving a stale run replays it with the workflow file it was created against), then enqueue
  it. Setting up the App ends this.
- **A build on `main` shows as cancelled with no steps.** No hosted runner picked the job up, which happens
  to macOS arm64 when GitHub is short of capacity. The `CI retry` workflow reruns a failed CI run once when
  every failure is of that kind or a failed tool download; a failing test, lint or build is never retried, and
  merge-queue runs are left to the queue. If the rerun fails the same way, rerun it by hand later.
- **The release pull request predates a workflow fix.** release-please does not rebase its branch when the release
  content has not changed. Close it and let the next push to `main` open a fresh one.

## Store channels

Every channel below is wired into `release.yaml` and skipped while its secrets are absent. Each job starts with
`scripts/release-secrets.sh`: none of a channel's secrets set is a notice ("skipped: ... not set"), some set is a
warning naming the missing ones. A skipped channel never fails the release.

Secrets go in **Settings → Secrets and variables → Actions → Secrets**. To base64 a file without line breaks:
`base64 -w0 FILE` on Linux, `base64 -i FILE` on macOS.

| Channel | State without owner action | Owner creates |
| --- | --- | --- |
| [Release App](#the-release-github-app) | Checks approved by hand | A GitHub App |
| [Google Play](#google-play) | Skipped | Play Console account, app, service account |
| [TestFlight](#testflight-ios) | Unsigned iOS build only | Apple Developer account, App ID, certificate, profile, API key |
| [macOS notarisation](#macos-notarisation) | Ad-hoc signed zip | Developer ID Application certificate (same Apple account) |
| [F-Droid](#f-droid) | Recipe in `fdroid/`, not submitted | A merge request to fdroiddata |
| [Flathub](#flathub) | Manifest in `flatpak/`, not submitted | A submission pull request to Flathub |
| [Desktop update signing](#desktop-update-signing) | No `SHA256SUMS.sig`; desktop apps offer the download | An Ed25519 key |

### Store text

`fastlane/metadata/android/<locale>/` holds `title.txt` (30 characters at most), `short_description.txt` (80) and
`full_description.txt` (4000) in `en-US`, `bg`, `fr-FR` and `de-DE`. Google Play gets it on every upload and
F-Droid reads it from the tagged source. Keep it to what the README says.

`changelogs/<versionCode>.txt` is not committed. The `play` job writes it at upload time from the version's
`CHANGELOG.md` section (`just store-changelog VERSION CODE`), links and hashes dropped, cut at 500 characters.

`images/icon.png` is the 512 px icon. Screenshots are not committed yet. Real ones go in
`images/phoneScreenshots/` and `images/tenInchScreenshots/` (PNG or JPEG, 2 to 8 each, named `1.png`, `2.png`,
...) and are used by F-Droid at once; Play needs at least two phone screenshots and a 1024 x 500
`images/featureGraphic.png`, uploaded by hand in the Play Console until the upload step stops skipping images
(`skip_upload_images` in `fastlane/Fastfile`). Take them from a build against a throwaway server
(`tix demo seed`), never real work.

### Google Play

Owner, once:

1. A Google Play developer account (one-off fee, identity verification).
2. **Create app**: name `tix`, app, free. Fill in the store listing's required forms (privacy policy URL, data
   safety: no data collected or shared, content rating, target audience, ads: none).
3. Play App Signing: accept it. The key in `ANDROID_KEYSTORE_*` becomes the upload key.
4. Upload the first App Bundle by hand: Play does not accept API uploads for an app that never had one. Take
   `tix-mobile-X.Y.Z-android.aab` from a release built with the Android signing secrets (no `-debug-signed` in
   the name) and add it to an internal testing release.
5. A service account: in Google Cloud, create a project, enable the **Google Play Android Developer API**, create a
   service account and a JSON key for it. In the Play Console, **Users and permissions → Invite new users**, the
   service account's email, with **Release apps to testing tracks** and **Manage store presence** for this app.

| Secret or variable | Value |
| --- | --- |
| `PLAY_SERVICE_ACCOUNT_JSON` (secret) | The JSON key file's contents |
| `ANDROID_KEYSTORE_*` (secrets) | Already described under [Android](#android); without them the bundle is debug-signed and the upload is skipped |
| `PLAY_RELEASE_STATUS` (variable, optional) | `draft` (default) until the app has passed its first review, then `completed` |

What runs: after the release is published, the `play` job uploads the bundle to the **internal** track with the
store text and the changelog. Promote to closed, open or production testing in the Play Console.

Verify: the release's `Google Play (internal track)` job is green and the Play Console shows the version code
(`MAJOR*1000000 + MINOR*1000 + PATCH`) under internal testing. Re-running a release after a successful upload
fails that job, because Play takes a version code once; that is expected.

### TestFlight (iOS)

Bundle id `red.tix.tixMobile` (from `ios/Runner.xcodeproj`). Android's id is `red.tix.tix_mobile`; they stay
different because both are already in use.

Owner, once:

1. An Apple Developer Program membership. Note the **Team ID** (Membership details).
2. **Certificates, Identifiers & Profiles → Identifiers**: register the App ID `red.tix.tixMobile`.
3. **Certificates**: an **Apple Distribution** certificate. Create the CSR in Keychain Access, download the
   certificate, and export it with its private key as a `.p12` with a password.
4. **Profiles**: an **App Store Connect** distribution profile for `red.tix.tixMobile` with that certificate.
5. App Store Connect → **Apps → New App**: iOS, name `tix`, bundle id `red.tix.tixMobile`. Answer export
   compliance on the first build (the app uses HTTPS and the Go standard library's TLS).
6. App Store Connect → **Users and Access → Integrations → App Store Connect API**: a **Team** key with the
   **App Manager** role. Download the `.p8` (only once) and note the Key ID and the Issuer ID.

Why plain secrets and not fastlane match: match needs a second private repository or bucket and a passphrase to
keep, which pays off for a team sharing certificates. One maintainer with one certificate is the same shape as
the Android keystore.

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | The 10-character Team ID |
| `IOS_CERT_P12_BASE64` | The distribution `.p12`, base64 |
| `IOS_CERT_PASSWORD` | Its export password |
| `IOS_PROFILE_BASE64` | The `.mobileprovision`, base64 |
| `APP_STORE_CONNECT_KEY_ID` | The API key's Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | The Issuer ID |
| `APP_STORE_CONNECT_KEY_BASE64` | The `.p8` file, base64 |

What runs: the iOS job imports the certificate and profile into a throwaway keychain, switches the Runner
target's Release configuration to manual signing on the runner (the committed project keeps automatic signing),
fills the team and profile into `ios/ExportOptions.plist`, runs `just build-ipa`, checks libtix is in the archive
and uploads to TestFlight (`fastlane/Fastfile`, lanes `ios ipa` and `ios testflight`).

Verify: the iOS job's log shows `Successfully uploaded`, and the build appears in App Store Connect → TestFlight
after processing. Before an App Store submission the app also needs a privacy manifest; see the
[roadmap](../ROADMAP.md#store-releases). The certificate expires after a year and the profile with it; replace both
secrets when Apple says so.

### macOS notarisation

Owner, once (same Apple account):

1. **Certificates → Developer ID Application** (only the account holder can create it). Export it with its
   private key as a `.p12`.
2. The App Store Connect API key from [TestFlight](#testflight-ios) is reused for `notarytool`.

| Secret | Value |
| --- | --- |
| `MACOS_CERT_P12_BASE64` | The Developer ID Application `.p12`, base64 |
| `MACOS_CERT_PASSWORD` | Its export password |
| `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_BASE64` | Shared with TestFlight |

What runs: `scripts/macos-notarize.sh` re-signs every nested framework and dylib, then the app, with the hardened
runtime, a timestamp and `macos/Runner/Release.entitlements`, submits it with `notarytool --wait`, staples the
ticket and checks it with `spctl`. The zip asset keeps its name and now holds the notarised app.

Verify: on a Mac, unzip the release asset and run `spctl --assess --type execute --verbose tix.app` (prints
`source=Notarized Developer ID`) and `xcrun stapler validate tix.app`. It opens with a double-click.

### F-Droid

F-Droid builds from source and signs with its own key, so there are no secrets. Nothing in the app is non-free,
so there is no separate Gradle flavour: CI fails any APK that carries Play services, Firebase, Play Core or the
other SDKs F-Droid's scanner rejects (`just fdroid-check`), and APKs leave out AGP's encrypted dependency
metadata, which F-Droid also rejects (`dependenciesInfo` in `android/app/build.gradle.kts`).

- `fdroid/red.tix.tix_mobile.yml` is the recipe for fdroiddata's `metadata/`, and `fdroid/srclibs/tix.yml` the
  srclib for the engine. The embedded engine is tix, AGPL Go, built from the commit `tix.lock` pins: the recipe
  checks that commit out as the `tix` srclib, places it where `hook/build.dart` looks for a cached checkout, and
  installs Go from go.dev with its checksum, so the build fetches nothing unpinned apart from Go modules.
- Three builds per release, one per ABI, with version codes from the `+N` release-please increments in
  `pubspec.yaml` plus Flutter's per-ABI offset (1000+N, 2000+N, 4000+N), which F-Droid's update checker reads
  from the tag (`VercodeOperation`). `just build-fdroid` runs the same build locally.
- Reproducible builds: not claimed yet. Both Flutter and libtix strip paths (`-trimpath` for Go), but our
  release APKs use different version codes and our signature, so F-Droid publishes its own build. Matching them
  would mean F-Droid building the GitHub APK's exact inputs and `Binaries:` plus `AllowedAPKSigningKeys` in the
  recipe; worth doing once a release has been compared byte for byte.

Owner, once: replace the placeholder version in the recipe (v0.4.0 predates this) with the first release that
carries it, check it with `fdroid lint` and `fdroid build -v -l red.tix.tix_mobile` in a clone of fdroiddata,
and open a merge request to <https://gitlab.com/fdroid/fdroiddata> with both files. After that, F-Droid picks up
new tags on its own.

Verify: the app appears at `https://f-droid.org/packages/red.tix.tix_mobile/` a few days after the merge request
lands.

### Flathub

The app id is `red.tix.tix_mobile`, the id the GTK application, desktop entry and icons already have. Renaming
it to something like `red.tix.TixMobile` would move every Linux user's data directory.

- `linux/packaging/red.tix.tix_mobile.metainfo.xml` is the AppStream metadata, installed with the Linux bundle.
  Its `<releases>` come from `CHANGELOG.md` (`just metainfo` refreshes the committed copy, and the Flatpak build
  regenerates it from the tag). `just metainfo` also runs `appstreamcli validate`.
- `flatpak/red.tix.tix_mobile.yml` builds the app and libtix from source on the GNOME runtime, with Go from
  go.dev; `flatpak/build.sh` is its build. It requests network, Wayland/X11, the GPU, the secret service (tokens)
  and notifications, the StatusNotifierWatcher for the tray icon, and no filesystem access: files go through the
  portals, and start at login through the Background portal.

Flathub builds offline, so before submitting, the offline sources are generated next to the manifest (the
manifest names them under `generated/`; rename to match what the tools write):

- The Flutter SDK's engine artifacts and every pub package `pubspec.lock` pins, with
  [flatpak-flutter](https://github.com/TheAppgineer/flatpak-flutter), run on the manifest.
- tix's Go modules, unpacked as `tix-src/vendor`, with [flatpak-go-mod](https://github.com/dennwc/flatpak-go-mod)
  run on a tix checkout at the `tix.lock` commit.
- [flathub/shared-modules](https://github.com/flathub/shared-modules) as a `shared-modules` git submodule beside
  the manifest, for `libayatana-appindicator` (the tray icon). Its sources are downloads Flathub fetches like any
  other, so it needs nothing generated.

Neither has been run yet, and the manifest has not been built: that needs `flatpak-builder` and the generated
files, and is the first step below.

Owner, once:

1. Decide the id. `red.tix.*` needs the `tix.red` domain verified on Flathub; without it, an
   `io.github.heliopsy.*` id is the alternative, at the cost of the data directory move above.
2. Set the manifest's tag and commit to the first release that carries `flatpak/build.sh`, generate the sources,
   and build locally: `flatpak-builder --user --install --force-clean build-dir flatpak/red.tix.tix_mobile.yml`.
3. Add screenshots to the metainfo (Flathub requires them; hosted at a stable URL such as a tagged raw GitHub
   file).
4. Follow <https://docs.flathub.org/docs/for-app-authors/submission>: a pull request to `flathub/flathub` on the
   `new-pr` branch with the manifest and generated files.

Verify: `flatpak run red.tix.tix_mobile` starts, signs in, and keeps the token across restarts (the secret
service), and Flathub's linter (`flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest
flatpak/red.tix.tix_mobile.yml`) passes.

### Not wired yet

- **App Store** (beyond TestFlight): a privacy manifest, screenshots and the review.
- **Windows** signing: needs a code-signing certificate; nothing is wired.
