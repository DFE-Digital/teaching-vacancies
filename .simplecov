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

  untested_tasks = %w[audit
                      data
                      migrate_swallowing_concurrent_migration_exceptions
                      populate_organisation_slug_history
                      discard_invalid_subscriptions
                      migrate_legacy_job_preferences]
  untested_jobs = %w[reset_sessions
                     set_organisation_slugs_of_batch
                     set_organisation_slugs
                     refresh_organisations_gias_data_hash
                     remove_google_index_queue
                     update_google_index_queue
                     send_weekly_alert_email]

  # rubocop:disable Metrics/BlockLength
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

    #  Deprecated non-API vacancy importers
    skip "app/services/vacancies/import/sources/fusion.rb"
    skip "app/services/vacancies/import/sources/broadbean.rb"
    skip "app/services/vacancies/import/sources/ventrus.rb"
    skip "app/services/vacancies/import/sources/vacancy_poster.rb"

    # none of these files seem to have tests at all - but they don't change and seem to work
    untested_tasks.each do |task|
      skip "lib/tasks/#{task}.rake"
    end

    untested_jobs.each do |task|
      skip "app/jobs/#{task}_job.rb"
    end

    #  These files appear to have no coverage at all - are they unused?
    skip "app/services/email_event.rb"
    skip "app/components/landing_page_link_component.rb"
    skip "app/controllers/publishers/organisations/schools_controller.rb"
    skip "app/controllers/sha_controller.rb"

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

    # All non-covered code lines in this project are now marked with :nocov:
    # markers, so care has to be taken when changing code without coverage information
    # This way any code coverage reduction can be spotted early as these numbers should not change

    minimum_coverage line: 100, branch: 100
  end
  # rubocop:enable Metrics/BlockLength
end
