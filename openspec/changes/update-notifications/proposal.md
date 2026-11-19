# Proposal

## Why

An update only showed in Settings, About and the desktop tray. People who never open those, which is nearly
everyone on a phone, ran old versions for weeks. App Store builds never checked at all, so they could not
even suggest updating.

## What Changes

- The automatic check runs at start and every three hours (with a few minutes of jitter) instead of every six.
- A newer version raises a system notification, once per version: "tix 0.21.0 is available" with wording that
  matches what the build does with it (download from the release page, update from the App Store, restart to
  update, or install on quit). Tapping it opens About, where the update panel is, or the App Store page in an
  App Store build. It respects "Check for updates" and the OS notification permission, and is on its own Android
  channel ("Updates").
- While the app is closed on a phone the same check runs from the background paths that already exist: iOS's
  background refresh and a new Android WorkManager job, both limited to once every three hours by a stored
  time of the last check. The OS decides when they actually run.
- App Store builds get a `store` update mode: they ask Apple's public lookup which version the App Store serves
  and link to the App Store page. TestFlight, simulator and debug builds stay off.
- Google Play, F-Droid, Flatpak and Snap stay off. Play's in-app update API comes from the Play Core library,
  which `scripts/fdroid-check.sh` rejects and the same Gradle build makes the F-Droid APKs, and there is no
  public lookup of the version Play serves; Play updates the app itself.
- The "Check for updates" subtitle says it also notifies; no new switch.

## Impact

- Capabilities: `self-update`.
- Code: `lib/src/core/update/` (`updates.dart`, new `update_notice.dart`), `lib/src/data/update/` (`updater.dart`,
  new `store_feed.dart`), `core/notifications/local_notifier.dart` (permission check, update channel),
  `core/widgets/desktop_host.dart` and `update_panel.dart`, `main.dart`, settings, l10n (en, bg, de, fr), Android
  `MainActivity.kt` and `widgets/Receivers.kt`.
- Docs: README, `docs/architecture.md`, `docs/widgets.md`.
