# account

## ADDED Requirements

### Requirement: The account screen shows who I am

The account screen SHALL show the caller's name, handle, email, role and kind from `whoami`, and each tenant
membership with its role, marking the current one.

#### Scenario: Memberships

- **WHEN** ana belongs to default and acme
- **THEN** both are listed with their role and default is marked current

### Requirement: Account history when readable

When the credential may read the account (a person's session, or a token with `account:read`), the account
screen SHALL list `account.log` newest first, a page at a time, with what changed, the tenant, who made it and
when. Otherwise it SHALL say why the history is not shown.

#### Scenario: Token without the scope

- **WHEN** the credential is a token without `account:read`
- **THEN** the history section says the token cannot read it and asks nothing
