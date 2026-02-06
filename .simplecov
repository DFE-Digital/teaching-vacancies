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

    # This line would enable template coverage,
    # but slim templates don't seem to work very well
    # enable_coverage_for_eval
    merge_timeout ENV["MERGE_TIMEOUT"].to_i if ENV.key? "MERGE_TIMEOUT"

    # Filters out files from coverage reports
    add_filter "app/services/custom_log_formatter.rb"
    add_filter "app/controllers/robots_controller.rb"
    add_filter "app/controllers/previews_controller.rb"
    add_filter "app/controllers/sha_controller.rb"
    add_filter "app/jobs/set_organisation_slugs_job.rb"

    add_filter "lib/dfe_sign_in/fake_sign_out_endpoint.rb"
    add_filter "lib/modules/aws_ip_ranges.rb"

    # Each group will be displayed in the report as its own Tab.
    add_group "Components", "app/components"
    add_group "Queries", "app/queries"
    add_group "Services", "app/services"
    add_group "Forms", "app/form_models"
    add_group "Validators", "app/validators"
    add_group "Presenters", "app/presenters"
    add_group "Notifiers", "app/notifiers"
    add_group "Tasks", "lib/tasks"

    # These minima seem to be a bit unstable, so they need to be set around
    # .25% lower (branch) and .1% lower (line) than the test run for now
    #
    # possibly the tests are stable now?
    # SD 16/01/26 branch coverage still appears to be ~ .1% unstable
    # 97.47% (12503 / 12828) -> 325  85.57% (2798 / 3270) -> 202 + 270 = 472
    minimum_coverage line: 97.45, branch: 85.56
  end
end
