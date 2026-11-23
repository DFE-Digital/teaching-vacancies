# Agent-assisted workflow: shift left and the until loop

> **Experimental and optional.** This is a way of working some of the team are trying out. It is
> not an [agreed practice](../agreed-practices.md) yet, nobody has to use it, and nothing here
> changes how you work if you don't. [`bin/verify`](../tooling/testing.md#optional-pre-push-check-binverify)
> is useful either way.

## Why, and what it is not

A ticket often goes through several rounds between the product owner, business analyst,
designer, content designer and user researcher before an engineer sees it. By then, the context
behind decisions has been lost in hand-offs, and technical constraints surface late, causing more
rounds.

AI agents now make prototyping and building cheap. That lets engineers move **left**: into
research and shaping, alongside the rest of the team, producing something people can see and
try early. Once a plan exists, handing it to an agent is faster than handing it to a person, so
the human effort goes into the plan, and the agent loops **until** the code matches it.

The engineer stays at the top of the loop, not at the receiving end of the agent's output.

It is **not**:

- a replacement for product, design, content or research, who shape the work with engineers
  rather than hand over a finished ticket;
- a replacement for code review: humans review every pull request and humans merge it;
- a spec framework: there are no per-ticket specification files in this repository.

## The two processes

**Specification (shift left).** The engineer takes an ambiguous idea, researches it, and makes
assumptions from their knowledge of the service and the code rather than waiting for a detailed
ticket or stopping to ask questions. Within about 24 hours they show a demo or prototype, and the
team corrects the assumptions together.

**Loop engineering (the until loop).**

```text
agent.research_codebase()
human.decide_approach()
human.make_tradeoffs()
plan = human.write_with(agent)   # then peer reviewed

until agent.matches(plan)
do
  agent.implement(plan)
done
```

Define the condition first; an agent can check whether the code matches it.

| Stage | Who | Output | Where it lives |
|---|---|---|---|
| 1. Idea | Product and team | A rough problem statement | Ticket |
| 2. Research and shape | Engineer (optionally `tv-research`) | Facts and constraints; an **assumptions log** | `.work/`, then a summary in the private doc |
| 3. Prototype or demo (about 24h) | Engineer with the agent | A throwaway demo, made from the [prototype brief](prototype-brief.md) | Local, or a review app when public-safe (`prototype/*` branch, `deploy` label, never merged) |
| 4. Demo session | Whole team: PO, BA, design, content, research, engineers | Assumptions confirmed or corrected; decisions | Private doc |
| 5. Plan | **The human writes it** from the [plan template](plan-template.md); `tv-plan` interviews and sharpens | A plan of 1–1.5 pages with test scenarios | Private doc, exported to `.work/<ticket>/plan.md` |
| 6. Plan review (the main gate) | A second engineer and the PO; design and content when user-facing | Approval recorded in the doc, using the [plan review checklist](plan-review-checklist.md) | Private doc |
| 7. Build | Agent with `tv-implement`; the engineer moves on to other work | Specs commit, then slice commits, then `bin/verify --full` passes, then a draft PR | Branch (public-safe) |
| 8. Code review, acceptance, merge | Engineers review; the team checks the review app; a human merges | A merged PR | GitHub |

Stages 2–4 are optional for small or well-understood work: go straight to the plan.

## Privacy and the source of truth

This repository is public. Requirements, designs, discussion and plans are not.

| What | Lives in | Public? |
|---|---|---|
| Problem, requirements, designs, discussion | Ticket and the private doc tool | No |
| The plan and its review | Private doc tool (exported to `.work/` for the agent) | No |
| Research, progress notes, assumptions | `.work/<ticket>/` on your machine, ignored by git | No |
| Conventions for every contributor and agent | [`AGENTS.md`](../../../AGENTS.md) | Yes |
| The behaviour delivered | Code and specs | Yes |
| A summary of the change | Pull request description | Yes |

- `.work/` is never committed: `.gitignore` covers it, and `bin/verify` fails if anything under it
  is tracked or staged. Delete it when the ticket is done.
- Spec names, commit messages and pull requests describe behaviour in plain language, never
  ticket wording, colleague names or internal links.
- **Pushing a branch is publishing.** Only push a prototype whose idea is safe to publish.
- **Security fixes never go through this workflow on a public branch.** Follow the private
  security process.
- The Copilot cloud agent works from GitHub issues, which are public here, so only give it work
  whose ticket content is safe to publish.

## The 24-hour prototype and the demo session

The engineer works from the [prototype brief](prototype-brief.md). They record each assumption
they make instead of stopping to ask, and build something the team can react to. The prototype is
**disposable**: it is never merged. The real change comes from the plan.

Show it in a **demo session** with everyone who shapes the work: product owner, business analyst,
designer, content designer, user researcher and engineers. Everyone should be able to see and hear
everyone else, watch the prototype running and try it. Expect the setup to take a couple of
attempts before it works smoothly. Tips:

