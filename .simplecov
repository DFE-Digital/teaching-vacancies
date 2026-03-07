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

  untested_tasks = %w[audit data migrate_swallowing_concurrent_migration_exceptions]
  untested_jobs = %w[reset_sessions set_organisation_slugs refresh_organisations_gias_data_hash remove_google_index_queue update_google_index_queue send_weekly_alert_email]

  # rubocop:disable Metrics/BlockLength
  SimpleCov.start :rails do
    enable_coverage :branch

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

    # none of these files seem to have tests at all - but they don't change and seem to work
    untested_tasks.each do |task|
      add_filter "lib/tasks/#{task}.rake"
    end

    untested_jobs.each do |task|
      add_filter "app_jobs/#{task}_job.rb"
    end

    add_filter "app/services/email_event.rb"
    add_filter "app/components/landing_page_link_component.rb"
    add_filter "app/services/publishers/dfe_sign_in/big_query_export/users.rb"
    add_filter "app/services/publishers/dfe_sign_in/big_query_export/approvers.rb"
    add_filter "app/controllers/publishers/organisations/schools_controller.rb"
    add_filter "app/controllers/sha_controller.rb"
    add_filter "app/controllers/publishers/vacancies/publish_controller.rb"
    add_filter "app/models/support_user.rb"
    add_filter "app/form_models/publishers/job_listing/documents_confirmation_form.rb"
    add_filter "app/controllers/support_users/sessions_controller.rb"

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
    # Normally this value needs to be 0.01 below the reported value due to rounding issues.
    minimum_coverage line: 98.51, branch: 88.49
    # Values from test run Fri 6th March 2026
    # 97.23% (12692 / 13053) -> 308 + 53 = 361 lines uncovered
    # 87.25% (2821 / 3233) -> 179 + 233 = 412 branches uncovered
  end
  # rubocop:enable Metrics/BlockLength
end
