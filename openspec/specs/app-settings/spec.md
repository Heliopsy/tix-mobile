# app-settings Specification

## Purpose
What a person can set, grouped by where it is kept: on this device, with their account on the server, or for the whole tenant.

## Requirements

### Requirement: Theme mode is chosen

Settings SHALL offer system, light, dark and OLED black themes, apply the choice at once and remember it across
launches on this device. The default SHALL be system.

#### Scenario: Dark chosen

- **WHEN** a person picks dark and restarts the app
- **THEN** the app is dark

#### Scenario: OLED black chosen

- **WHEN** a person picks OLED black
- **THEN** the app is dark on a pure black page at once, and still is after a restart

### Requirement: Language is chosen

The app SHALL be translated into English, Bulgarian, French and German. Settings SHALL offer the system language
and each of those, each named as its own readers write it, and SHALL remember the choice.

#### Scenario: Bulgarian chosen

- **WHEN** a person picks Български
- **THEN** the app's own text is Bulgarian at once

#### Scenario: German chosen

- **WHEN** a person picks Deutsch
- **THEN** the app's own text is German at once

### Requirement: The system theme can go black

Under the system theme, Settings SHALL offer a switch that draws the system's dark as OLED black. The switch
SHALL be remembered on this device and SHALL NOT be shown for the other themes.

#### Scenario: System dark goes black

- **WHEN** the theme is system, the switch is on and the platform turns dark
- **THEN** the app is dark on a pure black page

### Requirement: Unknown languages fall back to English

When none of the platform's preferred languages is one the app speaks, the app SHALL show English.

#### Scenario: Japanese system

- **WHEN** the system language is Japanese and the app follows the system
- **THEN** the app's text is English

### Requirement: Every language has every string

Every translation SHALL carry every key of the English template with the same placeholders, the same select
cases and at least the English plural's explicit and `other` cases. A test SHALL fail otherwise.

#### Scenario: A key added in English only

- **WHEN** a change adds a key to `app_en.arb` and not to `app_fr.arb`
- **THEN** the test suite fails naming the key

### Requirement: Widget privacy is chosen

Settings SHALL offer a switch, on by default and remembered on this device, that limits widgets on the lock screen
to counts.

#### Scenario: Turned off

- **WHEN** a person turns counts only off
- **THEN** the lock screen inbox widget may show the newest item's text

### Requirement: Settings are grouped by where they are kept

Settings SHALL draw three groups in order: This device, Your account on the active tenant (only with a session),
and This tenant (only for a credential that administers the tenant). Each section SHALL carry a label: "On this
device", "Synced to your account" or "Whole tenant".

#### Scenario: A member

- **WHEN** a member without administrative scopes opens Settings
- **THEN** This device and Your account are shown, each section labelled, and This tenant is not

#### Scenario: An administrator

- **WHEN** a credential with `tenant:admin` opens Settings
- **THEN** This tenant is shown and links to the Manage hub

### Requirement: Motion, touch feedback and the start screen are chosen per device

Settings SHALL offer reduce motion (the app keeps still whatever the platform allows), touch feedback (on by
default) and the screen the app opens on (Projects by default, or Tasks, My work or Inbox). Each SHALL be
remembered on this device only.

#### Scenario: Start on the inbox

- **WHEN** a person picks Inbox as the start screen and starts the app signed in
- **THEN** the app opens on the inbox

#### Scenario: Touch feedback off

- **WHEN** a person turns touch feedback off and completes a task by swiping
- **THEN** the device does not buzz

### Requirement: The date format and time zone are kept with the account

Settings SHALL show the reader's date format and time zone from `GET /me/time`: what is in force, where it came
from (your choice, the tenant default, the server default), and Inherit naming what it would inherit. A choice
SHALL be sent with `PATCH /me/time`, and Inherit SHALL send an empty value.

#### Scenario: Choose dotted

- **WHEN** a person picks Dotted
- **THEN** the app sends `{"time_format": "dotted"}` and the section says it is in use, from your choice

#### Scenario: A token

- **WHEN** the server says the caller is not a person
- **THEN** the controls are replaced by a notice that it reads the tenant's defaults

### Requirement: Account arrangements and filters are managed from Settings

Your account SHALL link to inbox kinds and channels, list saved filters with the task list's menu, and reset the
board, lanes and My work arrangement with `view.reset` after a destructive confirmation. After a reset, even a
partly failed one, every open board, lanes or My work view SHALL read its arrangement again.

