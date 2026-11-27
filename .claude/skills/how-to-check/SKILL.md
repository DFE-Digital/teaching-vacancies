---
name: how-to-check
description: Write plain-language steps that let a non-developer test a change in the review app. Use when a change is ready for people to try, such as the end of an AI mob session or before asking design, product or research to look at a pull request.
---

# How to check this

Maintained by developers, with input from product and design. Last reviewed: 2026-11-27.

The readers are product, design, research and accessibility colleagues who don't write code. They
need to know where to go, what to do and what they should see, in words they'd use themselves.

Write it after `verify-against-plan`, so you know what actually works. Post it in the chat and in
the "How to check this" section of the pull request description.

## Template

```
**What changed**
One or two sentences about what a jobseeker, publisher or support user can now do or see.

**Before you start**
- Review app: <link from the pull request's sticky comment, or "still building, check again in a few minutes">
- Sign in with your own work email. A sign-in link comes by email from GOV.UK Notify. Publishers
  and jobseekers sign in separately, so say which one each step needs.
- Use <the school, search or example that shows the change>.

**Steps**
1. Go to <page or link>.
2. Do <action>.
   You should see <result>.
3. ...

**Decisions made, and why**
- <decision>: <reason>

**What we couldn't check**
- <for example: screen reader and keyboard testing, wording, visual design>
```

## Rules

- No code terms: say "the search results page", not a route or a class name.
- Follow the GOV.UK style guide for wording.
- Each step has one action and one thing to look for. Include the unhappy path if the plan covers
  one, for example a search with no results.
- Give a real link or page name for every step.
- Say plainly what you couldn't check, and ask for it by name.
- The review app takes a while to build the first time and updates quickly after that.
- Never put real people's names, emails or personal data in the steps or in examples.
