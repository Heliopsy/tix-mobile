# Proposal

## Why

The first App Store update (0.20.1) failed at submission: App Review refuses any version after the first without
What's New, and the promote workflow never set it. It had to be typed in App Store Connect and the job run again.

## What Changes

- The App Store job of `promote` builds What's New from `CHANGELOG.md`: the user-facing changes (features, fixes,
  performance, reverts) since the version live on the App Store, as short lines without scopes, hashes or links,
  cut at Apple's 4000 characters.
- Before submitting it sets that text on every locale of the version that has no What's New. Text already there
  is kept. The first version, which cannot have What's New, is left alone.
- The dry run prints the text and which locales would get it, and changes nothing.
- `scripts/store-whatsnew.sh` writes the text and has a `--self-test` that CI runs.
- Google Play is unchanged: promotion carries over the internal release's notes.

## Impact

- Capabilities: `release-channels`.
- Code: `scripts/store-whatsnew.sh`, `fastlane/Fastfile` (`ios promote`), `justfile`, `.github/workflows/ci.yaml`,
  `docs/releasing.md`.
