# default to coverage 'off' as it makes no sense
# unless most of the tests are being run
# however setting merge_timeout super-large is a possible option
# e.g. COVERAGE=1 MERGE_TIMEOUT=86400
# merge_timeout just keeps coverage data around a long time
# as it doesn't change very often - would probably need guard support
# for this to be valuable so that only changed files have tests run
if ENV.fetch("COVERAGE", 0).to_i.positive?
  require "simplecov"

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

    # The coverage for this file is flakey, but profiles are going away soon anyway
    # so makes sense to exclude rather than trying to fix
    skip "app/views/jobseekers/profiles/qualified_teacher_status/_summary.html.slim"

    # These files appear to have flakey coverage, so exclude them for now
    skip "app/views/jobseekers/job_applications/_banner.html.slim"
    skip "app/views/jobseekers/job_applications/_job_application_review_sections.html.slim"
    skip "app/views/api/vacancies/_show.json.jbuilder"
    skip "app/views/jobseekers/job_applications/_messages.html.slim"

    skip "app/views/publishers/vacancy_templates/_salary_details.html.slim"
    skip "app/views/support_users/service_data/index.html.slim"

    skip "app/views/posts/index.html.slim"
    skip "app/views/posts/show.html.slim"
    skip "app/views/posts/subcategory.html.slim"

    # This whole page (and controller action) is untested
    skip "app/views/vacancies/campaign_landing_page.html.slim"

    # Each group will be displayed in the report as its own Tab.
    group "Components", "app/components"
    group "Queries", "app/queries"
    group "Services", "app/services"
    group "Forms", "app/form_models"
    group "Validators", "app/validators"
    group "Presenters", "app/presenters"
    group "Notifiers", "app/notifiers"
    group "Tasks", "lib/tasks"
    group "Views", "app/views"

    # All non-covered code lines in this project are now marked with :nocov:
    # markers, so care has to be taken when changing code without coverage information
    # This way any code coverage reduction can be spotted early as these numbers should not change

    minimum_coverage line: 100, branch: 100

    formats :html, :baseline
  end
  # rubocop:enable Metrics/BlockLength
end
