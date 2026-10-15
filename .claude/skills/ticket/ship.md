# Ship: from reviewed change to a green PR ready for review

Run from the ticket's worktree, after the developer has reviewed the diff.

## 0. Preconditions

- Refuse to run on `main`. The branch should look like `<card number>-<slug>`.
- Show `git status` and the `git diff origin/main...` stat, and confirm with the developer that
  this is the change to ship.
- If the diff is over about 400 changed lines (excluding `db/schema.rb`, lockfiles and generated
  files), suggest splitting it. Small PRs get better reviews. Carry on if the developer says so.

## 1. Rebase

Commit any work in progress, then `git fetch origin main` and `git rebase origin/main`. Resolve
simple conflicts. If a conflict is not obvious, stop and show it to the developer.

## 2. Automated review

The plan is not the code. Review the diff with a fresh context before anyone else does:

- Invoke the `code-review` skill at `high` on the branch's changes against `origin/main`.
- If the diff touches `app/models/`, `app/controllers/`, `app/form_models/`, `app/mailers/`,
  `app/jobs/` or `config/`, also invoke the `security-review` skill.
- If those skills are not available, review the diff with a fresh subagent instead.

Fix the findings you can confirm. List the rest for the developer, with your view of each, and
let them decide.

## 3. Repo-specific checks

Check the diff for these, which the generic review can miss:

- **Personal data** (AGENTS.md, "Non-negotiables"): every new column, attribute or param that
  holds personal data is in `config/initializers/filter_parameter_logging.rb`, and sensitive
  columns use Lockbox `has_encrypted`, not plaintext.
- **Migrations:** they follow `online_migrations` (`config/initializers/online_migrations.rb`)
  and change schema only; data changes belong in a rake task. Note in the PR any deploy order or
  backfill needed.
- **Acceptance criteria:** each card criterion has a spec that proves it. List any criterion
  without one, and either add the spec or tell the developer why not.

## 4. Run what CI runs

Run the checks in AGENTS.md, "Before you call a task done". That list is the source of truth — do
not work from a copy of it. Notes:

- Run specs with coverage (`COVERAGE=1`) so `bundle exec undercover` has data to check.
- Run the Yarn lint and Jest steps only if the diff touches `app/assets/javascript/`,
  `app/assets/stylesheets/`, `package.json` or `yarn.lock`.
- **UI changes** (views, components, stylesheets, locales): also run
  `bundle exec rspec --tag a11y` on the affected specs. The full Pa11y run in CI is only weekly.
- On a failure, fix it and re-run that check. If a fix is not obvious, stop and report the failure.

Then check the diff against the "Keeping documentation current" table in AGENTS.md and update any
documentation that the change has made stale.

## 5. See it working (UI changes only)

Specs passing is not the same as the feature working. Start the app (the `run` skill, or
`bin/dev`), open the changed pages with Claude in Chrome if it is available, and take before
(`origin/main`) and after screenshots for the PR. Use seeded or factory data only, never real
user data. If no browser tool is available, ask the developer to add screenshots themselves.

## 6. Commit and push

- Commit with a short, sentence-case subject and the `Co-Authored-By` trailer that AGENTS.md
  requires. No card text in the message.
- `git push -u origin HEAD` (after a rebase on an already-pushed branch:
  `git push --force-with-lease`).

## 7. Open a draft PR

Fill in `.github/pull_request_template.md` exactly as it is laid out:

- **Trello card URL** — the card URL.
- **Changes in this PR** — a short summary written from the diff, not copied from the card, plus
  any review findings the developer chose to leave and any deploy notes from step 3.
- **Screenshots** — the images from step 5 under Before and After, or "N/A" if no UI changed.
- **Data & Schema Changes** — tick each box honestly from the diff: validations added or removed,
  migrations (`db/migrate/`, `db/schema.rb`), and changes to Vacancy array enums. If any box is
  ticked, list which integration and user-experience items you checked and what you found.

Write the body to a temporary file and run
`gh pr create --draft --base main --body-file <file>` (fallback: the GitHub MCP
`create_pull_request` tool with `draft: true`). Give the developer the PR link.

## 8. Finish the PR

[address.md](address.md) ends with this step too.

- **Wait for CI without blocking the developer.** Start
  `gh pr checks <number> --watch --fail-fast` as a background command, then give the developer
  the PR link and tell them they can keep working; you will pick up when CI finishes. Do not poll
  its output: the session is notified when the command exits, and you continue from here.
  - If the developer is about to close the session, offer to use the `loop` skill instead, so
    that it checks the PR every 10–15 minutes and finishes these steps (or reports a failure)
    when CI completes, then stops.
  - Fallback without `gh`: check the PR's check runs with the GitHub MCP `pull_request_read`
    tool every few minutes until none are pending.
- **Any failure:** do not continue. Report which job failed with the relevant log lines and offer
  to fix it; after a fix, push and restart this step.
- **All green:**
  1. If the PR is a draft, `gh pr ready <number>`.
  2. `gh pr edit <number> --add-label "Waiting for dev review"` (fallback: the GitHub MCP
     `issue_write` tool, keeping any labels already on the PR — it replaces the whole set).
  3. Comment the PR link on the Trello card (first time only).
  4. Move the card to the **For Review** list.
