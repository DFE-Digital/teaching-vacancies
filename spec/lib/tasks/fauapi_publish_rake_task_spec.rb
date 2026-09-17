require "rails_helper"

RSpec.describe "fauapi:publish" do
  it "publishes the catalogue entry" do
    expect(FindAndUseAnApi::PublishCatalogue).to receive(:call)

    subject.execute # rubocop:disable RSpec/NamedSubject
  end
end
