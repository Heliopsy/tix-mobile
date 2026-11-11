# event-watch

## ADDED Requirements

### Requirement: An event copies as JSON

An event's details SHALL offer Copy JSON, and a long press on its row SHALL do the same. It SHALL put on the
clipboard the event object tix sent, over the WebSocket or the poll, indented by two spaces, with no field added or
dropped, and SHALL confirm with a toast.

#### Scenario: Copy from the details

- **WHEN** a person opens an event's details and picks Copy JSON
- **THEN** the clipboard holds the event exactly as tix sent it, pretty-printed
- **THEN** a toast says the JSON was copied

#### Scenario: Long press

- **WHEN** a person long-presses a row
- **THEN** the clipboard holds that event's JSON and a toast confirms it
