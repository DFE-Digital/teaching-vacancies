require "rails_helper"

RSpec.describe Search::WiderSuggestionsBuilder do
  subject { described_class.new(search_params) }

  let(:search_params) do
    {
      radius: radius,
      keyword: "test",
      location: "somewhere",
      filters: [],
      page: 1,
      per_page: 5,
      sort_by: nil,
    }
  end

  let(:pg_search) { double("search") }

  describe "#suggestions" do
    context "given a radius" do
      let(:radius) { 6 }

      it "provides radius suggestions beyond the current radius" do
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 10)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 15)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 20)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 25)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 50)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 100)).and_return(pg_search)
        expect(Search::VacancySearch).to receive(:new).with(hash_including(radius: 200)).and_return(pg_search)

        allow(pg_search).to receive(:total_count).and_return(0, 0, 2, 4, 15, 80, 80)

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
