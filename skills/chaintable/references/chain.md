# Chain calls

`chaintable rpc <chain>` reads chain state through Leafage: blocks, balances, nonces, code, storage and read-only
contract calls at a block. It never sends transactions. Use it for current or block-specific state that no table
holds; use tables for history and anything already indexed.

- `<chain>` is the chain name used in table ids (`eth`, `base`) or its numeric chain id (`1`, `8453`); a name costs
  one extra chain list call. `chaintable chain list` lists both for every supported chain.
- Methods (`chaintable schema rpc` lists them): `getLatestBlock`, `getBlockById`, `getBlockByHeight`, `blockIsValid`,
  `getAddressBalance`, `getAddressNonce`, `getAddressCode`, `getStorageAt`, `contractMultiCall`.
- Address and state methods take an optional block as the last parameter, `{"type": "Equals", "block_id": "latest"}`
  or a block id; without it they read the latest block. For several reads that must agree, resolve a block first
  and pass the same `block_id` to each.
- Amounts are hex wei; convert with integer arithmetic (1 ETH = 10^18 wei), not floating point.
- A JSON-RPC `error` in the response exits 1 with the message.

```sh
chaintable rpc eth --method getLatestBlock
chaintable rpc eth --method getAddressBalance --params '["0x…", {"type": "Equals", "block_id": "latest"}]'
chaintable rpc eth --method contractMultiCall --params '[[{"to": "0x…", "data": "0x313ce567"}], {"type": "Equals", "block_id": "latest"}]'
```

`contractMultiCall` takes a list of calls (`to`, ABI-encoded `data`) and returns one entry per call in
`result.results`: `code` 0 and the ABI-encoded `result`, or a non-zero `code` with `err`. `0x313ce567` is
`decimals()`; decode the 32-byte words yourself.

Inside functions and notebooks, the Leafage SDK offers the same reads, plus contract calls by method signature.

Docs: https://docs.chaintable.com/guides/functions/data-access.md, https://docs.chaintable.com/reference/sdk/leafage-py.md
