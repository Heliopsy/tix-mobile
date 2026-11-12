# agent-connect

## ADDED Requirements

### Requirement: Connect an agent screen

The app SHALL offer Connect an agent in Settings and the palette. It SHALL name the server, the tenant and the
reader's handle, and give the CLI, MCP, SSH, API and skill commands of tix's web, each with Copy.

#### Scenario: Commands for this server

- **WHEN** a person signed in to https://tix.example.com in the tenant acme opens Connect an agent
- **THEN** the CLI tab offers `tix ctx add acme --server https://tix.example.com --token $TIX_TOKEN --tenant acme --use`

### Requirement: MCP clients

The MCP tab SHALL offer one choice per client tix documents (Claude Code, Codex, OpenCode, Gemini CLI, Claude
Desktop, Cursor, VS Code, Zed), each with tix's registration command or configuration file.

#### Scenario: Codex

- **WHEN** a person picks Codex
- **THEN** the screen shows `codex mcp add tix …` and `~/.codex/config.toml`

### Requirement: Issued token fills the commands

A reader holding `token:admin` SHALL be able to issue a token there, prefilled with the name `mcp-agent` and the
agent preset's scopes they hold. Its value SHALL be shown once and SHALL replace `$TIX_TOKEN` in every command,
and SHALL be kept only while the screen is open.

#### Scenario: Issue

- **WHEN** a person issues a token on Connect an agent
- **THEN** every command on the screen carries its value

#### Scenario: Without token:admin

- **WHEN** a reader without `token:admin` opens Connect an agent
- **THEN** no Issue button is drawn and the screen says an administrator issues tokens
