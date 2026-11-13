# Proposal

## Why

A release reaches Google Play's internal track and TestFlight on its own, and stops there. Moving it on to
production meant clicking through the Play Console and App Store Connect, which is easy to get wrong (the wrong
build, a forgotten export compliance answer) and leaves no record. The other Heliopsy apps have a manual promote
workflow for this; tix-mobile should have the same.

## What Changes

- A `promote` workflow, started by hand only, with the store (both, Google, Apple), the version (empty takes the
  newest published release), the Play rollout in percent and a dry run switch.
- Google Play: the version code release.yaml stamped on that tag moves from the internal track to production,
  as a draft while `PLAY_RELEASE_STATUS` is unset, otherwise completed or as a staged rollout.
- App Store: the version's newest processed TestFlight build is attached to the App Store version and submitted
  for review, with export compliance answered.
- A dry run checks the credentials and that the build is there, prints what would be promoted, and changes
  nothing. Nothing to promote is a warning on a dry run and a failure on a real one.
- Missing credentials skip a store the same way release.yaml does.

## Impact

- Capabilities: `release-channels`.
- Code: `.github/workflows/promote.yaml`, `fastlane/Fastfile` (`android promote`, `ios promote`),
  `docs/releasing.md`, `README.md`.
