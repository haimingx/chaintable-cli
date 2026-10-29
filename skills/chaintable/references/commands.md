# chaintable command reference

Generated from the command catalog; do not edit. `*` marks required flags.
Built-in commands (`auth`, `account`, `api`, `commands`, `schema`, `skill`, `version`) and the workflow
flags `query run --wait`, `notebook run --follow` and `table row export` are described in SKILL.md.

## chain

- `chaintable chain list`: List supported chains

## dashboard

- `chaintable dashboard create`: Create a dashboard. `--id` (generated if omitted) `--name`* `--options` `--space`*
- `chaintable dashboard delete`: Delete a dashboard. `--id`*
- `chaintable dashboard get`: Get a dashboard and its widgets. `--id`*
- `chaintable dashboard list`: List dashboards. `--direction` `--limit` `--name` `--order-by` (id|name|created_at|updated_at) `--space` `--start` `--with-schedule`
- `chaintable dashboard update`: Update a dashboard's name or options, or move it to another space. `--id`* `--name` `--options` `--target-space`
- `chaintable dashboard widget create`: Add a widget to a dashboard. `--dashboard-id`* `--entities` `--id` (generated if omitted) `--options` `--text-content` `--type`* (text|visualization|parameter) `--visualization-id`
- `chaintable dashboard widget delete`: Delete a dashboard widget. `--id`*
- `chaintable dashboard widget update`: Update a widget's text, options or referenced resources. `--entities` `--id`* `--options` `--text-content`

## function

- `chaintable function create`: Create a function. `--code` `--language`* (python|go|javascript|sql) `--name`* `--parameters` `--return-type` `--space`*
- `chaintable function delete`: Delete a function. `--id`*
- `chaintable function get`: Get a function. `--id`*
- `chaintable function invoke`: Call a saved function and return its result. `--arguments`* `--id`*
- `chaintable function list`: List functions. `--direction` `--keyword` `--limit` `--match-type` (name|code) `--name` `--order-by` (id|name|created_at|updated_at) `--space` `--start`
- `chaintable function run`: Run function code without saving it. `--arguments` `--code`* `--func-name` `--language`* (python|go|javascript|sql) `--parameters`
- `chaintable function testcase create`: Add a test case to a function. `--arguments` `--function-id`*
- `chaintable function testcase delete`: Delete a function test case. `--id`*
- `chaintable function testcase get`: Get a function test case. `--id`*
- `chaintable function testcase list`: List a function's test cases. `--direction` `--function-id`* `--limit` `--order-by` (id|created_at|updated_at) `--start`
- `chaintable function testcase update`: Replace a test case's arguments. `--arguments` `--id`*
- `chaintable function update`: Update a function. `--code` `--id`* `--language` (python|go|javascript|sql) `--name` `--parameters` `--return-type`

## notebook

- `chaintable notebook create`: Create a notebook. `--code` `--language` (python) `--name`* `--parameters` `--space`*
- `chaintable notebook delete`: Delete a notebook. `--id`*
- `chaintable notebook get`: Get a notebook. `--id`*
- `chaintable notebook instance cancel`: Cancel a notebook execution. `--id`*
- `chaintable notebook instance get`: Get a notebook execution. `--id`*
- `chaintable notebook instance keepalive`: Keep a foreground notebook execution alive for 150 more seconds. `--id`*
- `chaintable notebook instance list`: List notebook executions of an account, a notebook or a schedule. `--account-id` `--display-status` (running|succeeded|failed|canceled) `--keyword` `--launched` (manual|schedule) `--limit` `--name` `--notebook-id` `--schedule-id` `--start`
- `chaintable notebook instance logs`: Read a notebook execution's logs. `--id`* `--timestamp`
- `chaintable notebook instance metrics blockx`: Get a notebook execution's data access metrics. `--id`*
- `chaintable notebook instance metrics container`: Get a notebook execution's container metrics. `--id`*
- `chaintable notebook instance set-background`: Move a foreground notebook execution to the background. `--background` `--id`*
- `chaintable notebook instance specs`: List the CPU and memory options for executions
- `chaintable notebook list`: List notebooks. `--direction` `--limit` `--name` `--order-by` (id|name|created_at|updated_at) `--schedule-space` `--space` `--start` `--with-schedule`
- `chaintable notebook run`: Run a saved notebook or notebook code. `--account-id`* `--arguments` `--background` `--code` `--id` `--max-cpu`* `--max-memory`* `--notebook-debug` `--parameters`
- `chaintable notebook update`: Update a notebook. `--code` `--id`* `--language` (python) `--name` `--parameters`

## query

- `chaintable query create`: Create a query and its default visualization. `--code` `--id` (generated if omitted) `--language` (sql|python) `--name`* `--parameters` `--space`*
- `chaintable query delete`: Delete a query and its visualizations. `--id`*
- `chaintable query get`: Get a query. `--id`*
- `chaintable query job cancel`: Cancel a query execution. `--id`*
- `chaintable query job get`: Get a query execution's status. `--id`*
- `chaintable query job latest`: Find the latest execution of a query with the given code and arguments. `--arguments` `--code`* `--id`*
- `chaintable query list`: List queries. `--direction` `--limit` `--name` `--order-by` (id|name|created_at|updated_at) `--space` `--start` `--with-schedule` `--with-visualizations`
- `chaintable query result`: Read the rows of a query result. `--direction` `--id`* `--limit` `--metadata-only` `--order-by` `--search` `--start`
- `chaintable query run`: Run a saved query. `--arguments` `--code`* `--id`*
- `chaintable query update`: Update a query. `--code` `--id`* `--name` `--parameters`
- `chaintable query visualization create`: Create a visualization for a query. `--id` (generated if omitted) `--name`* `--options` `--query-id`* `--type`* (table|chart|counter)
- `chaintable query visualization delete`: Delete a visualization. `--id`*
- `chaintable query visualization ensure-default`: Get or create a query's default visualization. `--query-id`*
- `chaintable query visualization list`: List a query's visualizations. `--direction` `--limit` `--order-by` (id|name|created_at|updated_at) `--query-id`* `--start`
- `chaintable query visualization update`: Update a visualization's name or options. `--id`* `--name` `--options`

