require "rails_helper"

RSpec.describe Search::KeywordFilterGeneration::QueryParser do
  before do
    allow(Rails.application.config.x.search).to receive(:keyword_filter_mapping_triggers)
      .and_return(%w[foo bar baz])

    allow(Rails.application.config.x.search).to receive(:keyword_filter_mappings)
      .and_return({
        "foo" => { phases: ["sixth_form_or_college"] },
        "bar" => { subjects: ["French"] },
        "baz" => { job_roles: %w[headteacher sendco] },
      })
  end

  describe ".filters_from_query" do
    it "turns a query into filters" do
      expect(described_class.filters_from_query("baz bar quux"))
        .to eq({ job_roles: %w[headteacher sendco], subjects: %w[French] })
    end
  end
end
