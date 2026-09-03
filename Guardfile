# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}
# directories %w[app config lib spec .]

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# NOTE: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :bundler do
  require "guard/bundler"
  require "guard/bundler/verify"
  helper = Guard::Bundler::Verify.new

  files = %w[Gemfile]
  files += Dir["*.gemspec"] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

RSPEC_OPTIONS = {
  cmd: "bundle exec rspec",
  run_all: {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "'",
  },
}.freeze

JOBSEEKER_SYSTEM_SPEC_MAPPINGS = {
  subscriptions: %w[can_create_a_job_alert_from_a_listing
                    can_create_a_job_alert_from_a_mailing_campaign
                    can_create_a_job_alert_from_a_search
                    can_create_a_job_alert_from_the_dashboard
                    can_manage_their_job_alerts_from_the_dashboard
                    can_unsubscribe_from_subscriptions
                    can_manage_their_job_alerts_from_the_email],
  profiles: %w[can_manage_a_profile
               can_add_professional_status_to_their_profile],
  saved_jobs: %w[can_save_a_job],
  schools: %w[can_search_for_schools can_search_for_colleges],
  jobs: %w[can_search_for_jobs can_search_from_home_page can_view_a_vacancy can_view_all_the_jobs],
  home: %w[can_view_intermediary_landing_pages can_view_job_role_location_landing_pages],
}.freeze

JOBSEEKER_PROFILE_SYSTEM_SPEC_MAPPINGS = {
  about_you: %w[can_add_a_personal_statement],
  job_preferences: %w[can_add_job_preferences_to_their_profile
                      can_manage_job_preferences],
  qualifications: %w[can_add_qualifications],
}.freeze

JOBSEEKER_JOB_APPLICATIONS_SPECS = %w[can_add_declarations_to_their_job_application
                                      can_add_professional_status_to_their_job_application
                                      can_review_a_job_application
                                      can_start_a_job_application
                                      can_submit_a_job_application
                                      can_complete_a_prefilled_job_application
                                      can_complete_a_job_application
                                      can_delete_a_draft_job_application
                                      can_view_a_job_application
                                      can_review_a_job_application
                                      can_edit_a_draft_job_application
                                      can_complete_a_religious_job_application
                                      can_manage_their_job_applications].freeze

JOBSEEKER_JOB_APPLICATION_SYSTEM_SPEC_MAPPINGS = {
  employments: %w[can_add_employments_to_their_job_application],
  professional_body_memberships: %w[can_add_professional_body_membership_to_their_job_application],
  qualifications: %w[can_add_qualifications_to_their_job_application],
  referees: %w[can_add_references_to_their_job_application],
  training_and_cpds: %w[can_add_training_and_cpds_to_their_job_application],
  feedbacks: %w[can_give_application_feedback can_give_job_alert_feedback],
}.freeze

PUBLISHER_JOB_APPLICATION_MAPPINGS = {
  references: %w[can_add_a_manual_reference],
  messages: %w[can_message_multiple_job_candidates can_send_messages_to_applicants can_view_candidate_messages],
  notes: %w[can_add_notes_to_a_job_application],
  online_checks: %w[can_manage_online_checks],
  pre_employment_checks: %w[can_fill_out_pre_employment_checks],
  reference_requests: %w[can_manage_a_reference_request],
  religious_references: %w[can_interview_for_a_religious_vacancy],
  self_disclosure: %w[can_manage_self_disclosure can_send_self_disclosure_reminder],
}.freeze

