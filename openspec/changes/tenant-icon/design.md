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

## Client

`tix.lock` pins tix v0.61.0, so the generated `Tenant`, `UpdateTenantInput`, `Actor` and `AccountMembership` carry
the icon fields and `tenant.icon` is bound in the capability registry. `TenantIcon` is the app's own value for one
tenant's icon, built from those models and stored on `Membership` and `Connection` so the switcher draws icons
offline. A token connection that learns its tenant from `tenant.show` takes the icon from there too.

## Capability

A server older than v0.61.0 never sends the fields, so drawing needs no gate; every tenant keeps its monogram. The
editor is gated on the server's version from `/healthz`: `supportsTenantIcons` is true from `tenantIconsSince`
(v0.61.0) on, and for a version the app cannot read (a development build).

## Images

An image is fetched with the active session's client, so only tenants of the active connection show their
uploaded image. A tenant on another connection with an image falls back to its monogram rather than reading a
credential from secure storage for every row.

## Reuse

The switcher draws `ProjectMark` and the settings section uses `ProjectIconPicker`, `projectIconNames` and the
image picker that project forms use, moved from the projects feature to `core/platform/attachments.dart` so the
admin feature can use it without importing another feature.
