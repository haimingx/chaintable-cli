# Accounts, spaces and usage

## Accounts

An account owns resources, usage and API keys: the user's personal account, or an organization they joined. A
personal access token acts for one of the user's accounts per request, and that account is billed.

- `chaintable auth status` shows the current account and every account the token can act for; `account list` lists
  them; `account use <name or id>` switches; `--account-id <id>` acts for another account in one command.
- Organization roles: `owner`, `admin` (manages members and settings), `member` (creates spaces and edits resources).
  A request outside the role exits 4.
- The user picks the account. Never switch it to make a command pass; ask.

## Spaces

A space groups an account's tables, functions, notebooks, queries and dashboards; its id is the first part of every
resource id (`token.token_transfer.eth`, `demo.usdc_amount`).

- Visibility is `public`, `org` or `private`. Everything in a `public` space can be read by every account; confirm
  with the user before putting anything sensitive in one (`chaintable space get --id <space>` shows `visibility`).
- Lists without `--space` include public resources of other accounts. For the user's own resources, list their spaces
  with `chaintable space list --space-account-id <account_id>`, then pass `--space` to each list.
- Resources in another account's public space can be read, not changed.

## Usage and limits

- Plans cover indexing (tables and notebooks), API calls and analytics. Community is free for individual,
  non-commercial use; Business is for commercial use. Tiers set table storage and count, notebook CPU and memory, API
  compute units and request rates.
- Every API call is billed in compute units to the selected account, except `auth status` and `account list`.
- Exit 4 with an exhausted-units or not-enabled message, or exit 7 when rate limited after the CLI's retries, are
  account limits: report them to the user instead of retrying in a loop.

Docs: https://docs.chaintable.com/guides/accounts/management.md, https://docs.chaintable.com/guides/accounts/plans-and-usage.md,
https://docs.chaintable.com/guides/openapi/calling.md
