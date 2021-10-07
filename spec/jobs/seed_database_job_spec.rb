require "rails_helper"

RSpec.describe SeedDatabaseJob do
  let(:import_school_data) { instance_double("ImportSchoolData") }
  let(:import_trust_data) { instance_double("ImportTrustData") }
  let(:rake_task) { instance_double("Rake::Task", clear_comments: nil, enhance: nil) }

  it "executes the importers and seeds the database" do
    expect(Gias::ImportSchoolsAndLocalAuthorities).to receive(:new).and_return(import_school_data)
    expect(Gias::ImportTrusts).to receive(:new).and_return(import_trust_data)

    expect(import_school_data).to receive(:call)
    expect(import_trust_data).to receive(:call)

    expect(Rake::Task).to receive(:[]).at_least(:once).and_return(rake_task)
    expect(rake_task).to receive(:invoke)

    described_class.perform_now
  end
end
