# default to coverage 'off' as it makes no sense
# unless most of the tests are being run
# however setting merge_timeout super-large is a possible option
# e.g. COVERAGE=1 MERGE_TIMEOUT=86400
# merge_timeout just keeps coverage data around a long time
# as it doesn't change very often - would probably need guard support
# for this to be valuable so that only changed files have tests run
if ENV.fetch("COVERAGE", 0).to_i.positive?
  require "simplecov"
  require "simplecov-lcov"

  # This allows both LCOV and HTML formatting -
  # lcov for undercover gem, HTML for humans
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::LcovFormatter.new.format(result)
    end
  end

  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

  SimpleCov.start :rails do
    enable_coverage :branch
    primary_coverage :branch

    # This line would enable coverage for view templates, but the slim compiler
    # appears to have a bug which puts the whole coverage data out by one line.
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
    add_filter "lib/dfe_sign_in/fake_sign_out_endpoint.rb"
    # only used in development to preview email layouts
    add_filter "app/controllers/previews_controller.rb"
    # only really used in review apps - hard to auto-test
    add_filter "app/mailers/jobseekers/authentication_fallback_mailer.rb"
    # used to format production logs
    add_filter "app/services/custom_log_formatter.rb"

    # base mailer, currently unused
    add_filter "app/mailers/amazon_ses_mailer.rb"

    # Each group will be displayed in the report as its own Tab.
    add_group "Components", "app/components"
    add_group "Queries", "app/queries"
    add_group "Services", "app/services"
    add_group "Forms", "app/form_models"
    add_group "Validators", "app/validators"
    add_group "Presenters", "app/presenters"
    add_group "Notifiers", "app/notifiers"
    add_group "Tasks", "lib/tasks"

    # Most of the uncovered lines are in very old unchanging code, so chasing more coverage
    # in those areas does not appear to be worth-while

    # However (possibly due to some residual random behaviour in test factories)
    # the line coverage needs to be set 0.02 below the reported value.
    # Nornmally this value needs to be 0.01 below the reported value due to rounding issues.
    minimum_coverage line: 97.44, branch: 87.01
    # Values from test run Fri 13th February 2026
    # 97.46% (12553 / 12880) -> 327 lines uncovered
    # 87.18% (2808 / 3221) -> 192 + 221 = 411 branches uncovered
  end
end
