# offline-sync Specification

## Purpose

Changes made while a remote server cannot be reached are kept on the device, shown at once, and sent when the
server is back, in order, without duplicates, with conflicts settled by the person or their chosen policy and
kept in a reversible history.

## Requirements

### Requirement: Writes queue while the server is out of reach

When the device has no network, or a write fails because the server cannot be reached (network error, timeout, a 502/503/504), the app SHALL keep the write in an outbox for the active context and show it at once. Each entry SHALL record the operation, the target task, the version and the task as the person saw it, the new values, a client-generated Idempotency-Key and when it was made. A refusal (403, 422, 400) SHALL NOT be queued.

#### Scenario: Editing offline

- **WHEN** the person renames a task with no network
- **THEN** the new title shows at once with an "Unsynced" mark
- **AND** the outbox holds an update with the task's version, the old task and the new title

#### Scenario: A refusal is not queued

- **WHEN** the server refuses a comment with 403 while online
- **THEN** the comment is not queued and the server's reason is shown

### Requirement: Writes to one task stay in order

The app SHALL replay the writes to one task in the order they were made, and SHALL queue a write behind earlier ones still waiting for the same task even while online. Writes to different tasks SHALL replay in parallel. A task's writes SHALL stop at the first one that waits for the person, without holding back other tasks.

#### Scenario: Two edits to one task

- **WHEN** the person renames a task and then changes its priority offline, and the network returns
- **THEN** the rename is sent first and the priority change is sent on the version the rename produced

#### Scenario: A conflict holds back only its task

- **WHEN** an edit to one task conflicts and an edit to another does not
- **THEN** the other task's edit is sent and the conflicting task's later writes keep waiting

### Requirement: Tasks can be created offline

A task created offline SHALL get a temporary reference made of its project key and `draftN`, visibly marked as a draft. Writes that name the draft (comments, subtasks, dependencies, moves, edits) SHALL be queued against it and rewritten to the real reference once its create is sent. A link or route to a sent draft SHALL open the real task.

#### Scenario: Comment on a draft

- **WHEN** the person quick-adds a task offline, comments on it and makes another task depend on it
- **THEN** on reconnect the task is created first and the comment and the dependency are sent to its real reference

#### Scenario: Opening a sent draft

- **WHEN** the person opens a link to `infra-draft1` after it was created as `infra-42`
- **THEN** the app shows `infra-42`

### Requirement: Replays are idempotent

Every replayed write SHALL carry its entry's `Idempotency-Key`, and the app SHALL ask each server once whether it honours the key. On a server that does, a create whose answer was lost SHALL be sent again with the same key, a write the server reports as applied with its answer lost SHALL count as done and be read back, and one it reports as still running SHALL be retried later.

#### Scenario: Lost answer with key support

- **WHEN** a create's answer is lost and the server honours Idempotency-Key
- **THEN** the create is sent again with the same key and one task exists

#### Scenario: Applied but the answer was not kept

- **WHEN** the server answers a retried create with "applied but its response was not kept"
- **THEN** the create is not sent again and the task it made is found and adopted

### Requirement: Lost creates are checked on older servers

On a server that does not honour `Idempotency-Key`, a create whose answer may have reached the server SHALL be marked "needs check". The app SHALL look for tasks the caller made in that project since the write, adopt the one whose normalized title equals the queued one when nothing else resembles it, send it when nothing matches, and otherwise ask.

#### Scenario: Lost answer without key support

- **WHEN** a create's answer is lost and the server ignores the key
- **THEN** the create is marked to be checked and is not sent twice when the task is found

#### Scenario: Only a prefix matches

- **WHEN** the queued title is "Call Bob re invoice" and the lookup finds only "Call Bob"
- **THEN** nothing is adopted or sent, and the person is asked

### Requirement: A stale update is merged three ways

When the server answers an update with 409, the app SHALL read the task and merge per attribute against the version the person saw: an attribute only the person changed SHALL be sent on the new version, one both changed to the same value SHALL be dropped, and one both changed differently SHALL be a conflict settled by the policy. Tags SHALL merge as sets and each custom field SHALL merge on its own.

#### Scenario: Different attributes

- **WHEN** the person changed the title offline and someone else changed the priority
- **THEN** the title is sent on the new version with no conflict

#### Scenario: The same attribute

- **WHEN** both changed the title to different values and the policy is Ask
- **THEN** the write waits and a conflict shows both titles

### Requirement: Some writes never conflict, some always ask

Comments, tags, stars, dependencies and attachments SHALL be sent without a merge and SHALL never conflict. A move the workflow refuses SHALL be a conflict carrying the server's reason. A write to a task deleted on the server SHALL be a conflict offering to restore the task and apply the writes, or discard them. Another refusal SHALL fail the write with the server's reason, editable or discardable.

#### Scenario: Refused move

- **WHEN** a queued move is refused with 422 "no route from todo to done"
- **THEN** a conflict shows that reason and offers another status or keeping the server's

#### Scenario: Deleted task

- **WHEN** a task with a queued edit was deleted on the server and the person picks "Restore and apply"
- **THEN** the task is restored and the edit is sent

### Requirement: Conflict policy per context

Settings SHALL let the person choose, per context, how conflicts found during replay are settled: Ask (the default), Keep mine or Keep theirs. Changing the policy SHALL apply to conflicts found afterwards and SHALL leave open conflicts open.

#### Scenario: Keep theirs

- **WHEN** the policy is Keep theirs and an offline title change conflicts
- **THEN** the server's title stays, the rest of the change is sent and the conflict is recorded as settled by the setting

### Requirement: Conflicts are listed and reversible

