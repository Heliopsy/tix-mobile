# home-widgets Specification

## Purpose
Native home screen widgets on Android, iOS and macOS: what they show, how the app feeds them, how their taps and ticks come back, and what never reaches widget storage.

## Requirements

### Requirement: My work widget

Android, iOS and macOS SHALL offer a My work widget listing the next open tasks assigned to the reader, overdue
and due today first, with the total. Each row SHALL open its task, and its tick SHALL complete the task.

#### Scenario: Overdue first

- **WHEN** the reader has a task due yesterday and one due next week
- **THEN** the widget lists yesterday's first, its due date in the danger colour

### Requirement: Inbox widget

Android, iOS and macOS SHALL offer an Inbox widget with the unread count and the latest unread items. Tapping an
item SHALL open its task in the item's context and mark it read. iOS SHALL also offer the count on the lock screen.

#### Scenario: Tap an item

- **WHEN** a person taps a mention in the Inbox widget
- **THEN** the app opens that task and the mention is read

### Requirement: Quick add widget

Android, iOS and macOS SHALL offer a Quick add widget whose one button opens the app's quick add sheet, in the
widget's context and, when it has one, its project.

#### Scenario: One tap

- **WHEN** a person taps the Quick add widget
- **THEN** the app opens with the quick add sheet showing

### Requirement: Project widget

Android, iOS and macOS SHALL offer a Project widget for a project picked when it is added, showing its open tasks
under each unfinished state of its workflow with a count per state.

#### Scenario: Picked project

- **WHEN** a person adds the Project widget and picks Operations
- **THEN** it shows Operations' open tasks grouped by state

### Requirement: Widgets look like tix

Widgets SHALL use the design tokens in light and dark, OLED black when the app is set to it, the tenant's accent for
their accent only, and fixed status and priority colours. They SHALL stay readable at their smallest size.

#### Scenario: Plum tenant

- **WHEN** the active tenant uses plum and a task is in progress
- **THEN** the header mark is plum and the status is tix's teal

### Requirement: Widgets read a snapshot

The app SHALL write a versioned JSON snapshot per widget kind and context to widget storage after the session
changes, after events touching the data, after its own mutations, on resume, and on a periodic background refresh.
A widget SHALL show the snapshot's age.

#### Scenario: Event arrives

- **WHEN** a task assigned to the reader is created elsewhere while the app runs
- **THEN** the My work widget shows it within seconds

### Requirement: Widget storage holds no secret

Widget storage SHALL NOT contain an API token, a session, a password or a server address.

#### Scenario: Token connection

- **WHEN** the app writes snapshots for a context signed in with an API token
- **THEN** no written value contains the token

### Requirement: Widget ticks are queued

A tick SHALL be queued in widget storage and hidden from the widget at once. The app's own code SHALL run the
queue in the background where the platform allows, otherwise when the app next opens, and SHALL drop an entry the
server refuses for good.

#### Scenario: Offline tick

- **WHEN** a person ticks a task in the widget with no network
- **THEN** the task disappears from the widget and is completed once the app next reaches the server

### Requirement: Widgets choose a context

A widget SHALL follow the active context unless it was pinned to an instance and tenant when added, and SHALL name
its context. A tap SHALL open the app in the widget's context.

#### Scenario: Pinned widget

- **WHEN** a widget pinned to Home · Family is tapped while Work · Acme is active
- **THEN** the app switches to Home · Family and opens the task

### Requirement: Local instances stay cold

Background widget work SHALL NOT start the embedded engine. A local context's widget SHALL show its last snapshot
with its age, and its ticks SHALL wait until the app runs that context.

#### Scenario: Phone in a pocket

- **WHEN** the periodic refresh runs while a widget shows a local database
- **THEN** no engine starts and the widget keeps its snapshot and age

### Requirement: Lock screen shows counts only

When the counts only setting is on, widgets on the lock screen SHALL show counts and no titles.

#### Scenario: iPhone lock screen

- **WHEN** counts only is on and the inbox accessory is on the lock screen
- **THEN** it shows the unread count and no item text

### Requirement: Desktop widgets where the platform has them

macOS SHALL offer the widgets as WidgetKit desktop widgets. Windows and Linux SHALL NOT offer widgets until a host
is supported, and the documentation SHALL say why and what is planned.

#### Scenario: macOS desktop

- **WHEN** a Mac user opens the widget gallery
- **THEN** My work, Inbox, Quick add and Project are offered
