
# Tests and linting

The Rails application uses [RSpec](https://rspec.info) and [RuboCop](https://rubocop.org) for
testing and linting, as well as [Brakeman](https://brakemanscanner.org) for security scanning and
[Slim-Lint](https://github.com/sds/slim-lint) to lint Slim templates.

```bash
# Run tests and linting
bundle exec rake

# Run tests only
bundle exec rspec

# Run linters only
bundle exec rails lint
```

The frontend Javascript code uses [Jest](https://jestjs.io) and [ESLint](https://eslint.org/) for
testing and linting (using [Airbnb rules](https://www.npmjs.com/package/eslint-config-airbnb)), as
well as [Stylelint](https://stylelint.io/) for SASS linting (with the default ruleset):

```bash
# Run tests and linting
yarn test

# Run tests only
yarn run js:test

# Generate a coverage report
yarn run js:test:coverage

# Run JS linter only
yarn run js:lint

# Run SASS linter only
yarn run sass:lint
```

## RSpec parallel testing
The service include [parallel_tests](https://github.com/grosser/parallel_tests) gem, that allows to split the RSpec test
suite run accross multiple CPU cores.

Each group will run against a separate database.
To set it up:

```
RAILS_ENV=test rails parallel:create
```

To run the test suite in parallel:

```
RAILS_ENV=test rake parallel:spec
```

or
```
RAILS_ENV=test rails parallel:spec
```

or using Spring binstub:
```
parallel_rspec
```

## RSpec test coverage reports
We use [Simplecov](https://github.com/simplecov-ruby/simplecov) and [Undercover](https://github.com/grodowski/undercover) gems for measuring and enforcing our test coverage.

The configuration and minimum coverage requirements are set on the [.simplecov file](/.simplecov)

### How to generate coverage reports locally?

Set `COVERAGE=1` in your environment or as a prefix the full rspec run.

EG: `COVERAGE=1 rspec`

After running the full test suite, the coverage report should be available at the project's `/coverage/index.html` path.

### Finding code coverage on the PR runs

The code coverage is generated as an artifact on the projects Github PR check `test -> Run RSpec Tests in parallel -> Upload coverage report`

When the step is expanded, there is a link to download it as:
`Artifact download URL: https://github.com/DFE-Digital/teaching-vacancies/actions/runs/111111111/artifacts/22222222`

The link will download a `ZIP` file containing the coverage report for the PR tests run.

### Undercover alerts

Once having a coverage report generated, undercover can be used to alert us about code that we added or changed without test coverage.

This happens automatically in the PRs `test -> Run RSpec Tests in parallel` workflow. But can also be run locally invoking the `undercover` command.
