require "rails_helper"

RSpec.describe "fauapi:publish" do
  it "publishes the catalogue entry" do
    # flakey rake specs - can end up calling multiple times during tests
    expect(FindAndUseAnApi::PublishCatalogue).to receive(:call).at_least(:once)

    subject.execute # rubocop:disable RSpec/NamedSubject
  end
end
