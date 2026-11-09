# webhooks Specification

## Purpose
Webhook endpoints of a tenant, their delivery log and redelivery, and the signing secret shown once.

## Requirements

### Requirement: Endpoints are managed

The webhooks screen SHALL list the tenant's endpoints with their address, event types and whether they are active, and SHALL let a tenant admin add one, edit one and delete one. Deleting SHALL be a red action that asks first. A refused address SHALL be shown with the server's message in the form.

#### Scenario: A plain http address

- **WHEN** a person saves an endpoint at `http://example.com`
- **THEN** the form shows tix's message that the address must use https and nothing is saved

#### Scenario: Deleting asks first

- **WHEN** a person deletes an endpoint and cancels the confirmation
- **THEN** no request is sent and the endpoint stays

### Requirement: A generated secret is shown once

When a new endpoint is saved with the secret left blank, the app SHALL send no secret and SHALL show the `secret` tix returns in `IssuedWebhook` once, with a way to copy it and a warning that it cannot be read back. The secret SHALL NOT be written to the response cache, the log, provider state or a route. Saving an existing endpoint with the field blank SHALL keep its stored secret.

#### Scenario: New endpoint without a secret

- **WHEN** a person saves a new endpoint with an empty secret
- **THEN** the request carries no secret, the app shows the secret tix returned, once, and it is in no cache entry or log line

#### Scenario: Editing keeps the secret

- **WHEN** a person edits an endpoint and leaves the secret empty
- **THEN** the request carries no secret and no secret is shown

### Requirement: Deliveries are listed and redelivered

The screen SHALL list deliveries newest first, a keyset page at a time, with status, attempts, the last HTTP status and error, filterable by endpoint and status, and SHALL offer Redeliver on each.

#### Scenario: Failed only

- **WHEN** a person picks the Failed filter
- **THEN** the list asks for `status=failed` and shows only failed deliveries

### Requirement: An endpoint can be sent a test event

Each active endpoint SHALL offer Send test, which sends `webhook.ping` and shows the delivery tix answers: its status, the HTTP status the endpoint returned if any, the attempts and the last error. The delivery log SHALL then be read again.

#### Scenario: Test delivered

- **WHEN** a person sends a test to an active endpoint that answers 200
- **THEN** the app sends `POST /webhooks/{id}/ping` and shows Delivered with HTTP 200

#### Scenario: Inactive endpoint

- **WHEN** a person opens the actions of an inactive endpoint
- **THEN** Send test is not offered
