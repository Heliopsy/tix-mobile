# Design

## One host, two sheets

`QuickAddDraft` gains `detailed`. `QuickActionsHost` already opens a sheet for every draft, so the palette command
and quick add's More details write a draft with `detailed: true` and the host opens Add with details instead of
quick add. More details closes quick add first; the host drains the draft once that sheet has closed, so the two
sheets never stack and the created task gets the same toast with Open.

## The title is carried, not parsed

The line typed in quick add becomes the title exactly as typed. The app does not parse quick-add syntax, so it
does not strip `!high` or `#tag` from it; the person edits the title in the form, as on the web, where Add with
details also stores its title as typed.

## Structured request

`TaskDetails` holds the fields as written and builds the generated `CreateTaskRequest`: trimmed text, the comma
separated tags and dependencies split into lists, empty fields left out, no `parse`. The server validates
everything else (handles, references, the repeat rule, the lease and its maximum).

## Due date

The web's due field is a text box read by tix's quick-add date parser. The API takes an RFC 3339 instant and the
app does not parse date words, so the form uses a date picker and sends the picked day as the task screen's due
picker does, through the reader's time style.

## Offline

`TasksRepository.create` goes through the outbox like quick add: unreachable, the task is queued as a draft and
the form closes on it. The outbox stores the request as JSON and replays it unchanged.

## Errors

A `TixException` whose `details.field` names a request field (`title`, `lease`, `parent_ref` and so on) is drawn
under that field; others above the form with `errorMessage`. The form keeps every value either way.
