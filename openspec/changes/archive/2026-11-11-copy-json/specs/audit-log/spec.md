# audit-log

## ADDED Requirements

### Requirement: An entry copies as JSON

An entry's detail SHALL offer Copy JSON, on a phone and beside the list on a wide window, and a long press on its
row SHALL do the same. It SHALL put on the clipboard the JSON object tix returned for that entry, indented by two
spaces, with no field added or dropped, and SHALL confirm with a toast.

#### Scenario: Copy from the detail

- **WHEN** a person opens an entry and picks Copy JSON
- **THEN** the clipboard holds that entry's JSON exactly as tix sent it, pretty-printed
- **THEN** a toast says the JSON was copied

#### Scenario: Nothing filled in

- **WHEN** tix sent an entry whose `via` carries only `kind`
- **THEN** the copied `via` carries only `kind`
