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

- Hooks are shared with Claude Code: `.github/hooks/agent-hooks.json` runs the scripts in
  `.claude/hooks/`. The Copilot app only runs hooks from `.github/hooks/`, so don't remove it. They
  block `git add -f` and `git commit --no-verify` and lint edited Ruby and Slim files. The Copilot
  CLI and app may also load `.claude/settings.json`, so a hook can run more than once and lint
  feedback can appear twice; both hooks are safe to repeat. This config has no matchers, so the lint
  script skips read-only tools by name.
- Worktrees made by the GitHub app start from the **pushed** branch, so push hook changes before
  testing them there.
- Project skills live in `.claude/skills/`. The cloud agent, Copilot CLI and VS Code read that
  folder as well as `.github/skills/`, so Copilot and Claude Code share one copy. Visual Studio
  reads only `.github/skills/`. The skills are listed in
  [AGENTS.md](../AGENTS.md#skills-and-ai-compounding).
- `.github/workflows/copilot-setup-steps.yml` prepares the cloud agent's environment: Ruby,
  gems, the database, precompiled assets and the Swagger docs.
- Gap compared with Claude Code: Copilot has no repo-level deny rules for secret files. Only
  organisation content exclusion blocks those reads.
