---
status: draft            # draft | in review | approved
approved_by:             # initials of the reviewers
approved_at:             # date and time of approval, for the experiment's measures
ticket:                  # short ticket id, e.g. the tracker number
---

<!--
How to use this template
- Copy it into the team's private doc tool. Plans contain requirements, so they never go in this
  repository. Export the plan to .work/<ticket>/plan.md when an agent needs it.
- The human writes every section marked (human). An agent may help with the sections marked
  (agent). Keep the whole plan to 1.5 pages or less; if it grows beyond that, split the ticket.

Instructions for any agent helping with this plan (the tv-plan skill follows the same rules)
1. Never make a decision. Do not write in a (human) section. Put any suggestion on its own line
   starting "> proposed:" and leave it for the human to accept or remove.
2. Interview the human one question at a time, numbered, with options and your recommendation.
3. Check every statement against the code and flag contradictions, with path:line.
4. Make each success criterion checkable: at least one test scenario each, with its spec type.
5. Fill in the (agent) sections only from the human's decisions. If a slice needs a decision that
   isn't here, ask instead.
6. Use plain language. No ticket wording, names or internal links in anything that will become
   code, spec names, commits or the pull request.
-->

# <Plan title: the change in plain language>

## Problem and outcome (human)

What is wrong or missing today, for whom, and what will be true when this is done. Two to four
lines.

## Decisions (human)

- **Approach chosen:** …, because …
- **Alternatives rejected:** … (why), … (why)
- **Trade-offs accepted:** …

## Success criteria and test scenarios (human): the "until" condition

1. <Criterion in plain language>
   - Scenario (system | request | view | a11y): given …, when …, then …
2. <Criterion>
   - Scenario (…): given …, when …, then …

Add an accessibility scenario for any new or changed page. System specs cover the happy path;
request and view specs cover edge cases.

## Assumptions and out of scope (human)

- Assuming: …
- Not doing: …

## Codebase facts and patterns to follow (agent)

- `path:line`: what it is, and why it matters here.
- Follow `path` for … (the closest existing example).

## Risks (agent proposes, human confirms)

Personal data (`filter_parameter_logging.rb`), analytics (`config/analytics*.yml`), migrations,
routes, feature flags, accessibility, the pull request's data and schema checklist. Write "none"
where true.

## Slices (agent drafts from the decisions above)

Two to five vertical slices, each about 400 changed lines or fewer.

### Slice 1: <name>
- [ ] done
- **Files:** …
- **Action:** …
- **Verify:** `bin/verify spec/…`
- **Done when:** …

### Slice 2: <name>
- [ ] done
- **Files:** …
- **Action:** …
- **Verify:** …
- **Done when:** …
