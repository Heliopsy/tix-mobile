# instances Specification

## Purpose
The tix servers the app knows about, remote or local, the connections saved on each, and the migration from 0.1.

## Requirements

### Requirement: Instances are saved servers of two kinds

The app SHALL keep a list of instances, each a tix server with a name, a kind and the times it was created and last used. A `remote` instance SHALL have a server address. A `local` instance SHALL have the path of a `.db` file on this device. Adding a remote instance at an address already saved SHALL reuse that instance.

#### Scenario: Two addresses, two instances

- **WHEN** a person connects to `tix.example` and then to `home.example`
- **THEN** the instances screen lists two remote instances

#### Scenario: Same address reuses the instance

- **WHEN** a person adds a second connection at an address already saved
- **THEN** one instance remains, with two connections

### Requirement: An instance holds one or more connections

Each instance SHALL hold at least one connection: a token connection or a sign-in connection. Each connection SHALL record its kind, a label, the handle it acts as and the tenant it targets. Saving a connection of the same kind, handle and tenant on the same instance SHALL replace it rather than add another.

#### Scenario: Reconnecting replaces

- **WHEN** a person connects twice to the same address with tokens of the same handle and tenant
- **THEN** one connection remains

#### Scenario: Removing the last connection removes the instance

- **WHEN** a person removes the only connection of an instance
- **THEN** the instance is no longer listed

### Requirement: Instances can be managed

The instances screen SHALL list every instance with its connections, mark the active one, and let a person add an instance, add a connection to an instance, and remove a connection or a whole instance after confirming.

#### Scenario: Remove an instance

- **WHEN** a person removes an instance with two connections and confirms
- **THEN** both connections and their secrets are gone

### Requirement: Saved servers from 0.1 are migrated losslessly

On first start after upgrading, every server saved by 0.1 SHALL become a token connection with the same name, handle and token, on a remote instance at its address. Servers sharing an address SHALL share one instance. The active server SHALL stay active. The migration SHALL run once and SHALL NOT move or rewrite any token.

#### Scenario: Upgrade keeps the active server

- **WHEN** 0.1 saved `Work` and `Home` at two addresses with `Work` active, and the new version starts
- **THEN** two remote instances exist, `Work` is the active context, and both tokens still work without asking

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

### Requirement: A rotated token is never dropped

Before rotating, the app SHALL check that secure storage accepts a write and SHALL NOT rotate when it does not. When
storing the rotated token fails anyway, the app SHALL show it once with Copy and a warning that it is not saved and
the old token stops in a minute, and SHALL keep using it until the app closes. The token SHALL NOT be logged.

#### Scenario: Locked keyring before rotating

- **WHEN** secure storage refuses a write and the person rotates a token
- **THEN** nothing is sent to the server, the old token stays and the reason is shown

#### Scenario: Write fails after rotating

- **WHEN** the server rotates the token but storing the new one fails
- **THEN** the new token is shown once with Copy and a warning, and the connection keeps working with it
