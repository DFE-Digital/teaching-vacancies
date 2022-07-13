require "rails_helper"

RSpec.describe Search::VacancySearch do
  subject { described_class.new(form_hash, sort: sort) }

  let(:form_hash) do
    {
      keyword: keyword,
      location: location,
      radius: radius,
      organisation_slug: organisation_slug,
    }.compact
  end

  let(:keyword) { "maths teacher" }
  let(:location) { "Louth" }
  let(:radius) { 10 }
  let(:sort) { Search::VacancySort.new(keyword: keyword) }
  let(:organisation_slug) { "test-slug" }
  let(:vacancy_ids) { ["test-id"] }

  let(:school) { create(:school) }

  let(:scope) { double("scope", count: 870) }

  before do
    allow(subject).to receive(:organisation).and_return(school)
    allow(school).to receive_message_chain(:all_vacancies, :pluck).and_return(vacancy_ids)
    allow(Vacancy).to receive(:live).and_return(scope)
    allow(scope).to receive(:includes).with(:organisations).and_return(scope)
    allow(scope).to receive(:search_by_location).with("Louth", 10).and_return(scope)
    allow(scope).to receive(:search_by_filter).and_return(scope)
    allow(scope).to receive(:search_by_full_text).with("maths teacher").and_return(scope)
    allow(scope).to receive(:where).with(id: vacancy_ids).and_return(scope)
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
