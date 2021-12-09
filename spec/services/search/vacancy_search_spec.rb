require "rails_helper"

RSpec.describe Search::VacancySearch do
  subject { described_class.new(form_hash, sort_by: jobs_sort, page: page, per_page: per_page) }

  let(:form_hash) do
    {
      keyword: keyword,
      location: location,
      radius: radius,
    }.compact
  end

  let(:keyword) { "maths teacher" }
  let(:location) { "Louth" }
  let(:radius) { 10 }
  let(:jobs_sort) { Search::VacancySearchSort::RELEVANCE }
  let(:per_page) { nil }
  let(:page) { 1 }

  before do
    allow(Search::Strategies::PgSearch).to receive(:new).and_return(pg_search)
  end

  describe "pagination helpers" do
    let(:per_page) { 20 }
    let(:page) { 3 }

    let(:pg_search) { double(total_count: 50) }

    it "returns the expected bounds" do
      expect(subject).not_to be_out_of_bounds

      expect(subject.page_from).to eq(41)
      expect(subject.page_to).to eq(50)
    end

    context "when out of bounds" do
      let(:pg_search) { double(total_count: 20) }

      it "returns the expected bounds" do
        expect(subject).to be_out_of_bounds

        expect(subject.page_from).to eq(41)
        expect(subject.page_to).to eq(20)
      end
    end
  end

  describe "performing search" do
    let(:vacancies) { [build_stubbed(:vacancy)] * 3 }
    let(:pg_search) { double(vacancies: vacancies, total_count: 3) }

    before do
      expect(Search::Strategies::PgSearch).to receive(:new).with(
        keyword: "maths teacher",
        location: "Louth",
        radius: 10,
        filters: hash_including(keyword: "maths teacher"),
        page: 1,
        per_page: 20,
        sort_by: Search::VacancySearchSort::RELEVANCE,
      ).and_return(pg_search)
    end

    it "uses the PgSearch strategy" do
      expect(subject.vacancies).to eq(vacancies)
      expect(subject.total_count).to eq(3)
    end
  end

  describe "wider suggestions" do
    context "when results are returned" do
      let(:pg_search) { double(vacancies: [double("vacancy")], total_count: 1) }

      it "does not offer suggestions" do
        expect(subject.wider_search_suggestions).to be_nil
      end
    end

    context "when no results are returned" do
      let(:pg_search) { double(vacancies: [], total_count: 0) }
      let(:suggestions_builder) { double(suggestions: [1, 2, 3]) }

      before do
        allow(Search::WiderSuggestionsBuilder).to receive(:new).and_return(suggestions_builder)
      end

      it "offers suggestions" do
        expect(subject.wider_search_suggestions).to eq([1, 2, 3])
      end
    end
  end
end
