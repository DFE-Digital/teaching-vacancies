# CLAUDE.md

Guidance for Claude Code in this repository lives in [AGENTS.md](AGENTS.md), which is shared by
all coding agents used on this project.

@AGENTS.md

## Claude Code specifics

This section describes Claude Code's own configuration only. Project rules belong in
[AGENTS.md](AGENTS.md), not here.

- **`.claude/settings.json`** is committed and shared. It sets `HEADLESS=1` (so JavaScript specs
  never open browser windows), allows running specs, linters, read-only git commands and read-only
  `gh pr` commands without a prompt, and denies reading `.env` files, keys, certificates and
  database dumps.
- **`.claude/hooks/`** holds the hooks that `settings.json` runs:
  - `lint-edited-file.sh` autocorrects each Ruby or Slim file after an edit and sends any
    remaining RuboCop or slim-lint offences back to Claude to fix.
  - `guard-bash.rb` blocks `git add -f` and `git commit --no-verify`, which enforce the
    non-negotiables in AGENTS.md rather than adding new rules.
- **`.claude/skills/ticket/`** is the `/ticket` workflow, run by hand only. It works out the
  ticket's phase from git, GitHub and Trello (or takes it as an argument), confirms, then follows
  that phase's file:
  - `start` (`/ticket <trello card>`) tidies up merged tickets, reads the card, asks the
    developer for extra context, assigns the card and moves it to In Progress, creates a
    `<card number>-<slug>` worktree and branch off `origin/main`, and plans the change
    (`opusplan` model recommended).
  - `ship` rebases, runs `/code-review` (and `/security-review` where relevant) plus
    personal-data, migration and acceptance-criteria checks, runs the AGENTS.md pre-PR checks,
    screenshots UI changes, opens a draft PR from the template, waits for CI in the background
    (or via `/loop` if the session is closing), and once CI is green marks it ready, adds the
    `Waiting for dev review` label and moves the card to For Review.
  - `address` works through review comments with the developer, re-runs the checks, replies on
    each thread and re-labels.
  - `finish` moves the card to Done and removes the merged worktree and branch.
  - It needs a connected Trello MCP server with write access to the board, and either the `gh`
    CLI logged in (preferred) or the GitHub MCP server, and checks these first.
- **`.claude/settings.local.json`** is git-ignored and personal (extra permissions, environment
  such as `PARALLEL_TEST_PROCESSORS`). Don't commit it.

If you change `.claude/settings.json`, `.claude/hooks/` or `.claude/skills/`, update this section
in the same pull request.
