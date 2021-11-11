require "rails_helper"

RSpec.describe Search::Postgres::QueryParser do
  describe "#parse" do
    it "parses search queries into their components" do
      expect(subject.parse("Hello World")).to eq(
        {
          query: [
            { plain_term: "hello" },
            { plain_term: "world" },
          ],
        },
      )
    end
  end
end
