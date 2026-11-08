# local-instances Specification

## Purpose
tix databases on this device, served by the embedded engine, and how their tenants are opened.

## Requirements

### Requirement: A local instance is a database file on this device

The app SHALL add a local instance from a `.db` file, either an existing one the person opens or a new one the person names. On desktop it SHALL use the system open and save dialogs. On phones it SHALL use the system open dialog and SHALL create a new file in the app's documents folder by name.

#### Scenario: New database on a phone

- **WHEN** a person on a phone chooses to create a database named `notes`
- **THEN** the engine is started on `notes.db` in the app's documents folder with `initIfMissing`

### Requirement: The embedded engine serves a local instance over HTTP

A local instance SHALL be served by the embedded tix engine on a loopback address, and the app SHALL talk to it with the same HTTP client and API as a remote instance. The engine SHALL be started when a local context becomes active and stopped when the active context moves to another instance and when the app exits.

#### Scenario: Switching away stops the engine

- **WHEN** a local context is active and the person switches to a remote one
- **THEN** the engine for the local instance is stopped

### Requirement: Local tenants are opened with minted tokens

Adding a local instance SHALL list the database's tenants from the engine and let the person open one or create one with a key and a name. Opening a tenant SHALL mint an API token for it through the engine, keep it in secure storage and save a token connection pinned to that tenant. Nothing SHALL be saved unless this succeeds.

#### Scenario: Create a tenant

- **WHEN** a person adds a local database and creates the tenant `home`
- **THEN** the engine creates `home`, mints a token for it, and the active context is the local instance › `home`

### Requirement: An engine that is not available says so

When the build has no engine, starting one SHALL fail with a message saying local databases are not available in this build yet, and nothing SHALL be saved. Without the local-instances flag, the add-instance screen SHALL show the local choice disabled with the same note.

#### Scenario: No engine in this build

- **WHEN** a person adds a local database in a build without the engine
- **THEN** the screen says local databases are not available yet and no instance is saved
