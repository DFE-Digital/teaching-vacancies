require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "db:migrate:ignore_concurrent_migration_exceptions" do
  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  before do
    Rake::Task.define_task("db:migrate")
  end

  it "invokes db:migrate" do
    allow(Rake::Task["db:migrate"]).to receive(:invoke)

    subject.execute

    expect(Rake::Task["db:migrate"]).to have_received(:invoke)
  end

  it "swallows ActiveRecord::ConcurrentMigrationError" do
    allow(Rake::Task["db:migrate"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError)

    expect { subject.execute }.not_to raise_error
  end
end
# rubocop:enable RSpec/NamedSubject
