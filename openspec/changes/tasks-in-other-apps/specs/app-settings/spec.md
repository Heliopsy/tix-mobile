## ADDED Requirements

### Requirement: Tasks in other apps is reached from the account group

Settings SHALL list Tasks in other apps in the account group beside Calendar for a remote context, and settings search SHALL find it by "CalDAV", "Reminders", "DAVx5" and "Thunderbird". A local context SHALL list it too, opening the explanation that it needs a server.

#### Scenario: Search

- **WHEN** a person searches settings for "reminders"
- **THEN** Tasks in other apps is a result and opens `/settings/other-apps`
