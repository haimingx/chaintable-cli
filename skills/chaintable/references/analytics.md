# Queries, visualizations and dashboards

Analytics runs SQL (Trino syntax) over an analytics copy of the online tables to filter, join and aggregate. Write
the SQL with `references/sql.md`. A saved query holds SQL and parameter definitions; each run creates a job that
produces a saved result, which visualizations and dashboards display.

## Freshness: three stages

| Stage | Question | How it moves forward |
|---|---|---|
| Online table | Was the data written? | The writing task completes |
| Analytics snapshot | Can SQL see it? | Synchronization publishes a new version, typically within minutes |
| Query result | Which run produced these numbers? | Run the query again |

Tables synchronize independently, so a join may mix heights: bound it to a range every table covers. A saved result
never changes; paging, sorting and searching it (`query result`) read that run only. For live values of one table,
use `table row query` instead.

## Queries and jobs

- `query create` saves the SQL and creates a default table visualization; it prints the id. Languages: `sql`, the
  only one that runs, and `python`, which is accepted when saving but cannot run.
- `query run --id <id> --code @query.sql --wait` submits a job and prints the rows. Job status: `pending`, `running`,
  then `succeeded`, `failed` or `canceled` (`canceling` in between).
- At `--timeout` (exit 9) the job continues: `query job get --id <job-id>`, then `query result --id <query_result_id>`.
  `query job latest --id <query-id> --code @query.sql` finds the newest job for that SQL; `query job cancel` stops one.
- Parameters are declared on the query (`--parameters`, items `{"name","type"}`) and given per run as
  `--arguments '[{"name":"day","value":"2026-09-01"}]'`.
- Filter and aggregate in SQL; results have size limits, so return what answers the question, not raw tables.

## Visualizations and dashboards

- A visualization belongs to a query and displays its latest result. Types: `table`, `chart`, `counter`. Use a line
  or bar chart for trends over time and a counter for a single total.
- `query visualization ensure-default --query-id <id>` makes sure the default table view exists;
  `query visualization list --query-id <id>` shows existing ones. Chart `--options` follow the shape of an existing
  chart's options; copy and adjust it rather than inventing keys.
- A dashboard groups widgets on one page. Widget types: `visualization` (`--visualization-id`), `text`
  (`--text-content`) and `parameter`. Rerunning a query updates every chart and dashboard that uses it.

```sh
chaintable query create --space <space> --name "USDC daily transfers" --language sql --code @query.sql
chaintable query run --id <query-id> --code @query.sql --wait --limit 50
chaintable query visualization list --query-id <query-id>
chaintable dashboard create --space <space> --name "USDC activity"
chaintable dashboard widget create --dashboard-id <dashboard-id> --type visualization --visualization-id <visualization-id>
chaintable dashboard widget create --dashboard-id <dashboard-id> --type text --text-content "Daily USDC transfers on Ethereum"
```

Scheduled refresh of a query or dashboard: `references/schedules.md`.

Docs: https://docs.chaintable.com/guides/analytics/how-it-works.md, https://docs.chaintable.com/guides/analytics/sql-queries.md,
https://docs.chaintable.com/guides/analytics/visualizations-and-dashboards.md
