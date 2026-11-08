# Proposal

## Why

v0.1.0 saves several servers, each with one API token, and nothing else. People run more than one tix: a shared
company server, a personal one, a database on the laptop. One server can host several tenants, and one person can
belong to several of them. They need to reach all of it from one client, and choose for themselves whether a
connection follows them between tenants or stays pinned to one.

## What Changes

- **Instances replace servers.** An instance is a tix server: `remote` (an address) or `local` (a `.db` file on
  this device, served by tix embedded in the app). Each has a name and remembers when it was created and last used.
- **Connections** say how the app is authenticated on an instance: an API token (pinned to the tenant it was
  minted in), or a sign-in with email and password, second factor included. A sign-in can be pinned to one tenant
  or left switchable between the person's tenants.
- **Active context** is instance, connection and tenant. A switcher on every signed-in screen shows
  Instance › Tenant, recent contexts first, and switching rebuilds the API client and every list.
- **Tenants served at their own address** are offered as their own instance instead of a switch tix would refuse.
- **Local instances**: create or open a `.db` file, start the embedded engine when it becomes active, list and
  create tenants, mint one token per tenant opened. The engine is a separate library; this change codes against
  a Dart interface and ships an in-memory fake for tests and an honest "not available yet" stub for the app.
- **Migration**: every v0.1.0 saved server becomes a remote instance with a token connection, losslessly.
- Packages: `file_selector` (open and save dialogs on all five platforms) and `path_provider` (the app's documents
  folder on phones). macOS gets the user-selected read-write file entitlement.

## Capabilities

### New Capabilities

- `instances`: saving remote and local instances, their connections, and the v0.1.0 migration.
- `sign-in`: email and password sign-in with the second factor, and how a session is presented.
- `tenants`: the active context, the switcher, pinned and switchable connections, tenants at their own address.
- `local-instances`: `.db` files served by the embedded engine, and its lifecycle.

### Modified Capabilities

- `server-connection`: connecting with a token now adds a token connection to an instance; signing out removes
  a connection.

## Impact

`lib/src/data` (models, API client, repositories, local engine interface), `lib/src/core/session`, the connect
and settings features, a new instances feature, the router, both ARB files, `docs/architecture.md`, the README
feature list, `pubspec.yaml` and the macOS entitlements.
