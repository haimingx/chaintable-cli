# Schedules

A schedule runs saved content automatically, for the account that owns its space. For notebooks, every run holds
compute from that account's quota while it runs; agree on the frequency with the user.

| Content (`--content-type`) | Each run |
|---|---|
| `query` | Runs the query and saves a new result, refreshing its visualizations |
| `dashboard` | Reruns the queries behind the dashboard's visualizations |
| `notebook` | Starts an instance of the saved script with the schedule's arguments and resources |

| Mode (`--mode`) | Behavior | Use for |
|---|---|---|
| `crontab` | Runs at each `--cron` time, evaluated in UTC; a run is skipped while the previous one still runs | Periodic refreshes and batch jobs that finish |
| `perpetual` | Notebooks only: keeps one instance running and starts it again whenever it exits, from the top of the script | `Pipeline.update()` and other continuous work |

- Notebook schedules take the run's `--arguments` (`{name, value}` objects) and `--max-cpu`/`--max-memory`, a pair from
  `notebook instance specs` (hundredths of a core, bytes).
- `schedule disable` stops future runs; for `perpetual` it also stops the instance. Disabling `crontab` does not
  cancel a run already started. `schedule restart` restarts a perpetual schedule's instance.
- A perpetual instance does not pick up new code until it restarts: update the notebook, then `schedule restart`.
- `schedule get` shows `enabled`, `next_run_at` (Unix seconds) and recent runs; notebook runs appear in
  `notebook instance list --schedule-id <id>`.

```sh
chaintable schedule create --space <space> --content-type query --content-id <query-id> --mode crontab --cron "30 0 * * *"
chaintable schedule create --space <space> --content-type notebook --content-id <notebook-id> --mode perpetual --max-cpu 100 --max-memory 4294967296
chaintable schedule list --space <space>
chaintable schedule disable --id <schedule-id>
```

Docs: https://docs.chaintable.com/guides/notebooks/scheduling.md
