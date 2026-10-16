# Start: from Trello card to approved plan

Turns a Trello card (read-only context) into a planned change on its own branch and worktree.
Ends at an approved plan; implementation follows on plan approval.

If no card was given, ask the developer for the card URL and stop until they give one.

## 1. Tidy up merged tickets

List worktrees (`git worktree list`). For each ticket worktree whose PR is merged, follow
[finish.md](finish.md) for it, after one confirmation covering all of them. Skip this step if
there are none.

## 2. Read the card

Fetch the card's name, short number (`idShort`), URL, description, checklists (often the
acceptance criteria) and comments from the Trello MCP server. Read only; do not change the card.
Without one, ask the developer to paste the title, URL and description.

## 3. Ask for extra context

Tickets are often thin. Summarise the card back to the developer in a few lines (goal, acceptance
criteria, anything ambiguous you noticed), then ask in one AskUserQuestion round for anything that
would improve the plan, for example:

- areas, files or models they expect to be involved;
- constraints or approaches to prefer or avoid;
- related PRs, previous attempts, or designs;
- whether a migration, an enum change or an ATS API change is expected (these trigger the PR
  template's data and schema checklist).

An empty answer is fine — carry on with the card alone.

## 4. Create the worktree and branch

Branch names follow `<card number>-<kebab-case title slug>`, as existing branches do (for example
`1866-job-offered-status`). Keep the slug to four or five words.

1. `git fetch origin main`
2. Create the worktree on a new branch from `origin/main`, using the EnterWorktree tool if it is
   available, otherwise
   `git worktree add ../teaching-vacancies-<branch> -b <branch> origin/main`
   and tell the developer to open Claude Code in that directory before continuing.
3. A worktree has no gitignored files. Copy the local `.env` across with `cp` (do not read it), and
   run `bundle install` and `yarn install` in the new worktree if dependencies differ.

Worktrees share the local databases. Warn the developer not to run specs in two worktrees at the
same time unless they use separate `TEST_ENV_NUMBER`s.

## 5. Plan

This workflow expects the `opusplan` model (Opus plans, Sonnet implements). If the session is on a
different model, suggest `/model opusplan` before planning.

Enter plan mode and plan the change using as the brief:

- the card's goal and acceptance criteria;
- the developer's extra context from step 3;
- the rules in AGENTS.md, especially "Non-negotiables", "Testing" and "Keeping documentation
  current".

The plan must:

- map **each acceptance criterion to the spec that will prove it**;
- name any locale keys and documentation to update;
- say whether the PR template's data and schema checklist will apply, and whether any new field
  holds personal data.

Once the plan is approved and implemented, tell the developer to review the diff and then run
`/ticket` to ship it.