A Conflicts screen, reached from a badge in the shell and from a banner on the task, SHALL show each open conflict side by side per attribute with Keep mine, Keep theirs and Edit, with Keep all mine and Keep all theirs when several are open. It SHALL list writes still waiting and refused ones, and a history of settled conflicts, including those settled by the policy, each of which SHALL be reversible by sending the side that was not kept.

#### Scenario: Reversing an automatic decision

- **WHEN** the policy kept the person's title over someone else's and the person picks Reverse in the history
- **THEN** the other title is sent and the record says theirs was kept

### Requirement: Catching up after replay

After a replay sends writes or finds conflicts, the app SHALL report a gap on the event stream, so every list and record reads the server again. Replay SHALL start when the network returns, when the event stream goes live again, when a write is queued while the server is reachable, at Sync now, and every minute while writes wait.

#### Scenario: Reconnect

- **WHEN** the network returns with writes waiting
- **THEN** they are sent shortly after and the open lists reload from the server

### Requirement: Discard all unsynced changes

Settings SHALL offer to discard every unsynced change of the context, as a red button that asks for confirmation and says how many changes are dropped.

#### Scenario: Discard all

- **WHEN** the person confirms Discard all unsynced changes
- **THEN** the outbox is empty, drafts disappear and open conflicts are closed as discarded

### Requirement: One replay at a time per context

Replays of one context SHALL never overlap, however many times the session changes: a replay asked for while
another runs SHALL wait for it to end. Every writer of a context SHALL share one outbox for the life of the app.
Each replay SHALL settle conflicts by the policy of its own context, read once when it starts.

#### Scenario: Session changes during a replay

- **WHEN** the session changes while a replay is sending and a new replay starts
- **THEN** the new one waits, and no write is sent twice

#### Scenario: Away and back

- **WHEN** the person switches to another context and back while a replay is sending, and queues a write
- **THEN** each write is sent once and the new write is kept

### Requirement: Day-old idempotency keys are not trusted

tix forgets an `Idempotency-Key` a day after it first sees it. Only a send that may have reached the server (a
timeout or an unreadable answer, not a refused connection) SHALL start that clock. A create or comment first sent
23 hours ago or more SHALL be looked up before it is sent again, and sent with a new key when it is not found.

#### Scenario: Create retried the next day

- **WHEN** a create's answer was lost and the app retries it 23 hours later
- **THEN** the task it made is found and adopted, and the create is not sent again

#### Scenario: Comment retried the next day

- **WHEN** a comment's answer was lost and the caller's comment with the same text is on the task 23 hours later
- **THEN** the comment is not added again

### Requirement: An unreadable outbox is kept

When the stored outbox of a context cannot be read, the app SHALL move it aside under `sync/` with a timestamp,
SHALL not write over it, and SHALL say so in the offline settings.

#### Scenario: Outbox written by a broken build

- **WHEN** the stored outbox no longer decodes
- **THEN** it is kept aside untouched, a new outbox starts, and the offline settings say changes could not be read

### Requirement: Sync history stays bounded

Settled conflicts SHALL be kept for 30 days and at most the newest 100, and sent drafts SHALL keep their real
reference for the newest 200 and for any a waiting write still names.

#### Scenario: Months of offline work

- **WHEN** a replay ends with settled conflicts older than 30 days
- **THEN** they are dropped from the history and open conflicts stay

### Requirement: Forgetting a connection warns about unsent writes

Signing out, removing a connection or removing an instance SHALL say how many changes made offline are still
unsent and will be lost before it asks for confirmation, and SHALL stop a replay under way before it deletes the
outbox.

#### Scenario: Sign out with writes waiting

- **WHEN** a person signs out with two changes not yet sent
- **THEN** the confirmation says two changes made offline will be lost

### Requirement: Project stars queue like task stars

A project star or unstar made while the server is out of reach SHALL be queued in the outbox against the
project's key, drawn on the starred list at once, and sent in order when the server is back. It SHALL never
conflict. A project the server no longer has SHALL make the write refused, not a deleted task to restore.

#### Scenario: Starring offline

- **WHEN** the person stars Web with no network
- **THEN** Web shows under Starred at once and the outbox holds a project star for `web`
- **AND** the star is sent when the server is reachable again

#### Scenario: The project is gone

- **WHEN** a queued project star is replayed and the server answers 404
- **THEN** the write is marked refused with the server's reason and no conflict is opened

### Requirement: Notification actions use the outbox

A notification action SHALL be written through the outbox of the notification's context with its own Idempotency-Key, sent at once when the server is reachable and kept for replay when it is not. When the context cannot be reached from the background (a local instance, or a sign-in sitting in another tenant) the write SHALL be queued and sent when the app next runs that context.

#### Scenario: Done offline

- **WHEN** a person taps Done with no network
- **THEN** a move to the done state is queued in that context's outbox with a fresh key, the notification goes away, and the move is sent when the network returns

#### Scenario: Local instance

- **WHEN** a person replies to a notification from a local instance while its engine is stopped
- **THEN** no engine starts and the comment waits in that context's outbox

### Requirement: One engine holds the outbox at a time

On Android, the app SHALL NOT read or write an outbox while a headless engine that ran a notification action is alive. When the app opens during one, the headless engine SHALL finish the actions it is running and be stopped, and only then SHALL the app load the outbox. An action pressed while the app is open SHALL run in the app.

#### Scenario: Opening the app right after an action

- **WHEN** a person taps Done with the app closed and opens tix while the background engine is still up
- **THEN** the background engine finishes the move and stops, and the app then loads an outbox that holds it
