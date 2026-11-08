# Releasing

Releases are cut by [release-please](https://github.com/googleapis/release-please) from Conventional Commits on
`main`. Nobody edits a version number or a changelog by hand.

## The flow

1. Pull requests merge to `main` with a Conventional Commit title. `fix:` is a patch, `feat:` a minor, and `feat!:`
   or a `BREAKING CHANGE:` footer a major.
2. The `release-please` workflow keeps one open release pull request that bumps the version in `pubspec.yaml`,
   updates `CHANGELOG.md`, and lists what will ship.
3. Merging that pull request tags the commit (`vX.Y.Z`) and creates the GitHub release.
4. The `release` workflow builds every artifact for that tag and attaches them to the release.

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

Every release also carries `SHA256SUMS` over all of them, and each artifact has a GitHub build provenance
attestation. Users verify with:

```sh
sha256sum --check --ignore-missing SHA256SUMS
gh attestation verify <file> --repo heliopsy/tix-mobile
```

No iOS artifact is published until iOS signing exists.

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

### iOS

Not set up yet. It needs an Apple developer account, a distribution certificate and provisioning profile stored as
secrets, and an App Store Connect API key for upload. Until then `just build-ipa` works only on a Mac with signing
configured in Xcode, and nothing iOS is attached to a release.

### macOS and Windows

The macOS and Windows archives are not code-signed or notarised yet. macOS Gatekeeper and Windows SmartScreen warn
on first launch; the checksum and provenance attestation are the way to check a download until signing lands.

## When a release goes wrong

- **No artifacts on a release.** A tag created with the workflow's own `GITHUB_TOKEN` cannot start another
  workflow. Dispatch the `release` workflow by hand with the tag; it rebuilds an existing tag.
- **The release pull request's checks never run.** A pull request opened by `GITHUB_TOKEN` gets its checks held for
  approval. Approve only the runs whose head is the current commit; approving a stale run replays it with the
  workflow file it was created against.
- **The release pull request predates a workflow fix.** release-please does not rebase its branch when the release
  content has not changed. Close it and let the next push to `main` open a fresh one.

## Store releases

Google Play, the App Store, F-Droid and Flathub are on the [roadmap](../ROADMAP.md#store-releases), not part of the
release flow today.
