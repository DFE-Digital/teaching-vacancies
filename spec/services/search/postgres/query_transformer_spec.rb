require "rails_helper"

RSpec.describe Search::Postgres::QueryTransformer do
  let(:search_configuration) { Rails.application.config.x.search }

  before do
    allow(search_configuration).to receive(:synonyms).and_return([%w[mondo welt world]])
    allow(search_configuration).to receive(:oneway_synonyms)
      .and_return({ "how are you" => ["come sta"] })
  end

  describe "#apply" do
    let(:tree) do
      {
        query: [
          { plain_term: "hello" },
          { synonym_term: "world" },
          { oneway_synonym_term: "how are you" },
        ],
      }
    end

    it "produces the expected Arel" do
      expected_sql = "(plainto_tsquery('simple', 'hello') && " \
                     "(phraseto_tsquery('simple', 'mondo') || " \
                     "phraseto_tsquery('simple', 'welt') || " \
                     "phraseto_tsquery('simple', 'world')) && " \
                     "(phraseto_tsquery('simple', 'how are you') || " \
                     "phraseto_tsquery('simple', 'come sta')))"

      expect(subject.apply(tree).to_sql).to eq(expected_sql)
    end
  end
end
