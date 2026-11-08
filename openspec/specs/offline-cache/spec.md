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

A cache read that fails or cannot be decoded SHALL count as a miss, a failed write SHALL be dropped, data of one context SHALL never be served to another, and removing a connection SHALL delete what was cached for it.

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
