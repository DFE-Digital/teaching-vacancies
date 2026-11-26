# AI mob sessions

An experiment in whole-squad working: product, design, service design, research, accessibility
and development work together, at the same time, around one AI coding agent. One person, the
operator, drives the agent, and the role rotates. Everyone else, developers included, acts as a
navigator: they watch the wider system and the result in a review app, and give their input
through the operator. Start with the whole squad, then use what the team sees about who adds
value to decide whether fewer people are needed.

This page covers how a session runs, how the team turns what it knows into rules the agent
follows (**AI compounding**), and how we measure whether the experiment works. Everything
recorded here, and in the skills it describes, is public: see [Public-safety rule](#public-safety-rule).

## Choosing work and what to expect

- Sessions suit requirements that are still emerging, where seeing working output may change a
  decision. Work that is already fully specified, technical debt and known bugs may suit parallel
  work better.
- Prompt the agent directly rather than pasting in a detailed story. It can infer a lot from the
  codebase, and the team learns by inspecting what it produces.
- Treat the first one or two sessions as table reads, to learn the mechanics. By about the third
  or fourth session, success means bringing a real problem, solving it in the session and
  agreeing on the solution together. If that isn't happening, find out why or rethink the approach.

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
   [`grill-me` skill](/.claude/skills/grill-me/SKILL.md) to ask the team about decisions that are
   really open, in numbered rounds, each with a recommended answer. For low-risk details it
   states its assumption and moves on. It looks up codebase facts itself. The team can also ask
   what-if questions that change nothing, such as the specification a change implies or what a
   signed-out user sees today.
2. **Plan, then stop.** The agent writes a numbered plan and waits. The team changes it until
   they agree, then says "implement".
3. **Implement.** The agent works in small steps. It stops and flags before migrations,
   personal-data fields, `Vacancy` or `JobApplication` enum or validation changes, public route
   changes and security middleware. The team reviews the result in the review app.
4. **Session state.** When the team pauses or reaches an impasse, the agent writes where things
   stand and the work carries on, so the next operator, who may be on another machine, can pick
   it up. Keep the branch and draft pull request, with the state in a "Session state" section of
   the description. `tmp/ai-mob-sessions/` is git-ignored and only for work that hasn't been
   pushed. Revert and close the review app only at a deadlock or when the team drops the idea.
5. **AI compounding wrap-up.** The agent lists the decisions and knowledge from the session and
   proposes which are worth turning into rules (see below).

Label pull requests that come out of a session `ai-mob`.

## AI compounding

Each session should make the next one cheaper. Knowledge the agent should apply next time, such
as design principles, content choices, trade-offs, accessibility fixes, publishable research
findings and technical conventions, is written down once as a rule. Expert review then moves
from "by hand in every session" to "once, when the rule is written".

| Level | Where it lives | Applied by |
|---|---|---|
| Rule | A skill for that area in [`.claude/skills/`](/.claude/skills/), or [AGENTS.md](/AGENTS.md) if universal and short | the agent, when relevant |
| Check | A spec, CI job or agent hook | always enforced |

- Put a rule in the skill for its area. If none fits, propose a new skill with an owner.
- Add a check only after a rule has been missed in practice.
- Keep AGENTS.md short. Discipline knowledge belongs in skills, which the agent loads only when
  relevant.
- Prune as well as add. Remove rules that are wrong or unused when the team reflects.

### Skills and owners

| Skill | Owner | Use |
|---|---|---|
| [`ai-mob-session`](/.claude/skills/ai-mob-session/SKILL.md) | Developers | Session protocol |
| [`grill-me`](/.claude/skills/grill-me/SKILL.md) | Developers | Clarifying questions; vendored from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) |
| [`ucd-principles`](/.claude/skills/ucd-principles/SKILL.md) | Design and user research | User-facing changes |
| [`accessibility-review`](/.claude/skills/accessibility-review/SKILL.md) | Accessibility, design and developers, shared | Views, components, front end |

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

This repository is public, and there is nowhere private to keep what isn't safe to publish.
Before adding a rule, remove:

- names of people
- internal tools, URLs and hostnames
- quotes from colleagues or research participants
- unpublished research findings

Record the general principle. If the evidence behind it can't be published, leave it out.

## Measuring the experiment

We want evidence, not a feeling of productivity. The measure is a proposal until the team agrees
it. One candidate is cycle time, from pull request creation to merge, for `ai-mob` pull requests
against other merged pull requests from the same period. Mob pull requests tend to be opened at
the end of a session, while others are opened early as drafts, so this flatters the mob. Time
from starting the work to production is a fairer alternative if it can be measured.

```bash
gh pr list --state merged --label ai-mob --limit 200 --json createdAt,mergedAt \
  --jq '[.[] | ((.mergedAt | fromdate) - (.createdAt | fromdate)) / 86400] | sort | {prs: length, median_days: .[length / 2 | floor]}'
```

```bash
gh pr list --state merged --limit 200 --search "-label:ai-mob -label:ai-compounding -author:app/dependabot merged:>=YYYY-MM-DD" --json createdAt,mergedAt \
  --jq '[.[] | ((.mergedAt | fromdate) - (.createdAt | fromdate)) / 86400] | sort | {prs: length, median_days: .[length / 2 | floor]}'
```

Cycle time alone flatters small changes, so also track:

- how many `ai-mob` pull requests were merged and how many were closed unmerged
- issues found in code review or CI after the session
- person-hours spent in the session, not just elapsed time
- how many `ai-compounding` pull requests each session produced. If there are none, compounding
  isn't happening.
