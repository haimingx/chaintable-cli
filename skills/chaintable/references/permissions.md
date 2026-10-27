# Claude Code permissions for chaintable

The plugin's skill pre-approves these read-only commands in the turns where it is used. To allow them in every turn
while writes still ask, and to keep the agent from reading the saved token, add this to `.claude/settings.json`
(project) or `~/.claude/settings.json` (user):

```json
{
  "permissions": {
    "allow": [
      "Bash(chaintable auth status *)",
      "Bash(chaintable account list *)",
      "Bash(chaintable commands *)",
      "Bash(chaintable schema *)",
      "Bash(chaintable skill print *)",
      "Bash(chaintable chain list *)",
      "Bash(chaintable rpc *)",
      "Bash(chaintable space get *)",
      "Bash(chaintable space list *)",
      "Bash(chaintable space stats *)",
      "Bash(chaintable space discover core *)",
      "Bash(chaintable space discover search *)",
      "Bash(chaintable space table search *)",
      "Bash(chaintable space notebook search *)",
      "Bash(chaintable table search *)",
      "Bash(chaintable space check-id *)",
      "Bash(chaintable space content parse *)",
      "Bash(chaintable space content entity batch-get *)",
      "Bash(chaintable table get *)",
      "Bash(chaintable table list *)",
      "Bash(chaintable table row list *)",
      "Bash(chaintable table row get *)",
      "Bash(chaintable table row query *)",
      "Bash(chaintable query get *)",
      "Bash(chaintable query list *)",
      "Bash(chaintable query job get *)",
      "Bash(chaintable query result *)",
      "Bash(chaintable notebook get *)",
      "Bash(chaintable notebook list *)",
      "Bash(chaintable notebook instance get *)",
      "Bash(chaintable notebook instance list *)",
      "Bash(chaintable notebook instance logs *)",
      "Bash(chaintable function get *)",
      "Bash(chaintable function list *)",
      "Bash(chaintable schedule get *)",
      "Bash(chaintable schedule list *)",
      "Bash(chaintable table templates *)",
      "Bash(chaintable table id-types *)",
      "Bash(chaintable table stats block *)",
      "Bash(chaintable table stats daily *)",
      "Bash(chaintable table stats minute *)",
      "Bash(chaintable table instance list *)",
      "Bash(chaintable notebook instance specs *)",
      "Bash(chaintable notebook instance metrics blockx *)",
      "Bash(chaintable notebook instance metrics container *)",
      "Bash(chaintable query visualization list *)",
      "Bash(chaintable dashboard get *)",
      "Bash(chaintable dashboard list *)",
      "Bash(chaintable function testcase get *)",
      "Bash(chaintable function testcase list *)"
    ],
    "deny": [
      "Read(~/.config/chaintable/credentials.json)"
    ]
  }
}
```

When Claude Code's Bash sandbox is on, allow network access to `api.chaintable.com`.
In Codex CLI, enable network access for the workspace; without a reachable keychain, set `CHAINTABLE_TOKEN` and `CHAINTABLE_ACCOUNT_ID`.
