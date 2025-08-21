require "rails_helper"

RSpec.describe Search::WiderSuggestionsBuilder do
  subject { described_class.new(initial_search) }

  let(:search_params) do
    {
      radius: radius,
      keyword: "test",
      location: location,
      filters: [],
      sort_by: nil,
    }
  end
  let(:radius) { 6 }
  let(:location) { "somewhere" }
  let(:initial_search) { Search::VacancySearch.new(search_params) }
  let(:pg_search) { double("search") }

  before do
    subject
    allow(pg_search).to receive(:total_count).and_return(0, 0, 2, 4, 15, 80, 80)
  end

  describe ".call" do
    let(:suggestions) { described_class.call(initial_search) }

    context "when initial_search is missing the search_criteria[:location] then suggestion search is not allowed" do
      let(:location) { nil }

      it { expect(suggestions).to be_nil }
    end

    context "when initial_search has some results then suggestion search is not allowed" do
      before { allow(initial_search).to receive(:total_count).and_return(1) }

      it { expect(described_class.call(initial_search)).to be_nil }
    end

    context "returns suggestions" do
      let(:expected_suggestions) do
        [
          ["20", 2],
          ["25", 4],
          ["50", 15],
          ["100", 80],
        ]
      end

      before do
        [10, 15, 20, 25, 50, 100, 200].each do |radius|
          allow(initial_search.class)
            .to receive(:new)
                  .with(hash_including(radius:), scope: kind_of(ActiveRecord::Relation))
                  .and_return(pg_search)
        end
      end

      context "when initial_search is a Search::VacancySearch" do
        let(:initial_search) { Search::VacancySearch.new(search_params) }

        it { expect(suggestions).to eq(expected_suggestions) }
      end

      context "when initial_search is a Search::SchoolSearch" do
        let(:initial_search) { Search::SchoolSearch.new(search_params, scope: Organisation.all) }

        it { expect(suggestions).to eq(expected_suggestions) }
      end
    end
  end

  describe "#suggestions" do
    context "given a radius" do
      it "provides radius suggestions beyond the current radius" do
        [10, 15, 20, 25, 50, 100, 200].each do |radius|
          expect(initial_search.class)
            .to receive(:new)
                  .with(hash_including(radius:), scope: kind_of(ActiveRecord::Relation))
                  .and_return(pg_search)
        end

        expect(subject.suggestions).to eq([
          ["20", 2],
          ["25", 4],
          ["50", 15],
          ["100", 80],
        ])
      end
    end
  end
end
