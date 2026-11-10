# Proposal

## Why

On a desktop window the navigation rail is a fixed width and cannot be folded away, and a task opened beside a
board or lanes has no way to close short of navigating elsewhere. The tix web interface lets the reader drag its
sidebar wider or narrower, collapse it to a rail of icons and back, and closes an open task with a button or
Escape. The app should behave the same on wide windows.

## What Changes

- The rail gets a drag handle on its edge. Dragging resizes it between 180 and 480 pixels, never wider than half
  the window; letting go under 120 collapses it. Double-clicking the handle, or Enter on it, restores the default.
  The handle is a focusable separator: arrow keys move it by 16 (64 with Shift), Home and End jump to the limits,
  Left at the minimum collapses and Right on a collapsed rail expands it. These are tix web's numbers and keys.
- A collapse and expand button at the top of the rail, as tix web has beside its brand, and a palette command.
  Collapsed is the plain rail: icons with their short labels. tix web binds no global key for this, so neither
  does the app.
- Width and collapsed state are remembered on the device. Until the reader collapses or expands it, the rail
  follows the window as today: collapsed below 1200, expanded from there.
- The task panel beside the list gets a header with a close button. Escape closes it, unless select mode is on or
  a field has focus. Navigating to another screen closes it. Closing goes back to the plain list.
- Beside a board or lanes the panel is a fixed width; it gets the same handle, between 360 and 720, remembered.
  Beside a list the panel already takes the rest of the window and is left alone.
- Phones are unchanged.

## Impact

- Capability: `adaptive-layout`.
- `core/theme`: pane limits and a `Panes` provider over the settings store.
- `core/design`: `TixPaneResizer`, with a gallery entry.
- `features/shell`: the wide frame. `features/tasks`: the panel's header, Escape and its width.
- Strings in English, German, French and Bulgarian. No new dependency, no server change.
