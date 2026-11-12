# server-release

## ADDED Requirements

### Requirement: Server release screen

The app SHALL offer a Server release screen in Settings and the palette that reads `GET /release` and shows the
running version, the newest published release or that it is not known, and the status in words: update available,
up to date, not comparable, check failed or not checked yet.

#### Scenario: Newer release

- **WHEN** the server answers status `newer` with running 0.58.0 and latest 0.59.0
- **THEN** the screen says v0.59.0 is available and this installation runs v0.58.0

#### Scenario: Never checked

- **WHEN** the server answers status `pending`
- **THEN** the screen says it has not been checked yet and offers no upgrade commands

### Requirement: Upgrade commands and notes

When a newer release is out the screen SHALL list the server's upgrade command per install method with Copy, and
the newest release's notes as Markdown; otherwise it SHALL show neither.

#### Scenario: Copy a command

- **WHEN** a newer release is out and the person taps Copy beside the container command
- **THEN** `podman pull ghcr.io/heliopsy/tix:0.59.0` is copied

### Requirement: What's new

The screen SHALL list the changelog the server carries: the running version's entry marked as running here, then
the entries before it, or the newest entries with a line saying why when the running version has none.

#### Scenario: Untagged build

- **WHEN** the server runs a build the changelog has no entry for
- **THEN** the screen lists the newest entries and says the build is not a tagged release
