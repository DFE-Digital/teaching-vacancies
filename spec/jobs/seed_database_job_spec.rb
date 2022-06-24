require "rails_helper"

RSpec.describe SeedDatabaseJob do
  let(:rake_task) { instance_double("Rake::Task", clear: nil, clear_comments: nil, enhance: nil) }

  it "executes the importers and seeds the database" do
    expect(Rake::Task).to receive(:[]).at_least(:once).and_return(rake_task)
    expect(rake_task).to receive(:invoke)

    described_class.perform_now
  end
end
