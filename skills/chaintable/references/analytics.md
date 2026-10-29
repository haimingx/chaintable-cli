# Queries, visualizations and dashboards

Analytics runs SQL (Trino syntax) over an analytics copy of the online tables to filter, join and aggregate. Write
the SQL with `references/sql.md`. A saved query holds SQL and parameter definitions; each run creates a job that
produces a saved result, which visualizations and dashboards display.

## Freshness: three stages

| Stage | Question | How it moves forward |
|---|---|---|
| Online table | Was the data written? | The writing task completes |
| Analytics snapshot | Can SQL see it? | Synchronization publishes a new version: block ranges for block tables, an hour or more for normal tables |
| Query result | Which run produced these numbers? | Run the query again |

Tables synchronize independently, so a join may mix heights: bound it to a range every table covers. A saved result
never changes; paging, sorting and searching it (`query result`) read that run only. For live values of one table,
use `table row query` instead.

## Queries and jobs

- `query create` saves the SQL and creates a default table visualization; it prints the id. Languages: `sql`, the
  only one that runs, and `python`, which is accepted when saving but cannot run.
- `query run --code @query.sql --wait` runs SQL without saving anything; `query run --id <id> --wait` runs a saved
  query's own SQL, and `--id` with `--code` runs other SQL under it. Each submits a job and prints the rows. Job status: `pending`, `running`,
  then `succeeded`, `failed` or `canceled` (`canceling` in between).
- At `--timeout` (exit 9) the job continues: `query job get --id <job-id>`, then `query result --id <query_result_id>`.
  `query job latest --id <query-id> --code @query.sql` finds the newest job for that SQL; `query job cancel` stops one.
- Parameters are declared on the query (`--parameters`, items `{"name","type"}` with a column type such as `INT`,
  `STRING`, `DATE` or `TIMESTAMP`), written in the SQL as `{{name}}` and given per run as
  `--arguments '[{"name":"day","value":"2026-09-01"}]'`. Values are inserted as text: quote strings in the SQL
  (`'{{day}}'`), and a list becomes `a,b,c` for `IN ({{ids}})`.
- Each execution may run at most 120 seconds on the server, plus time queued. For heavy SQL (long ranges, joins, many
  tokens) pass `--timeout 3m`; waiting longer does not help.
- `query execution time limit exceeded` (exit 1) fails again unchanged: narrow the block or time range, aggregate
  before joining and select only the columns needed, then run again.
- Filter and aggregate in SQL; a result is capped at 100 MB, so return what answers the question, not raw tables.

## Visualizations and dashboards

- A visualization belongs to a query and displays its latest result. Types: `table`, `chart`, `counter`. Use a line
  or bar chart for trends over time and a counter for a single total.
- `query visualization ensure-default --query-id <id>` makes sure the default table view exists;
  `query visualization list --query-id <id>` shows existing ones. Minimal `--options`: a chart
  `{"type":"line","x_column":"day","y_columns":["transfers"]}` (`bar`, `line`, `area`, `scatter`; `pie` takes
  `label_column` and `value_column`) and a counter `{"type":"counter","column_name":"total"}`. `chaintable schema
  query visualization create` lists every option.
- A dashboard groups widgets on one page. Widget types: `visualization` (`--visualization-id`), `text`
  (`--text-content`, which takes `@file` for long Markdown) and `parameter`. Rerunning a query updates every chart and dashboard that uses it.

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
