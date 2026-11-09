# app-settings

## MODIFIED Requirements

### Requirement: Account arrangements and filters are managed from Settings

Your account SHALL link to inbox kinds and channels, list saved filters with the task list's menu, and reset the
board, lanes and My work arrangement with `view.reset` after a destructive confirmation. After a reset, even a
partly failed one, every open board, lanes or My work view SHALL read its arrangement again.

#### Scenario: Reset

- **WHEN** a person confirms Reset arrangement
- **THEN** the app resets the `board`, `lanes` and `mine` views on the server

#### Scenario: Open views follow

- **WHEN** My work had a hidden group and the person resets the arrangement from Settings
- **THEN** My work reads its arrangement again and shows the group

## ADDED Requirements

### Requirement: Missing date settings say why

When there are no date settings to show, Settings SHALL say which case it is: still reading (a spinner), a tix
without `/me/time` (this version keeps no date preferences, with no Retry), or a failed request (with Retry).

#### Scenario: Older server

- **WHEN** the server answers 404 to `GET /me/time`
- **THEN** the date section says this version of tix keeps no date preferences and offers no Retry

#### Scenario: Server error

- **WHEN** `GET /me/time` fails with a server error
- **THEN** the date section says the server did not answer and offers Retry
