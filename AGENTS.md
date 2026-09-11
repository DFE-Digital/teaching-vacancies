# AGENTS.md

Guidance for AI coding agents working in this repository. It is deliberately vendor-neutral, and
it is the single source of truth — other agent config files point here rather than duplicate it.

## Agent entry points

Different tools look for different filenames. Keep this file authoritative and the others thin.

| Tool | File it reads | How it reaches this file |
| --- | --- | --- |
| OpenAI Codex / ChatGPT | `AGENTS.md` | Reads this file directly — nothing else needed |
| Claude Code | `CLAUDE.md` | Imports it with `@AGENTS.md`; content is inlined at load time |
| Gemini CLI | `GEMINI.md` | Imports it with `@./AGENTS.md`; content is inlined at load time |
| GitHub Copilot | `.github/copilot-instructions.md` | Links here. Copilot has no include mechanism, so the pointer tells it to open this file. The Copilot coding agent also reads a root `AGENTS.md` directly, and VS Code will too with `chat.useAgentsMdFile` enabled |

**No rule is duplicated in those files** — they are pointers, so this file is the only copy to
keep current. Add guidance here, never there.

## Overview

Teaching Vacancies is a free job-listing service from the Department for Education (DfE).
Teachers search and apply for jobs at schools, trusts and colleges in England; hiring staff
list and manage those vacancies.

Ruby 4.0.6, Rails 8.x, PostgreSQL with PostGIS, Redis, Solid Queue.

Two things shape every rule below:

1. **This repository is public and open source.** Assume every line of code, comment, TODO,
   fixture, branch name and commit message is world-readable, permanently.
2. **The service holds substantial personal data.** Jobseeker names, addresses, dates of
   birth, National Insurance numbers, criminal-record self-disclosures and references all pass
   through this codebase. A careless log line or fixture is a real data incident, not a
   style nit.

## Non-negotiables

- **Nothing internal goes in the repo.** No internal-only URLs or hostnames, no credentials,
  no colleague names, no ticket contents pasted into comments or commit messages.
- **Never commit real user data.** Build test data with FactoryBot plus `faker`/`ffaker`. Test
  emails use the `contoso.com` domain (`TEST_EMAIL_DOMAIN` in `spec/rails_helper.rb`).
- **Never force-add a gitignored secret.** `.gitignore` already covers `.env*` (except
  `.env.development` and `.env.test`), `*.pem`, `*.key`, `*.crt`, `serviceAccount.json`,
  `*.sql` and `*dump*`. If `git add` refuses, that is the control working — do not use `-f`.
- **Secrets live outside the repo.** Application secrets are in AWS Systems Manager Parameter
  Store under `/teaching-vacancies/<env>/app/*`; non-secret config is in
  `terraform/workspace-variables/<env>_app_env.yml`. Generate a local `.env` with
  `aws-vault exec ReadOnly -- make -s local print-env > .env`. See
  [secrets detection](documentation/development/tooling/secrets-detection.md) for the
  `git-secrets` pre-commit hook.
- **Any new field holding personal data must be added to
  `config/initializers/filter_parameter_logging.rb`.** This is the single most important
  repo-specific security rule. `config/initializers/sentry.rb` derives its event-scrubbing
  filter from that same list, so an omission leaks the field into both the application logs
  and Sentry.
- **Sensitive columns are encrypted at rest** with Lockbox `has_encrypted` — see
  `app/models/job_application.rb`, `self_disclosure.rb`, `personal_details.rb`, `referee.rb`,
  `job_reference.rb`, `publisher.rb`. Do not add a plaintext column for sensitive data.
- **Do not weaken the security middleware** to make something work:
  `config/initializers/rack_attack.rb`, `content_security_policy.rb`, `recaptcha.rb`,
  `cors.rb`, `permissions_policy.rb`, or CSRF protection. Brakeman must pass.
- **Never record a VCR cassette against a real environment.** Cassettes live in
  `spec/fixtures/vcr`; WebMock runs with `disable_net_connect!`. Check any new cassette for
  personal data and API keys before committing it.
- **Disclose AI assistance.** When an AI coding agent contributes to a commit, record it with a
  `Co-Authored-By:` trailer naming the tool and model, for example
  `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`. This is a public sector project and
  we disclose the tools used to build it.

## Setup and running

The supported setup is the devcontainer in `.devcontainer/`. See
[the quick start guide](documentation/development/setup/quick_start.md).

```bash
bin/dev     # web on :3000, JS watcher, CSS watcher, Solid Queue worker (see Procfile.dev)
bin/jobs    # Solid Queue worker on its own
```

The app is tied to port 3000; no other port works. Outside the devcontainer, run
`corepack enable` first for Yarn 4. Ports in use: 3000 (Rails), 3035 (assets), 5432
(Postgres), 6379 (Redis).

## Commands

