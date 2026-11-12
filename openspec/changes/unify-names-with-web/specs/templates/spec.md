# templates

## MODIFIED Requirements

### Requirement: Templates are listed

The templates screen SHALL list the templates the person can read, by name, a page at a time, each with its
project (or "All projects", as tix web says), its title and how often it was used, and SHALL say when there are
none. The template form SHALL name its due offset "Due in".

#### Scenario: Templates listed

- **WHEN** the server holds templates `weekly` in `ops` and `bug` for every project
- **THEN** both are listed with their project and title, and `bug` reads All projects

#### Scenario: None

- **WHEN** the server holds no template
- **THEN** the screen says so and offers New template
