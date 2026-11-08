# local-instances

## MODIFIED Requirements

### Requirement: A local instance is a database file on this device

The app SHALL add a local instance from a `.db` file, either an existing one the person picks or a new one the person names. On Linux and Windows a new file SHALL be placed with the system save dialog, and an existing file SHALL be opened in place through the advanced choice. On Android, iOS and macOS a new file SHALL be created by name in the app's documents folder.

#### Scenario: New database on a phone

- **WHEN** a person on a phone chooses to create a database named `notes`
- **THEN** the engine is started on `notes.db` in the app's documents folder with `initIfMissing`

#### Scenario: Opening in place on a desktop

- **WHEN** a person on Linux chooses open in place and picks `/data/team.db`
- **THEN** the engine is started on `/data/team.db`, the instance is saved as used in place, and the screen says the file stays where it is

### Requirement: Engines rest while a phone app is in the background

On Android and iOS the app SHALL stop every running engine gracefully when it goes to the background and start them again when it returns, on the same loopback address when that is free. When the address changed, the active session SHALL rebuild against the new one. Desktops SHALL keep engines of imported or app-created files running while minimised.

#### Scenario: Background and back

- **WHEN** a local context is active on a phone and the app is paused and then resumed
- **THEN** the engine is stopped while paused and serves the same address after resuming

#### Scenario: Port taken on resume

- **WHEN** the old port is taken when the app resumes
- **THEN** the engine starts on another port and the session uses it

## ADDED Requirements

### Requirement: Only the active local instance runs an engine

At most one engine SHALL run. Making a remote context active SHALL stop it, making another local instance active SHALL stop the previous one first, and launching the app SHALL start an engine only when the active context is local.

#### Scenario: Local to remote

- **WHEN** a local context is active and the person switches to a remote one
- **THEN** no engine runs

#### Scenario: Local to another local

- **WHEN** local instance A is active and the person switches to local instance B
- **THEN** A's engine is stopped before B's starts

#### Scenario: Launch with a remote context

- **WHEN** the app starts with a remote context active and local instances saved
- **THEN** no engine is started

### Requirement: An idle engine stops and comes back on demand

An engine that has served no request for the idle timeout SHALL stop, while the app is in the foreground too. The timeout SHALL default to 10 minutes and be a setting, with a choice that never stops. The next request SHALL start the engine again before it is sent, on the same address when that is free, without the person doing anything.

#### Scenario: Idle and back

- **WHEN** a local context has made no request for 10 minutes
- **THEN** the engine is stopped, and the next request starts it on the same address and succeeds

#### Scenario: Never

- **WHEN** the idle timeout is set to never
- **THEN** the engine keeps running however long no request comes

### Requirement: The Instances screen shows each engine

The Instances screen SHALL show, for each local instance, whether its engine is running or stopped and the file it serves. A running engine SHALL offer Stop, which stops it; for the active instance the next request starts it again.

#### Scenario: Stop from the Instances screen

- **WHEN** the active local instance's engine runs and the person presses Stop on its card
- **THEN** the card says stopped and no engine runs until the next request

### Requirement: Open in place is an advanced choice on every platform

Adding a local instance SHALL offer an advanced choice to open a database in place. Linux and Windows SHALL use the system dialogs; Android SHALL browse shared storage; iOS and macOS SHALL pick the database's folder and keep a security-scoped bookmark of it. The instance SHALL be saved as used in place and SHALL NOT offer Export.

#### Scenario: Open in place on macOS

- **WHEN** a person on macOS chooses open in place, picks the folder `Nextcloud/tix` and the file `team.db` in it
- **THEN** the engine opens `Nextcloud/tix/team.db` itself and the instance keeps a bookmark of `Nextcloud/tix`

### Requirement: Android asks for All files access only for open in place

On Android 11 and later, open in place SHALL need "All files access". The app SHALL ask for it only when the person chooses open in place, after saying why, and SHALL fall back to importing a copy when it is refused. A build made without the permission SHALL NOT offer open in place on Android.

#### Scenario: Refused

- **WHEN** a person chooses open in place and does not grant All files access
- **THEN** the screen says so and offers to import a copy instead

#### Scenario: Play build

- **WHEN** the app was built with `-PtixAllFilesAccess=false`
- **THEN** the Android add-instance screen offers no open in place

### Requirement: Bookmarks are resolved around every engine start

On iOS and macOS the app SHALL resolve an in-place instance's bookmark and start accessing it before its engine starts, and stop accessing it after the engine stops. A stale bookmark SHALL be renewed and saved. A bookmark that no longer resolves SHALL be the session problem, asking the person to pick the folder again.

#### Scenario: Stale bookmark

- **WHEN** the engine starts for an in-place instance whose bookmark is stale
- **THEN** the renewed bookmark is saved on the instance and the engine starts

### Requirement: Files SQLite cannot use safely are refused

Before opening in place the app SHALL check that it can create a file in the database's folder, that an existing file is an SQLite database and that it can lock it. On Apple platforms an iCloud file that is not downloaded SHALL be refused. A refused file SHALL be explained and nothing SHALL be saved.

#### Scenario: Placeholder from a cloud provider

- **WHEN** the picked file does not start with the SQLite header
- **THEN** the screen says the file is not available on this device as a database and no instance is saved

### Requirement: Opening in place warns about sync

Choosing open in place SHALL show a warning that a synced database must be open on one device at a time. When the database is opened, and whenever its engine starts, the app SHALL look for sync-conflict copies of it in its folder and a leftover `-wal` file, and SHALL show what it found on the connect screen and the Instances card.

#### Scenario: Conflict copy

- **WHEN** `team (conflicted copy 2026-11-08).db` sits next to `team.db`
- **THEN** the Instances card names it as a conflict copy

### Requirement: In-place engines stop in the background on every platform

An engine of a database used in place SHALL stop whenever the app is hidden or paused, on desktops too, so its write-ahead log is checkpointed into the file before a sync client reads it.

#### Scenario: Desktop minimised

- **WHEN** an in-place instance's engine runs on Linux and the app is hidden
- **THEN** the engine is stopped and no `-wal` file is left beside the database
