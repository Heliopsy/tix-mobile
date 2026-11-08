# Design

## Context

`LocalEngines` already runs at most one engine: `ensure` stops every other instance's engine first, the session
stops all of them when the active context is remote, and phones suspend them on pause and resume them on the same
address. Nothing stops an engine while the app sits in the foreground, and phones and macOS can only import a
copy of a database (SQLite needs a real path it can lock, and writes `-wal` and `-shm` files beside the database).

## Goals / Non-Goals

**Goals:** an idle engine stops by itself and comes back without the person noticing; the person can see and stop
engines; a database in a synced folder can be used where it is on every platform, as safely as SQLite allows.

**Non-Goals:** several writers on one synced file; SAF content URIs; merging sync conflicts.

## Decisions

### Idle stop and transparent restart

Every request to a local instance goes through a Dio interceptor (`LocalWakeInterceptor`) added to the session's
client. Before the request it calls `LocalEngines.wake`, which starts the engine if it is stopped and resets the
idle timer, and it rewrites the request's base URL to the engine's current address. After the answer it resets the
timer again. When the timer fires (default 10 minutes, `settings.local_idle_minutes`, 0 for never) the engine
*rests*: it stops and its address is remembered, and the next `wake` asks for that address back. Only when the port
is taken does the session rebuild, through the existing `moved` stream. The event socket is not a request: it
does not keep the engine awake, and it reconnects on its own backoff once the engine is back.

Rejected: a timer tied to screen interaction (a list on screen that never asks for anything would still keep the
engine running) and a loopback proxy in Dart (another server to keep alive, for the same result).

### Engine state on the Instances screen

`LocalEngines` publishes a status per instance (stopped, starting, running with its address, resting) on a
broadcast stream, and its conflict findings. The Instances card reads it through a provider and shows a Stop
button while the engine runs. Stop rests the engine, so the active instance comes back on the next request.

### Open in place, per platform

A `LocalFileAccess` service in `core/platform` hides the platform:

| Platform | How the file is reached | What is stored |
| --- | --- | --- |
| Linux, Windows | The system open and save dialogs give a real path | `dbPath`, `inPlace: true` |
| Android | An in-app browser over shared storage, after "All files access" | `dbPath`, `inPlace: true` |
| iOS, macOS | A native folder picker; a security-scoped bookmark of the folder | `dbPath`, `bookmark`, `inPlace: true` |

The Apple platforms bookmark the *folder*, not the file: the sandbox grants access to what was picked, and SQLite
must create `-wal`, `-shm` and journal files beside the database. Before the engine starts, the bookmark is
resolved and `startAccessingSecurityScopedResource` is called; after it stops, access is released. A stale bookmark
is recreated from the resolved URL and saved; one that no longer resolves asks the person to pick the folder again.

### Android and Google Play

`MANAGE_EXTERNAL_STORAGE` is a restricted permission on Google Play: an app must justify it as a core feature, and a
task tracker opening its own database file in a synced folder may be refused. The permission therefore lives in an
overlay manifest (`android/app/src/allFilesAccess/AndroidManifest.xml`) that Gradle merges unless the build is made
with `-PtixAllFilesAccess=false`. The app asks the platform whether the permission is declared and offers open in
place only when it is, so a Play build simply has no such option and keeps importing copies. Below Android 11 the
overlay declares `WRITE_EXTERNAL_STORAGE` (up to API 29) and `requestLegacyExternalStorage` instead. The permission
is asked for only when the person picks open in place, after a screen that says why; refused, the screen falls
back to importing a copy.

SAF content URIs are not used: SQLite cannot lock or create siblings through a content provider.

### Refusing files SQLite cannot use safely

Before opening in place, `probeInPlace` checks, in Dart, that a file can be created and deleted in the folder (for
the `-wal` and `-shm` files), that an existing file starts with the SQLite header, and that it can take and release
an exclusive lock. On Apple platforms the native side also reports whether the file is an iCloud item that is not
downloaded yet; such a file is refused with a message, and its download is started. A cloud provider that hands
over a placeholder fails the header or the lock check and is refused, rather than opened and corrupted.

### Sync safety

A database synced by Nextcloud, Syncthing or iCloud is safe only with one writer at a time and when the sync
client never swaps the file while it is open. The app cannot enforce either, so it:

- warns, before opening in place, that the file must not be open on another device at the same time;
- looks for conflict copies next to the file when it opens and whenever its engine starts (`name (conflicted
  copy ...).db`, `name.sync-conflict-....db`, `name (1).db`, `name 2.db`, anything with `conflict` in its name)
  and shows them on the connect screen and the Instances card;
- warns when a `-wal` file is already beside the database before the engine starts (another program has it open,
  or a sync client copied one from another device);
- stops in-place engines whenever the app is hidden or paused, on every platform. tix closes the database on stop,
  and SQLite checkpoints the write-ahead log into the file and removes `-wal` when the last connection closes, so
  the sync client sees one consistent file. The Linux integration test checks that `-wal` is gone after a stop.

tix opens every database in WAL mode and refuses any other (`verifyJournalMode`). `journal_mode=DELETE` would keep
everything in one file at every moment, which is safer for a sync client that picks up changes while the app is
open; that needs a small option in tix's `embedded.Options` and is proposed there separately.

## Risks / Trade-offs

- A sync client that rewrites the file while the engine runs can still corrupt it. Mitigation: the warning, the
  background stop and the idle stop keep the window short.
- The Apple code cannot be exercised in PR CI (iOS and macOS build on main only) or on a device here; the Dart side
  is covered with a fake `LocalFileAccess`.
- A Play build without the permission loses open in place on Android; it keeps import and export.
