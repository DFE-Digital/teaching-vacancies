---
name: verify-against-plan
description: Check by hand, in the running local app, that a change does what was agreed, before it is pushed or handed over for review. Use after implementing any change that has a plan or numbered outcomes, not only in an AI mob session.
---

# Verify against the plan

Maintained by developers. Last reviewed: 2026-11-27.

Passing specs show that the code does what the specs expect. They don't show that the change does
what was agreed. This skill closes that gap. An outcome is **passed** only if you saw it happen
in the running app.

## 1. Get the outcomes

Take the numbered outcomes from the plan, which is in the pull request description if there is
one. If there are none, write them from the request and confirm them with the person before you
go on.

## 2. Run the specs for what you changed

`bundle exec rspec <paths>`. Fix failures first. Never let a spec record a new VCR cassette, which
would call a real service. Replay an existing cassette instead.

## 3. Start the app

- `bin/dev` starts everything. The app only works on port 3000. In a worktree, run
  `bin/setup-worktree` first if `node_modules` or `app/assets/builds` is missing.
- If pages return "Page Not Found" or lists are empty, seed the database with
  `bundle exec rails db:prepare` (see `documentation/development/tooling/data.md`).
- Signed-out pages need no sign-in. For publisher or jobseeker pages, find out what works in this
  checkout before trying to sign in: the sign-in flows are in `documentation/service/users/`.
  Don't guess accounts or use real people's details. If you can't sign in, mark every outcome
  that needs it **couldn't check** and say why.

## 4. Check each outcome

For each outcome, load the page in the running app and look at what the user would see.

- Use a browser tool if you have one. Otherwise request the page and read the HTML.
- Try the unhappy paths the plan mentions, such as no results or an invalid form.
- Check the case the plan says must **not** happen, as well as the one that should.

## 5. Report

| Outcome | How checked | Result |
|---|---|---|
| 1. ... | Loaded `/jobs?...` locally and read the page | passed / failed / couldn't check (why) |

Fix every failure and check it again. A passing spec isn't a reason to mark an outcome as passed.

## 6. Say what a person still has to check

Screen reader and keyboard testing, wording and visual design are not things you can verify. List
them for the `how-to-check` skill.

Only push once every outcome has passed or you have explained why it couldn't be checked.
