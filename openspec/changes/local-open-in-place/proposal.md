# Proposal

## Why

Two things the owner asked for. A local instance's engine keeps running while the person works in another
instance or leaves the app open on one screen, and its workers wake every minute: that drains a phone's battery
for nothing. And phones and macOS only ever work on an imported copy of a database, so a file kept in a folder
that Nextcloud, Syncthing or iCloud Drive syncs cannot be used from the app at all.

## What Changes

- The rules that already keep one engine running at a time get tests that fail if they regress: switching to a
  remote context or another local instance stops the engine, a phone stops it in the background, and launching
  the app starts nothing unless the active context is local.
- An engine that has served no request for a while (10 minutes by default, a setting) stops, and starts again,
  on the same address when it can, the next time a request needs it.
- The Instances screen shows each local instance's engine: running or stopped, its file, and a Stop button.
- Adding a local instance gets an advanced choice, open in place, that uses a database where it is:
  - Android: a real path in shared storage, with "All files access" asked for only when this is chosen. A build
    flag leaves the permission out, for Google Play.
  - iOS and macOS: a folder the person picks, kept through a security-scoped bookmark that is resolved, and
    refreshed when stale, each time the engine starts.
  - Linux and Windows: the existing open-a-file flow, moved under the same advanced choice.
- Opening in place warns that a synced file needs one writer at a time, refuses a file it cannot lock or that a
  cloud provider has not downloaded, points out sync-conflict copies next to the file, and stops the engine
  (which checkpoints the write-ahead log into the file) whenever the app goes to the background.

## Impact

- Capability: `local-instances` (modified and added requirements).
- Code: `core/session/local.dart`, `core/session/session.dart`, `core/platform/` (a local file access service),
  `data/local/`, the connect and instances screens, the settings screen (idle timeout), `Instance` gains
  `inPlace` and `bookmark`.
- Native: an Android method channel and an optional manifest overlay; iOS and macOS method channels for folder
  picking and bookmarks; the macOS app-scope bookmark entitlement.
- No new dependencies.
