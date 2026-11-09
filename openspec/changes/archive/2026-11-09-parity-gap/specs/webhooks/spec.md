# webhooks

## MODIFIED Requirements

### Requirement: A generated secret is shown once

When a new endpoint is saved with the secret left blank, the app SHALL send no secret and SHALL show the `secret` tix returns in `IssuedWebhook` once, with a way to copy it and a warning that it cannot be read back. The secret SHALL NOT be written to the response cache, the log, provider state or a route. Saving an existing endpoint with the field blank SHALL keep its stored secret.

#### Scenario: New endpoint without a secret

- **WHEN** a person saves a new endpoint with an empty secret
- **THEN** the request carries no secret, the app shows the secret tix returned, once, and it is in no cache entry or log line

#### Scenario: Editing keeps the secret

- **WHEN** a person edits an endpoint and leaves the secret empty
- **THEN** the request carries no secret and no secret is shown

## ADDED Requirements

### Requirement: An endpoint can be sent a test event

Each active endpoint SHALL offer Send test, which sends `webhook.ping` and shows the delivery tix answers: its status, the HTTP status the endpoint returned if any, the attempts and the last error. The delivery log SHALL then be read again.

#### Scenario: Test delivered

- **WHEN** a person sends a test to an active endpoint that answers 200
- **THEN** the app sends `POST /webhooks/{id}/ping` and shows Delivered with HTTP 200

#### Scenario: Inactive endpoint

- **WHEN** a person opens the actions of an inactive endpoint
- **THEN** Send test is not offered
