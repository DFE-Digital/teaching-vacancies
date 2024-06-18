require "rails_helper"

RSpec.describe Search::Postgres::QueryParser do
  let(:search_configuration) { Rails.application.config.x.search }

  before do
    allow(search_configuration).to receive_messages(synonym_triggers: %w[hello ciao], oneway_synonym_triggers: ["beautiful world"])
  end

  describe "#parse" do
    it "parses search queries into their components" do
      expect(subject.parse("Hello oh beautiful World")).to eq(
        {
          query: [
            { synonym_term: "hello" },
            { plain_term: "oh" },
            { oneway_synonym_term: "beautiful world" },
          ],
        },
      )
    end
  end
end
