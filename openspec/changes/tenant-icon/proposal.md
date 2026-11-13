# Proposal

## Why

The switcher shows every tenant as a grey monogram of its name, so tenants that start with the same letters look
the same and picking the right one means reading every row. tix is gaining a tenant icon (an emoji or monogram, a
built-in icon, or an uploaded image), the same three kinds a project already has, and the web shows it. The app
should show it wherever a tenant is named and let a tenant admin set it.

## What Changes

- The switcher's rows, and the switcher button at the top of the rail or the foot of a phone screen, show each
  tenant's icon in the square a project wears (`ProjectMark`), with the monogram from the name when it has none.
- The tenant settings screen gains an **Icon** section with the project icon picker: none, emoji or monogram,
  built-in icon, or an uploaded image. Save sends only the icon fields with `PATCH /api/v1/tenants/{ref}`.
- An uploaded image is read from `GET /api/v1/tenants/{ref}/icon` (`tenant.icon`) with the active connection.
- Against a tix older than the release that adds tenant icons, the section is not offered and every tenant keeps
  its monogram.

## Depends on

The tix release that adds tenant icons. Until `tix.lock` pins it, the icon fields and the image route are read and
written by a small hand-written shim (`lib/src/data/api/tenant_icon_shim.dart`); the bump replaces it with the
generated client.
