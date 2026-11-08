# api-client Specification

## Purpose
How the app talks to a tix server: the API description pinned with the engine, the client generated from it, the credential each connection presents and the typed errors every failure becomes.

## Requirements

### Requirement: The API description is pinned with the engine

The app SHALL keep tix's OpenAPI document as `api/tix-openapi.yaml`, identical to tix's `api/openapi.yaml` at the commit `tix.lock` pins. A check SHALL fail while the two differ, and bumping `tix.lock` SHALL be the only change needed to move the engine and the API description together.

#### Scenario: Drift is caught

- **WHEN** `api/tix-openapi.yaml` differs from the document at the pinned commit
- **THEN** `just openapi-check` fails and names `just openapi-sync`

### Requirement: The client is generated from the pinned description

The models and the client SHALL be generated from `api/tix-openapi.yaml`, committed, and checked by `just gen-check`. Every operation SHALL have a typed method; a listing SHALL return a keyset page; a body field left unset SHALL not be sent.

#### Scenario: Partial update

- **WHEN** the app updates a task's title only
- **THEN** the PATCH body holds the title and nothing else

#### Scenario: Stale generated code

- **WHEN** the spec changes and the generated client is not regenerated
- **THEN** `just gen-check` fails

### Requirement: Each connection presents its own credential

Every request SHALL go through a client for one connection, sending an API token as `Authorization: Bearer` and a sign-in as the `tix_session` cookie only. `X-Tix-Tenant` SHALL be sent only when a sign-in names a tenant, and `X-Tix-Client` SHALL NOT be sent.

#### Scenario: Session as cookie

- **WHEN** a sign-in connection calls `whoami`
- **THEN** the request carries `Cookie: tix_session=...` and no `Authorization` header

### Requirement: Every failure is one typed error

Every failed request SHALL become a `TixException` built from tix's error envelope, including a failed streamed listing, and a response of the wrong shape SHALL be classified as not tix.

#### Scenario: Refused NDJSON listing

- **WHEN** a streamed task listing is answered `403` with code `forbidden`
- **THEN** the error's kind is forbidden and it carries the server's message

### Requirement: A null that clears is sent

For an input field whose null means "clear", the generated client SHALL distinguish leaving it out from clearing
it, and send JSON null for a clear. No request SHALL be built by hand to carry one.

#### Scenario: Clear a due date

- **WHEN** a person clears a task's due date
- **THEN** the generated `task.update` sends `"due_at": null`
