# AI mob sessions

An experiment in whole-squad working: product, design, research and development work together, at the same time, around one AI coding agent. One person, the operator, drives the
agent. Everyone else shapes the prompt and reviews the result in a review app. The operator role
rotates.

This page covers how a session runs, how the team turns what it learns into rules the agent
follows (**AI compounding**), and how we measure whether the experiment works. Everything
recorded here, and in the skills it describes, is public: see [Public-safety rule](#public-safety-rule).

## What does not change

- **Every pull request still needs a developer's approval before it merges.** A session review
  checks the behaviour in the review app. It doesn't replace code review, the data and schema
  checklist in the pull request template, or the security rules in [AGENTS.md](/AGENTS.md).
- Pull requests are created as drafts, and a person applies the `deploy` label.
- CI is unchanged.

## How a session runs

The agent follows the [`ai-mob-session` skill](/.claude/skills/ai-mob-session/SKILL.md). Start a
session by telling the agent it is an AI mob session.

1. **Understand.** The agent restates the goal and uses the
   [`grill-me` skill](/.claude/skills/grill-me/SKILL.md) to ask the team about open decisions,
   in numbered rounds, each with a recommended answer. It looks up codebase facts itself.
2. **Plan, then stop.** The agent writes a numbered plan and waits. The team changes it until
   they agree, then says "implement".
3. **Implement.** The agent works in small steps. It stops and flags before migrations,
   personal-data fields, `Vacancy` or `JobApplication` enum or validation changes, public route
   changes and security middleware. The team reviews the result in the review app.
4. **Session state.** At an impasse, the agent writes where things stand, then the team reverts
   and closes the review app. Locally this goes in `tmp/ai-mob-sessions/`, which is git-ignored.
   In a pull request it goes in a "Session state" section of the description.
5. **AI compounding wrap-up.** The agent lists the decisions made, marks the recurring ones, and
   proposes rules for them (see below).

Label pull requests that come out of a session `ai-mob`.

## AI compounding

Each session should make the next one cheaper. Decisions the team makes repeatedly, such as
design trade-offs, content choices, accessibility fixes, research findings and technical
conventions, get written down once as rules the agent applies every time. Expert review then
moves from "by hand in every session" to "once, when the rule is written".

A learning moves up a rung only when it recurs:

| Rung | Where it lives | Applied by |
|---|---|---|
| 1. Note | [Learnings log](#learnings-log) on this page | the team |
| 2. Rule | A skill in [`.claude/skills/`](/.claude/skills/), or [AGENTS.md](/AGENTS.md) if universal and short | the agent, when relevant |
| 3. Check | A spec, CI job or agent hook | always enforced |

- Add a check only after a rule has been missed in practice.
- Keep AGENTS.md short. Discipline knowledge belongs in skills, which the agent loads only when
  relevant.
- Prune as well as add. Remove rules that are wrong or unused at each reflection session.

### Skills and owners

| Skill | Owner | Use |
|---|---|---|
| [`ai-mob-session`](/.claude/skills/ai-mob-session/SKILL.md) | Developers | Session protocol |
| [`grill-me`](/.claude/skills/grill-me/SKILL.md) | Developers | Clarifying questions; vendored from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) |
| [`ucd-principles`](/.claude/skills/ucd-principles/SKILL.md) | Design and user research | User-facing changes |
| [`accessibility-review`](/.claude/skills/accessibility-review/SKILL.md) | Design and developers, shared | Views, components, front end |

The owner reviews every change to their skill. Claude Code and the Copilot cloud agent, CLI and
VS Code all read project skills from `.claude/skills/`
([GitHub docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)),
so there is one copy. Visual Studio reads only `.github/skills/`. Check that the Copilot desktop
app lists these skills before the first session. If it doesn't, move them to `.github/skills/`
and symlink `.claude/skills/` to it.

`grill-me` is a reviewed copy of a third-party skill. Update it only by re-vendoring it in an
`AI compound:` pull request, never with an installer.

### AI compounding pull requests

- Keep them small and separate from feature work.
- Title them `AI compound: <summary>` and label them `ai-compounding`.
- Request review from the skill's owner.

### Public-safety rule

This repository is public, and there is nowhere private to keep learnings. Anything that isn't
safe to publish is not recorded. Before adding a rule or a learnings log entry, remove:

- names of people
- internal tools, URLs and hostnames
- quotes from colleagues or research participants
- unpublished research findings

Record the general principle. If the evidence behind it can't be published, leave it out.

## Measuring the experiment

We want evidence, not a feeling of productivity. Compare cycle time, from pull request creation
to merge, for `ai-mob` pull requests against other merged pull requests from the same period:

```bash
gh pr list --state merged --label ai-mob --limit 200 --json createdAt,mergedAt \
  --jq '[.[] | ((.mergedAt | fromdate) - (.createdAt | fromdate)) / 86400] | sort | {prs: length, median_days: .[length / 2 | floor]}'
```

```bash
gh pr list --state merged --limit 200 --search "-label:ai-mob -label:ai-compounding -author:app/dependabot merged:>=YYYY-MM-DD" --json createdAt,mergedAt \
  --jq '[.[] | ((.mergedAt | fromdate) - (.createdAt | fromdate)) / 86400] | sort | {prs: length, median_days: .[length / 2 | floor]}'
```

Cycle time alone flatters small changes, so also record:

- how many `ai-mob` pull requests were merged and how many were closed unmerged
- issues found in code review or CI after the session
- person-hours spent in the session, not just elapsed time
- how many `ai-compounding` pull requests each session produced. If there are none, compounding
  isn't happening.

## Learnings log

Add a dated entry after each reflection session. Record aggregate numbers and public-safe
observations:

- what worked and what didn't
- which types of work suit a session and which suit parallel work
- how many people each session needed

<!-- Newest first. Template:
### YYYY-MM-DD
- Sessions: n. Merged / closed `ai-mob` PRs: n / n. Median cycle time: n days (others: n days).
- Worked:
- Didn't work:
- Work types that suited a session / suited parallel work:
- Rules added or removed (link the AI compound PRs):
-->

No entries yet.
