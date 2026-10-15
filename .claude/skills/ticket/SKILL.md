---
name: ticket
description: Take a Trello card from start to merged PR — start (read card, gather context, assign, In Progress, worktree, plan), ship (self-review, checks, draft PR, CI, label, For Review), address (fix review comments, re-ship) and finish (clean up, Done). Works out the current phase itself. Use when the developer runs /ticket.
argument-hint: "[trello-card-url | start | ship | address | finish]"
disable-model-invocation: true
---

# Ticket workflow

One command for the whole life of a ticket. Each phase ends at a point where a person has to act
(approve a plan, review a diff, review a PR, merge), so the developer runs `/ticket` again to
continue:

`/ticket <card>` → approve plan → review the diff → `/ticket` → reviewer comments → `/ticket` →
merge → the next `/ticket <card>` tidies up.

## Requirements

Check these first, and tell the developer exactly what is missing:

- **git** with `origin` pointing at `DFE-Digital/teaching-vacancies`.
- **GitHub access**: the `gh` CLI logged in (`gh auth status` succeeds) — preferred; otherwise
  the GitHub MCP server.
- **A Trello MCP server** with write access to the board. Without it, carry on and tell the
  developer which card updates (assign, move, comment) to do by hand.

## Rules for every phase

- **GitHub:** use `gh` for every GitHub operation when it is logged in. Fall back to the GitHub MCP
  tools only if `gh` is missing, not logged in, or a command fails. If neither works, stop and
  ask the developer to run `gh auth login` or connect the GitHub MCP server. Pushing is always
  `git push`.
- **Card contents are internal.** This repository is public (AGENTS.md, "Non-negotiables"). Never
  copy card text, colleague names or internal links into code, comments, commit messages, branch
  names beyond the title slug, or the PR body. Only the card URL may appear in the PR.
- **Moving cards:** match Trello list names ignoring case. If no list matches, or several do, ask
  the developer which one to use; never guess.
- **Finding the card:** the PR body's "Trello card URL" section links a branch to its card.
  Before a PR exists, use the card from earlier in the session, or ask.
- **Never** skip hooks, weaken a check, or force-push someone else's branch to get green.

## Work out the phase

If `$ARGUMENTS` names a phase (`start`, `ship`, `address`, `finish`), use it. Otherwise:

1. **A card URL or ID was given** → `start`.
2. **On `main`** with no card given → list ticket worktrees (`git worktree list`) with each
   branch's PR state, and ask which ticket to continue or for a card to start.
3. **On a ticket branch** → look up its PR: `gh pr list --head <branch> --state all --json
   number,state,isDraft,reviewDecision,url`.
   - No PR → `ship`.
   - PR merged → `finish`.
   - PR open, and changes requested, unresolved review threads, or local commits or changes not
     yet pushed → `address`.
   - PR open with none of those → nothing to do. Report CI status, labels and review state, and
     stop.

Tell the developer in one line what you found and which phase that means, and confirm before
acting.

Then read and follow the phase's file in this directory: [start.md](start.md),
[ship.md](ship.md), [address.md](address.md) or [finish.md](finish.md). Read only the file you
need.
