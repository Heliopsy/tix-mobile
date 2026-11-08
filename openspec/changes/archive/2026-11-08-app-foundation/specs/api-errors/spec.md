## ADDED Requirements

### Requirement: The error envelope is typed

A failed call SHALL become a typed error carrying the envelope's `code`, `message`, `details`, the HTTP
status and the `X-Request-Id`. A response without an envelope SHALL be classified by its status, and a
transport failure as a timeout or a network error.

#### Scenario: Conflict envelope

- **WHEN** the server answers `409` with code `conflict`
- **THEN** the error's kind is conflict and it carries the message and request id

#### Scenario: Server unreachable

- **WHEN** the connection is refused
- **THEN** the error's kind is network

### Requirement: Errors are explained in the reader's language

Every error kind SHALL map to a message in the app's language. Where the server's message is the reason (an
invalid request, a failed precondition, a missing record) it SHALL be included; a refused token SHALL NOT
echo the server's text. A server failure SHALL name its `X-Request-Id`. Every error view SHALL offer a retry.

#### Scenario: Invalid request

- **WHEN** the server refuses a request with `invalid` and `unknown project`
- **THEN** the message shown includes `unknown project`

#### Scenario: Server failure

- **WHEN** the server answers `500` with request id `r-42`
- **THEN** the message says the server had a problem and names `r-42`

#### Scenario: Retry after failure

- **WHEN** the projects list fails to load and a person taps Retry after the server recovers
- **THEN** the projects are shown
