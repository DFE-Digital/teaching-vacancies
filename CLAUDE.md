# CLAUDE.md

Guidance for Claude Code in this repository lives in [AGENTS.md](AGENTS.md), which is shared by
all coding agents used on this project.

@AGENTS.md

## Claude Code specifics

This section describes Claude Code's own configuration only. Project rules belong in
[AGENTS.md](AGENTS.md), not here.

- **`.claude/settings.json`** is committed and shared. It allows running specs, linters and
  read-only git commands without a prompt, and denies reading `.env` files, keys, certificates and
  database dumps.
- **`.claude/hooks/`** holds the hooks that `settings.json` runs. GitHub Copilot runs the
  same scripts from `.github/hooks/agent-hooks.json`, so there is only one copy of each hook:
  - `guard-bash.rb` blocks `git add -f` and `git commit --no-verify`, which enforce the
    non-negotiables in AGENTS.md rather than adding new rules.
  - `lint-edited-file.rb` autocorrects each Ruby or Slim file after an edit and sends any
    remaining RuboCop or slim-lint offences back to the agent to fix.
  - `run-ruby.sh` runs each hook with the Ruby in `.ruby-version`, looking in the mise, rbenv,
    asdf and chruby install folders too, because desktop apps may resolve `ruby` to another
    version. If that Ruby isn't installed, every hook blocks rather than letting tools run
    unguarded. Hooks must accept both Claude and Copilot input fields.
- **`.claude/settings.local.json`** is git-ignored and personal (extra permissions, environment
  such as `PARALLEL_TEST_PROCESSORS`). Don't commit it.

If you change `.claude/settings.json` or `.claude/hooks/`, update this section in the same pull
request.
