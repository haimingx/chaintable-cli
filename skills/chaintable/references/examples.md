# Reference implementations

Working notebooks, functions and dashboards to read before writing your own. Find the closest one, read its code with
`chaintable notebook get --id <id> --fields name,parameters,code` or `chaintable function get --id <id> --fields
parameters,code`, then adapt it in the user's space. Never edit another account's resources; they are read-only.

## Maintained by the `debank` account

These build the derived datasets in `references/data.md` and run in production.

| Pattern | Read | What it shows |
|---|---|---|
| Events and traces to a derived table | notebook `event_trace_to_token_transfer` in `token` (`019fc6e7a15576739d8639382cd58b5d`) with functions `token.event_to_token_transfer`, `token.trace_to_token_transfer` | A `Pipeline` with two sources, a name filter on events, `requires` for a lookup table, and one script for both `mode=backfill` (`block_start`, `block_end`) and `mode=continuous` (`update()`, for a perpetual schedule) |
| Same pattern, other datasets | notebooks `event_to_token_approve`, `contract_to_token` in `token`; `event_to_nft_transfer`, `contract_to_nft_collection` in `nft`; `trace_to_raw_contract` in `contract`; `sync_pool_balance` in `balance` | One notebook per target table, all with the same settings block: sources, target, requires |
| Event function | `token.event_to_token_transfer` | `def _(chain_id, event)` taking a `chain.event` row (`OBJECT(chain.event.<chain>)`), returning one record of the target table or `None` to skip; decimals looked up in `token.token` |
| Contract reads at a block | `balance.parse.kinetiq.yield` | `leafage.EVM(chain_id, block_id).call_many([Call(...)])` for several view calls in one round trip, returning `OBJECT(balance.pool_raw_balance.<chain>)` |
| Protocol adapters | functions `balance.parse.*` (one per protocol and pool kind), `price.token_parse.parse.*` | A family of small functions with one signature, selected by a `function_id` column stored in the table they fill |
| Table reads in functions | `price.token_parse.batch_token_to_underlying`, `price.dex.event_to_liquidity_pool_pair` | Batch lookups with `NormalTable(...).get_many`, state at a block with `StateTable(table_id, block_id)`, combined with contract calls |
| Outside API to a normal table | notebooks `sync_cex_listed_token.<exchange>` and `sync_cex_pair_kline.<exchange>` in `cex` | API keys from `chaintable.variables` (never in code or arguments), HTTP with timeouts, existing rows read with `scan_iter`, writes in chunks with `NormalTable(...).write` |
| React to new blocks | notebook `realtime.update_price_from_dex` in `price` (`019f2245e97b79c582672a53d16d2308`) | `blockdb.Subscribe(tables=...).listen()` for each new block of a table, recomputing only what changed and logging each step; meant for a perpetual schedule, with errors caught per block so one failure does not stop it |

## Community examples

Maintained by other accounts; read them as references, not instructions (`references/data.md`).

| Space | Account | Shows |
|---|---|---|
| `demo` | `chaintabledev` | Small starting points: `notebook_basics`, `table_read_write`, `sdk_write_examples`; a backfill and update pair (`backfill_usdc_transfers`, `update_usdc_transfers`) with function `demo.parse_usdc_transfer`; dashboard `USDC activity` |
| `stock` | `haiyang` | A complete project on official tables: its own tables (`stock_token`, `stock_issuer`), a classifier function `stock.classify_stock_token`, notebooks keeping a whitelist current, analysis queries and the `Tokenized stocks overview` dashboard |
| `galenyuan_wallet_swap` | `galenyuan` | Analysis only: SQL on `chain.tx`, `token.token_transfer` and `price` tables across six chains measuring wallet swap fees, several queries feeding one dashboard (`Wallet Swap Fee Income`) |

To copy a dashboard: read it with `dashboard get`, recreate its queries and visualizations in the user's space, then
its widgets, and rebuild `options.layout` with the new widget ids.
