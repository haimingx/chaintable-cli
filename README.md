# chaintable

A command-line client for [Chaintable](https://chaintable.com), the data and compute platform for on-chain applications, built for terminals, coding agents such as Claude Code and Codex, and MCP clients such as Claude Desktop, Cursor and VS Code.

- **Query on-chain data with SQL**: indexed blocks, transactions, transfers, tokens and prices, including state at past blocks.
- **Read live data**: table rows by key or filter, and chain state (balances, code, storage, contract reads) through Leafage.
- **Run compute**: BlockX functions, notebooks and pipelines, on demand or on a schedule.
- **Agent-ready**: a bundled skill for Claude Code and Codex, a local MCP server for other clients, structured JSON output and documented exit codes.

> Unofficial and in active development: commands and output may change between releases. We improve it from community feedback, so please [open an issue](https://github.com/haimingx/chaintable-cli/issues) for problems and ideas.
>
> Using the Chaintable services through it is governed by the [Chaintable Terms of Service](https://chaintable.com/docs/terms), including the restrictions of your service edition. Data and results are not investment advice.

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/haimingx/chaintable-cli/main/install.sh | sh
```

The script installs to `~/.local/bin` (set `CHAINTABLE_INSTALL_DIR` to change it), always checks the archive against `checksums.txt` and, when [cosign](https://docs.sigstore.dev/cosign/system_config/installation/) is installed, verifies its signature. Set `CHAINTABLE_VERSION` to install a specific release.

Windows: download the `.zip` for your architecture from [Releases](https://github.com/haimingx/chaintable-cli/releases) and put `chaintable.exe` on your `PATH`.

### Verify a download

`checksums.txt` is signed in the release workflow with [Sigstore](https://www.sigstore.dev/) keyless signing:

```sh
cosign verify-blob --bundle checksums.txt.sigstore.json \
  --certificate-identity "https://github.com/haimingx/chaintable-cli-src/.github/workflows/release.yml@refs/tags/<tag>" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com checksums.txt
sha256sum -c --ignore-missing checksums.txt
```

Each archive also has an SPDX SBOM (`*.sbom.json`).

### Shell completion

```sh
source <(chaintable completion bash)                                     # bash, add to ~/.bashrc
chaintable completion zsh > "${fpath[1]}/_chaintable"                    # zsh
chaintable completion fish > ~/.config/fish/completions/chaintable.fish  # fish
```

### Update

```sh
chaintable update              # newest release; --version v0.1.0 for a specific one, --check to only look
```

It verifies the download like the install script (checksum, and signature when cosign is installed) and replaces the binary in one atomic rename; login and settings stay. Rerunning the install command does the same. On a terminal, chaintable checks GitHub for a newer release at most once a day and prints a notice; it never does in scripts, CI or agents, and `CHAINTABLE_NO_UPDATE_NOTIFIER=1` turns it off. A binary installed by a package manager is updated with that package manager.

`chaintable update` then brings the skill everywhere it is installed to the new version: it updates the Claude Code and Codex plugins through their own CLIs (`claude`, `codex`; skip with `--no-plugins`) and rewrites skills installed with `chaintable skill install`. Start a new agent session afterwards: a running session keeps the skill it loaded. `chaintable skill sync` does the same for the installed binary. Without the agents' CLIs on PATH, update the plugin in the agent:

```text
/plugin marketplace update chaintable          # Claude Code, then
/plugin update chaintable@chaintable           # and restart Claude Code
```

```sh
codex plugin marketplace upgrade chaintable    # Codex
```

A plugin does not update a separate copy of the skill in `~/.agents/skills`, `~/.codex/skills` or `~/.claude/skills`, and the agent loads that copy next to the plugin; `chaintable update` and `chaintable skill sync` name such copies. Delete them when you use the plugin.

## Quick start

Query commands work without login and read public data. Log in to change resources, run notebooks and schedules, and to
read the private data of your accounts.

1. Create a personal access token on chaintable.com.
2. Log in. The token is read without echo and kept in an owner-only file (`~/.config/chaintable/credentials.json`, mode 0600) that coding agents' sandboxes, CI and containers can read; `--keychain` keeps it in the system keychain instead, which agent sandboxes cannot reach:

   ```sh
   chaintable auth login
   ```

   `space create` and `notebook run` need an account. If you belong to several, login lists them and asks which one to use. `chaintable auth status` shows the selected account and when you logged in; `chaintable auth login --remark "work laptop, token cli-mac"` adds a note of your own, such as the token's name, kept only on this machine. Switch with `chaintable account use` (choose from a list), `chaintable account use <name or id>`, or pass `--account-id` to a single command; on a terminal, a create or run that uses the selected account first prints `Acting for <account>`.

3. Run commands. They mirror the API: `chaintable <resource> [sub-resource] <action>`.

   ```sh
   chaintable query list --limit 5
   chaintable table get --id token.token_transfer.eth
   chaintable query run --id <query-id> --code @query.sql --wait     # run, wait, print rows
   chaintable notebook run --id <id> --max-cpu 1 --max-memory 2 --follow
   chaintable rpc eth --method getLatestBlock                       # chain name, or numeric id (1)
   chaintable commands                                              # every API command
   chaintable schema query run                                      # inputs of one command
   chaintable api GET '/v1/space/list?limit=5'                      # any endpoint without a command
   ```

CLI calls are not billed; they are rate limited per IP address. `chaintable auth status` checks the token with the API; `--offline` shows the saved state.

Each request identifies the CLI in its `User-Agent`, for usage statistics: `chaintable-cli/<version> (<os>/<arch>; <caller>)`. The caller is the AI agent running the CLI when the agent's environment variables name one (`claude-code`, `codex`, …), `ci` in CI, otherwise `interactive` or `noninteractive` depending on whether stdin is a terminal. Nothing else about you, your machine or your commands is sent.

In CI, set `CHAINTABLE_TOKEN` and, when you belong to several accounts, `CHAINTABLE_ACCOUNT_ID` instead of logging in. The CLI uses personal access tokens only; API keys are for services that call the API directly and are billed to their account.

A coding agent can read anything the CLI can, so treat the token on an agent's machine as exposed to it: give each machine its own token with a short expiry, and revoke it on chaintable.com when the machine no longer needs it. The skill tells agents never to read or print the token, and the permissions below keep Claude Code from reading the file.

## Use with Claude Code

Install the CLI first (see [Install](#install)), then the plugin:

```text
/plugin install chaintable --marketplace haimingx/chaintable-cli
```

On Claude Code before 2.1.275, run `/plugin marketplace add haimingx/chaintable-cli` and then `/plugin install chaintable@chaintable`. To update, see [Update](#update).

Then ask in plain language, for example "How many USDC transfers happened on Ethereum yesterday?". Log in yourself with `! chaintable auth login`; the agent never needs to see the token.

When the plugin's skill is in use, read-only commands such as `table get` and `query list` run without a prompt; creates, runs, updates and deletes still ask. To allow the read-only commands in every turn and keep Claude Code from reading the token file, add the settings printed by `chaintable skill print references/permissions.md` to `~/.claude/settings.json`. With the Bash sandbox on, allow network access to the API host.

## Use with Codex

```sh
codex plugin marketplace add haimingx/chaintable-cli
codex plugin add chaintable@chaintable
```

If a chaintable skill is also in `~/.codex/skills` or `~/.agents/skills`, delete that copy so the plugin's skill is the only one loaded.


Codex's sandbox blocks network access by default. Enable it in `~/.codex/config.toml`:

```toml
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = true
```

## Use with MCP clients

`chaintable mcp` is a local [MCP](https://modelcontextprotocol.io) server for clients such as Claude Desktop, Cursor and VS Code. The client starts it as a process on your computer and talks to it over stdio; requests go from your computer straight to the Chaintable API. Coding agents that run shell commands, such as Claude Code and Codex, are better served by the plugin above.

1. Install the CLI (see [Install](#install)), version 0.4.0 or later.
2. Optional: log in in a terminal with `chaintable auth login`. Without login the server reads public data; with it, it also reads your accounts' private data and can create and run resources. The server uses this login, so no token goes into the client's configuration.
3. Desktop apps do not read your shell's `PATH`, so give them the binary's full path: `chaintable mcp --help` prints a ready configuration with it (or use `which chaintable`, on Windows `where chaintable`).
4. Add the server to your client, then restart the client fully.

**Claude Desktop**: Settings → Developer → Edit Config opens `claude_desktop_config.json` (macOS: `~/Library/Application Support/Claude/`, Windows: `%APPDATA%\Claude\`):

```json
{
  "mcpServers": {
    "chaintable": {
      "command": "/Users/you/.local/bin/chaintable",
      "args": ["mcp"]
    }
  }
}
```

**Cursor**: the same `mcpServers` entry in `~/.cursor/mcp.json`, or in `.cursor/mcp.json` for one project.

**VS Code**: in `.vscode/mcp.json` of a workspace, or through the command MCP: Add Server:

```json
{
  "servers": {
    "chaintable": {
      "type": "stdio",
      "command": "/Users/you/.local/bin/chaintable",
      "args": ["mcp"]
    }
  }
}
```

**Claude Code**, when you prefer MCP to the plugin: `claude mcp add --scope user chaintable -- chaintable mcp`.

On Windows, use the full path to `chaintable.exe`, with backslashes escaped in JSON (`"C:\\Tools\\chaintable.exe"`). To use another profile, add `"env": {"CHAINTABLE_PROFILE": "work"}` to the server entry. Do not put `CHAINTABLE_TOKEN` in a client's configuration: those files are plain text and often synced or shared.

### Tools

| Tool | Runs | Approval |
|---|---|---|
| `chaintable_read` | Read-only commands: SQL and table reads, chain calls, getting and listing resources, `commands`, `schema`, `skill print` | Marked read-only; safe to allow always |
| `chaintable_run` | Commands that create, change, delete or run something | Keep asking each time; deletes also need `--yes` |

Both take the command line after `chaintable` as a list of arguments, for example `["table", "get", "--id", "token.token.eth"]`. The model is told to read the skill first through `["skill", "print"]`, so it follows the same guidance as the Claude Code plugin. Login, `update`, `skill sync` and other CLI management run only in a terminal, and `--base-url` is refused so that no text the model reads can send your token elsewhere.

A result over 80 KB is refused with a hint to ask for less (`LIMIT`, `--limit`, `--fields`, or the next page with `--start`), since clients cap tool results and may not read local files.

### Troubleshooting

| Symptom | Check |
|---|---|
| The tools do not appear | Restart the client fully; check the `command` path with `"<path>" version` in a terminal |
| `spawn chaintable ENOENT` or command not found | Use the absolute path from step 3 |
| `this command requires login` | Run `chaintable auth login` in a terminal; the server picks it up on the next call |
| Calls fail with network errors | The machine needs access to `api.chaintable.com` |
| Anything else | Run `chaintable mcp` in a terminal: it waits for a client without printing, so stop it with Ctrl-C. Claude Desktop's logs are in `~/Library/Logs/Claude/mcp*.log` (Windows: `%APPDATA%\Claude\logs`) |

## Use with other agents

Agents that read [Agent Skills](https://agentskills.io) but have no plugin system get the skill from the binary, in the shared user directory or a project's:

```sh
chaintable skill install ~/.agents/skills      # or .agents/skills in a project
```

`chaintable update` keeps it at the same version as the binary.

## Output and errors

Output is a table on a terminal and JSON otherwise; use `-o ndjson` for rows, `--fields` to trim and `--out <file>` for large results. On a terminal errors read as `Error:` and `Hint:` lines; otherwise the last stderr line is a JSON error report.

| Exit code | Meaning |
|---|---|
| 0 | Success |
| 1 | Ran but failed (query error, failed function or notebook) |
| 2 | Usage error or rejected input |
| 3 | Not logged in or invalid credential |
| 4 | No permission or wrong account |
| 5 | Not found |
| 6 | Conflict |
| 7 | Rate limited |
| 8 | Network or server error (retryable; GET requests are already retried twice) |
| 9 | `--wait` or `--follow` timed out |

## Feedback and security

Report bugs and request features in [Issues](https://github.com/haimingx/chaintable-cli/issues). Include `chaintable version` and the `request_id` from the error, never a token. The source is not public, so pull requests are not accepted.

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).

## License

Free to use under the terms in [LICENSE](LICENSE), which cover this software only; third-party components are listed in [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES).
