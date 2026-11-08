## ADDED Requirements

### Requirement: Every tix operation is classified

Every operationId in `api/tix-openapi.yaml` SHALL be bound in the app's capability registry to a feature, an action and a wave, or listed in `exemptions.yaml` as exempt with a reason or pending in a wave. A test SHALL fail on an operation classified nowhere, more than once, or no longer in the spec.

#### Scenario: Spec bump adds an operation

- **WHEN** a new tix version adds an operation and nothing classifies it
- **THEN** the parity test fails naming it

#### Scenario: Pending work passes

- **WHEN** an operation is listed as pending in wave 1
- **THEN** the parity test passes and prints how many are still pending

### Requirement: Coverage is reported per wave

`just parity` SHALL print, per wave, how many operations are bound and pending, and the share of the operations the app should offer that it does.

#### Scenario: Report

- **WHEN** a contributor runs `just parity`
- **THEN** it prints one line per wave and the overall coverage
