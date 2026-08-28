# default to coverage 'off' as it makes no sense
# unless most of the tests are being run
# however setting merge_timeout super-large is a possible option
# e.g. COVERAGE=1 MERGE_TIMEOUT=86400
# merge_timeout just keeps coverage data around a long time
# as it doesn't change very often - would probably need guard support
# for this to be valuable so that only changed files have tests run
if ENV.fetch("COVERAGE", 0).to_i.positive?
  require "simplecov"
  require "undercover/simplecov_formatter"

  # This allows both LCOV and HTML formatting -
  # lcov for undercover gem, HTML for humans
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::Undercover,
      SimpleCov::Formatter::HTMLFormatter,
    ],
  )

  SimpleCov.configure do
    enable_coverage :branch

    # This line would enable coverage for view templates, but the slim compiler
    # appears to have a bug which puts the whole coverage data out by one line.
    # turns out this only works with ERB according to the docs
    # enable_coverage_for_eval

    # This is the 'cache timeout' for coverage files. Setting it high
    # (e.g. to 86400 (1 day) allows confident running of test subsets (using guard)
    # as the coverage data for not-run tests stays valid for that long. The
    # default is 10 minutes which is just long enough to make sure that these don't
    # expire in the middle of a test run.
    merge_timeout ENV["MERGE_TIMEOUT"].to_i if ENV.key? "MERGE_TIMEOUT"

    # Filter out files from coverage reports
    # which are not part of the actual code under test.

    # only used in tests
    skip "lib/dfe_sign_in/fake_sign_out_endpoint.rb"
    # only used in development to preview email layouts
    skip "app/controllers/previews_controller.rb"
    # only really used in review apps - hard to auto-test
    skip "app/mailers/jobseekers/authentication_fallback_mailer.rb"
    # used to format production logs
    skip "app/services/custom_log_formatter.rb"

    # base mailer, currently unused
    skip "app/mailers/amazon_ses_mailer.rb"

    # legacy rake tasks, unlikely to ever be test covered
    skip "lib/tasks/audit.rake"

    # safe replacement for rake db:migrate, never going to be covered by tests
    skip "lib/tasks/migrate_swallowing_concurrent_migration_exceptions.rake"

    # doesn't appear to be used
    skip "app/services/email_event.rb"

    # Each group will be displayed in the report as its own Tab.
    group "Components", "app/components"
    group "Queries", "app/queries"
    group "Services", "app/services"
    group "Forms", "app/form_models"
    group "Validators", "app/validators"
    group "Presenters", "app/presenters"
    group "Notifiers", "app/notifiers"
    group "Tasks", "lib/tasks"

    # Most of the uncovered lines are in very old unchanging code, so chasing more coverage
    # in those areas does not appear to be worth-while

    # However (possibly due to some residual random behaviour in test factories)
    # the line coverage needs to be set 0.02 below the reported value.
    # Nornmally this value needs to be 0.01 below the reported value due to rounding issues.
    minimum_coverage line: 98.00, branch: 89.88
    # Values from test run 28th August 2026
    # Line Coverage: 98.02% (13031 / 13293) -> 262 lines uncovered
    # Branch Coverage: 89.90% (2789 / 3102) -> 211 + 102 = 313 branches uncovered
  end
end
