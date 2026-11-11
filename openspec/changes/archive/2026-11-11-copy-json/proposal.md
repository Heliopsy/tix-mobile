# Proposal

## Why

Reading an audit entry or a Watch event field by field is fine, but sharing one in an issue, or diffing it against
what the CLI prints, needs the whole record. Selecting the before and after blocks by hand misses the rest of it.

## What Changes

- An audit entry's detail, in the sheet on a phone and in the side pane on a wide window, gets a Copy JSON button.
- A Watch event's details sheet gets the same button.
- A long press on an audit row or a Watch row copies its JSON without opening it.
- What is copied is the object tix sent for that record, pretty-printed with two-space indents: nothing the server
  left out is filled in and nothing it sent is dropped. A toast confirms the copy.

## Impact

- Capabilities: `audit-log`, `event-watch`.
- Code: `data/api` (keep the answer's JSON), `data/repositories/audit_repository.dart`, `data/events`,
  `core/widgets`, `features/audit`, `features/watch`, l10n (two strings).
