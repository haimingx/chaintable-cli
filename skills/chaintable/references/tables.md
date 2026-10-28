# Tables

Chaintable tables are BlockDB online tables in a space, addressed by full id: `space.table` for normal and time
tables, `space.table.chain` for block tables (for example `token.token_transfer.eth`). They serve live reads and
writes; SQL reads an analytics copy of them that trails behind (see `references/sql.md`).

## Types and when to use them

| Type (`--table-type`) | Suitable data | What `id` identifies | How changes are kept |
|---|---|---|---|
| `normal` | Asset information, configuration, lookup dictionaries | The record | One current record per `id`; writing an `id` again updates the fields given, no history |
| `block_event` | Transfers, transactions, contract events | One event | Every event is a row at its block; events in the same block need distinct ids (for example transaction hash plus log index) |
| `block_state` | Pool reserves, balances, contract state | The tracked object (for example a pool address) | A version per block where it changed; latest is kept current, history in `._archive` |
| `time` | Prices and other time-sampled values | The series | One value per time bucket; latest and `._archive` |

Choose by the question the data answers: "what is it now" (`normal`), "what happened" (`block_event`), "what was it
at block N" (`block_state`), "what was it at time T" (`time`). A balance cannot be read from a single transfer row;
derive it from events or keep it in a `block_state` table.

## Fields and ids

- Every table has an `id` column; its type is one of `chaintable table id-types` (`STRING`, `ADDRESS`, `TOKENID`,
  `HASH`, `BLOCKID`, `CHAINID`, `TXID`) and is never numeric.
- Block tables add `block_height`, `block_id` and `block_timestamp`; time tables use `id`, `time_at` and `value`.
  `chaintable table templates --table-type <type>` shows the default columns and indexes; `table init` needs an `id`
  on each column as well, usually the name.
- Column types: `STRING` (up to 128 characters), `TEXT`, `HEXSTRING`, `ADDRESS`, `TOKENID`, `TXID`, `BLOCKID`,
  `HASH` (32 hex characters, not a transaction hash), `CHAINID`, `INT` (signed 64-bit), `BLOCKHEIGHT`, `UINT256`
  (exact), `FLOAT`, `BOOLEAN`, `TIMESTAMP`. `INT` and `UINT256` values are read back as decimal strings. Keep
  addresses and hashes lowercase.
- Index the columns you filter on. `table indexes update` replaces the user indexes: list every index to keep, the
  existing ones with their `id` from `table get`.

## Subtables, coverage and history

- Block and time tables keep system subtables: `<id>._archive` holds historical versions, `<id>._height` the
  processed block ranges, `<id>._write` batch-write jobs, and others for internal bookkeeping. `latest` and `event` are roles of the main table, not
  suffixes. Read subtables; never write to them.
- A `block_state` read at a block returns the latest version at or before it, so unchanged blocks are not stored.
- Start height is the first block a block table covers; set it after `table init` and before the first write
  (`table start-height editable`, then `table start-height update`). It cannot change once blocks are processed.
- Consensus height is the highest block processed continuously from the start height; a newer row does not mean
  every earlier block is complete. Compare tables only at a block all of them cover (`table stats block`).
- Time tables round a time up to its bucket and return the value at or before it, without interpolation. Buckets
  grow from minutes to hours and days as data ages, so old data shows trends, not every change.
- The replica count (`--replica-num`, `1` or `3`) is fixed at creation; `3` survives failures at higher storage cost.

## Reading and writing

| Need | Command |
|---|---|
| Rows by primary key | `chaintable table row get --table-id <id> --pks '["usdc"]'`; on a block state or time table it returns each id's latest value, for example the latest WETH price: `--table-id price.price.eth --pks '["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"]'` |
| Latest rows, or a simple filter | `chaintable table row query --table-id <id> --sql "SELECT * FROM <id> WHERE … ORDER BY block_height DESC LIMIT 100"` (only `SELECT *` with `WHERE`, `ORDER BY` and `LIMIT`), or `chaintable table row list --table-id <id> --order-by block_height --limit 50 --filter '[{"field":"token_id","op":"eq","value":"0x…"}]'` (`op`: `eq`, `neq`, `gt`, `lt`, `gte`, `lte`) |
| Every row | `chaintable table row export <id> --out rows.ndjson` (10000 rows per page) |
| Aggregation, joins, history | SQL (`query run --wait`) |
| Writes | `chaintable table row create`, `table row update`, `table row delete`, on `normal` tables only; `create` on an existing `id` updates the fields given |

- Always sort when you want recent rows: without `ORDER BY` (or `--order-by`) rows come in primary key order, which on
  block tables starts at the first blocks.
- Sort and filter on indexed columns (`chaintable table get --id <id> --fields indexes`): `block_height` or
  `block_timestamp` on block tables, `time_at` on time tables, and indexes such as `(to_addr, block_timestamp)`.
  Sorting by any other column scans the table and times out with exit 8; that is not transient: narrow the filter to
  an indexed column or use SQL instead of retrying.
- A write with an unknown column or a value of the wrong type fails with exit 8 (`50106`); it is not transient, so
  check the columns and types instead of retrying.
- Writes to a column added moments ago can be dropped while the change spreads, for a minute or two: read the row
  back before relying on it.

Block and time tables are filled through the BlockDB SDK, usually by a notebook pipeline (see
`references/notebooks.md`), because a write must keep latest, history and coverage consistent.

## Creating a table

A table is created without columns, then initialized once. A block table's name ends with its chain
(`pool_reserves.eth`, id `<space>.pool_reserves.eth`):

```sh
chaintable table create --space <space> --name asset_notes --table-type normal
chaintable table init --id <space>.asset_notes --columns '[{"name":"id","type":"STRING"},{"name":"symbol","type":"STRING"},{"name":"amount","type":"UINT256"}]' --indexes '[{"columns":["symbol"]}]'
chaintable table create --space <space> --name pool_reserves.eth --table-type block_state --chain-id eth
```

Leave column ids out, as the web app does: the CLI gives new columns their ids, and column ids are unique across all
tables, so a made-up id such as the column name fails. Initialization is one-time: if it fails, the error is not
retryable; tell the user, and with their agreement delete the table (`table delete --id <table-id> --yes`) and create it
again.

`table columns update` and `table indexes update` change an initialized table. `table columns update` takes every
column to keep, still without ids: columns named as before keep their data, new names are added and missing ones are
dropped with their data. To rename a column, pass its `id` from `table get` with the new name; adding a column under
the old name must wait for a second update.

`table truncate` deletes every row and keeps the definition; `table delete` removes the table with its data, and the id
can be used again. Both need the space admin role and `--yes`, and cannot be undone: confirm with the user first.

Docs: https://docs.chaintable.com/guides/tables/model.md, https://docs.chaintable.com/guides/tables/create-and-manage.md,
https://docs.chaintable.com/guides/tables/advanced.md, https://docs.chaintable.com/reference/data-types.md,
https://docs.chaintable.com/reference/sdk/blockdb-py.md
