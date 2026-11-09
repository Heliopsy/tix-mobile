# reader-time Specification

## Purpose
How every date and time the app shows follows the reader's date format and time zone kept by tix, with the device as fallback.

## Requirements

### Requirement: Dates follow the reader's server preference

Every date and time the app shows SHALL be written in the effective format and zone `GET /me/time` returns, which
tix resolves from the person, then the tenant, then the deployment. Where the server names none, or cannot
answer, the device's locale formats and zone SHALL apply.

#### Scenario: Dotted in Sofia

- **WHEN** the effective preference is `dotted` in `Europe/Sofia` and a task was created at 12:00 UTC on 1
  November 2026
- **THEN** the task shows it was created 01.11.2026 14:00

#### Scenario: An older server

- **WHEN** the server has no `/me/time`
- **THEN** dates are written in the device's locale formats and zone

### Requirement: Day boundaries follow the reader's zone

Due today, overdue, My work's deadline groups, the inbox's Today and Yesterday and the summary's counts SHALL count
days in the effective zone, and a date or time a person picks SHALL be read as a wall clock in that zone.

#### Scenario: Late evening in Sofia

- **WHEN** the zone is `Europe/Sofia`, it is 23:30 there, and a task is due at 22:30 UTC the same day
- **THEN** the task is due tomorrow, not today

### Requirement: The preference is remembered per context

The app SHALL remember the last settings it read for each context and use them at start, then refresh them from
the server, so dates do not change format after the first frame. It SHALL read them again when the context
changes, when the app comes back to the foreground and when Settings opens.

#### Scenario: Start offline

- **WHEN** the app starts without a network after reading `dotted` before
- **THEN** dates are written in `dotted`

#### Scenario: Changed on the web

- **WHEN** the person picks `us` on the web and returns to the app
- **THEN** the app reads `/me/time` again and dates are written in `us`
