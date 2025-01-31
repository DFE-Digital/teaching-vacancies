# default to coverage 'off' as it makes no sense
# unless most of the tests are being run
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
  # SimpleCov.formatter = if ENV.key? "CI"
  #                         SimpleCov::Formatter::LcovFormatter
  #                       else
  #                         SimpleCov::Formatter::MergedFormatter
  #                       end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

  SimpleCov.start :rails do
    enable_coverage :branch
    primary_coverage :branch

    # This line would enable template coverage,
    # but slim templates don't seem to work very well
    # enable_coverage_for_eval

    add_filter %r{.rake$}
    add_filter "app/services/custom_log_formatter.rb"
    add_filter "app/controllers/robots_controller.rb"
    add_filter "app/controllers/sha_controller.rb"
    add_filter "app/jobs/set_organisation_slugs_job.rb"
    add_filter "app/mailers/jobseekers/authentication_fallback_mailer.rb"

    add_filter "lib/dfe_sign_in/fake_sign_out_endpoint.rb"
    add_filter "lib/modules/aws_ip_ranges.rb"

    add_group "Components", "app/components"
    add_group "Queries", "app/queries"
    add_group "Services", "app/services"
    add_group "Forms", "app/form_models"
    add_group "Validators", "app/validators"
    add_group "Presenters", "app/presenters"
    add_group "Notifiers", "app/notifiers"

    minimum_coverage line: 93.93, branch: 77.91 unless ENV.key? "CI"
  end
end
