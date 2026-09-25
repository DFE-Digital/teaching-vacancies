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

  SimpleCov.configure do # rubocop:disable Metrics/BlockLength
    enable_coverage :branch

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

    # Doesn't render during tests, so has to be excluded from coverage
    skip "app/components/landing_page_group_component.rb"
    skip "app/components/landing_page_link_group_component/landing_page_link_group_component.html.slim"

    # These files appear tp be unreachable and unused
    design_system = %w[index _header _nav_side _nav_top _option_controls]

    design_system.each do |l|
      skip "app/views/design_system/#{l}.html.slim"
    end

    # These don't have tests, and aren't really reachable from a test setup
    skip "app/components/environment_banner_component/environment_banner_component.html.slim"
    skip "app/components/scheduled_maintenance_banner_component/scheduled_maintenance_banner_component.html.slim"

    # Hasn't changed for a long time - doesn't have a test
    skip "app/views/robots/show.text.erb"

    # These might just need to be hang-overs from the Notify clean-up some time ago
    js_mailers = %w[message_mailer/message_received
                    vacancy_mailer/unapplied_saved_vacancy
                    account_mailer/email_changed
                    vacancy_mailer/draft_application_only
                    authentication_fallback_mailer/sign_in_fallback
                    subscription_mailer/jobseeker_missing]

    js_mailers.each do |l|
      skip "app/views/jobseekers/#{l}.text.erb"
    end

    hs_mailers = %w[expired_vacancy_feedback_prompt_mailer/prompt_for_feedback
                    job_application_mailer/applications_received]

    hs_mailers.each do |l|
      skip "app/views/publishers/#{l}.text.erb"
    end

    # These will only render after user has accepted cookies
    cookie_layouts = %w[clarity_head
                        facebook_pixel_body
                        facebook_pixel_head
                        google_tag_manager_body
                        google_tag_manager_head
                        linkedin_pixel_body
                        linkedin_pixel_head
                        reddit_pixel_head
                        vwo_head]

    cookie_layouts.each do |l|
      skip "app/views/layouts/_#{l}.html.slim"
    end

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
    minimum_coverage line: 96.30, branch: 84.11
    # Values from test run 25th September 2026
    # Line Coverage: 96.32% (20678 / 21466) -> 788 lines uncovered
    # Branch Coverage: 84.24% (4212 / 5000) -> 788 branches uncovered
  end
end
