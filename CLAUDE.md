# CLAUDE.md

Guidance for Claude Code in this repository lives in [AGENTS.md](AGENTS.md), which is shared by
all coding agents used on this project.

@AGENTS.md

## Claude Code specifics

This section describes Claude Code's own configuration only. Project rules belong in
[AGENTS.md](AGENTS.md), not here.

- **`.claude/settings.json`** is committed and shared. It sets `HEADLESS=1` (so JavaScript specs
  never open browser windows), allows running specs, linters and read-only git commands without a
  prompt, and denies reading `.env` files, keys, certificates and database dumps.
- **`.claude/hooks/`** holds the hooks that `settings.json` runs:
  - `lint-edited-file.sh` autocorrects each Ruby or Slim file after an edit and sends any
    remaining RuboCop or slim-lint offences back to Claude to fix.
  - `guard-bash.rb` blocks `git add -f` and `git commit --no-verify`, which enforce the
    non-negotiables in AGENTS.md rather than adding new rules.
- **`.claude/settings.local.json`** is git-ignored and personal (extra permissions, environment
  such as `PARALLEL_TEST_PROCESSORS`). Don't commit it.

If you change `.claude/settings.json` or `.claude/hooks/`, update this section in the same pull
request.
