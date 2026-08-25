require "rails_helper"

RSpec.describe "ons:create_composites" do
  let(:task_path) { "lib/tasks/data" }

  # rubocop:disable RSpec/NamedSubject
  it "calls create composites" do
    allow(OnsDataImport::CreateComposites).to receive(:call)
    subject.execute
    expect(OnsDataImport::CreateComposites).to have_received(:call).at_least(:once)
  end
  # rubocop:enable RSpec/NamedSubject
end
