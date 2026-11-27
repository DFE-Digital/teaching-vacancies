---
name: accessibility-review
description: Accessibility rules and checks the Teaching Vacancies squad has agreed. Use when adding or changing views, components, forms, styles or front-end JavaScript, and before showing a user-facing change to the team.
---

# Accessibility review

Maintained by developers, with designers. Last reviewed: 2026-11-27.

This skill grows through AI compounding. See
`documentation/development/ai-mob-sessions.md` for how rules get here.

## How to add or change a rule

- Add a rule when it is knowledge the agent should apply next time.
- Write it as an instruction the agent can follow, with a short reason.
- Keep it public-safe: no names, participant quotes or unpublished research findings.
- Propose it in an `AI compound:` pull request.
- Remove rules that turn out to be wrong or that nobody uses.

## Baseline

- The service must meet WCAG 2.2 AA. GOV.UK Design System components already handle most of
  this, so prefer them to custom markup.
- Accessibility specs are tagged `a11y: true` and run with axe in Chrome:
  `bundle exec rspec --tag a11y`. Add or extend one for new user-facing pages.
- An agent's own check is not an accessibility review. Say what you checked and what still needs
  a person, such as screen reader and keyboard testing.

## Agreed rules

None yet.
