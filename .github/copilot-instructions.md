# GitHub Copilot instructions

**Read [AGENTS.md](../AGENTS.md) in the repository root before proposing any change, and follow
it.** It is the single source of truth for this repository: architecture, commands, domain
model, testing, code style, and the security rules that apply because this repository is public
and the service holds significant personal data.

Do not rely on this file for the rules themselves — they are deliberately not duplicated here,
so that there is only ever one copy to keep current. Open `AGENTS.md` and work from it.

Copilot can also load `AGENTS.md` directly:

- The Copilot coding agent reads a root `AGENTS.md` automatically.
- In VS Code, set `chat.useAgentsMdFile` to `true` to have it loaded into every new chat.
