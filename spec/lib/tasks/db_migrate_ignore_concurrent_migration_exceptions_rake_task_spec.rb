require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "db:migrate:ignore_concurrent_migration_exceptions" do
  let(:task_path) { "lib/tasks/migrate_swallowing_concurrent_migration_exceptions" }

  context "with happy path" do
    before { allow(Rake::Task["db:migrate"]).to receive(:invoke) }

    it "invokes db:migrate" do
      subject.execute

      expect(Rake::Task["db:migrate"]).to have_received(:invoke)
    end
  end

  context "with ConcurrentMigrationError" do
    before { allow(Rake::Task["db:migrate"]).to receive(:invoke).and_raise(ActiveRecord::ConcurrentMigrationError) }

    it "swallows ActiveRecord::ConcurrentMigrationError" do
      expect { subject.execute }.not_to raise_error
    end
  end
end
# rubocop:enable RSpec/NamedSubject
