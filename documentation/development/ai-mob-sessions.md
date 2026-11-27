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

## Before you start

- Start the session in normal mode, on the default Copilot Fusion model. Nothing about the model
  is fixed in the repository.
- Check you are on a clean, up-to-date `main`.
- After the agent opens the review app pull request, switch the session to `/plan` mode for the
  grilling and planning. Leave plan mode when the team says "implement".

## What does not change

- **Every pull request still needs a developer's approval before it merges.** A session review
  checks the behaviour in the review app. It doesn't replace code review, the data and schema
  checklist in the pull request template, or the security rules in [AGENTS.md](/AGENTS.md).
- Pull requests are created as drafts, except `AI compound:` pull requests (see below). The
  operator confirms, then `bin/ai-mob-setup-review-app` adds the `deploy` label.
- Closing the pull request or removing the `deploy` label deletes the review app.
- CI is unchanged.

## How a session runs

The agent follows the [`ai-mob-session` skill](/.claude/skills/ai-mob-session/SKILL.md). Start a
session by telling the agent it is an AI mob session.

0. **Start.** The operator confirms, then the agent runs `bin/ai-mob-setup-review-app <slug>`. It
   opens a draft pull request labelled `deploy` and `ai-mob`, so the review app starts building
   while the team plans. The first build and seeding are the slow part. The agent then asks the
   operator to switch to `/plan` mode.
1. **Understand.** The agent restates the goal and uses the
   [`grill-me` skill](/.claude/skills/grill-me/SKILL.md) to ask the team about decisions that are
   really open, in numbered rounds, each with a recommended answer. Questions nobody answers stay
   open and are asked again. For low-risk details the agent states its assumption and moves on.
   It looks up codebase facts itself. The team can also ask what-if questions that change
   nothing, such as the specification a change implies or what a signed-out user sees today.
2. **Plan, then stop.** The agent writes the plan as numbered, checkable outcomes in the pull
   request description and waits. The team changes it until they agree, then says "implement".
3. **Implement.** The agent works in small steps. It stops and flags before migrations,
   personal-data fields, `Vacancy` or `JobApplication` enum or validation changes, public route
   changes and security middleware.
4. **Verify, then push once.** The agent uses the
   [`verify-against-plan` skill](/.claude/skills/verify-against-plan/SKILL.md) to check each
   agreed outcome in the running local app, not just the specs. It pushes once, when every outcome
   has passed or been explained, and the review app updates.
5. **How to check.** The agent uses the
   [`how-to-check` skill](/.claude/skills/how-to-check/SKILL.md) to write plain-language test
   steps for non-developers, in the chat and in the pull request description. The team tries the
   change in the review app.
6. **Session state.** When the team pauses or reaches an impasse, the agent writes where things
   stand in the "Session state" section of the pull request description, and the work carries on,
   so the next operator, who may be on another machine, can pick it up. Revert and close the
   review app only at a deadlock or when the team drops the idea.
7. **Compounding.** The agent uses the
   [`ai-compound` skill](/.claude/skills/ai-compound/SKILL.md) to propose rules from the session.
   Once the team has chosen, it opens the `AI compound:` pull request.

## AI compounding

Each session should make the next one cheaper. Knowledge the agent should apply next time, such
as design principles, content choices, trade-offs, accessibility fixes, publishable research
findings and technical conventions, is written down once as a rule. Expert review then moves
from "by hand in every session" to "once, when the rule is written".

| Level | Where it lives | Applied by |
|---|---|---|
| Rule | A skill for that area in [`.claude/skills/`](/.claude/skills/), or [AGENTS.md](/AGENTS.md) if universal and short | the agent, when relevant |
| Check | A spec, CI job or agent hook | always enforced |

- Put a rule in the skill for its area. If none fits, propose a new skill.
- Add a check only after a rule has been missed in practice.
- Keep AGENTS.md short. Discipline knowledge belongs in skills, which the agent loads only when
  relevant.
- Prune as well as add. Remove rules that are wrong or unused when the team reflects.

### Skills

The skills, and who maintains them, are listed in the
[Skills and AI compounding section of AGENTS.md](/AGENTS.md#skills-and-ai-compounding). Developers
maintain all of them, using feedback from product and design. Claude Code and the Copilot cloud
agent, CLI and VS Code all read project skills from `.claude/skills/`
([GitHub docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)),
so there is one copy. Visual Studio reads only `.github/skills/`. Check that the Copilot desktop
app lists these skills before the first session. If it doesn't, move them to `.github/skills/`
and symlink `.claude/skills/` to it.

`grill-me` is a reviewed copy of a third-party skill. Update it only by re-vendoring it in an
`AI compound:` pull request, never with an installer.

### AI compounding pull requests

- Keep them small and separate from feature work.
- Title them `AI compound: <summary>` and label them `ai-compounding`.
- Open them as ready for review, not as drafts, and don't request a reviewer. A developer still
  approves before merge.

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
against other merged pull requests from the same period. Mob pull requests are opened at the
start of a session, while others are often opened after the work has started, so this isn't like
for like. Time from starting the work to production is a fairer alternative if it can be
measured.

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
