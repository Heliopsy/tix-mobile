# instances

## ADDED Requirements

### Requirement: A token connection rotates its token

A remote token connection SHALL offer to rotate its API token with `token.rotate`, after a confirmation, giving the
old token a one minute grace. The new value SHALL replace the old one in secure storage only; a refusal SHALL keep
the old token and say why. Sign-ins and local databases SHALL NOT offer it.

#### Scenario: Rotate

- **WHEN** a person rotates the token of a connection and confirms
- **THEN** the app stores the new token and keeps working with it

#### Scenario: Refused

- **WHEN** the server refuses the rotation
- **THEN** the old token stays and the reason is shown
