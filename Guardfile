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
                    can_manage_their_job_alerts_from_the_email],
  profiles: %w[can_manage_a_profile],
}.freeze

JOBSEEKER_PROFILE_SYSTEM_SPEC_MAPPINGS = {
  about_you: %w[can_add_a_personal_statement],
  job_preferences: %w[can_add_job_preferences_to_their_profile can_manage_job_preferences],
}.freeze

JOBSEEKER_JOB_APPLICATIONS_SPECS = %w[can_add_declarations_to_their_job_application
                                      can_review_a_job_application
                                      can_manage_their_job_applications].freeze

JOBSEEKER_JOB_APPLICATION_SYSTEM_SPEC_MAPPINGS = {
  employments: %w[can_add_employments],
}.freeze

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
    system_spec_name = m[1].split("/")
    if system_spec_name == %w[jobseekers job_applications build]
      JOBSEEKER_JOB_APPLICATIONS_SPECS.map do |spec|
        "spec/system/jobseekers/jobseekers_#{spec}_spec.rb"
      end
    elsif system_spec_name.size > 2 && system_spec_name.first(2) == %w[jobseekers job_applications]
      JOBSEEKER_JOB_APPLICATION_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_to_their_job_application_spec.rb"
      end
    elsif system_spec_name.size > 2 && system_spec_name.first(2) == %w[jobseekers profiles]
      JOBSEEKER_PROFILE_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
      end
    elsif system_spec_name.size > 1 && system_spec_name.first == "jobseekers"
      JOBSEEKER_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
      end
    end
  end

  watch(rails.view_dirs) do |m|
    system_spec_name = m[1].split("/")
    if system_spec_name == %w[jobseekers job_applications build]
      JOBSEEKER_JOB_APPLICATIONS_SPECS.map do |spec|
        "spec/system/jobseekers/jobseekers_#{spec}_spec.rb"
      end
    elsif system_spec_name.size > 2 && system_spec_name.first(2) == %w[jobseekers job_applications]
      JOBSEEKER_JOB_APPLICATION_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_to_their_job_application_spec.rb"
      end
    elsif system_spec_name.size > 2 && system_spec_name.first(2) == %w[jobseekers profiles]
      JOBSEEKER_PROFILE_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
      end
    elsif system_spec_name.size > 1 && system_spec_name.first == "jobseekers"
      JOBSEEKER_SYSTEM_SPEC_MAPPINGS.fetch(system_spec_name.last.to_sym).map do |system_spec|
        "spec/system/jobseekers/jobseekers_#{system_spec}_spec.rb"
      end
    end
  end
end

guard :rubocop, cli: ["-A", "--no-parallel", "--no-server"], all_on_start: false do
  watch(%r{.+\.rb$})
  watch("Guardfile")
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

# Guard-SlimLint supports a lot options with default values:
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
