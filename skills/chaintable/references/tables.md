# Tables

Chaintable tables are BlockDB online tables in a space, addressed by full id: `space.table` for normal and time
tables, `space.table.chain` for block tables (for example `token.token_transfer.eth`). They serve live reads and
writes; SQL reads an analytics copy of them that lags by minutes (see `references/sql.md`).

## Types and when to use them

| Type (`--table-type`) | Suitable data | What `id` identifies | How changes are kept |
|---|---|---|---|
| `normal` | Asset information, configuration, lookup dictionaries | The record | One current record per `id`; writing an `id` again overwrites it, no history |
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
  `chaintable table templates --table-type <type>` shows the default columns and indexes.
- Column types: `STRING` (up to 128 characters), `TEXT`, `HEXSTRING`, `ADDRESS`, `TOKENID`, `TXID`, `BLOCKID`,
  `HASH` (32 hex characters, not a transaction hash), `CHAINID`, `INT` (signed 64-bit), `BLOCKHEIGHT`, `UINT256`
  (exact; read as a decimal string), `FLOAT`, `BOOLEAN`, `TIMESTAMP`. Keep addresses and hashes lowercase.
- Index the columns you filter on (`table indexes update`); keep the system indexes.

## Subtables, coverage and history

- Block and time tables keep system subtables: `<id>._archive` holds historical versions, `<id>._height` the
  processed block ranges, `<id>._write` batch-write jobs. `latest` and `event` are roles of the main table, not
  suffixes. Read subtables; never write to them.
- A `block_state` read at a block returns the latest version at or before it, so unchanged blocks are not stored.
- Start height is the first block a block table covers; set it before the first write
  (`table start-height editable`, then `table start-height update`). It cannot change once blocks are processed.
- Consensus height is the highest block processed continuously from the start height; a newer row does not mean
  every earlier block is complete. Compare tables only at a block all of them cover (`table stats block`).
- Time tables round a time up to its bucket and return the value at or before it, without interpolation. Buckets
  grow from minutes to hours and days as data ages, so old data shows trends, not every change.
- The replica count (`--replica-num`, `1` or `3`) is fixed at creation; `3` survives failures at higher storage cost.

## Reading and writing

| Need | Command |
|---|---|
| Rows by primary key | `chaintable table row get --table-id <id> --pks '["usdc"]'` |
| A page of rows, or a simple filter | `chaintable table row list --table-id <id> --limit 50`, `chaintable table row query --table-id <id> --sql "SELECT * FROM <id> WHERE … LIMIT 100"` |
| Every row | `chaintable table row export <id> --out rows.ndjson` (10000 rows per billed page) |
| Aggregation, joins, history | SQL (`query run --wait`) |
| Writes | `chaintable table row create`, `table row update`, `table row delete`, on `normal` tables only |

Block and time tables are filled through the BlockDB SDK, usually by a notebook pipeline (see
`references/notebooks.md`), because a write must keep latest, history and coverage consistent.

## Creating a table

A table is created without columns, then initialized once:

```sh
chaintable table create --space <space> --name asset_notes --table-type normal
chaintable table init --id <space>.asset_notes --columns '[{"id":"id","name":"id","type":"STRING"},{"id":"symbol","name":"symbol","type":"STRING"},{"id":"amount","name":"amount","type":"UINT256"}]' --indexes '[{"columns":["symbol"]}]'
chaintable table create --space <space> --name pool_reserves --table-type block_state --chain-id eth
```

`table columns update` and `table indexes update` change an initialized table.

Docs: https://docs.chaintable.com/guides/tables/model.md, https://docs.chaintable.com/guides/tables/create-and-manage.md,
https://docs.chaintable.com/guides/tables/advanced.md, https://docs.chaintable.com/reference/data-types.md,
https://docs.chaintable.com/reference/sdk/blockdb-py.md
