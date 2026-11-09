# offline-cache Specification

## Purpose
The copy of server data the app keeps so screens draw at once, how it stays out of the way, and the optimistic changes built on screen state.

## Requirements

### Requirement: Screens draw the last good data at once

The app SHALL keep the last successful first page of a listing and the last read of a record per context, show it as soon as a screen opens, and replace it with the server's answer when that arrives. A refresh SHALL always ask the server.

#### Scenario: Reopening the app

- **WHEN** the projects list was read before and the app starts again
- **THEN** the cached projects show at once and the server's list replaces them

#### Scenario: Pull to refresh fails

- **WHEN** the person refreshes a list that was drawn from the cache and the server fails
- **THEN** the error is shown

### Requirement: The cache never breaks a screen and leaves with its connection

A cache read that fails or cannot be decoded SHALL count as a miss, a failed write SHALL be dropped, data of one
context SHALL never be served to another, and removing a connection SHALL delete what was cached for it, entries
waiting to be sent included.

#### Scenario: Unreadable entry

- **WHEN** a cached entry no longer decodes
- **THEN** the screen loads from the server as if nothing was cached

#### Scenario: Connection removed

- **WHEN** a person removes a connection
- **THEN** its cached responses are deleted

### Requirement: Optimistic changes plug into the shared undo flow

A provider SHALL be able to describe a change as apply, rollback, commit and undo steps that the design system's optimistic runner executes, so a refused change restores the previous state.

#### Scenario: Refused change

- **WHEN** a change is applied and the server refuses it
- **THEN** rollback restores the state from before the change

### Requirement: Reads fall back to the saved copy when the server is unreachable

When a read fails because the server cannot be reached (no network, a timeout, or a 502, 503 or 504) and a copy is
kept for it, the app SHALL show the copy instead of an error, even if the screen already drew it once. Any other
failure SHALL be shown as before.

#### Scenario: No network

- **WHEN** a task list that was saved is refreshed with no network
- **THEN** the saved list is shown, not an error

#### Scenario: The server refuses

- **WHEN** the server answers 403, 404 or 500 to a read that has a saved copy
- **THEN** the error is shown

### Requirement: The app says when it shows a saved copy

While a screen draws a saved copy because the server could not be reached, the task screen SHALL say it is offline
and when the copy was saved, and SHALL stop saying so after the next read that reaches the server.

#### Scenario: Offline task screen

- **WHEN** the task screen is drawn from a copy saved at 12:00
- **THEN** its header says it is offline and shows a saved copy from 12:00

### Requirement: Chosen work is prefetched for offline use

For each project a person keeps offline, and My work and Starred when on, a sync SHALL fetch every page of the
listing the task screen reads, each listed task with its comments and subtasks, and the projects, workflows,
fields, tags and actors needed to draw them, under the keys the screens read.

#### Scenario: A project opened offline

- **WHEN** a project kept offline has three pages of tasks, a sync ran, and the project is opened with no network
- **THEN** every task of all three pages is listed, and each opens with its comments and subtasks

### Requirement: Sync runs in the background with care for data and battery

For a remote instance, sync SHALL run when the context becomes active, every 30 minutes while the app is open and
when the network returns, at most four requests at a time. On a phone it SHALL NOT run on its own on mobile data,
in battery saver or on a low battery. Sync now SHALL always run.

#### Scenario: Mobile data

- **WHEN** a phone on mobile data activates a remote context
- **THEN** no prefetch runs until Sync now is pressed or Wi-Fi returns

#### Scenario: Wi-Fi

- **WHEN** a remote context becomes active on Wi-Fi
- **THEN** a prefetch runs

### Requirement: Local instances are never prefetched

A local instance runs on the device and is always reachable, so the app SHALL NOT prefetch it, on its own or on
request.

#### Scenario: Local context activated

- **WHEN** a local context becomes active
- **THEN** no prefetch runs

### Requirement: Clearing saved copies keeps unsent work

Clearing a context's saved copies SHALL delete every cached response of that context and SHALL keep entries
holding work not yet sent to the server.

#### Scenario: Clear with queued work

- **WHEN** a person clears saved copies while a change waits to be sent
- **THEN** the saved copies are gone and the waiting change is kept
