# chaintable

A command-line client for [Chaintable](https://chaintable.com), the data and compute platform for on-chain applications, built for terminals and coding agents such as Claude Code and Codex.

- **Query on-chain data with SQL**: indexed blocks, transactions, transfers, tokens and prices, including state at past blocks.
- **Read live data**: table rows by key or filter, and chain state (balances, code, storage, contract reads) through Leafage.
- **Run compute**: BlockX functions, notebooks and pipelines, on demand or on a schedule.
- **Agent-ready**: a bundled skill for Claude Code and Codex, structured JSON output and documented exit codes.

> Unofficial and in active development: commands and output may change between releases. We improve it from community feedback, so please [open an issue](https://github.com/haimingx/chaintable-cli/issues) for problems and ideas.
>
> Using the Chaintable services through it is governed by the [Chaintable Terms of Service](https://chaintable.com/docs/terms), including the restrictions of your service edition; every API call is billed to your account. Data and results are not investment advice.

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

1. Create a personal access token on chaintable.com.
2. Log in. The token is read without echo and kept in an owner-only file (`~/.config/chaintable/credentials.json`, mode 0600) that coding agents' sandboxes, CI and containers can read; `--keychain` keeps it in the system keychain instead, which agent sandboxes cannot reach:

   ```sh
   chaintable auth login
   ```

   If the token can act for several accounts, login lists them and asks which one to use; that account is billed for API calls. `chaintable auth status` shows the current account and when you logged in; `chaintable auth login --remark "work laptop, token cli-mac"` adds a note of your own, such as the token's name, kept only on this machine. Switch with `chaintable account use` (choose from a list), `chaintable account use <name or id>`, or pass `--account-id` to a single command; on a terminal, commands that may change data first print `Acting for <account>`.

3. Run commands. They mirror the API: `chaintable <resource> [sub-resource] <action>`.

   ```sh
   chaintable query list --limit 5
   chaintable table get --id token.token_transfer.eth
   chaintable query run --id <query-id> --code @query.sql --wait     # run, wait, print rows
   chaintable notebook run --id <id> --max-cpu 1 --max-memory 2 --follow
   chaintable rpc 1 --method getLatestBlock
   chaintable commands                                              # every API command
   chaintable schema query run                                      # inputs of one command
   chaintable api GET '/v1/space/list?limit=5'                      # any endpoint without a command
   ```

Every authenticated API call is billed to the selected account; `chaintable auth status` (which checks the token with the API; `--offline` shows the saved state) and `chaintable account list` are free.

In CI, set `CHAINTABLE_TOKEN` and, for a token with several accounts, `CHAINTABLE_ACCOUNT_ID` instead of logging in. The CLI uses personal access tokens only; API keys are for services that call functions and chain nodes directly.

A coding agent can read anything the CLI can, so treat the token on an agent's machine as exposed to it: give each machine its own token with a short expiry, and revoke it on chaintable.com when the machine no longer needs it. On a terminal, chaintable reminds you a week before the saved token expires; `chaintable auth status` shows `expires_in_days`. The skill tells agents never to read or print the token, and the permissions below keep Claude Code from reading the file.

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
| 4 | No permission, wrong account or no compute units |
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
