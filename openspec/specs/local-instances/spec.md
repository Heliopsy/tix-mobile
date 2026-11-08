# local-instances Specification

## Purpose
tix databases on this device, served by the embedded engine, and how their tenants are opened.

## Requirements

### Requirement: A local instance is a database file on this device

The app SHALL add a local instance from a `.db` file, either an existing one the person picks or a new one the person names. On Linux and Windows it SHALL use the system open and save dialogs and work on the file in place. On Android, iOS and macOS it SHALL create a new file by name in the app's documents folder.

#### Scenario: New database on a phone

- **WHEN** a person on a phone chooses to create a database named `notes`
- **THEN** the engine is started on `notes.db` in the app's documents folder with `initIfMissing`

#### Scenario: Opening in place on a desktop

- **WHEN** a person on Linux opens `/data/team.db`
- **THEN** the engine is started on `/data/team.db` and the screen says the file stays where it is

### Requirement: The embedded engine serves a local instance over HTTP

A local instance SHALL be served by the embedded tix engine on a loopback address, and the app SHALL talk to it with the same HTTP client and API as a remote instance. The engine SHALL be started when a local context becomes active and stopped when the active context moves to another instance and when the app exits.

#### Scenario: Switching away stops the engine

- **WHEN** a local context is active and the person switches to a remote one
- **THEN** the engine for the local instance is stopped

#### Scenario: The real engine serves a new database

- **WHEN** the engine starts on a new file, creates the tenant `home` and mints a token
- **THEN** `whoami` with that token over HTTP names the tenant `home`

### Requirement: Local tenants are opened with minted tokens

Adding a local instance SHALL list the database's tenants from the engine and let the person open one or create one with a key and a name. Opening a tenant SHALL mint an API token for it through the engine, keep it in secure storage and save a token connection pinned to that tenant. Nothing SHALL be saved unless this succeeds.

#### Scenario: Create a tenant

- **WHEN** a person adds a local database and creates the tenant `home`
- **THEN** the engine creates `home`, mints a token for it, and the active context is the local instance › `home`

### Requirement: An engine that is not available says so

When the build has no engine, starting one SHALL fail with a message saying this build was made without the tix engine, and nothing SHALL be saved. The add-instance screen SHALL offer local databases when the engine loads and SHALL otherwise show the local choice disabled with the same note, unless the local-instances flag overrides it.

#### Scenario: No engine in this build

- **WHEN** a person adds a local database in a build without the engine
- **THEN** the screen says the build has no engine and no instance is saved

#### Scenario: Engine present

- **WHEN** the build bundles the engine and no flag is set
- **THEN** the add-instance screen offers "This device"

### Requirement: Phones and macOS work on an imported copy

On Android, iOS and macOS, opening an existing database SHALL import it: copy the picked file into the app's documents folder under a name not already taken, and open the copy. The screens SHALL say the app works on a copy kept inside it.

#### Scenario: Import on a phone

- **WHEN** a person on a phone picks `team.db`
- **THEN** it is copied to the documents folder and the engine opens the copy

#### Scenario: Name taken

- **WHEN** `team.db` already exists in the documents folder and the person imports another `team.db`
- **THEN** the copy is saved as `team-2.db`

### Requirement: An imported database can be exported

A local instance kept as a copy SHALL offer Export. Export SHALL stop the instance's engine so the file holds every write, hand the file to the share sheet on phones or a save dialog on macOS, and start the engine again if it was running. A file used in place SHALL NOT offer Export.

#### Scenario: Export the active instance

- **WHEN** a person exports the active local instance on a phone
- **THEN** its engine stops, the file goes to the share sheet, and the engine runs again afterwards

### Requirement: Engines rest while a phone app is in the background

On Android and iOS the app SHALL stop every running engine gracefully when it goes to the background and start them again when it returns, on the same loopback address when that is free. When the address changed, the active session SHALL rebuild against the new one. Desktops SHALL keep engines running while minimised.

#### Scenario: Background and back

- **WHEN** a local context is active on a phone and the app is paused and then resumed
- **THEN** the engine is stopped while paused and serves the same address after resuming

#### Scenario: Port taken on resume

- **WHEN** the old port is taken when the app resumes
- **THEN** the engine starts on another port and the session uses it

### Requirement: Every release build carries the engine

The build SHALL compile the engine from the tix commit pinned in `tix.lock` for the target being built. A build without Go SHALL succeed without the engine. CI and release builds SHALL fail unless every artifact carries it, and Android artifacts SHALL store it uncompressed and 16 KB aligned.

#### Scenario: Artifact without the engine

- **WHEN** a CI build produces an APK without `libtix.so`
- **THEN** the build job fails
