# Proposal

## Why

Reactions shipped in `comment-reactions`, with rough edges. Any 404 to a reaction switched reactions off for the
session, including the 404 for a comment someone deleted meanwhile. A chip only changed once the server answered,
so a tap felt dead on a slow link, and two quick taps could race. The picker offered eight emoji when tix takes any
one. A screen reader heard the count but not whether the reader was among those who reacted, and only the middle
of a chip took a tap.

## What Changes

- Only a missing route (405, or a 404 saying `no such route` or carrying no tix error) means the server lacks
  reactions. The toast then says so. A 404 for a comment shows the server's error and reloads the thread.
- A toggle draws at once, the way tix would answer: a new emoji goes last, and one nobody reacts with any more
  goes. The server's comment replaces the guess; a refusal puts the chip back with a toast and a haptic. Toggles on
  one comment are sent one after another, and a second tap on a chip whose toggle is still out is ignored.
- The picker keeps the eight quick emoji and takes any one emoji typed in a field. The server judges it, and its
  reason shows when it refuses. A long press on a comment outside its text opens the picker too.
- A chip says "you reacted" to a screen reader when the reader did, and takes a tap anywhere in its 48 dp target.

## Impact

- Capabilities: `task-detail`.
- Code: `core/errors` (`missingRoute`), `core/design` (reaction chip), `data/models`, `data/repositories`,
  `features/tasks`, l10n (four strings).
