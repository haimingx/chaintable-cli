# Functions

A function is a short BlockX computation with defined inputs and outputs, saved in a space and called by id
`space.name`: parse an event, convert an amount, read an object's state at a block and derive a price. Callers are
`function invoke` (the API), other functions, notebooks and pipelines; each passes positional arguments and gets the
return value. Before writing one, read a similar working function in `references/examples.md`.

## Execution model

- One call handles one input. BlockX runs many calls in parallel and in no guaranteed order, may combine calls with
  identical code and arguments, and may retry failed ones. Compute only from the arguments: no module globals across
  calls, no dependence on the current time or call counts.
- Each call has an execution budget; nested calls share the caller's. Long loops over history belong in a notebook
  that submits many bounded calls, not in one function.
- The runtime is a restricted Python: the standard library and the Chaintable SDKs (BlockDB for tables, Leafage for
  chain state, BlockX to call other functions); no other packages, operating system or network access. Import inside
  the function body.
- Synchronous entry points (`function run`, `function invoke`) reject writes. Return results; let a pipeline's target
  table or the caller store them.
- Return JSON values (numbers, strings, booleans, lists, objects, `None`); return large integers such as wei amounts as
  strings. `print()` output is for debugging only.

## Code, parameters and arguments

- Python entry point `_`; its positional parameters follow `--parameters`, each `{"name", "type"}` with a data type
  such as `UINT256`, `ADDRESS` or `STRING` (`references/tables.md` lists the types). Languages: `python`, `go`,
  `javascript`, `sql`.
- Argument shapes differ: `function run` takes `{name, value}` objects matching `--parameters`; `function invoke` and
  `function testcase create` take the plain values in parameter order (`[]` when there are none).
- Inside a function, read tables with the BlockDB SDK at the block being processed, chain state with Leafage, and
  other functions with `blockx.function.call('space.name', *args)`.

## Flow

```sh
chaintable function run --language python --code @fn.py --func-name _ --parameters '[{"name":"raw_amount","type":"UINT256"}]' --arguments '[{"name":"raw_amount","value":"1500000"}]'
chaintable function create --space <space> --name usdc_amount --language python --code @fn.py --parameters '[{"name":"raw_amount","type":"UINT256"}]'
chaintable function testcase create --function-id <space>.usdc_amount --arguments '["1500000"]'
chaintable function invoke --id <space>.usdc_amount --arguments '["1500000"]'
```

- Try the code with `function run` first: it runs inline, returns `status` (`succeeded`, `failed`, `timeout`),
  `return_value` and output, and is never delayed.
- A Python error returns `status: failed` (or `"success": false` from invoke, exit 1) with the message; fix the code.
- For about 2 minutes after a function is created or updated, `function invoke` may exit 8 with code 50203 while it
  propagates: run the same invoke again every 30 seconds, up to 5 times; never recreate the function.
- A 502 that `function run` reproduces with the same code points at the code, not an outage: rewrite the failing part
  with simpler constructs and run again.
- Calls across spaces use the full id and need access to that space.

Docs: https://docs.chaintable.com/guides/functions/model.md, https://docs.chaintable.com/guides/functions/create.md,
https://docs.chaintable.com/guides/functions/data-access.md, https://docs.chaintable.com/reference/sdk/blockx-py.md
