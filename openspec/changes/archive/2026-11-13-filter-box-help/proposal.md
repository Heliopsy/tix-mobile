# Proposal

## Why

The filter field takes tix's filter language, but on a phone nobody remembers that it is `assignee:` and not
`owner:`, which statuses a workflow has, or how a tag was spelled. tix web helps with this: its filter box suggests
keys and values as you type, its Filters menu has pickers for status, priority and assignee, and every term can be
taken out on its own. The app had none of it, and it also read `@raj` as free text where tix reads it as
`assignee:raj`.

## What Changes

- While the caret sits in a word of the filter field, a list under it offers what the word completes to, from
  the tenant's projects, tags, people and workflow states: keys for a bare word, handles after `@`, tags after `#`
  (written as `tag:`), and values after `project:`, `status:`, `priority:`, `tag:`, `assignee:`, `creator:`,
  `claimed-by:`, `due:` and `is:`. A minus is kept. Tapping a suggestion takes it.
- On a keyboard: Down and Up move through the list, Enter takes the reached one (Enter alone still applies the
  filter), Tab takes the reached or first one, Escape closes the list. Same rules as tix web's box.
- A Filters button beside the sort opens pickers for status, priority, assignee and tag. Picking a value replaces
  that key's terms in the expression; Any takes them out.
- Each term of the expression shows as a chip with a remove button under the field.
- `@handle` in the filter expression is an assignee term, as tix reads it.
- The one-tap chips and saved filters are unchanged.
- Two design components: `TixTermChip` and `TixSuggestionList`, with gallery entries.

## Impact

- Capabilities: `task-views`.
- Code: `data/query/filter_expression.dart`, new `data/query/filter_suggest.dart`, `core/design` (filters),
  `features/tasks` (filter panel, a suggestion data provider), gallery, l10n (en, bg, de, fr).
