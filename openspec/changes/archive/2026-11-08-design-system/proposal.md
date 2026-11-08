# Proposal

## Why

The app draws stock Material 3 seeded from tix's teal, or the platform's wallpaper colours on Android 12 and
later, so it looks like a generic Flutter app rather than like tix. A tenant that brands itself in the browser
shows up in the app in a colour nobody chose. The app is about to grow screens for every tix API operation,
written by several people at once, and without a shared set of components each screen will invent its own
rows, buttons and empty states.

## What Changes

- Port tix's design tokens (`010-tokens.css`) to a `TixTokens` theme extension: colours for light, dark and
  dim, spacing, radii, control sizes, the type scale, shadows, measures and motion.
- Build the Material theme from the tokens so stock widgets look like tix; drop dynamic colour.
- Follow the active tenant's accent, read from the tenant's `theme` and resolved the way tix resolves it.
  Status, priority and project colours never follow it.
- A component library under `lib/src/core/design/components/`: page scaffold, buttons, task row and card,
  status and priority marks, tags, projects, avatars, badges, empty, error and loading states, sections,
  fields, filter bar, quick add, sheets and dialogs, confirm, action sheet, toast and optimistic updates,
  swipe actions, keyboard shortcuts with a `?` help, and a command palette.
- Restyle the existing screens with them.
- A component gallery at `/gallery` in debug and profile builds, goldens for the components, and
  `docs/design.md` with the UX rules and a checklist for new screens.

## Impact

- New capability: `design-system`. `app-settings` loses "Colours follow the platform".
- `dynamic_color` is removed. No new dependencies.
- `Tenant` gains `theme`, `Task` gains `snoozed_until`; both are fields tix already sends.
- One extra request when a context becomes active: `GET /api/v1/tenants/{key}`, best effort.
