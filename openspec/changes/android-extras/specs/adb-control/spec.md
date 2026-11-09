# adb-control

## ADDED Requirements

### Requirement: Links open quick add and saved filters

On Android, `tix://quick-add` SHALL open quick add, in the project named by an optional `project` parameter, and `tix://tasks?filter=<name or id>` SHALL open the task screen on that saved filter. Neither SHALL change data, and both SHALL honour `context` like the other links.

#### Scenario: Quick add in a project

- **WHEN** `tix://quick-add?project=OPS` is opened
- **THEN** the quick-add sheet opens with OPS picked

#### Scenario: Saved filter

- **WHEN** `tix://tasks?filter=f7&context=s1.acme` is opened
- **THEN** the app switches to `s1.acme` if needed and the task screen applies saved filter `f7`
