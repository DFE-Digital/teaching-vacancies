---
name: ucd-principles
description: User-centred design, content and research principles the Teaching Vacancies squad has agreed. Use for any change a jobseeker, publisher or support user will see, including page flows, forms, wording and emails.
---

# User-centred design principles

Owner: design and user research. Last reviewed: 2026-11-25.

This skill grows through AI compounding. See
`documentation/development/ai-mob-sessions.md` for how rules get here.

## How to add or change a rule

- Add a rule only when a decision has come up more than once, in a session or in review.
- Write it as an instruction the agent can follow, with a short reason.
- Keep it public-safe: state the principle, not the evidence behind it. No names, participant
  quotes or unpublished research findings.
- Propose it in an `AI compound:` pull request, reviewed by design or research.
- Remove rules that turn out to be wrong or that nobody uses.

## Baseline

- Use GOV.UK Design System components and patterns, through the `govuk-components` gem and the
  repository's own components in `app/components/` (see
  `documentation/service/technical/components.md`), before building anything custom.
- Follow the GOV.UK style guide for wording. User-facing copy lives in `config/locales/`, never
  inline in views.
- Pages must work without JavaScript. Show JavaScript-only controls with the `.js-action` class
  (see `documentation/service/technical/front-end.md`).

## Agreed rules

None yet.
