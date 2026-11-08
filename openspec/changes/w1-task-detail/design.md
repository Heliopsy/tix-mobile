# Design

## Data

The calls live in `TaskDetailRepository` (`lib/src/data/repositories/task_detail_repository.dart`), built in
`core/session` from the session's generated client and response cache. Every request is a generated method, with
one exception: clearing a due date needs `"due_at": null`, which the generated `UpdateTaskInput` drops, so that one
`task.update` body goes through the client's transport with the null kept. The reads that open a section
(comments, subtasks, custom fields, the workflow) are remembered in the cache and drawn from it first, and every
section refreshes on the event topics that concern it.

An update is a `TaskPatch`: one or more attributes, with JSON `null` meaning "clear" and an absent key meaning
"leave". The same patch applies to a local `Task`, which is what makes the optimistic update and its Undo
symmetrical: the inverse patch is built from the task before the change.

## State

`TaskDetailController(ref)` owns the task. A change is applied locally, sent, and replaced by the server's
answer. Sends run one after another, so a version-checked write (description, checklist) always carries the
version of the last answer, and two quick ticks do not conflict with each other. A refusal restores the task as
it was before that change and the widget says why.

Comments, dependencies, subtasks, artifacts and history are separate providers keyed by the task reference, so
each section loads and fails on its own and the properties draw as soon as the task arrives.

## Workflow moves

The move menu lists every state reachable from the current one, with the states a move passes through, found by
a breadth-first walk of the workflow's transitions. The move itself is `POST /tasks/{ref}/route` with `to`, so the
server picks the route and reports a move that stopped partway, which the app shows. A transition that requires a
comment asks for one.

## Checklist

The description is split into Markdown chunks and checklist lines (outside fenced code), each line a 48 dp row
with its own tick. Items are numbered in reading order as tix numbers them; a tick sends `task.check` with that
number and the task's version, and the server's answer replaces the body.

## Layout

Below 760 dp of pane width the properties stack under the title; wider they sit in a column on the right, as the
web's task grid does. Comments, History and Artifacts share a segmented control with counts.