PUBLISHER_VACANCY_MAPPINGS = {
  activity_log: %w[can_view_vacancy_activity_log],
  application_forms: %w[],
  base: %w[],
  build: %w[],
  bulk_messages: %w[],
  bulk_rejection_messages: %w[],
  bulk_shortlisting_messages: %w[],
  collect_reference_flags: %w[],
  collect_self_disclosure_flags: %w[],
  copy: %w[can_copy_a_vacancy],
  documents: %w[can_publish_a_vacancy_as_a_college],
  end_listing: %w[can_end_a_job_listing_early],
  expired_feedbacks: %w[can_provide_feedback_on_expired_vacancies_via_prompt_email],
  extend_deadline: %w[can_extend_a_deadline],
  feedbacks: %w[],
  form_previews: %w[],
  job_applications: %w[can_reject_a_job_application
                       can_change_status_of_applications
                       can_set_interview_data_and_time
                       can_end_a_job_listing_early],
  publish: %w[can_publish_a_vacancy_as_as_trust
              can_publish_a_vacancy_as_a_local_authority
              can_publish_a_vacancy_as_a_school],
  references_and_self_disclosure_base: %w[can_manage_self_disclosure],
  references_and_self_disclosure: %w[can_manage_self_disclosure],
  relist: %w[],
  statistics: %w[can_view_vacancy_statistics],
  vacancy_review_sections: %w[],
  wizard_base: %w[],
  wizard: %w[],
}.freeze

def system_specs_to_run(controller_name) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  if controller_name == %w[jobseekers job_applications build]
    JOBSEEKER_JOB_APPLICATIONS_SPECS.map do |spec|
      "spec/system/jobseekers/jobseekers_#{spec}_spec.rb"
    end
  elsif controller_name.size > 2 && controller_name.first(2) == %w[jobseekers job_applications]
    JOBSEEKER_JOB_APPLICATION_SYSTEM_SPEC_MAPPINGS.fetch(controller_name.last.to_sym).map do |system_spec|
      "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
    end
  elsif controller_name.size > 2 && controller_name.first(2) == %w[jobseekers profiles]
    JOBSEEKER_PROFILE_SYSTEM_SPEC_MAPPINGS.fetch(controller_name.last.to_sym).map do |system_spec|
      "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
    end
  elsif controller_name.size > 1 && controller_name.first == "jobseekers"
    JOBSEEKER_SYSTEM_SPEC_MAPPINGS.fetch(controller_name.last.to_sym).map do |system_spec|
      "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
    end
  elsif controller_name.size > 3 && controller_name.first(3) == %w[publishers vacancies job_applications]
    # puts "found Controller #{controller_name}"
    PUBLISHER_JOB_APPLICATION_MAPPINGS.fetch(controller_name.last.to_sym).map do |system_spec|
      "spec/system/publishers/publishers_#{system_spec}_spec.rb"
    end
  elsif controller_name.size > 2 && controller_name.first(2) == %w[publishers vacancies]
    PUBLISHER_VACANCY_MAPPINGS.fetch(controller_name.last.to_sym).map do |system_spec|
      "spec/system/publishers/publishers_#{system_spec}_spec.rb"
    end
  end
end

guard :rspec, RSPEC_OPTIONS do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w[yml slim])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) do |m|
    [
      rspec.spec.call("routing/#{m[1]}_routing"),
      rspec.spec.call("requests/#{m[1]}"),
    ]
  end

  watch(rails.view_dirs)       { |m| rspec.spec.call("requests/#{m[1]}") }

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/requests" }

  # Capybara features specs
  watch(rails.controllers) do |m|
    controller_name = m[1].split("/")
    system_specs_to_run(controller_name)
  end

  watch(rails.view_dirs) do |m|
    controller_name = m[1].split("/")
    system_specs_to_run(controller_name)
  end
end

guard :rubocop, cli: %w[-A --no-parallel --no-server], all_on_start: false do
  watch(%r{.+\.rb$})
  watch("Guardfile")
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

# Guard-SlimLint supports a lot of options with default values:
# all_on_start: true        # Check all files at Guard startup. default: true
# slim_dires: ['app/views'] # Check Directories. default: 'app/views' or '.'
# cli: '--no-color' # Additional command line options to slim-lint.
guard :slim_lint, all_on_start: false do
  watch(%r{.+\.html.*\.slim$})
  watch(%r{(?:.+/)?\.slim-lint\.yml$}) { |m| File.dirname(m[0]) }
end

guard :shell do
  watch %r{^app/models/*\.rb$} do
    system "bundle exec database_consistency"
  end
  watch ".database_consistency.yml" do
    system "bundle exec database_consistency"
  end
  watch "db/schema.rb" do
    system "bundle exec database_consistency"
  end
end
