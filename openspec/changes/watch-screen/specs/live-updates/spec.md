# live-updates

## ADDED Requirements

### Requirement: Extra subscriptions share the connection

The app SHALL serve a filtered tail of events over the connection it already holds: as another subscription with its own id, filter and cursor on the same WebSocket, or, while polling, as a filtered poll after each of its own. It SHALL NOT open a second socket for it.

#### Scenario: Watch opens

- **WHEN** live updates run over the WebSocket and Watch opens with the filter `task.*`
- **THEN** a second `subscribe` with its own id and `filter.types` `["task.*"]` is sent on the open socket

#### Scenario: Polling

- **WHEN** live updates fall back to polling and a tail is open
- **THEN** after each poll of the app's own, the tail is polled with its filter from its cursor

### Requirement: A tail's refusal stays with the tail

An error the server sends for an extra subscription SHALL stop that subscription only, and an expired cursor SHALL be reported to it and followed by a live subscription, leaving the app's own subscription untouched.

#### Scenario: Unknown type

- **WHEN** the server answers a tail's subscription with an error naming its id
- **THEN** the tail reports the refusal and the app's own subscription stays live
