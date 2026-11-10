# Proposal

## Why

People using Watch reported five problems. It takes four taps to reach. The live dot next to the title never moves,
so it is hard to tell the tail is alive. Opening a task from a row and going back lands somewhere other than Watch.
A row names only a handle, not the person or the token and channel the change came through. And a row says little
about what happened: no comment text, plain text where the web shows coloured badges and status pills.

## What Changes

- A Watch button in the shell's bar, beside quick add, shown only with `event:subscribe`, and a Watch entry in the
  desktop tray menu that shows the window on Watch through a new `tix://watch` link.
- The live dot on Watch breathes while live or connecting, and holds still when the platform or the app asks for
  reduced motion.
- Rows push the task or project over Watch, so back returns to Watch with its list, filters and scroll position.
- Rows show the actor's display name (from the tenant's actor list), the handle, and the channel with the token or
  job, as the web's activity feed writes it ("via API (deploy-bot)").
- Rows look like the web's activity feed: an avatar of initials, the event type as a badge coloured by what
  happened, the project chip, status pills for transitions and new tasks, the changed fields by name, the first
  lines of a comment, and a relative time.

## Impact

- Capabilities: `event-watch`, `desktop-integration`.
- Code: `features/watch`, `features/shell` (one new button), `core/desktop`, `core/platform` (tray action, link),
  `core/design` (`LiveIndicator.pulse`), l10n in all four locales.
- Requests: Watch now reads the tenant's actors once, and a task's comments when a comment row shows.
