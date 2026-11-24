## ADDED Requirements

### Requirement: The screen explains CalDAV before setup

The Tasks in other apps screen SHALL say in visible text that it lets other apps on this device show the active context's tix tasks over CalDAV, that the app itself keeps syncing through the tix API, and, while the server reads only, that changes made in the other app do not come back.

#### Scenario: Read-only server

- **WHEN** a person opens the screen and `dav.info` answers `enabled: true, write: false`
- **THEN** the lead text says tasks are shown in other apps and changes there are not sent back

### Requirement: Setup is offered only where the server serves CalDAV

The screen SHALL ask `dav.info` with the connection's own credential and offer setup only when it answers `enabled: true`. A local instance, a 404 or 405, `enabled: false`, and a 403 or a `reason` SHALL each show their own explanation and no setup. A network failure SHALL show an error with Retry.

#### Scenario: Older server

- **WHEN** `dav.info` answers 404
- **THEN** the screen says the server does not offer CalDAV yet and names the tix version that does, with no Set up action

#### Scenario: Local instance

- **WHEN** the active context is a local instance
- **THEN** the screen says other apps cannot reach a database on this device, and sends no request

#### Scenario: Credential not allowed

- **WHEN** `dav.info` answers 403 for a token connection
- **THEN** the screen shows tix's message and says a sign-in can set it up instead

### Requirement: Setup mints a dedicated app password

Set up SHALL create one app password with `dav.password.create`, named after the app, the platform and the day unless the person changes the name. A conflict or refusal SHALL show tix's message and leave the sheet open.

#### Scenario: Default name

- **WHEN** a person sets up on an iPhone on 2027-03-01 without editing the name
- **THEN** the request names the password "tix app, iOS, 2027-03-01"

#### Scenario: Name taken

- **WHEN** `dav.password.create` answers 409
- **THEN** the sheet stays open with tix's message under the name field

### Requirement: The app password is never kept

The app password SHALL exist only in the create answer, the open setup sheet and the hand-off it starts. It SHALL never be written to the response cache, preferences, secure storage, files beyond a profile deleted when the sheet closes, provider state or the log.

#### Scenario: Sheet closed

- **WHEN** a password is created and the setup sheet is closed
- **THEN** neither the cache, the preferences, secure storage, provider state nor the log holds its value, and no profile file remains

### Requirement: Copied passwords are marked sensitive

Copying the app password SHALL mark the clip sensitive on Android 13 and later and make it local-only and expire after 2 minutes on iOS. Each detail SHALL have its own copy button labelled with the field it copies.

#### Scenario: Copy on Android

- **WHEN** a person copies the password on Android 14
- **THEN** the clip carries the sensitive flag and the toast says the password was copied

### Requirement: iOS and macOS get a configuration profile

On iOS and macOS the hand-off SHALL build a `com.apple.caldav.account` profile with tix's `url` and `username` and the password, identified per connection, and show the install steps and the unsigned-profile warning before opening it.

#### Scenario: Profile contents

- **WHEN** a profile is built for connection `c1` on `https://tix.example.com/dav/`
- **THEN** its payload has host `tix.example.com`, SSL on, the principal URL, tix's user name, and identifier `red.tix.mobile.caldav.c1`

#### Scenario: Set up again

- **WHEN** a person sets up twice on the same connection
- **THEN** both profiles carry the same payload identifier, so the second replaces the first

### Requirement: iOS opens the profile in Safari once

On iOS the app SHALL serve the profile from `127.0.0.1` at a random path, to one request, for at most 2 minutes, and open that address in Safari. When Safari has not fetched it, the sheet SHALL offer to save the profile through the share sheet.

#### Scenario: Served once

- **WHEN** Safari fetches the profile and the same address is asked again
- **THEN** the second request gets no profile and the server has closed

#### Scenario: Never fetched

- **WHEN** 2 minutes pass without a request
- **THEN** the server closes and the sheet offers Save the profile

### Requirement: macOS opens the profile in System Settings

On macOS the app SHALL write the profile to its temporary directory, open it with the system's handler, and delete it when the sheet closes or on the next start.

#### Scenario: Cleaned up

- **WHEN** the setup sheet closes after the profile was opened
- **THEN** the profile file is gone

### Requirement: Android hands off to DAVx5

On Android, when `at.bitfire.davdroid` is installed, the hand-off SHALL open DAVx5's login with a `caldavs://` address (`caldav://` for http) and the user name and password as intent extras, never in the address.

#### Scenario: DAVx5 installed

- **WHEN** a person taps Open DAVx5
- **THEN** an intent for `at.bitfire.davdroid` carries data `caldavs://tix.example.com/dav/` and the extras `username` and `password`

#### Scenario: DAVx5 fails to open

- **WHEN** starting DAVx5 fails
- **THEN** the sheet shows the details with copy buttons

### Requirement: Without DAVx5 the details and installs are offered

On Android without DAVx5 the sheet SHALL show the details with copy buttons and links to DAVx5 and to tasks.org and jtx Board, from F-Droid in the oss build and Google Play in the play build.

#### Scenario: Play build

- **WHEN** the play build runs on a phone without DAVx5
- **THEN** the links open the Google Play pages for DAVx5, tasks.org and jtx Board

### Requirement: Desktops show details for their clients

On Linux and Windows the sheet SHALL show the address, user name and password with copy buttons and steps for Thunderbird, and on Linux for Evolution. Every platform SHALL offer the same details as a fallback.

#### Scenario: Linux

- **WHEN** a person sets up on Linux
- **THEN** the sheet shows the three details with copy buttons and the Thunderbird and Evolution steps

### Requirement: App passwords are listed and revoked

The screen SHALL list the caller's app passwords from `dav.password.list` with name, created, last use ("Not yet" when none) and state, and revoke one with `dav.password.revoke` after a red confirmation naming it.

#### Scenario: Revoke

- **WHEN** a person revokes "tix app, iOS, 2027-03-01" and confirms
- **THEN** the app calls `DELETE /api/v1/dav/passwords/{id}` and the row reads revoked

### Requirement: App password state is not a connection refusal

The app SHALL never send an app password in a request of its own. A revoked or unused app password SHALL be drawn as a row state, never with `RefusedMark`, and SHALL leave the connection's refusal mark as it was.

#### Scenario: Revoked password row

- **WHEN** the list holds a revoked app password
- **THEN** the row says Revoked, the connection is not marked refused, and no notification is shown

#### Scenario: Own credential refused

- **WHEN** `dav.password.list` answers 401
- **THEN** the connection is handled as any refused credential and reconnect opens

### Requirement: Each context has its own setup

The screen SHALL follow the active context. Switching context SHALL close an open setup sheet and dismiss its password, and the list SHALL show the passwords of the new context's account on its server.

#### Scenario: Switch while the sheet is open

- **WHEN** a person switches context with the setup sheet open
- **THEN** the sheet closes and the screen lists the other account's passwords

### Requirement: Write-back is announced when the server takes writes

When `dav.info` answers `write: true`, the lead text SHALL say changes in the other app come back to tix, and a password without the write scope SHALL be marked Read only with Replace, which sets up a new one and then offers to revoke the old.

#### Scenario: Replace a read-only password

- **WHEN** a person replaces a read-only password and finishes the hand-off
- **THEN** the app offers to revoke the old password by name