### Tests

```bash
bundle exec rspec                                 # all specs
bundle exec rspec spec/models/vacancy_spec.rb:42  # one example
CI=1 bundle exec rake parallel:spec               # parallel; without CI=1, js specs open a browser
RAILS_ENV=test bin/rails parallel:create          # one-off parallel DB setup (tvs_test1, tvs_test2, ...)
COVERAGE=1 bundle exec rspec                      # writes coverage/ and the undercover lcov report
bundle exec undercover                            # fails on new/changed code without coverage
bundle exec rspec --tag a11y                      # accessibility specs (excluded by default)
yarn run js:test                                  # Jest
```

`.rspec` excludes **both** `~smoke_test` and `~a11y`, so neither runs in a normal
`bundle exec rspec`.

### Linting

```bash
bundle exec rake lint                          # rubocop + slim-lint + brakeman
bundle exec rubocop
bundle exec slim-lint app/views app/components
bundle exec brakeman
bundle exec database_consistency                # required CI check; validates model/schema agreement
yarn run js:lint
yarn run sass:lint
```

### Other

```bash
bundle exec rake                               # lint + spec
bundle exec rake rswag:specs:swaggerize        # regenerate the ATS API OpenAPI docs
bin/rails db:migrate:status
```

## Architecture

| Directory | Contents |
| --- | --- |
| `app/services/` | Business logic. Namespaced `jobseekers/`, `publishers/`, `vacancies/`, `search/`, `gias/`. `step_process.rb` drives multi-step wizards |
| `app/queries/` | Complex reads: `VacancyFilterQuery`, `VacancyFullTextSearchQuery`, `VacancyLocationQuery`, `SubscriptionVacanciesMatchingQuery` |
| `app/form_models/` | Non-ActiveRecord form objects, base class `base_form.rb` |
| `app/components/` | ViewComponents on the GOV.UK Design System. Each is `foo_component.rb` plus a sibling `foo_component/foo_component.html.slim` |
| `app/presenters/` | Draper decorators and presenters (naming is mixed, both patterns exist) |
| `app/notifiers/` | In-app notifications via `noticed` v2 |
| `app/jobs/` | Solid Queue jobs |
| `app/validators/`, `app/helpers/`, `app/mailers/` | Custom validators, view helpers, GOV.UK Notify mailers |

### Routing

Controllers mirror the route namespaces in `config/routes.rb`:

- `namespace :jobseekers` → `app/controllers/jobseekers/`
- `namespace :publishers` → publisher account, organisations, messages, statistics
- `scope "/organisation"` → the main publisher vacancy area, controllers under
  `app/controllers/publishers/vacancies/`
- `namespace :support_users, path: "support-users"`
- `namespace :api` with `scope "v:api_version"` → the internal JSON API
- `scope path: "ats-api"` → `publishers/ats_api/v1`, the external Publisher ATS API

Two easy mistakes:

- **`config/routes.rb` ends with lambda-constrained landing-page catch-alls**
  (`CampaignPage.exists?`, `LandingPage.exists?`, `OrganisationLandingPage.exists?`, …). A new
  top-level route added below these will never match. Add it above them.
- **Removing or renaming a public route requires a redirect** in
  `config/routes/legacy_redirects.rb`. These URLs are indexed by search engines.

Engines mounted behind `authenticate :support_user` outside development: `/solid_queue_jobs`
(Mission Control), `/field_test`, `/ats-api-docs` (RSwag).

### Domain model

- **`Vacancy`** — single-table inheritance: `DraftVacancy` and `PublishedVacancy`. There is
  **no `status` enum**; status is derived (`draft?`, `scheduled?`, `live?`, `expired?`). Uses a
  custom `ArrayEnum` extension for `phases`, `job_roles`, `key_stages` and `working_patterns`,
  plus regular enums for `contract_type`, `receive_applications`, `start_date_type` and others.
  FriendlyId slugs with history, Discard for soft deletes, PaperTrail for the activity log.
- **`JobApplication`** — STI: `NativeJobApplication` and `UploadedJobApplication`. `enum :status`
  with 11 values, governed by a hand-rolled `STATUS_TRANSITIONS` map rather than a state
  machine gem. **Adding a status also requires a matching `<status>_at` column** on
  `job_applications`, which `before_save :update_status_timestamp` writes.
- **`Organisation`** — STI: `School` and `SchoolGroup`. Trusts and local authorities are both
  `SchoolGroup`, distinguished by `uid` vs `local_authority_code`. GIAS data lives in a
  `gias_data` JSON column; name search uses `pg_search` over a `searchable_content` tsvector.
- **`Jobseeker` / `JobseekerProfile`** — jobseeker accounts and profiles.
- **`Publisher`** — hiring staff, keyed on the DfE Sign In `oid`, 120-minute session timeout.
- **`Subscription`** — job alerts.

