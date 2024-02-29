require "rake"

module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) { self.class.top_level_description.delete_prefix("rake ") }
    let(:tasks) { Rake::Task }

    subject(:task) { tasks[task_name] }

    after(:each) do
      # Calling a rake task sets their invoked state to "already invoked" and causes further tests for the task to be
      # skipped and tests to fail.
      # Following line allows the task to be called again in the next test.
      task.reenable
    end
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/tasks/}) do |metadata|
    metadata[:type] = :task
  end

  config.include TaskExampleGroup, type: :task

  config.before(:suite) do
    Rails.application.load_tasks
  end
end
