require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "db:prepare:ignore_concurrent_migration_exceptions" do
  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  before do
    Rake::Task["db:prepare"].clear if Rake::Task.task_defined?("db:prepare")
    Rake::Task.define_task("db:prepare")
  end

  after do
    Rake::Task["db:prepare"].clear if Rake::Task.task_defined?("db:prepare")
  end

  it "invokes db:prepare" do
    expect(Rake::Task["db:prepare"]).to receive(:invoke)

    subject.execute
  end

  it "swallows ActiveRecord::ConcurrentMigrationError" do
    allow(Rake::Task["db:prepare"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError)

    expect { subject.execute }.not_to raise_error
  end
end
# rubocop:enable RSpec/NamedSubject