## rpc

- `chaintable rpc <chain_id>`: Send a JSON-RPC request to a chain node. `--id` `--method`* `--params`

## schedule

- `chaintable schedule create`: Schedule a query, dashboard or notebook. `--arguments` `--content-id`* `--content-type`* (query|dashboard|notebook) `--cron` `--max-cpu` `--max-memory` `--mode` (crontab|perpetual) `--name` `--space`*
- `chaintable schedule delete`: Delete and stop a schedule. `--id`*
- `chaintable schedule disable`: Disable a schedule. `--id`*
- `chaintable schedule enable`: Enable a schedule. `--id`*
- `chaintable schedule get`: Get a schedule and its upcoming runs. `--content-id` `--content-type` (query|dashboard|notebook) `--id` `--space`
- `chaintable schedule list`: List the schedules in a space. `--content-id` `--content-type` (query|dashboard|notebook) `--direction` `--keyword` `--limit` `--mode` (crontab|perpetual) `--order-by` (id|name|created_at|updated_at) `--space`* `--start`
- `chaintable schedule restart`: Restart a perpetual schedule. `--id`*
- `chaintable schedule update`: Update a schedule's name, cron, arguments or resources. `--arguments` `--cron` `--id`* `--max-cpu` `--max-memory` `--name`

## space

- `chaintable space check-id`: Check whether a space id is available. `--id`*
- `chaintable space content entity batch-get`: Read resources of several types in one call. `--entities`*
- `chaintable space content parse`: Resolve a table or function id to resources. `--content-id`* `--content-type`* (query|dashboard|notebook|table|field|function|contract|chain|schedule)
- `chaintable space create`: Create a space. `--account-id`* `--description` `--id` (generated if omitted) `--visibility` (public|private)
- `chaintable space delete`: Delete a space. `--id`*
- `chaintable space discover core`: List the featured public spaces
- `chaintable space discover search`: Search public spaces. `--exclude-core` `--limit` `--q` `--start`
- `chaintable space get`: Get a space and its account. `--id`*
- `chaintable space list`: List the spaces visible to you. `--account-id` `--direction` `--limit` `--order-by` (id|created_at|updated_at) `--start`
- `chaintable space notebook search`: Search notebooks by name. `--direction` `--id` `--limit` `--name` `--order-by` (created_at|updated_at) `--schedule-space` `--start`
- `chaintable space stats`: Count the resources in a space. `--id`*
- `chaintable space table search`: Search tables by name. `--direction` `--id` `--limit` `--name` `--order-by` (created_at|updated_at) `--start`
- `chaintable space update`: Change a space's description or visibility. `--description` `--id`* `--visibility` (public|private)

## table

- `chaintable table columns update`: Replace a table's columns. `--columns`* `--id`* `--view`
- `chaintable table columns validate`: Check whether a column name is valid. `--name`*
- `chaintable table create`: Create a table. `--chain-id` `--description` `--name`* `--replica-num` `--space`* `--table-type`* (normal|block_event|block_state|time)
- `chaintable table delete`: Delete a table with its data. `--id`*
- `chaintable table get`: Get a table definition. `--id`* `--is-l1`
- `chaintable table id-types`: List the available id column types
- `chaintable table indexes update`: Replace a table's indexes. `--id`* `--indexes`*
- `chaintable table init`: Initialize a table's columns, indexes and view. `--columns` `--id`* `--indexes` `--view`
- `chaintable table instance list`: List notebook executions that read or wrote a table. `--access`* (read|write) `--id`* `--limit`
- `chaintable table list`: List tables. `--direction` `--limit` `--name` `--order-by` (id|name|created_at|updated_at) `--space` `--start` `--with-activity`
- `chaintable table row create`: Insert a row into a normal table. `--data`* `--table-id`*
- `chaintable table row delete`: Delete a row from a normal table. `--id`* `--table-id`*
- `chaintable table row get`: Read rows by primary key. `--pks`* `--table-id`*
- `chaintable table row list`: Read a page of table rows. `--direction` `--filter` `--limit` `--order-by` `--start` `--table-id`*
- `chaintable table row query`: Query one table with a restricted SELECT statement. `--sql`* `--table-id`*
- `chaintable table row update`: Update a row in a normal table. `--data`* `--id`* `--table-id`*
- `chaintable table search`: Search tables across spaces. `--limit` `--name` `--start`
- `chaintable table start-height editable`: Check whether a block table's start height can be changed. `--id`*
- `chaintable table start-height update`: Change the start height of a block table that has not started. `--id`* `--start-height`*
- `chaintable table stats block`: Show write statistics for a block table's recent blocks. `--id`* `--recent`
- `chaintable table stats block-completeness`: Show which height ranges of a block table have been written. `--id`*
- `chaintable table stats daily`: Show daily statistics for a time table. `--from` `--id`* `--to` `--year`
- `chaintable table stats minute`: Show per-minute statistics for a time table. `--id`* `--minutes`
- `chaintable table templates`: Get the table templates for a table type. `--table-type` (normal|block_event|block_state|time)
- `chaintable table truncate`: Delete every row of a table and keep its definition. `--id`*
- `chaintable table view update`: Replace a table's view. `--id`* `--view`*
