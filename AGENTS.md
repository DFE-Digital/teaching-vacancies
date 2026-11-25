# AGENTS.md

The single source of truth for project rules for AI coding agents. Tool-specific files
(`CLAUDE.md`, `.github/copilot-instructions.md`) point here and may only describe
their own tool's configuration. Agent hooks live in `.claude/hooks/` and are configured in
`.claude/settings.json` for Claude Code and `.github/hooks/agent-hooks.json` for GitHub Copilot.

## Overview

Teaching Vacancies is a free DfE job-listing service: teachers search and apply for jobs at
schools, trusts and colleges in England; hiring staff list and manage vacancies.

Ruby 4.0.10, Rails 8.x, PostgreSQL with PostGIS, Solid Queue, Redis (production cache only).

Two things shape every rule below:

1. **This repository is public.** Every line of code, comment, TODO, fixture, branch name and
   commit message is world-readable, permanently.
2. **The service holds substantial personal data** (names, addresses, dates of birth, National
   Insurance numbers, criminal-record self-disclosures, references). A careless log line or
   fixture is a real data incident.

## Non-negotiables

- **Nothing internal in the repo:** no internal-only URLs or hostnames, credentials, colleague
  names, or pasted ticket contents in code, comments or commit messages.
- **Never commit real user data.** Use FactoryBot with `faker`/`ffaker`; test emails use
  `contoso.com` (`TEST_EMAIL_DOMAIN` in `spec/rails_helper.rb`).
- **Never force-add (`git add -f`) a gitignored file.** If `git add` refuses, that is the control
  working.
- **Secrets live outside the repo**, in AWS Systems Manager Parameter Store under
  `/teaching-vacancies/<env>/app/*`; non-secret config is in
  `terraform/workspace-variables/<env>_app_env.yml`. Generate a local `.env` with
  `aws-vault exec ReadOnly -- make -s local print-env > .env`. See
  [secrets detection](documentation/development/tooling/secrets-detection.md).
- **Any new field holding personal data must be added to
  `config/initializers/filter_parameter_logging.rb`.** This is the most important repo-specific
  security rule: `config/initializers/sentry.rb` builds its scrubbing filter from the same list,
  so an omission leaks into both logs and Sentry.
- **Encrypt sensitive columns at rest** with Lockbox `has_encrypted` (as in
  `app/models/job_application.rb`). Never add a plaintext column for sensitive data.
- **Do not weaken security middleware** (`config/initializers/rack_attack.rb`,
  `content_security_policy.rb`, `recaptcha.rb`, `cors.rb`, `permissions_policy.rb`) or CSRF
  protection. Brakeman must pass.
- **Never record a VCR cassette against a real environment.** Check new cassettes in
  `spec/fixtures/vcr` for personal data and API keys.