### Authentication

- **Publishers and support users**: DfE Sign In (DSI) via OmniAuth/OIDC.
- **Jobseekers**: GOV.UK One Login via Devise + OmniAuth.

See [DSI integration](documentation/service/users/dsi-integration.md) and
[GOV.UK One Login](documentation/service/users/govuk-one-login.md).

### Background jobs

Solid Queue, backed by PostgreSQL, run with `bin/jobs`. Worker and queue layout in
`config/queue.yml`; scheduled jobs in `config/recurring.yml`. Monitored via Mission Control at
`/solid_queue_jobs`. Emails go out through GOV.UK Notify (`mail-notify`, `NotifyMailer`).

### Feature flags and A/B tests

There is **no Flipper and no `FeatureFlag` model**. Two separate mechanisms:

- **`Flag`** (`lib/flag.rb`) — environment-variable backed, instantiated in
  `config/initializers/flags.rb`: `DisableExpensiveJobs`, `DisableIntegrations`,
  `DisableEmailNotifications`, `AuthenticationFallback`,
  `AuthenticationFallbackForJobseekers`. Values are read once at boot.
- **`field_test`** — A/B experiments defined in `config/field_test.yml`, dashboard at
  `/field_test`.

### Database

PostGIS adapter for location search, UUID primary keys, PaperTrail for audit history, Discard
for soft deletes, Lockbox for field-level encryption, `online_migrations` for safe migrations
against large live tables.

**Migrations are for schema changes only.** Data migrations belong in rake tasks that call a
tested service object or model method — see
[agreed practices](documentation/development/agreed-practices.md).

### External integrations

DfE Sign In, GOV.UK One Login, GOV.UK Notify, GIAS (school data), DWP Find a Job (SFTP export),
DfE Analytics / BigQuery, Google Indexing API, Google Places, Microsoft Defender for Cloud
(upload virus scanning), Sentry, Zendesk, Skylight, and the Publisher ATS API (REST, OpenAPI
via RSwag).

## Code style

- GOV.UK RuboCop. `.rubocop.yml` inherits selected `rubocop-govuk` configs (layout, naming,
  style, rake, rails, rspec) and deliberately **not** `default.yml`, so the metrics cops stay
  on. Existing offences are parked in `.rubocop_todo.yml` — don't add to it.
- Double quotes, trailing commas in multiline literals, no `# frozen_string_literal` comment,
  `is_` predicate prefixes forbidden.
- Custom cop `Custom/RakeTaskInvoke`: use `execute`, not `invoke`, for Rake tasks.
- Views are Slim, not ERB.
- **User-facing copy belongs in `config/locales/`** (53 YAML files, mirroring the controller and
  form namespaces), never inline. Specs frequently click and assert on `I18n.t(...)` values, so
  editing a YAML string changes what the tests match.
- Follow Rails conventions. If you are fighting the framework, you are doing it wrong.

## Testing

### Principles

- Pyramid: system specs for the happy path only; request and view specs for edge cases and
  detailed context.
- Prefer `build_stubbed` and `instance_double` over `double`.
- Favour `describe` / `scenario` over `context` / `it` in system specs.
- Cover every branch you add. Coverage is enforced, not advisory.

### Coverage gates

`.simplecov` sets `minimum_coverage line: 97.94, branch: 89.78`, and CI additionally runs
`undercover` against `origin/main` (`.undercover`) to catch new or changed code without tests.
When raising the threshold, set it 0.02 below the reported figure to absorb rounding. Known
causes of coverage fluctuation: random values in factories, and Ruby logic inside Slim
templates. Adding `#nocov` to pre-existing uncovered code you had to touch is acceptable.

### Factories

- One file per model in `spec/factories/`, plural filenames.
- **Use `factory_rand`, `factory_sample` and `factory_rand_sample`**
  (`spec/factories/support/random_helpers.rb`) instead of `rand` and `sample`. They return the
  minimum or first value under `Rails.env.test?`, which is what keeps coverage stable.
- Factories build STI subclasses: `:vacancy` produces a `PublishedVacancy`, `:job_application`
  a `NativeJobApplication`. Organisation factories are `:school`, `:academy`, `:college`,
  `:school_group`, `:trust`, `:local_authority`.
- Factories are **not test-only** — review-app seeding uses them via `:for_seed_data` traits,
  which is why `factory_bot_rails` and `faker` sit outside the test group in the `Gemfile`.

### Helpers and tags

- Sign-in helpers in `spec/support/auth_helpers.rb`: `login_as(jobseeker, scope: :jobseeker)`,
  `login_publisher(publisher:, organisation:)`, the block forms `run_with_jobseeker` and
  `run_with_publisher_and_organisation`, and the full-UI flows `sign_in_publisher`,
  `sign_in_jobseeker_govuk_one_login`, `sign_in_support_user`.
