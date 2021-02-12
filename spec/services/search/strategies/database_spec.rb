require "rails_helper"

RSpec.describe Search::Strategies::Database do
  subject { described_class.new(page, per_page, jobs_sort) }

  let(:page) { 1 }
  let(:per_page) { 2 }
  let(:jobs_sort) { Search::VacancySearchSort::PUBLISH_ON_DESC }

  describe "#total_count" do
    context "when there are no vacancies" do
      it "returns 0" do
        expect(subject.total_count).to be_zero
      end
    end

    context "when there are vacancies" do
      let!(:vacancies) { create_list(:vacancy, 5, :complete) }
      let!(:draft_vacancies) { create_list(:vacancy, 2, :draft) }

      it "returns the correct count" do
        expect(subject.total_count).to eq(5)
      end
    end
  end
end
