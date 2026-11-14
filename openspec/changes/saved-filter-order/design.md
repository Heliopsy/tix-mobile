# Design

## Where order and view live

Both are server fields shared with the web, read and written through the generated client: `SavedFilter.position`
and `SavedFilter.view`, `filter.save` with `view`, and `filter.order` with the ids of the reader's own filters.
Nothing is kept on the device.

## Reordering

`SavedFilters.reorder(from, to)` takes indexes into the reader's own filters, applies the new order at once and
sends the whole own order, as the web's move does, then takes the server's answer. A failure restores the list
from the server and the error reaches the caller, which shows it. `move(filter, by)` is a reorder by one place.

Drag lives on Settings, Saved filters, which is a vertical list with room for a drag handle. The chips on the
task screen keep tap to apply and long press for the menu; dragging a horizontal chip strip would fight both, so
there the menu's Move up and Move down are the way to reorder, and they are also the keyboard and screen reader
alternative to dragging everywhere.

## Lane grouping

A saved filter's `view` names list, board or lanes only. The web does not save its lane grouping with a filter
either, so applying a filter keeps the screen's grouping, as it does on the web.
