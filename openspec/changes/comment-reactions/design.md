# Design

## The calls live beside the generated client

`api/tix-openapi.yaml` must be tix's document at the commit `tix.lock` pins, and that commit (v0.53.0) has no
reactions. Editing the copy would fail `just openapi-check`, and bumping the pin waits for a tix release. So
`lib/src/data/api/reactions.dart` adds `ReactionOps` to `TixApi`: `add` and `remove` for the two routes, and
`comments`, the `comment.list` route read without dropping `reactions`. It marshals through the same
`TixTransport`, so errors map the same way. `ReactionSummary` and `Reaction` are written in `data/models/reaction.dart`
with generated JSON mapping, the way `TixEvent` is.

When the pin moves to a tix release with reactions, the generated `Comment` gains `reactions`, `ReactionOps` and the
hand-written model go, and the registry binds `comment.react` and `comment.unreact`.

## One read, the reactions kept with the comment

The generated `Comment` ignores fields it does not know, so the comments listing is read once as raw objects and
each becomes a `ReactedComment`: the generated `Comment` plus its reactions, null when the field was absent. The
response cache keeps the raw objects, so a cached thread shows its reactions too.

## Optimistic toggle

`TaskComments.toggleReaction` redraws the comment with the reaction added or removed (count, `reacted`, the
reader's actor id, the fixed order, a zero count dropped), sends the call, and takes the server's comment as the
answer. On failure it puts the comment back as it was and rethrows, and the tile shows the error as a toast.

## Telling an older server

A comment carrying `reactions` proves the server has them; one without proves nothing, because a comment nobody
reacted to omits the field. So the add button shows until a reaction is refused with 405, or with 404 and tix's
`no such route` (or no envelope at all), which is how a server without the routes answers. A 404 for a deleted
comment carries its own message and is an ordinary error. That verdict is kept per connection, for the life of the
session. A local instance starts refused: its engine is v0.53.0. Bumping the engine to a release with reactions
removes that line.

## Events

`comment.reacted` and `comment.unreacted` join `EventTopics.comments`, so an open thread refetches when someone
else reacts. Over the WebSocket both arrive as plain strings. The HTTP poll fallback reads events through the
generated `Event`, whose type enum predates them, so a polling client sees them only after the pin moves; until
then the thread refreshes on the next `comment.added` or reopen.
