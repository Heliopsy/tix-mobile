# Design

## Branch order

Watch is a new `StatefulShellBranch` at index 4, between Inbox and Manage. `HomeShell.destinations` lists it in the
same place, and every command selects branches through `at('<id>')`, so nothing else counts indexes. Ctrl+1 to
Ctrl+6 keep their targets; Watch has `g w` and the palette.

The destination is not gated on `event:subscribe`. Hiding it would shift the branch indexes per credential, and the
screen already says what is missing when the server refuses.

## Phone bar

With seven destinations the bar shows Projects, Tasks, My work and Inbox, and More lists Watch, Manage, Settings and
About. More is selected while Watch is open.

## Old links

`/manage/watch` stays as a redirect-only route under Manage, so saved links and history land on `/watch`.
