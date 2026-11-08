# custom-field-admin

## ADDED Requirements

### Requirement: A project's fields are listed and defined

A project's fields screen SHALL list its fields in position order with key, label, type, required and default.
With `project:write` a New field action SHALL define one with `PUT /projects/{ref}/fields`: key, label, type, enum
options, default, required.

#### Scenario: Define an enum

- **WHEN** a person defines "env" as an enum of production and staging
- **THEN** the app sends the type, the options and the key

### Requirement: Defaults use a control for their type

The default SHALL be entered with text for string and text, a number for int and float, a choice of none, yes or
no for bool, a date or date and time picker, a choice of the options for enum, a handle for actor and JSON text
for json.

#### Scenario: Number

- **WHEN** a person types 3 as the default of an int field
- **THEN** the app sends the number 3, not the string

### Requirement: Fields are edited, reordered and deleted

Tapping a field SHALL edit it with its key fixed. Dragging SHALL reorder fields by saving new positions. Delete
SHALL be red, confirmed, and sent as `DELETE /projects/{ref}/fields/{key}`.

#### Scenario: Delete

- **WHEN** a person confirms deleting "window"
- **THEN** the field leaves the list
