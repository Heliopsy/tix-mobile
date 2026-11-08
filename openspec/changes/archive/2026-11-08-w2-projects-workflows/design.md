# Design

## Who may do what

`whoami` answers with the actor's role and direct scopes. `Access` (`core/session/access.dart`) mirrors tix's
`Actor.HasScope`: `*` grants everything except `global:admin` and `account:read`, a role adds its bundle (viewer,
member, admin as in tix's `Role.Scopes`). The answer is cached per context, so the hub draws offline. Screens hide
what the credential cannot do instead of letting the server refuse it: a write control without the write scope is
not drawn, and the screen says it is read only.

## The hub

`features/manage/manage_sections.dart` is a flat `const` list of `ManageEntry` values: group, id, icon, title
and subtitle (localised getters), route, and the scope that shows it. Other features append entries and nothing
else, so parallel changes merge as one added block each. The hub groups the visible entries in `ManageGroup`
order and leaves a group out when none of its entries shows.

## Navigation

The shell builds its destinations from one list. A phone shows the first four and a More destination when there
are more than five; More opens a sheet with the rest. The rail shows every destination.

## Data

`ProjectsRepository` and `WorkflowsRepository` (`data/repositories`) wrap the generated client. Listings and
records that open a screen are cached first pages, as elsewhere. A workflow is edited as a `WorkflowDraft`: plain
immutable state (states in order, transitions, initial, default lease, migrations) built from a `Workflow` and
turned back into a `WorkflowInput`. Removing a state that existed in the stored workflow offers a migration
target; the server decides whether one is needed.

## Errors

A refusal from a form stays in the form: the server's message shows above the fields (and under the field the
envelope's `details.field` names, when it does), and the draft is kept.

## The null that clears

The generator marks an input field as clearable when its description says null clears it. Such a field is a
`Patch<T>?`: absent leaves the attribute, `Patch(value)` sets it, `Patch.clear()` sends JSON null. The generated
client builds those bodies itself, so json_serializable's `include_if_null: false` cannot drop the null.
