## ADDED Requirements

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

On a server that does not honour `Idempotency-Key`, a create whose answer was lost SHALL be marked "needs check": the app SHALL look for a task the caller made in that project since the write, whose title the queued line starts with, adopt a single match, send it when there is none, and ask the person when there are several.

#### Scenario: Lost answer without key support

- **WHEN** a create's answer is lost and the server ignores the key
- **THEN** the create is marked to be checked and is not sent twice when the task is found

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
