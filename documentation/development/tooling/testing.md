
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

## Visual regression testing

The visual layout and appearance of defined scenarios (pages and common content) can be tested using [BackstopJS](https://github.com/garris/BackstopJS)

This works by testing snapshot images in a branch or environment against accepted baseline/reference snapshot images. Tests are run across 3 viewports - mobile, tablet and desktop. Also if abtest variants are added to `config/ab_test.yml` then the corresponding page will be tested with each variant.

This is currently a tool for developers to test changes locally against the QA environment. Running the test suite will create and load a UI in the browser to report on and for you to compare visual changes.

### Setup

Install the backstopjs library as a global dependency

`npm install -g backstopjs@6.1.0`

Add the following variables to your local `.env` file:

```bash
VISUAL_TEST_JOBSEEKER_USERNAME=xxx
VISUAL_TEST_JOBSEEKER_PASSWORD=xxx
VISUAL_TEST_PUBLISHER_USERNAME=xxx
VISUAL_TEST_PUBLISHER_PASSWORD=xxx
```

### Usage

If you have never run tests before, ensure you have created an `backstop/lib/.tmp` folder for authentication tokens. (TODO could do with automating)

```bash
# Create reference snapshot images
yarn run visual:test:init

# Run test suite to compare your changes to reference snapshots
yarn run visual:test:run

# approve changes
yarn run visual:test:approve

This will approve changes to create new baseline snapshots and clear your file system of snapshots created by previous test suite runs.
```
