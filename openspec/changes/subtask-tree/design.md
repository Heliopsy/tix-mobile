# Design

## Read one level deeper than drawn

The web draws three levels and asks `task.tree` for four, so it knows which nodes on the third level have
subtasks it did not draw. The app does the same: `SubtaskTree.readDepth` is 4, `drawDepth` is 3, and a node on
the last drawn level carries `more`, the number of its subtasks that were read but not drawn.

## The tree is a flat list

`SubtaskTree` keeps `task.tree`'s depth-first list without the root and builds nodes from `parent_id`. A task
whose parent is not in the list is a direct subtask. That is where a subtask added from the screen, or an
offline draft, lands without knowing the root's id. The cache keeps the list and the shallow flag under a new
key, `task/{ref}/tree`, so an older cached list is never read as a tree.

## Loading a deeper level

"Show N subtasks" reads the node's own `taskSubtasksProvider`, the same provider its own task screen uses, and
draws its nodes below the node with their levels shifted. Nothing new is fetched on load: the tree costs one
request, as before.

## Fold state

Fold and loaded state are the section's widget state, keyed by reference. The web does not remember folds
across page loads either, and every node starts open there too.

## Too large

`task.tree` refuses a subtree of more than 10 000 tasks as `precondition_failed`. The repository then reads one
level and marks the tree shallow, and the section says only direct subtasks are shown, in the web's words. Any
other failure is shown as an error with a retry; the route itself has been there since the app's first server,
so there is no older-server fallback.

## Delete confirmation

A cascading delete removes every descendant. When the tree was read whole the confirmation gives the count of
every subtask; when it was not (shallow, or a level left unread) it says they are deleted at every level instead
of giving a number that would be too small.

## Indentation

Each level is indented by one spacing step, up to the fifth, so a deep row keeps room for its title on a phone.
Rows keep the fold column only when some node in the tree has subtasks, so a flat list looks as it did.
