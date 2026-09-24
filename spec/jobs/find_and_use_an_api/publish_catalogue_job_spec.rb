require "rails_helper"

RSpec.describe FindAndUseAnApi::PublishCatalogueJob do
  subject(:job) { described_class.perform_later }

  it "calls FindAndUseAnApi::PublishCatalogue" do
    expect(FindAndUseAnApi::PublishCatalogue).to receive(:call)

    perform_enqueued_jobs { job }
  end
end
