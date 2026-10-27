# Accounts, spaces and usage

## Accounts

An account owns resources, usage and API keys: the user's personal account, or an organization they joined. A
personal access token stands for the user: reads include public data and the private data of the user's accounts,
and a change needs the user's role in the account that owns the resource.

- Most commands take the account from the resource they work on. Only `space create`, `notebook run` (the account
  the execution and its notebook quota count against) and `notebook instance list` take one: the selected account,
  or `--account-id <id>` for one command.
- `chaintable auth status` shows the selected account and every account the user belongs to; `account list` lists
  them; `account use <name or id>` switches.
- Organization roles: `owner`, `admin` (manages members and settings), `member` (creates spaces and edits resources).
  A request outside the role exits 4.
- The user picks the account. Never switch it to make a command pass; ask.
- Without login, query commands read public data only; commands that change resources exit 3.

## Spaces

A space groups an account's tables, functions, notebooks, queries and dashboards; its id is the first part of every
resource id (`token.token_transfer.eth`, `demo.usdc_amount`).

- Visibility is `public`, `org` or `private`. Everything in a `public` space can be read by every account; confirm
  with the user before putting anything sensitive in one (`chaintable space get --id <space>` shows `visibility`).
- Lists without `--space` include public resources of other accounts. For the user's own resources, list their spaces
  with `chaintable space list --account-id <account_id>`, then pass `--space` to each list.
- Resources in another account's public space can be read, not changed.
- New space: `chaintable space check-id --id <id>` (3–64 lowercase letters, digits and underscores, starting with a
  letter), then `chaintable space create --id <id>` in the selected account; only `public` is accepted for now. The id
  cannot change later. `space update` changes the description or visibility; `space delete --yes` deletes it (space
  admin). `space stats --id <space>` counts its resources.

## Usage and limits

- Plans cover indexing (tables and notebooks), API calls and analytics. Community is free for individual,
  non-commercial use; Business is for commercial use. Tiers set table storage and count, notebook CPU and memory, API
  compute units and request rates.
- CLI calls are not billed in compute units; they are rate limited per IP address, and SQL executions submitted
  without an API key share a platform-wide concurrency limit. API keys, for services, are billed to their account.
- Notebook runs use the account's CPU and memory quota.
- Exit 4 with a quota message, or exit 7 when rate limited after the CLI's retries, are limits: report them to the
  user instead of retrying in a loop.

Docs: https://docs.chaintable.com/guides/accounts/management.md, https://docs.chaintable.com/guides/accounts/plans-and-usage.md,
https://docs.chaintable.com/guides/openapi/calling.md
