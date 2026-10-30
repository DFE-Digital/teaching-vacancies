# GitHub Copilot instructions

**Read [AGENTS.md](../AGENTS.md) in the repository root before proposing any change, and follow
it.** It is the single source of truth for this repository: architecture, commands, domain
model, testing, code style, and the security rules that apply because this repository is public
and the service holds significant personal data.

Do not rely on this file for the rules themselves — they are deliberately not duplicated here,
so that there is only ever one copy to keep current. Open `AGENTS.md` and work from it.

Copilot can also load `AGENTS.md` directly:

- The cloud agent, Copilot CLI and code review on GitHub.com read a root `AGENTS.md` automatically.
- In VS Code, set `chat.useAgentsMdFile` to `true` to have it loaded into every new chat.
- IDE code review (VS Code and Visual Studio) reads only this file, so it does not see the
  project rules in `AGENTS.md`.

## Copilot configuration

This section describes Copilot's own configuration only. Project rules stay in AGENTS.md.

- `.github/hooks/agent-hooks.json` runs two hooks: `guard-bash.rb` blocks `git add -f` and
  `git commit --no-verify`, and `lint-edited-file.rb` autocorrects Ruby and Slim files after
  `create`, `edit` and `str_replace_editor` calls (not `apply_patch`) and returns any remaining
  offences. Both are adapters over the shared rules in `.agents/hooks/lib/`.
- `.github/workflows/copilot-setup-steps.yml` prepares the cloud agent's environment: Ruby,
  gems, the database, precompiled assets and the Swagger docs. It also sets `HEADLESS=1`.
- Gaps compared with Claude Code: Copilot has no repo-level `HEADLESS` setting, so run JavaScript
  specs locally with `HEADLESS=1`. Copilot also has no repo-level deny rules for secret files.
  Only organisation content exclusion blocks those reads.
