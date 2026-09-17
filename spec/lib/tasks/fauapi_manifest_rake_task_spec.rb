require "rails_helper"

RSpec.describe "fauapi:manifest" do
  it "prints the manifest as JSON" do
    allow(FindAndUseAnApi::BuildManifest).to receive(:call).and_return({ name: "teaching-vacancies-ats-api" })

    expect { subject.execute }.to output(/"name": "teaching-vacancies-ats-api"/).to_stdout # rubocop:disable RSpec/NamedSubject
  end
end
