# Design

## Context

v0.1.0 keeps a list of `ServerContext` (id, name, base URL, handle) under the preference `contexts`, the active
id under `contexts.active`, and each token in secure storage under `token.<id>`. Every request goes through one
`TixApi` per active context, sending `Authorization: Bearer`.

tix itself (see its `docs/tenancy.md` and `docs/api.md`) gives us three facts this design rests on:

- An API token belongs to the tenant it was minted in. `whoami` reports `tenant_key` and `tenant_name`.
- `POST /api/v1/auth/login` answers a session or a challenge. The challenge `code` carries a `ticket` that the
  second step sends back with the code and no password. `enrol` and `password_change` are the other kinds.
- `POST /api/v1/auth/switch {"tenant":"KEY"}` mints a session in the target tenant and ends the one presented.
  A tenant with an address of its own is refused there with `400 invalid`; its sessions live at that address.
  `whoami` on a session lists `memberships`, each with `tenant_key`, `tenant_name`, `role`, `handle`, `host`.

## Goals / Non-Goals

**Goals:** several instances of either kind; token and sign-in connections; switching tenant inside an instance
or pinning a connection to one; one code path over the HTTP API for remote and local alike; a lossless upgrade.

**Non-Goals:** the FFI engine itself; enrolling a second factor or changing a password in the app (those
challenges send the person to the browser); SSH key sign-in; keeping a password on the device.

## Decisions

### Model

- `Instance { id, name, kind: remote|local, baseUrl, dbPath, createdAt, lastUsedAt }`. A remote instance has
  `baseUrl`, a local one `dbPath`; a local instance's URL is whatever the engine answers when started.
- `Connection { id, instanceId, kind: token|signIn, label, handle, email, tenantKey, tenantName, pinned,
  memberships, createdAt, lastUsedAt }`. A token connection is always pinned. A sign-in connection is pinned
  when the person says so; otherwise it is switchable and its `tenantKey` is the tenant its session is in now.
  `memberships` is the last list `whoami` gave, so the switcher draws without a request.
- `ContextRef { connectionId, tenantKey }` names an active or recent context. The instance follows from the
  connection.

### Storage layout

| Where | Key | Holds |
| --- | --- | --- |
| preferences | `instances` | JSON list of instances |
| preferences | `connections` | JSON list of connections |
| preferences | `context.active` | JSON `ContextRef` |
| preferences | `context.recent` | JSON list of `ContextRef`, newest first, at most 8 |
| preferences | `storage.version` | `2` once migrated |
| secure storage | `token.<connectionId>` | API token of a token connection (the v0.1.0 key, unchanged) |
| secure storage | `session.<connectionId>` | session token of a sign-in connection |

Local engines mint ordinary API tokens, so a local tenant is a token connection like any other and its token
sits under `token.<connectionId>`.

### Migration

On first read, when `storage.version` is absent and `contexts` exists, each v0.1.0 context becomes a token
connection with the same id, so its token stays under `token.<id>` and no secret moves. Contexts sharing a base
URL share one remote instance, named after the first of them. The connection keeps the context's name as its
label and its handle; the tenant is unknown until the next `whoami`, which fills it in. `contexts.active`
becomes `context.active`. The old keys are left in place so an older build still opens. The migration is a pure
function of the old values, run inside `InstancesRepository`, and runs once.

### How a session is presented: a cookie, not a bearer token

Checked against a real `tix serve` built from the tix repository (task 6.1): `Authorization: Bearer
<session.token>` is refused with `401 invalid credentials`, because the bearer authenticator checks API tokens
only. `Cookie: tix_session=<token>` is accepted, for reads and for writes, with no CSRF token on `/api/v1`. A bad
bearer header next to a good cookie is also refused, so a session client must not send `Authorization` at all.
After a switch the old session answers `401`, and after `POST /auth/logout` the new one does too.

`TixApi` therefore takes a `Credential`: `bearer(token)` or `session(token)`, the latter sent as the
`tix_session` cookie header. A cookie jar would add a dependency and per-host state for one header whose value
the login answer already hands us in its body.

Sessions last 12 hours on tix's defaults. The app keeps no password, so an expired session asks the person to
sign in again, with the email filled in, keeping the connection.

Login and switch send `"surface": "cli"`: the app is not a browser, `cli` is what a missing surface means on
login anyway, and switch would otherwise default to `web`.

### A token's tenant

Also found on the real server: `whoami` with an API token answers as an agent (`kind: agent`, the handle is the
token's name) with `tenant_id` and no `tenant_key` or `tenant_name`; those are filled in for a person's session
only, whatever tix's `docs/tenancy.md` says. The app then reads `GET /api/v1/tenants/{tenant_id}`, which a token
with `tenant:admin` (so also `*`) may read. A narrower token stays unnamed: the switcher shows its instance alone.

A switch into a tenant that requires a second factor this account has not set up answers `403` with
`details.reason` `second_factor_required`; the app explains it as something to finish in the browser.

### Switching

`SessionController.activate(ContextRef)` writes the active context and recents, then rebuilds. When the target
is a switchable sign-in connection in another tenant, it first calls `/auth/switch` and stores the new session.
A switch can answer a code challenge, which the switcher asks for and sends back with the tenant. Everything
that talks to the server watches the session, so the Dio client and every list rebuild without bookkeeping.

A membership whose `host` is set cannot be switched to. The switcher shows it with its address and offers to add
`https://host` (the current instance's scheme) as a new instance with a sign-in prefilled with the email.

### Local engine

`LocalTixEngine` is the interface the FFI library will implement. Two implementations ship:
`InMemoryLocalTixEngine` (tenants and tokens in memory, a fake loopback URL) for tests, and
`UnavailableLocalTixEngine`, which the app uses until the FFI library lands; every call throws
`TixErrorKind.engineUnavailable`, shown as "not available in this build yet". The add-instance screen shows the
local choice only when the compile-time flag `TIX_LOCAL_INSTANCES` is set; otherwise it lists it disabled with
the same honest note.

Lifecycle, kept simple:

- Start lazily, when a local context becomes active (the session build awaits `start`).
- Stop when the active context moves to another instance, and on app exit (`AppLifecycleListener`
  `onExitRequested` on desktop, `onDetached` on phones, best effort).
- One running handle per instance, owned by `LocalEngines` in `core/session`.

Adding a local instance starts the engine once to list tenants and mint the first token, and saves nothing unless
that works, exactly as a remote one is checked before it is saved.

### Files

`file_selector` covers open and save dialogs on Android, iOS, Linux, macOS and Windows and is maintained by the
Flutter team. It has no save dialog on phones, so there a new database is created by name in the app's documents
folder (`path_provider`). Android's picker hands back a content URI copy, not the file in place; the FFI step must
decide whether to accept that or ask for persistent URI permission. All platform calls sit behind a `FilePicking`
interface in `core/` so tests never reach a channel.

## Risks / Trade-offs

- 12-hour sessions mean more sign-ins than a token. The add flow says so and suggests a token for a phone that
  should stay signed in.
- A switchable connection holds one session, so switching tenant ends the previous one on the server, as the
  browser does. Two pinned sign-in connections give two parallel sessions.
- Leaving the v0.1.0 keys after migration costs a few bytes and buys a working downgrade.
