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
board, lanes and My work arrangement with `view.reset` after a destructive confirmation.

#### Scenario: Reset

- **WHEN** a person confirms Reset arrangement
- **THEN** the app resets the `board`, `lanes` and `mine` views on the server

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