- **Disclose AI assistance** on every commit an agent contributes to. A tool's automatic
  co-author trailer (e.g. Copilot's) satisfies this; otherwise add one naming tool and model,
  e.g. `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`.

## Setup

See [the quick start guide](documentation/development/setup/quick_start.md). `bin/dev` starts
the dockerised database (via `bin/dev-db`; skip with `SKIP_DEV_DB=1`), web, asset watchers and
the Solid Queue worker. The app only works on port 3000. Outside the devcontainer, run
`corepack enable` first (Yarn 4).

In a git worktree (the Copilot app creates one per session), run `bin/setup-worktree` first if
`node_modules` or `app/assets/builds` is missing; specs and `bin/dev` fail without them.

## Commands

```bash
bundle exec rspec                         # all specs; .rspec excludes ~smoke_test and ~a11y
bundle exec rspec --tag a11y              # accessibility specs
CI=1 bundle exec rake parallel:spec       # parallel; HEADED=1 shows the browser for js specs
RAILS_ENV=test bin/rails parallel:create  # one-off parallel DB setup
COVERAGE=1 bundle exec rspec && bundle exec simplecov patch --base origin/main --minimum 100  # fails on new/changed code without coverage
bundle exec rake rswag:specs:swaggerize   # on a fresh clone and after ATS API changes (specs read the git-ignored swagger/v1/swagger.yaml)
bundle exec rake lint                     # rubocop + slim-lint + brakeman
bundle exec database_consistency          # required CI check: model/schema agreement
yarn run js:lint && yarn run sass:lint && yarn run js:test  # frontend
```

**Before calling a task done**, run what CI runs (`.github/workflows/test.yml` and `lint.yml`):
the specs, `rake lint`, `database_consistency`, `simplecov patch` and `bin/rails db:migrate:status`,
plus the frontend commands if you touched the frontend.

## Where code goes

Business logic in `app/services/` (namespaced; `step_process.rb` drives multi-step wizards),
complex reads in `app/queries/`, non-ActiveRecord forms in `app/form_models/` (`base_form.rb`),
ViewComponents in `app/components/`, Draper decorators and presenters in `app/presenters/`,
in-app notifications (`noticed`) in `app/notifiers/`, Solid Queue jobs in `app/jobs/`.
Publishers and support users sign in with DfE Sign In; jobseekers with GOV.UK One Login.

## Pitfalls

- **Routes:** `config/routes.rb` ends with lambda-constrained landing-page catch-alls
  (`LandingPage.exists?`, …); add new top-level routes above them or they never match.
  **Removing or renaming a public route requires a redirect** in
  `config/routes/legacy_redirects.rb`.
- **`Vacancy`** is STI (`DraftVacancy`, `PublishedVacancy`) with **no `status` enum**; status is
  derived (`draft?`, `scheduled?`, `live?`, `expired?`). Array-valued fields use a custom
  `ArrayEnum` extension.
- **`JobApplication`** is STI (`NativeJobApplication`, `UploadedJobApplication`); `enum :status`
  transitions follow a hand-rolled `STATUS_TRANSITIONS` map. **A new status needs a matching
  `<status>_at` column**, written by `before_save :update_status_timestamp`.
- **`Organisation`** is STI (`School`, `SchoolGroup`); trusts and local authorities are both
  `SchoolGroup`, distinguished by `uid` vs `local_authority_code`.
- **Feature flags:** no Flipper and no `FeatureFlag` model. `Flag` (`lib/flag.rb`,
  `config/initializers/flags.rb`) is env-var backed and read once at boot; A/B tests use
  `field_test` (`config/field_test.yml`).
- **Migrations are for schema changes only.** Data migrations belong in rake tasks calling a
  tested service object or model method. Use `online_migrations` patterns for large tables.

## Code style

- GOV.UK RuboCop without its `default.yml`, so metrics cops stay on. Don't add to
  `.rubocop_todo.yml`.
- Double quotes, trailing commas in multiline literals, no `# frozen_string_literal`, no `is_`
  predicate prefixes. Use `execute`, not `invoke`, for Rake tasks (`Custom/RakeTaskInvoke`).
- Views are Slim, not ERB. Components are `foo_component.rb` plus
  `foo_component/foo_component.html.slim`.
- **User-facing copy belongs in `config/locales/`**, never inline. Specs assert on `I18n.t(...)`,
  so editing a YAML string changes what tests match.
- Don't restructure existing code when extending it; discuss refactors first unless asked.

## Testing

- System specs cover the happy path only; use request and view specs for edge cases. Name them
  `spec/system/<actor>/<actor>s_can_<action>_spec.rb` and prefer `describe` / `scenario`.
- Prefer `build_stubbed` and `instance_double` over `double`.
- Cover every branch you add: CI runs `simplecov patch` against `origin/main`. Never add
  `#simplecov:disable`.
- **In factories, use `factory_rand`, `factory_sample` and `factory_rand_sample`**
  (`spec/factories/support/random_helpers.rb`), not `rand`/`sample`, to keep coverage stable.
  Factories also seed review apps via `:for_seed_data` traits, so they are not test-only.
- `:vacancy` builds a `PublishedVacancy`; `:job_application` builds a `NativeJobApplication`.
- Sign-in helpers are in `spec/support/auth_helpers.rb`; behaviour-changing metadata tags
  (`:geocode`, `:perform_enqueued`, `disable_integrations`, …) are in `spec/rails_helper.rb`.
- **`Geocoder.search` raises** unless the example is tagged `:geocode`.
- WebMock blocks real HTTP (`disable_net_connect!`).
- System specs use `rack_test`; `js: true` switches to Cuprite and
  `a11y: true` to Chrome with axe; both run headless unless `HEADED=1` is set for debugging.

More in [tests and linting](documentation/development/tooling/testing.md).

## Skills and AI compounding

Shared agent skills live in `.claude/skills/`, which Claude Code and most Copilot surfaces read. They hold
knowledge an agent should load only when relevant: the AI mob session protocol, design,
accessibility and other discipline rules. Universal rules stay in this file. See
[AI mob sessions](documentation/development/ai-mob-sessions.md).

- Change a skill only in a separate pull request titled `AI compound: <summary>`, reviewed by
  the owner named in the skill. Never change one as part of feature work.
- Every rule must be safe to publish: no names, internal URLs, colleague or participant quotes,
  or unpublished research.

## Keeping documentation current

Update docs in the **same PR** as the change that makes them true. If you change the Ruby or Rails
version, a command, a pitfall above, or the setup, update this file. If you find this file wrong
or stale, fix it in the same PR. Also update:

- commands or CI → `documentation/development/tooling/testing.md`
- setup, ports, devcontainer or `compose.yaml` → `documentation/development/setup/quick_start.md`
- an authentication flow → `documentation/service/users/`
- an external integration → `documentation/service/integrations/`

- A new file under `documentation/` must be linked from the index in [README.md](README.md).
- Significant architectural decisions get the next numbered ADR in `documentation/adr/`.
- Team practices live in [agreed practices](documentation/development/agreed-practices.md).

## Git and pull requests

- Branch off `main`. Short, sentence-case commit subjects.
- Create PRs as drafts (`gh pr create --draft`); only the developer marks them ready. Keep the
  description to a short what/why.
- **Complete the data and schema checklist** in `.github/pull_request_template.md`. Changing a
  `Vacancy` enum, validation or database field can break DfE Analytics schemas, legacy imports,
  the DWP Find a Job export, the Publisher ATS API (which may need versioning), subscription
  alert filters, vacancy copying and in-progress drafts.
- Avoid Friday deploys where possible.
