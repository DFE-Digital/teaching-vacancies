---
name: ai-compound
description: Turn what a working session taught the team into proposed rules for the agent, and open the AI compound pull request once the team has chosen. Use at the end of an AI mob session, or when asked to compound, capture or add a rule to a skill.
---

# AI compound

Maintained by developers. Last reviewed: 2026-11-27. The process is in
`documentation/development/ai-mob-sessions.md`.

Each session should make the next one cheaper. Knowledge the agent should apply next time is
written down once, as a rule, in the skill for its area.

## 1. List what the session taught

- **Decisions and knowledge** from the session: design, content, accessibility, research and
  technical. Include anything you had to be told that a rule would have answered.

## 2. Check what already exists

Before proposing a rule, read `AGENTS.md` and the skills in `.claude/skills/`. If a rule already
covers it, don't repeat it. If it was missed, propose a stronger form, such as a spec, a CI job or
a hook, and say it was missed in practice.

## 3. Propose

For each rule worth keeping, give:

- the **skill it belongs to**, or a new skill if none fits, or `AGENTS.md` only if the rule is
  universal and short
- a **concrete diff** to that file
- a one-line reason

Also list any existing rules that were wrong or unused, and propose removing or rewording them.

Every proposal must be safe to publish: no names, internal URLs, colleague or participant quotes,
or unpublished research. State the principle, not the evidence behind it.

## 4. Open the pull request once the team has chosen

Only apply what the team picked. Then:

1. Branch from `main`: `git switch --create ai-compound/<yyyy-mm-dd>-<slug> origin/main`.
2. Apply the chosen diffs, and nothing from the feature work.
3. Push and open a **ready-for-review** pull request, not a draft:
   `gh pr create --label ai-compounding --title "AI compound: <summary>"`. Don't request a
   reviewer. A developer still has to approve it before it merges.
4. Keep the description to a short what and why, and the AI-disclosure line.