#### Scenario: Reset

- **WHEN** a person confirms Reset arrangement
- **THEN** the app resets the `board`, `lanes` and `mine` views on the server

#### Scenario: Open views follow

- **WHEN** My work had a hidden group and the person resets the arrangement from Settings
- **THEN** My work reads its arrangement again and shows the group

### Requirement: Settings can be searched

A search field SHALL filter every setting by its name, its keywords and its section's title, keeping the groups
and labels, and SHALL say when nothing matches. The command palette SHALL offer "Settings: <name>" for every
setting, opening its screen or Settings filtered to it.

#### Scenario: Search for zone

- **WHEN** a person types "zone" into the search
- **THEN** only the time zone setting is shown, under Your account

#### Scenario: Palette

- **WHEN** a person runs "Settings: Touch feedback" from the palette
- **THEN** Settings opens filtered to touch feedback

### Requirement: Account and tenant screens are reached from their group

Your account SHALL link to the profile, security (second factor, SSH keys, sessions), the caller's API tokens with
`token:admin`, and the calendar feed with `task:read`. This tenant SHALL link to the tenant's settings and retention
with `tenant:admin`, webhooks with `webhook:admin`, sync with `sync:admin`, and the Manage hub.

#### Scenario: A member

- **WHEN** a member opens Settings
- **THEN** the calendar feed and security are linked, and neither API tokens nor tenant links are shown

### Requirement: Missing date settings say why

When there are no date settings to show, Settings SHALL say which case it is: still reading (a spinner), a tix
without `/me/time` (this version keeps no date preferences, with no Retry), or a failed request (with Retry).

#### Scenario: Older server

- **WHEN** the server answers 404 to `GET /me/time`
- **THEN** the date section says this version of tix keeps no date preferences and offers no Retry

#### Scenario: Server error

- **WHEN** `GET /me/time` fails with a server error
- **THEN** the date section says the server did not answer and offers Retry

### Requirement: Offline availability is chosen per context

Settings SHALL offer an Offline screen where a person picks, for the active context, which projects stay available
offline and whether My work and Starred do. My work and Starred SHALL be on until turned off, and each context SHALL
keep its own choice.

#### Scenario: Picking a project

- **WHEN** a person turns on a project on the Offline screen
- **THEN** the next sync keeps it offline, and the choice is still there after a restart

#### Scenario: Another context

- **WHEN** a person switches to another context
- **THEN** the Offline screen shows that context's own choice

### Requirement: Offline storage and sync are visible

The Offline screen SHALL show how much room the context's saved copies take, a Clear action that asks for
confirmation, when the last sync finished, a Sync now action that shows while it runs, and the error of a sync that
failed.

#### Scenario: Clear confirmed

- **WHEN** a person presses Clear and confirms
- **THEN** the saved copies are deleted and the size shown drops

#### Scenario: Sync fails

- **WHEN** Sync now fails because the server cannot be reached
- **THEN** the error is shown with a way to retry

### Requirement: Local instances need no offline settings

For a local instance the Offline screen SHALL say that the instance is on this device and always available, and
SHALL offer nothing else.

#### Scenario: Local context

- **WHEN** the active context is a local instance and the person opens the Offline screen
- **THEN** only the note is shown

### Requirement: ADB control is chosen

On Android, Settings SHALL offer, under Advanced, a switch Allow control over ADB, off by default and remembered
on this device, with a line saying what it allows.

#### Scenario: Turned on

- **WHEN** a person turns Allow control over ADB on
- **THEN** a release build runs commands sent over `am broadcast`

#### Scenario: Not Android

- **WHEN** Settings opens on Linux
- **THEN** there is no Advanced section

### Requirement: Keyboard shortcuts are chosen per device

Settings SHALL offer a Keyboard section on every platform, kept on the device: a switch for keyboard shortcuts, a preset of Default, Vim, Emacs or Off, and a read-only list of the active preset's bindings. Search SHALL find it by keyboard, shortcut, keymap, Vim and Emacs.

#### Scenario: Pick Vim

- **WHEN** the person picks Vim and opens Settings again after a restart
- **THEN** Vim is still picked and the list shows `g g` for the first item

#### Scenario: Search

- **WHEN** the person searches Settings for "emacs"
- **THEN** the Keyboard section shows
