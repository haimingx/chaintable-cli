# Notebooks

A notebook is a saved Python driver script with parameter definitions. Running it starts an instance: an isolated
container with the CPU and memory chosen at start, the Chaintable SDKs preinstalled, and the code and arguments of
that moment. Use notebooks for backfills, continuous updates and batch work; the script prepares inputs, submits
computation to BlockX and writes results through BlockDB.

## Instances

- Arguments are strings: the script reads them with `from chaintable import arguments; arguments.get_arguments()`.
  Pass them as `--arguments '[{"name":"raw_amount","value":"1500000"}]'`.
- Resources come from `chaintable notebook instance specs`; a running instance holds the account's notebook quota.
- Always run with `--follow` (or `--background`). A foreground instance stops when nothing keeps it alive for 150
  seconds, which a CLI cannot do.
- Editing a notebook does not change a running instance; start a new one. Status: `running`, then `succeeded`,
  `failed` or `canceled`. Logs remain after the instance ends.
- Stopping an instance does not stop compute tasks it submitted or roll back their writes. A rerun starts the script
  from the top: keep progress in tables, not memory.

```sh
chaintable notebook create --space <space> --name daily_job --language python --code @job.py
chaintable notebook instance specs
chaintable notebook run --id <notebook-id> --max-cpu 1 --max-memory 4 --arguments '[{"name":"raw_amount","value":"1500000"}]' --follow
chaintable notebook instance list --notebook-id <notebook-id> --limit 5
chaintable notebook instance logs --id <instance-id>
chaintable notebook instance cancel --id <instance-id>
```

`--follow` streams logs until the instance ends; it exits 1 when the script fails and 9 at `--timeout`, leaving the
instance running.

## Pipelines

A pipeline, built in a notebook with the BlockX SDK, turns source-table records into function calls and writes the
returned records to a target table, keeping its block coverage:

- `sources`: source table ids, each with the function id, an argument template (`ROW` is the source record) and an
  optional filter. `target`: the table receiving the records. `requires`: tables the function reads, so blocks are
  computed only once their data is ready.
- `backfill(start, end)` fills a block range, skipping blocks already covered; `update()` follows new blocks and
  belongs in a perpetual schedule (`references/schedules.md`).
- Returned records must match the target table's columns; `None` writes nothing for that input.

Docs: https://docs.chaintable.com/guides/notebooks/how-it-works.md, https://docs.chaintable.com/guides/notebooks/manage-runs.md,
https://docs.chaintable.com/guides/notebooks/build-pipeline.md, https://docs.chaintable.com/reference/sdk/introduction.md,
https://docs.chaintable.com/reference/sdk/blockx-py.md
