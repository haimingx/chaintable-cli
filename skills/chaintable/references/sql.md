# Writing SQL for Chaintable

Queries run on Trino. Use Trino SQL syntax and functions.

## Table names

- Use the full table id in `FROM`: `space.table` or `space.table.chain`, for example `token.token_transfer.eth`.
  The short name shown in a table list (`token_transfer.eth`) does not work.
- Block state and time tables have two views. The plain id is the latest state or value.
  Append `._archive` for history, for example `demo.pool_reserves.eth._archive`.
- Check columns before writing SQL: `chaintable table get --id <table-id>`.

Common public spaces (`eth` is Ethereum mainnet):

| Space | Data | Examples |
|---|---|---|
| `chain` | Blocks, transactions, events, traces | `chain.block.eth`, `chain.tx.eth`, `chain.event.eth`, `chain.trace.eth` |
| `token` | Token metadata, transfers, approvals | `token.token.eth`, `token.token_transfer.eth`, `token.token_approve.eth` |
| `nft` | Collections, transfers, approvals | `nft.collection.eth`, `nft.nft_transfer.eth` |
| `contract` | Contract creation, code hashes, proxies | `contract.contract.eth` |
| `price` | Latest and historical USD prices | `price.price.eth` |
| `address` | Assets received, chains used | `address.address_received_token.eth`, `address.address_used_chain` |
| `cex` | Exchanges, listings, pair markets | `cex.cex_pair_rate`, `cex.cex_pair_kline_1d` |

## Example

```sql
SELECT
    CAST(block_timestamp AS DATE) AS day,
    COUNT(*) AS transfer_count
FROM token.token_transfer.eth
WHERE token_id = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
  AND block_timestamp >= TIMESTAMP '2026-09-01 00:00:00'
  AND block_timestamp <  TIMESTAMP '2026-09-08 00:00:00'
GROUP BY 1
ORDER BY 1
```

- Bound large tables by time or block range; unbounded scans are slow and costly.
- Timestamps are UTC. Use half-open ranges (`>=` start, `<` end).
- Addresses and hashes are lowercase hex strings.

## Freshness

SQL reads analytics storage that is synchronized from the online tables asynchronously. Block tables arrive in
block ranges and can trail the chain head; normal and time tables are copied periodically, about hourly for normal
tables, so a table written minutes ago may still be empty in SQL.

- Before relying on recent blocks, compare `SELECT max(block_height)` with `table stats block --recent 1`, and bound
  the query to the covered range.
- The newest rows may be missing from SQL while `chaintable table row list` or `table row query` already return them.
- Tables synchronize independently; when joining, restrict to a block or time range all of them cover.
- A query result is fixed when it is computed. Run the query again to include newer data.
- `latest` views reflect current state as of synchronization; use `._archive` to reconstruct past state.
