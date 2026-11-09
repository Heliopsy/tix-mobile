# live-updates

## ADDED Requirements

### Requirement: Live updates explain themselves

Live updates SHALL keep, for the active context: the mode and transport, the server's host, when the mode
started, the last contact and event, consecutive failures and those counting towards the fallback, whether the
poll endpoint is missing, the next retry, and the last error with its class, exception type, HTTP status, OS
error, WebSocket close code and reason, and time.

#### Scenario: Offline after a lookup failure

- **WHEN** the WebSocket fails because the host name does not resolve
- **THEN** the last error is unreachable, a SocketException, with the OS error message and code

#### Scenario: After the fallback

- **WHEN** three WebSocket upgrades are refused with 502 and polling starts
- **THEN** the transport is polling, the failures counting towards the fallback are back to 0, and the last error
  is an upgrade refused with 502

### Requirement: Recent changes are kept

The last 20 mode changes and errors SHALL be kept with their times, oldest dropped first, so an intermittent
failure can be read after it recovered.

#### Scenario: A long outage

- **WHEN** the WebSocket fails 30 times in a row
- **THEN** only the 20 most recent entries are kept

### Requirement: Diagnostics carry no secret

Diagnostics SHALL NOT hold a token, a cookie, an Authorization header or a URL's query string. Error messages
SHALL be redacted when recorded: the connection's header values, credential headers and parameters, query
strings and long opaque strings.

#### Scenario: A token in an error message

- **WHEN** a refused upgrade's message repeats the URL with a token and the Authorization header
- **THEN** neither the details nor the copied report contain the token

### Requirement: Connection details

Tapping the indicator in the phone bar, or a long press on the switcher, SHALL open Connection details: the facts
above in plain language, a hint for the last error's class, Reconnect now and Copy details. The indicator's
semantics SHALL say it opens them.

#### Scenario: Behind a proxy that drops idle connections

- **WHEN** a poll timed out and the person taps the indicator
- **THEN** the details say a proxy or load balancer may be closing idle connections and its read timeout should
  be above 60 s for the event endpoints

#### Scenario: Reconnect after a refusal

- **WHEN** live updates are Not available and the person taps Reconnect now
- **THEN** a WebSocket is opened again at once

### Requirement: The copied report is plain and redacted

Copy details SHALL put on the clipboard a plain-text report with the app version, the platform, the server's
host, the mode, the counts, the last error and the recent history, and no secret.

#### Scenario: Copy

- **WHEN** the person taps Copy details
- **THEN** the clipboard holds the report with the app version and host, and without the token
