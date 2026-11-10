# Design

## Context

tix web keeps the sidebar's width and rail in a cookie (`internal/web/assets/sidebar.js`): width clamped to
180..480, a drag that ends under 120 collapses, arrow keys step 16 or 64, Home and End go to the limits, Enter and
double-click reset to the default and expand. The toggle sits in the sidebar's head beside the brand. A task opens
in a dialog with a Close button in its header, and Escape closes it.

## Decisions

### One store for pane sizes

`Panes` (`core/theme/panes.dart`) holds the sidebar width, its collapsed choice and the detail panel width, read
from and written to the `KeyValueStore` under `layout.*` keys. A null width is the default and deletes the key, as
tix web leaves defaults out of its cookie. Collapsed is three-valued: unset follows the window, so a first run
looks as before; a choice, once made, wins at every width.

While dragging the width changes in memory only; the value is written when the drag ends. Keys and resets write at
once.

### One handle for both panes

`TixPaneResizer` is a design component: a 1 px line on an 8 px hit area with a resize cursor, a focusable
separator with slider semantics (label, value, increase and decrease). It knows which way its pane grows, so the
same keys move the handle the same way on the left of the panel and the right of the rail. It reports widths,
collapse, expand and reset; the screen decides what to keep.

### Limits follow the window

The sidebar is never wider than half the window, the panel never more than 60 % of the space beside the rail, and
neither less than its minimum. Stored widths are kept as chosen and clamped when drawn, so a narrower window does
not lose the reader's width.

### Closing the panel

On a project the panel is the route `/projects/<key>/tasks/<ref>`, so closing goes to `/projects/<key>`. On Tasks
and My work it is local state, cleared on close and when the router moves to another path, so leaving the screen
and coming back shows the plain list. Escape is the select-mode exit while selecting and the panel's close
otherwise; both are commands, so the shortcut help lists the one in force.

## Risks

- A width stored on a large monitor may be too wide on a laptop: it is clamped when drawn, not rewritten.
