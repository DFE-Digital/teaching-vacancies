# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  require "slim_lint/rake_task"
  SlimLint::RakeTask.new

  task(lint: :environment).prerequisites.unshift :slim_lint
end
