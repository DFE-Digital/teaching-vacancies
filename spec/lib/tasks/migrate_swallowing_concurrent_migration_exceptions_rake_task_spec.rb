require "rails_helper"

RSpec.describe "db:migrate:ignore_concurrent_migration_exceptions" do
  include_context "rake"

  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  it "invokes db:migrate and swallows concurrent migration errors" do
    allow(Rake::Task["db:migrate"]).to receive(:invoke)

    subject.invoke

    expect(Rake::Task["db:migrate"]).to have_received(:invoke)
  end

  it "swallows ActiveRecord::ConcurrentMigrationError" do
    allow(Rake::Task["db:migrate"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError)

    expect { subject.invoke }.not_to raise_error
  end
end

RSpec.describe "db:prepare:ignore_concurrent_migration_exceptions" do
  include_context "rake"

  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  it "invokes db:prepare and swallows concurrent migration errors" do
    allow(Rake::Task["db:prepare"]).to receive(:invoke)

    subject.invoke

    expect(Rake::Task["db:prepare"]).to have_received(:invoke)
  end

  it "swallows ActiveRecord::ConcurrentMigrationError" do
    allow(Rake::Task["db:prepare"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError)

    expect { subject.invoke }.not_to raise_error
  end
end
