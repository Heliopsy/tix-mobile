# adb-control Specification

## Purpose
Reading and driving the Android app from a computer over ADB: the dumpsys state report, tix:// links, and shell-only commands with their gating and redaction.

## Requirements

### Requirement: dumpsys prints the app's state

On Android, `dumpsys activity service` for the app's ADB service SHALL print the version and build, the theme,
the language, the saved contexts by name and host, the live status and connection details report, the outbox and
open conflicts per context, and the local engine. It SHALL never print a token, password, cookie or URL query.

#### Scenario: Reading the outbox

- **WHEN** a developer runs dumpsys for the service with the argument `outbox`
- **THEN** it prints the app line and the waiting writes and conflicts per context, and no other section

#### Scenario: App not open

- **WHEN** dumpsys runs while no Flutter engine is up
- **THEN** it prints the version and the contexts from the widget index, and says to run it again

### Requirement: tix links navigate

On Android, `tix://inbox`, `mine`, `tasks`, `projects`, `projects/<KEY>`, `projects/<KEY>/tasks/<ref>`,
`settings`, `about` and `connection` SHALL open their screen, or the connection details, and change no data.

#### Scenario: A task link

- **WHEN** `tix://projects/OPS/tasks/OPS-12` is opened
- **THEN** the app shows task OPS-12

### Requirement: Links name a context

A link's `context` parameter SHALL switch to the saved context it names before navigating. When it names several
other contexts the app SHALL ask which one, and when it names the active one the app SHALL stay.

#### Scenario: Ambiguous name

- **WHEN** a link says `?context=acme` and two saved contexts are called Acme, neither active
- **THEN** the app asks which one, and navigates only after one is picked

### Requirement: Unknown links go home

A `tix://` link the app does not know, or naming no saved context, SHALL show "Link not recognised" and go to the
start screen.

#### Scenario: Unknown path

- **WHEN** `tix://nowhere` is opened
- **THEN** the toast says the link is not recognised and the start screen shows

### Requirement: Commands over am broadcast

On Android, a broadcast `red.tix.ADB` to the app's ADB receiver SHALL run the command in `cmd`: reconnect,
sync-now, switch, quick-add, open, engine-stop, engine-start, clear-cache, theme, locale, dump or help. It SHALL
answer in the broadcast's result data and in logcat under `tix-adb`.

#### Scenario: Theme

- **WHEN** a developer broadcasts `cmd` `theme` with `value` `dark` in a debug build
- **THEN** the app turns dark and the broadcast prints `theme: dark`

#### Scenario: Unknown command

- **WHEN** `cmd` is `format-disk`
- **THEN** the broadcast prints that the command is unknown and to try help

### Requirement: Only the shell sends commands

The receiver SHALL accept broadcasts only from senders holding the DUMP permission. Commands SHALL never take a
credential, and an extra named like one SHALL be refused.

#### Scenario: Token extra

- **WHEN** a broadcast carries an extra called `token`
- **THEN** it is refused and nothing runs

### Requirement: Release builds ask first

A release build SHALL run commands other than help and dump only while Allow control over ADB is on, and SHALL
answer the others with how to turn it on. Debug builds SHALL run every command.

#### Scenario: Setting off

- **WHEN** a release build gets `switch` with the setting off
- **THEN** it answers `disabled: enable Settings > Advanced > Allow control over ADB` and nothing changes
