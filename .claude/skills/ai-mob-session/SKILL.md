---
name: ai-mob-session
description: Protocol for an AI mob session, where the whole squad works through one agent operator. Use when the operator says this is an AI mob session, or asks to plan, build or iterate on a change "with the team" or "for the mob".
---

# AI mob session

Owner: developers. Last reviewed: 2026-11-25. The team process around this skill is in
`documentation/development/ai-mob-sessions.md`.

You are working with a whole squad (product, service design, design, research, accessibility
and development) through one operator. Everything you write is read on a shared screen and may end up in this
**public** repository, so never write names, internal URLs or quotes from team members.

Follow these phases in order. Do not skip ahead.

**Explore on request.** At any point the team may ask a what-if question, such as the
specification a change implies or what a signed-out user would see today. Answer it from the
codebase without editing any files, then carry on.

## 1. Understand

- Restate the goal in one or two sentences, then list your assumptions.
- Use the `grill-me` skill to put the decisions that are really open to the team in numbered
  rounds, each with your recommended answer. For low-risk details, state your assumption and
  carry on to the plan. Look up facts in the codebase yourself instead of asking for them.
- Check the other skills in this repository and load any that apply, such as `ucd-principles`
  for user-facing changes and `accessibility-review` for views or components.

## 2. Plan, then stop

- Write a numbered plan: what changes, in which files, how it will be tested, and what is out of
  scope.
- If you are working in a pull request, put the plan in its description.
- **Stop and wait.** Do not edit any files until the team says "implement". If they change the
  plan, rewrite it and wait again.

## 3. Implement

- Work in small steps the team can follow, and say what each step changed.
- Follow `AGENTS.md`, including the non-negotiables, the pitfalls and the code style.
- **Stop and flag for discussion before** any of these, even if they were in the agreed plan:
  - a migration
  - a new or changed field that holds personal data
  - a `Vacancy` or `JobApplication` enum, validation or status change
  - removing or renaming a public route
  - editing security middleware or CSRF protection

  These are where the `AGENTS.md` rules on encryption, `filter_parameter_logging.rb`, the PR
  data and schema checklist and legacy redirects apply. Say which rule applies and how you will
  meet it.

## 4. Session state (at an impasse, or when the team pauses)

Write down where things stand so the next operator, who may be on another machine, can pick up
where the team left off. The work carries on: keep the branch and its draft pull request.

- **Working in a pull request:** add or update a "Session state" section in its description,
  written so it is safe to publish.
- **Not pushed yet:** write `tmp/ai-mob-sessions/<yyyy-mm-dd>-<short-slug>.md`. The `tmp/`
  folder is git-ignored, so this file never gets committed. Push the branch and move the state
  into a draft pull request before handing over.

Include the goal, the decisions made and why, the open questions, what was tried and didn't
work, and the next step.

Revert the changes and close the review app only at a deadlock, or when the team decides to drop
the idea. Write the state first.

## 5. AI compounding wrap-up (end of every session)

Before the session ends, list for the team:

1. **Decisions and knowledge** from this session: design, content, accessibility, research,
   technical. Include anything you had to be told that a rule would have answered.
2. **Proposed rules:** for each one worth keeping, a concrete diff to the skill for its area, or
   a new skill if none fits, or to `AGENTS.md` only if the rule is universal and short. Name the
   owning discipline that should review it.
3. **Rules that were wrong or unused:** propose removing or rewording them.

The team chooses which proposals to keep. Do not apply them inside the feature work. They go in
a separate small pull request titled `AI compound: <summary>`, reviewed by the owning
discipline. Every proposed rule must be
generic and public-safe: no names, no internal URLs, no participant quotes, no unpublished
research findings.
