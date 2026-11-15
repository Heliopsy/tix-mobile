# home-widgets

## ADDED Requirements

### Requirement: Quick add links carry a line

A `tixwidget://quickadd` link SHALL accept an optional `text` query parameter, and the app SHALL open the quick add
sheet with that text in the line, unsent. Without `text` the sheet SHALL open empty, as before.

#### Scenario: A line in the link

- **WHEN** the app opens `tixwidget://quickadd?ctx=active&text=Call%20the%20bank`
- **THEN** the quick add sheet opens with "Call the bank" in the line

#### Scenario: No line

- **WHEN** the app opens `tixwidget://quickadd?ctx=active`
- **THEN** the quick add sheet opens empty
