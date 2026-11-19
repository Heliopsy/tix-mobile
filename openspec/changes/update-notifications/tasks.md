# Tasks

## 1. Spec

- [x] 1.1 `self-update` delta

## 2. Checks and notifications

- [x] 2.1 Check at start and every three hours, with jitter, and record the time of the last automatic check
- [x] 2.2 Notify a newer version once per version, only where notifications are allowed, on an "Updates" channel
- [x] 2.3 Open About, or the App Store page in a store build, from a tapped or launching notification
- [x] 2.4 "Check for updates" subtitle says it notifies; store wording in Settings and the update panel

## 3. Background

- [x] 3.1 Run the check from the headless engine for `tixwidget://refresh` and `tixwidget://update`, at most once
  every three hours
- [x] 3.2 Android `UpdateWorker` every three hours, scheduled and cancelled from Dart over `tix/update`

## 4. Store builds

- [x] 4.1 `store` mode for App Store installs (not TestFlight, simulator or debug), from Apple's lookup
- [x] 4.2 Play, F-Droid, Flatpak and Snap stay off, with the reason in the docs

## 5. Docs and tests

- [x] 5.1 README, `docs/architecture.md`, `docs/widgets.md`
- [x] 5.2 Unit tests for once per version, the rate limit, mode selection and the lookup; widget tests for the
  panel, Settings and the notification tap
