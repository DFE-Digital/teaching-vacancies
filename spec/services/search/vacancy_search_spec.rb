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
  let(:per_page) { 20 }
  let(:page) { 1 }

  let(:scope) { double("scope", total_count: 870) }

  before do
    allow(Vacancy).to receive(:live).and_return(scope)
    allow(scope).to receive(:search_by_location).with("Louth", 10).and_return(scope)
    allow(scope).to receive(:search_by_filter).and_return(scope)
    allow(scope).to receive(:search_by_full_text).with("maths teacher").and_return(scope)
    allow(scope).to receive(:order).with(updated_at: :desc).and_return(scope)

    allow(scope).to receive(:page).with(page).and_return(scope)
    allow(scope).to receive(:per).with(per_page).and_return(scope)
  end

  describe "pagination helpers" do
    let(:scope) { double("scope", total_count: 50) }
    let(:page) { 3 }

    it "returns the expected bounds" do
      expect(subject).not_to be_out_of_bounds

      expect(subject.page_from).to eq(41)
      expect(subject.page_to).to eq(50)
    end

    context "when out of bounds" do
      let(:scope) { double("scope", total_count: 20) }

      it "returns the expected bounds" do
        expect(subject).to be_out_of_bounds

        expect(subject.page_from).to eq(41)
        expect(subject.page_to).to eq(20)
      end
    end
  end

  describe "performing search" do
    it "searches for vacancies" do
      expect(subject.vacancies).to eq(scope)
      expect(subject.total_count).to eq(870)
    end
  end

  describe "wider suggestions" do
    context "when results are returned" do
      let(:scope) { double("scope", empty?: false) }

      it "does not offer suggestions" do
        expect(subject.wider_search_suggestions).to be_nil
      end
    end

    context "when no results are returned" do
      let(:scope) { double("scope", empty?: true) }
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
