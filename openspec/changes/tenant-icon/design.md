# Design

## Contract

tix mirrors the project icon on the tenant:

- `Tenant` gains `icon`, `icon_name` and `icon_image` (the digest of an uploaded image); at most one is set.
- `UpdateTenantInput` gains `icon`, `icon_name` and `icon_file` (a `ProjectIconFile`). Naming one replaces the whole
  icon; an empty `icon` clears it.
- `whoami` gains `tenant_icon`, `tenant_icon_name` and `tenant_icon_image` for the caller's tenant, and each of its
  `memberships` gains `icon`, `icon_name` and `icon_image`, so the switcher can draw every tenant without reading
  each one.
- `GET /api/v1/tenants/{ref}/icon` (`tenant.icon`) returns the image to any member of that tenant, also from a
  session in another tenant.

## Shim until the tix bump

The vendored spec is tix's at `tix.lock`, which predates the icon, so the generated `Tenant`, `UpdateTenantInput`
and `AccountMembership` drop the new fields. `tenant_icon_shim.dart` adds four calls on `TixClient` that use its
transport directly: the raw `whoami` (to read the membership icons beside the generated `Actor`), the tenant's icon
fields, a PATCH of only the icon fields, and the image bytes. `TenantIcon` is the app's own value for one tenant's
icon; it is stored on `Membership` and `Connection` so the switcher draws icons offline.

After the bump: `TenantIcon` is built from the generated fields, the shim file goes, `tenant.icon` is bound in the
capability registry, and `tenantIconsSince` becomes the release that shipped it.

## Capability

The operation cannot be listed in `exemptions.yaml` or bound in `registry.dart` until the vendored spec has it (the
parity test calls an unknown operation stale). The run-time gate is the server's version from `/healthz`:
`supportsTenantIcons` is true from `tenantIconsSince` on, and for a version the app cannot read (a development
build). An older server never sends the fields, so drawing needs no gate; only the editor is hidden.

## Images

An image is fetched with the active session's client, so only tenants of the active connection show their
uploaded image. A tenant on another connection with an image falls back to its monogram rather than reading a
credential from secure storage for every row.

## Reuse

The switcher draws `ProjectMark` and the settings section uses `ProjectIconPicker`, `projectIconNames` and the
image picker that project forms use, moved from the projects feature to `core/platform/attachments.dart` so the
admin feature can use it without importing another feature.
