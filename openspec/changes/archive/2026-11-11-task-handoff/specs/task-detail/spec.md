# task-detail

## ADDED Requirements

### Requirement: A task is handed to a coding agent

The task view SHALL offer "Hand to an agent" in its header, its menu and the command palette, opening a sheet with
the prompt for an agent using the tix CLI, the command that starts each client tix documents on it, and the prompt
for the tix MCP tools, each copied with one tap, in the words tix's web UI uses. Opening it SHALL send nothing.

#### Scenario: Copy the prompt

- **WHEN** a person signed in to `https://tix.example` opens Hand to an agent on infra-1 titled "Fix login" and copies the prompt
- **THEN** the clipboard holds a prompt that starts `Work on tix task INFRA-1 ("Fix login") on the tix server at https://tix.example.` and claims the task with `tix claim task INFRA-1 -o json`

#### Scenario: A client without a command

- **WHEN** the person picks Zed
- **THEN** the sheet shows no command and offers the MCP prompt to paste into its chat

#### Scenario: A command is one shell word

- **WHEN** the title holds quotes, `$(...)`, backticks or line breaks
- **THEN** each client's command passes the prompt to the client as exactly one word under sh, on one line

### Requirement: A draft is not handed off

A task created offline and not yet sent SHALL NOT offer Hand to an agent, because the server does not know its
reference yet.

#### Scenario: Offline draft

- **WHEN** a person opens a task created offline that has not been sent
- **THEN** the header, the menu and the palette offer no Hand to an agent
