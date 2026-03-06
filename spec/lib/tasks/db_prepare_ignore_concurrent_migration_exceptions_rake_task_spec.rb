require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "db:prepare:ignore_concurrent_migration_exceptions" do
  include_context "rake"

  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  before do
    Rake::Task.define_task("db:prepare")
  end

  it "invokes db:prepare" do
    allow(Rake::Task["db:prepare"]).to receive(:invoke)

    subject.invoke

    expect(Rake::Task["db:prepare"]).to have_received(:invoke)
  end

  it "swallows ActiveRecord::ConcurrentMigrationError" do
    allow(Rake::Task["db:prepare"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError)

    expect { subject.invoke }.not_to raise_error
  end
end
# rubocop:enable RSpec/NamedSubject