- Metadata tags that change behaviour: `:vcr`, `:geocode`, `:dfe_analytics`,
  `:perform_enqueued`, `:recaptcha`, `:a11y`, `js: true`, and `disable_email_notifications`,
  `disable_expensive_jobs`, `disable_integrations`.
- **Geocoder is stubbed by default and `Geocoder.search` raises** unless the example is tagged
  `:geocode`.
- System specs default to `rack_test`; `js: true` switches to headless Cuprite; `a11y: true`
  uses Chrome with axe. `CAPYBARA_DRIVER=chrome` gives a headed browser for debugging.
- Page objects use `site_prism`, under `spec/page_objects/`. Also available:
  `shoulda-matchers`, `webmock`, `vcr`, `mock_redis`, `climate_control`, `rspec-rebound`.
- System spec naming: `spec/system/<actor>/<actor>s_can_<action>_spec.rb`.

See [tests and linting](documentation/development/tooling/testing.md) for more.

## Keeping documentation current

Documentation changes belong in the **same pull request** as the change that makes them true,
not a follow-up. The guidance file this one replaced drifted precisely because it was updated
separately, and ended up stating the wrong Ruby version and a model structure that no longer
existed.

**This file quotes specific values that go stale.** If you change one of them, change it here
too:

| If you change | Update |
| --- | --- |
| The Ruby, Rails or Node version | The stack line in **Overview** |
| A rake task, a CI job, or how tests are run | **Commands** here, and `documentation/development/tooling/testing.md` |
| The thresholds in `.simplecov` | The coverage figures quoted in **Testing** |
| A top-level directory under `app/` | The architecture table |
| Route namespaces, or the landing-page catch-alls | **Routing** |
| A model's STI subclasses, enums, or status transitions | **Domain model** |
| A flag in `config/initializers/flags.rb`, or an experiment in `config/field_test.yml` | **Feature flags and A/B tests** |
| An authentication flow | `documentation/service/users/` |
| An external integration | `documentation/service/integrations/` |
| Setup steps, ports, or the devcontainer | `documentation/development/setup/quick_start.md` |
| A practice the team has agreed | `documentation/development/agreed-practices.md` |

Also:

- **A new file under `documentation/` must be linked from the index in `README.md`.** Every
  non-ADR document is currently linked there; keep it that way, or the document is invisible.
  ADRs are a numbered series and are not indexed individually.
- **A significant architectural decision gets an ADR** in `documentation/adr/`, using the next
  number in the sequence.
- **If you find this file wrong, incomplete, or misleading while working, fix it in the same
  PR.** That is expected, not scope creep. Noticing that the guidance is stale and leaving it
  stale is the failure mode to avoid.
- **Rules live only in this file.** `CLAUDE.md`, `GEMINI.md` and
  `.github/copilot-instructions.md` are pointers and carry no guidance of their own — never add
  a rule to them.

## Before you call a task done

Run what CI runs (`.github/workflows/test.yml` and `lint.yml`), so green locally means green
in CI:

```bash
CI=1 bundle exec rake parallel:spec   # or: bundle exec rspec
bundle exec rubocop
bundle exec slim-lint app/views app/components
bundle exec brakeman
bundle exec database_consistency
bundle exec undercover                # after a COVERAGE=1 run
bin/rails db:migrate:status
yarn run js:lint && yarn run sass:lint && yarn run js:test   # if you touched the frontend
```

Then check the documentation: does this change make anything in **Keeping documentation
current** above out of date? If so, update it in this PR.

## Git and pull requests

- Branch off `main`. Short, sentence-case commit subjects; the squash merge appends `(#PR)`.
- Fill in `.github/pull_request_template.md`. **Its data and schema checklist is load-bearing.**
  Changing a `Vacancy` enum, a model validation, or a database field can break DfE Analytics
  event schemas, legacy import mappings, the DWP Find a Job export, the Publisher ATS API
  (which may need versioning), existing subscription alert filters, vacancy copying, and
  in-progress drafts. Surface that impact in the PR rather than changing an enum quietly.
- Avoid Friday deploys where possible.

## Further reading

The full documentation index is in [README.md](README.md). Most useful starting points:

- [Service overview and C4 diagrams](documentation/service/overview.md)
- [Architecture decision records](documentation/adr)
- [Development agreed practices](documentation/development/agreed-practices.md)
- [Tests and linting](documentation/development/tooling/testing.md)
- [Secrets detection](documentation/development/tooling/secrets-detection.md)
- [Our front-end](documentation/service/technical/front-end.md) and
  [view components](documentation/service/technical/components.md)
- [Searching by location](documentation/service/technical/searching-by-location.md)
- [Integrations](documentation/service/integrations/integrations.md) and the
  [Publisher ATS API](documentation/service/integrations/publisher-ats-api.md)
