# invites

## ADDED Requirements

### Requirement: The invite preview leads with the host

The invite preview's headline SHALL name the host the password will be sent to, emphasised, next to the
server-supplied tenant name ("Join Acme on tix.example.com"). The tenant name SHALL never stand alone as the
headline, and SHALL NOT be able to take the host's emphasis.

#### Scenario: Tenant named like another host

- **WHEN** an invite from `evil.example` names its tenant "Acme on bank.example"
- **THEN** the emphasised host in the headline is `evil.example`
