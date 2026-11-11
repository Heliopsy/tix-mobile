# live-updates

## REMOVED Requirements

### Requirement: Extra subscriptions share the connection

**Reason**: Its scenario named Watch, which is now Activity, as on the web.

**Migration**: Replaced by "Extra event tails share the connection".

## ADDED Requirements

### Requirement: Extra event tails share the connection

The app SHALL serve a filtered tail of events over the connection it already holds: as another subscription with its own id, filter and cursor on the same WebSocket, or, while polling, as a filtered poll after each of its own. It SHALL NOT open a second socket for it.

#### Scenario: Activity opens

- **WHEN** live updates run over the WebSocket and Activity opens with the filter `task.*`
- **THEN** a second `subscribe` with its own id and `filter.types` `["task.*"]` is sent on the open socket

#### Scenario: Polling

- **WHEN** live updates fall back to polling and a tail is open
- **THEN** after each poll of the app's own, the tail is polled with its filter from its cursor
