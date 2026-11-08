# about

## ADDED Requirements

### Requirement: About shows what runs

An About screen, reached from Settings and the command palette, SHALL show the app's version and build, the
embedded engine's tix version or that the build has none, and the active server's tix version from `/healthz` or
that none is connected.

#### Scenario: No engine

- **WHEN** a build without the engine opens About while signed out
- **THEN** the engine reads "Not in this build" and the server "Not connected"

### Requirement: About links to the project

The About screen SHALL say what tix-mobile is and link, outside the app, to the website, the source code (the
AGPL offer of it), the roadmap, the changelog, the tix server project and the security policy. It SHALL state the
licence and the CLA and open the licence page.

#### Scenario: Source code

- **WHEN** a person taps Source code
- **THEN** `https://github.com/heliopsy/tix-mobile` opens in the browser

### Requirement: Bugs are reported with the facts

Report a bug SHALL open the repository's bug form with the platform, OS version, app version, server version and
diagnostics filled in. Copy diagnostics SHALL copy the same facts as text, with the server's address only when the
person turns it on.

#### Scenario: Private server

- **WHEN** a person copies diagnostics without turning on the server address
- **THEN** the text names the versions and not the server's address

### Requirement: Diagnostics never carry a credential

Diagnostics, copied or sent to the bug form, SHALL NOT contain an API token, a session or a password.

#### Scenario: Signed in with a token

- **WHEN** a person signed in with a token copies diagnostics and opens a bug report
- **THEN** neither contains the token
