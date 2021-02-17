# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative "config/application"
Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  desc "Run Rubocop"
  task :rubocop do
    sh "bundle exec rubocop"
  end

  desc "Run Slim Lint"
  task :slim_lint do
    sh "bundle exec slim-lint app/views app/components"
  end

  desc "Run Brakeman"
  task :brakeman do
    # CI env var makes Brakeman not put its output in a pager
    sh "CI=true bundle exec brakeman"
  end

  desc "Run all linters"
  task lint: %i[rubocop slim_lint brakeman]

  desc "Run all linters and specs"
  task default: %i[lint spec]
end
