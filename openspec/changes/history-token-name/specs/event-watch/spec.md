## MODIFIED Requirements

### Requirement: Rows name the person, the token and the channel

A row SHALL name who caused the event by the display name the tenant's actor list gives, with the handle beside it, falling back to the handle, then the actor id, then the system. It SHALL show the channel the event came through with its token or job, as tix's web words it: "via token deploy-bot", "via MCP (token claude)", "via system (lease-sweep)".

#### Scenario: A token used by a person

- **WHEN** an event by actor Pax Ito (`@pax`) arrives with `via` kind `api` and token name `deploy-bot`
- **THEN** its row shows Pax Ito, `@pax` and "via token deploy-bot"

#### Scenario: A token used by an MCP client

- **WHEN** an event arrives with `via` kind `mcp` and token name `claude`
- **THEN** its row shows "via MCP (token claude)"

#### Scenario: Actor not in the list

- **WHEN** the actor list cannot be read
- **THEN** the row names the actor by handle