- Use a review app (add the `deploy` label to a draft pull request from a `prototype/*` branch)
  when the idea is safe to publish, so everyone can click through it themselves. Close the pull
  request without merging afterwards.
- Otherwise, the engineer drives on a shared screen and the team directs them. Never expose a
  local server to the internet with a tunnel.
- Go through the assumptions log; each one is confirmed, corrected or turned into a question for
  the plan.

## Writing the plan with the agent

"Don't let the agent slop out a plan." Reviewing about 1.5 pages of text is much easier than
reviewing the code that comes from it, so the plan is where the human attention goes. The
[plan template](plan-template.md) marks who owns each section:

| Section | Owner | Agent's role |
|---|---|---|
| Problem and outcome | Human | Asks questions |
| Decisions: approach chosen, alternatives rejected and why | **Human** | Challenges them against the codebase |
| Success criteria and test scenarios: the "until" condition | **Human** | Makes each one checkable |
| Assumptions and out of scope | **Human** | Points out gaps |
| Codebase facts and patterns to follow | Agent (from research) | Author |
| Slices: Files / Action / Verify | Agent drafts from the human's decisions | Must add no new decisions |

How it works in practice:

1. Write the human-owned sections in the private doc, in your own words, from the template.
2. Export the plan to `.work/<ticket>/plan.md` and run `tv-plan` (or paste the template's
   "Instructions for any agent" into any agent's plan mode or chat; the skill is a convenience).
3. The agent interviews you one question at a time, flags contradictions with the code, makes
   each criterion checkable and drafts the slices. Anything it suggests in your sections appears
   as `> proposed:` until you accept it.
4. Copy the result back to the private doc for review.

## Plan review

Plan review is the main gate. A second engineer reviews the approach, the test scenarios and the
slices. The product owner reviews the success criteria. A designer or content designer joins when
the change is user-facing. Use the [plan review checklist](plan-review-checklist.md), comment in
the private doc, and record the approval there. The engineer then sets `status: approved` and
`approved_by:` in `.work/<ticket>/plan.md`.

## Reject the recipe, not the meal

If the result is wrong, the cause is usually the plan. Patching the meal teaches nothing, and the
next meal will have the same problem. To re-plan:

1. Fix the plan in the private doc, get the change reviewed, and export it to `.work/<ticket>/plan.md`
   again.
2. If the **test scenarios** changed, reset the branch to before the specs commit
   (`git reset --hard <commit before "Add specs for …">`) and delete `.work/<ticket>/acceptance.txt`,
   so the specs are rewritten from the new scenarios.
   If only the approach or slices changed, reset to the specs commit itself and keep
   `acceptance.txt`.
3. Run `tv-implement` again. It unticks any slice whose commit the reset removed, then carries
   on from the first unfinished slice.

Hand-fix the code only for small implementation slips that the plan already describes correctly.

## Reviewing an agent-built pull request

Review it like any other pull request, to the same standard. In addition:

- start with the specs commit: do the specs really assert what the plan's scenarios say?
- then look at the "where to look first" list from `tv-implement`'s report;
- check the review app against the acceptance checklist, including keyboard-only and screen
  reader checks for changed pages;
- complete the data and schema checklist in the pull request template as usual.

Only humans approve, mark ready and merge.

## Worked example (fictional)

A made-up ticket to show each stage: "Show jobseekers how many jobs are open on the homepage".

**1. Idea.** The ticket says only: *jobseekers can't tell how big the service is from the
homepage; show how many jobs are open.*

**2. Research.** The engineer runs `/tv-research`. Extract of `.work/demo/research.md`:

> **Relevant code.** `config/routes.rb` maps `root` to `home#index`.
> `HomeController#index` (`app/controllers/home_controller.rb`) already builds counts from
> `PublishedVacancy.live`, split into school and further education scopes, using
> `VacancyCounter`. `PublishedVacancy.live` is `kept.listed.applicable`
> (`app/models/published_vacancy.rb:26`), so it excludes expired and future-dated jobs. Copy for
> the page lives under `home.index` in `config/locales/en.yml`. The view is
> `app/views/home/index.html.slim`, with a view spec in `spec/views/home/index.html.slim_spec.rb`.
>
> **Constraints and risks.** No personal data. No new columns, so no analytics change. The homepage
> is high traffic: an extra count query on every request. New text on a page needs an accessibility
> check.
>
> **Candidate approaches.** A: count in the controller on each request (always fresh, one more
> query). B: cache the count for a few minutes (cheaper, slightly stale). C: show the count
> inside the search box hint (less visible, no layout change).

**3–4. Prototype and demo.** The engineer builds approach A in an afternoon, writing assumptions in
the brief: *"open" means live jobs; schools and colleges together; the number sits above the search
box.* In the demo the content designer rewrites the copy to "2 jobs open now", and the product
owner confirms schools and colleges together.

**5. Plan.** The engineer writes the human sections. Extract:

> **Decisions.** Approach B: cache the total for 10 minutes. We rejected A because of the extra
> query on every homepage request, and C because users missed it in the demo.
>
> **Success criteria and test scenarios.**
> 1. The homepage shows how many jobs are open now. *Scenario (system): given two live jobs, one
> expired and one scheduled for the future, when a jobseeker visits the homepage, then they see
> "2 jobs open now".*
> 2. A single job reads naturally. *Scenario (view): given a count of one, the page shows "1 job
> open now".*
> 3. Accessible. *Scenario (a11y): the homepage passes the axe checks.*

Then `/tv-plan` asks, for example: *"1. Should the count include jobs from organisations outside
the in-scope schools and colleges that the existing counts use? (a) yes, all live jobs, (b) only
in-scope ones, matching the sections below. I'd choose (b) so the numbers on the page agree.
Why: `HomeController#index` filters by `Organisation.in_scope_schools`."* It adds the facts,
proposes two slices (count and cache, then view and copy), and marks its own suggestion in the
Decisions section as `> proposed:` until the engineer accepts it.

**6. Plan review.** A second engineer comments in the private doc that the cache key needs to
expire when a job is published; the product owner approves the criteria. The engineer updates the
plan and sets `status: approved`, `approved_by: AB, CD` and `approved_at`.

**7. Build.** `/tv-implement` first writes the specs and runs them. In this example the first run
fails for the wrong reason, `Translation missing: en.home.index.open_jobs_count`, so the agent adds
the agreed copy to the locale file. The second run fails for the right reason:
`expected to find text "2 jobs open now"`. It commits the specs, then implements and commits each
slice, appending to `progress.md`, until
`bin/verify --full --acceptance .work/demo/acceptance.txt` ends with `PASS`.

**8. Review and merge.** The engineer pushes and opens a draft pull request with the agent's
public-safe description. A reviewer starts with the specs commit and the "where to look first"
list, the team checks the review app, and a human merges.

*Re-plan variation.* On the review app, the product owner notices that the count includes jobs
closed earlier today, still within the cache window. That's the recipe: the engineer adds a
criterion and scenario for it, the plan is re-reviewed, and the agent runs again, rather than
someone patching the cache by hand.

## When to use it, and when not

Good fits: bounded, testable changes, such as a new filter, a form step, a component, a report,
or a change to an existing journey.

Poor fits, or plan only: exploratory design work the team hasn't shaped, unresolved product
decisions, security fixes, large data migrations, and incident response.

## Running the experiment

The team reviews the experiment in retros. The skills and template record timestamps:
`plan_started` (by `tv-plan`) and `started` and `finished` (by `tv-implement`) in
`.work/<ticket>/progress.md`, and `approved_at` in the plan, set by the engineer. From those and
the pull request, useful measures are:

- attention time (writing and reviewing the plan) against lead time (idea to merge);
- how often a plan had to be redone;
- review rework, and defects found after release;
- how the people involved found it.

Dates, results and anything team-specific live in the private wiki.

## Setup and tools

- **Skills** live in `.agents/skills/`: `tv-research`, `tv-plan` and `tv-implement`. Copilot reads
  project skills there (checked with Copilot CLI; GitHub documents the same folder for its other
  surfaces), and Claude Code reads them through symlinks in `.claude/skills/`. In Claude Code run `/tv-research` and so on; in Copilot, ask for the skill by
  name or use its skill picker.
- **Models:** use a strong model for research and planning, where judgement matters, and a
  cheaper, faster one for implementing an approved plan.
- **Safety:** run long `tv-implement` loops in the [devcontainer](../tooling/devcontainer.md) where
  possible, and never with the agent's permission checks switched off on your own machine.
- **Parallel work:** `bin/setup-worktree` prepares a git worktree, so you can shape one ticket
  while an agent builds another. Each worktree has its own `.work/`.
- **Optional:** add `.work/` to your clone's own exclude file too:
  `echo ".work/" >> "$(git rev-parse --git-common-dir)/info/exclude"`.

## FAQ

**I don't use AI. What changes for me?** Nothing. You may be asked to review a plan, which is
like reviewing a design note, and you'll review agent-built pull requests like any other.
`bin/verify` may still save you a CI round trip.

**Can product write the plan?** Product owns the problem and the success criteria; the engineer
owns the approach and the plan. Writing it together is fine.

**What if the agent gets stuck?** `tv-implement` stops after three failed attempts at the same
problem, or when it needs something outside the plan, and explains why in `progress.md`. Fix the
plan, then run it again: it continues from the first unfinished slice.

**Who is accountable for agent-written code?** The engineer who opens the pull request, as for any
code they submit.

**Can the agent open or merge pull requests?** It prints the commands for you to push and open a
draft pull request. It never pushes, approves, marks ready or merges.
