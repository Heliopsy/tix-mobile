# task-views

## MODIFIED Requirements

### Requirement: Saved filters are one tap away

Saved filters SHALL show as chips, the reader's own in their order then shared ones. Tapping one SHALL apply
its expression, sort and view. The current filter SHALL save with a name and a shared switch, keeping the sort
and the view in force, which the save sheet SHALL name; one the reader may edit SHALL rename, share, move and
delete.

#### Scenario: Saving

- **WHEN** a person saves `tag:ops` as Ops, shared
- **THEN** `POST /api/v1/filters` sends the name, query, sort, view and `shared: true`

#### Scenario: Applying restores the view

- **WHEN** a person drawing the list taps a saved filter whose view is lanes
- **THEN** the screen draws lanes

## ADDED Requirements

### Requirement: Saved filters keep the reader's order

The reader's own filters SHALL reorder by dragging a row in Settings, Saved filters, and with Move up and Move
down in a filter's menu, offered only where the reader has an own filter above or below. Each change SHALL send
the whole own order with `PUT /api/v1/filters/order`. Shared filters SHALL stay after them and SHALL not move.

#### Scenario: Dragging

- **WHEN** a person drags their third filter to the top in Saved filters
- **THEN** `PUT /api/v1/filters/order` sends the three ids with that filter first

#### Scenario: Moving from the menu

- **WHEN** a person opens the menu of their first filter
- **THEN** Move down is offered and Move up is not
