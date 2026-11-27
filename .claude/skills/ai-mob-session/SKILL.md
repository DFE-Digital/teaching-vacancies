---
name: ai-mob-session
description: Checklist for an AI mob session, where the whole squad works through one agent operator. Use when the operator says this is an AI mob session, or asks to plan, build or iterate on a change "with the team" or "for the mob".
---

# AI mob session

Maintained by developers. Last reviewed: 2026-11-27. The team process around this skill is in
`documentation/development/ai-mob-sessions.md`.

You are working with a whole squad (product, service design, design, research, accessibility
and development) through one operator. Everything you write is read on a shared screen and may end
up in this **public** repository, so never write names, internal URLs or quotes from team members.

Follow the steps in order. Each step names the skill or script to use and says what it must
achieve, so carry on from that description if a skill doesn't load. Do not skip ahead.

**Explore on request.** At any point the team may ask a what-if question, such as the specification
a change implies or what a signed-out user would see today. Answer it from the codebase without
editing any files, then carry on.

## 0. Start the review app, then plan mode

1. Ask the operator to confirm you may open a draft pull request, because it deploys a review app.
2. Run `bin/ai-mob-setup-review-app <short-slug>` with `AI_COAUTHOR` set to your own co-author
   trailer value. It branches from `main`, opens a draft pull request labelled `deploy` and
   `ai-mob`, and the review app starts building while the team plans.
3. Tell the team that the review app link will appear in the pull request's sticky comment, and
   that closing the pull request or removing the `deploy` label deletes the review app.
4. **Stop and ask the operator to switch to `/plan` mode.** Grilling and planning happen there.

## 1. Understand

- Restate the goal in one or two sentences, then list your assumptions.
- Use the `grill-me` skill to put the decisions that are really open to the team in numbered
  rounds, each with your recommended answer. For low-risk details, state your assumption and
  carry on to the plan. Look up facts in the codebase yourself instead of asking for them.
- Check the other skills in this repository and load any that apply, such as `ucd-principles`
  for user-facing changes and `accessibility-review` for views or components.

## 2. Plan, then stop

- Write the plan as numbered, checkable outcomes: what the user will be able to do or see, which
  files change, how it will be tested, and what is out of scope.
- Put the plan in the pull request description.
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

  These are where the `AGENTS.md` rules on encryption, `filter_parameter_logging.rb`, the PR data
  and schema checklist and legacy redirects apply. Say which rule applies and how you will meet it.

## 4. Verify, then push once

Use the `verify-against-plan` skill to check every agreed outcome in the running app. Push to the
pull request branch once, when every outcome has passed or been explained. The review app was
built at the start, so this push updates it quickly.

## 5. Tell the team how to check it

Use the `how-to-check` skill to write plain-language test steps for the people who are not
developers, in the chat and in the pull request description.

## 6. Session state (at a pause or an impasse)

Write where things stand in the "Session state" section of the pull request description, so the
next operator, who may be on another machine, can carry on. Include the goal, the decisions made
and why, the open questions, what was tried and didn't work, and the next step. Keep the work and
the review app. Revert the changes and close the review app only at a deadlock, or when the team
decides to drop the idea, and write the state first.

## 7. Compounding

Use the `ai-compound` skill to propose rules from the session and, once the team has chosen, to
open the `AI compound:` pull request.
