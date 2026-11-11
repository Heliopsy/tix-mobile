# api-client

## ADDED Requirements

### Requirement: Calls ahead of the pinned description are written beside it

When the app needs a tix route that the pinned description lacks, the call SHALL be written by hand in
`lib/src/data/api/` over the same transport and error mapping, and `api/tix-openapi.yaml` SHALL stay tix's document.
Such a call SHALL be replaced by the generated one when `tix.lock` moves to a release that describes it.

#### Scenario: Reactions before the pin moves

- **WHEN** the app adds a reaction while `tix.lock` pins v0.53.0
- **THEN** `ReactionOps` sends `PUT /api/v1/comments/{id}/reactions/{reaction}` and `just openapi-check` still passes
