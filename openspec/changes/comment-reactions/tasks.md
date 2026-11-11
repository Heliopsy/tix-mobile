# Tasks

## 1. Spec

- [x] 1.1 `task-detail` and `api-client` deltas

## 2. Data

- [x] 2.1 `Reaction` and `ReactionSummary` in `data/models/reaction.dart`, `ReactedComment` reading a comment with its reactions
- [x] 2.2 `ReactionOps` on `TixApi`: add, remove, and the comments listing that keeps `reactions`
- [x] 2.3 The repository reads and caches comments with their reactions and sends reactions

## 3. Task screen

- [x] 3.1 `TaskComments` holds reacted comments and toggles a reaction optimistically, undoing on failure
- [x] 3.2 Per-connection reaction support: proven by a `reactions` field, refused by an unknown route, off for a local engine
- [x] 3.3 Reaction chips under each comment, the reader's highlighted, tap to toggle, with semantics labels
- [x] 3.4 Add button and long press open the picker of eight
- [x] 3.5 Strings in every language

## 4. Live updates

- [x] 4.1 `comment.reacted` and `comment.unreacted` refresh the thread

## 5. Tests

- [x] 5.1 Parsing with and without `reactions`
- [x] 5.2 Optimistic toggle, server answer and rollback; an unknown route marks the server
- [x] 5.3 Chips, picker, long press, hidden without support

## 6. After tix releases reactions

- [ ] 6.1 Bump `tix.lock` to that release, `just openapi-sync gen`, and move to the generated `Comment.reactions` and operations
- [ ] 6.2 Bind `comment.react` and `comment.unreact` in the capability registry
- [ ] 6.3 Drop the local-instance switch once the engine has reactions
