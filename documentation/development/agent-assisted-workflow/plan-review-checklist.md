# Plan review checklist

Use this when reviewing a plan in the private doc tool, before any code is built. It should take
about 15 minutes. Comment on anything that fails, and approve in the doc when it all passes.

## Decisions (second engineer)

- [ ] The decisions answer the problem as stated.
- [ ] The alternatives and the reasons for rejecting them are explicit.
- [ ] There are no decisions the agent made that nobody agreed: no open `> proposed:` lines.
- [ ] It follows the conventions in `AGENTS.md`, or says why not.

## Success criteria (product owner; design and content when user-facing)

- [ ] The criteria describe what users need, in plain language.
- [ ] Copy that users will see is agreed, or the plan says who agrees it.
- [ ] Nothing important is missing, and the out-of-scope list is right.

## Test scenarios (second engineer)

- [ ] Every criterion has at least one scenario, and every scenario belongs to a criterion.
- [ ] Each scenario would fail if the behaviour were missing or wrong.
- [ ] The spec types are right: system specs for the happy path, request or view specs for edge
      cases, accessibility for new or changed pages.

## Slices and risk (second engineer)

- [ ] Two to five thin, vertical slices, each with a Verify command and a "done when".
- [ ] Risks are named: personal data, analytics, migrations, routes, feature flags,
      accessibility, and the pull request's data and schema checklist.
- [ ] The plan fits in about 1.5 pages. If not, split the ticket.

## Public safety

- [ ] Nothing that will become code, spec names, commits or the pull request contains ticket
      wording, names, internal links or unannounced policy.
- [ ] It is not a security fix. Those follow the private security process.
