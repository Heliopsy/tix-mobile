# Design

## Generated types only

`tix.lock` pins v0.57.0, so the generated `Comment` carries `reactions` as a list of the generated `Reaction`
(`emoji`, `count`, `actor_ids`), and `CommentOps` has `react` and `unreact`. The comments provider keeps holding
`List<Comment>`; nothing wraps it. The emoji goes in the path through the transport's `segment`, which
percent-encodes it (`👍` is `%F0%9F%91%8D`), as the API description asks.

## Mine is the reader's actor id

The server answers no `reacted` flag. A chip is the reader's when `actor_ids` holds the actor `whoami` named, read
from `currentAccessProvider` (the cached answer draws at once). The tile passes that id to the toggle, so the
optimistic comment lists the reader the way the server will. Before `whoami` answers, nothing is highlighted and
a tap adds.

## Optimistic toggle

`TaskComments.toggleReaction` redraws the comment with the reaction added or removed (`Comment.withReaction`: a
new emoji goes last, as tix orders by first use, and one nobody is left reacting with goes), sends the call, and
takes the server's comment as the answer. On failure it puts the comment back as it was and rethrows, and the
tile shows the error as a toast.

## The picker

Eight emoji in one tap, the list tix's web offers (`👍 👎 ❤️ 🎉 😄 😕 👀 🚀`), then a text field for any other.
Its button is enabled when the trimmed text is one grapheme; whether that grapheme is an emoji is the server's
call, and a refusal comes back as the usual error toast.

## Telling an older server

A comment carrying reactions proves the server has them; one without proves nothing, because tix leaves the field
out when nobody reacted. So the add button shows until a reaction is refused with 405, or with 404 and tix's
`no such route` (or no envelope at all), which is how a server without the routes answers. A 404 for a deleted
comment names the comment and is an ordinary error. `TixException.missingRoute` reads that; the repository turns
it into `ReactionsUnsupported`. The verdict is kept per connection for the session. The embedded engine is
v0.57.0 too, so a local instance offers reactions like a server.

Comments still in the outbox, and the comments of an offline draft, offer no reactions: the server does not have
them yet.

## Events

`comment.reacted` and `comment.unreacted` join `EventTopics.comments`, so an open thread refetches when someone
else reacts. Both are in the generated `EventType` now, so the poll fallback reads them too.
