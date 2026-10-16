# Finish: clean up after merge

Run after the PR is merged, or from [start.md](start.md) step 1 for each merged ticket.

1. Confirm the PR is merged (`gh pr view <branch> --json state,mergedAt,url`). If it is not,
   stop; never remove unmerged work.
2. Check the worktree for anything not in the PR: `git -C <worktree> status --porcelain` and
   commits not on `origin/main`. If there is any, show it to the developer and stop.
3. Remove the worktree: leave it first with the ExitWorktree tool if this session is in it,
   otherwise `git worktree remove <path>`. Then delete the local branch with `git branch -d`;
   if git refuses because the PR was squash-merged, `-D` is fine once step 2 found nothing.
4. `git fetch --prune` to drop the deleted remote branch.

Give the developer a one-line summary: PR, worktree and branch removed.
