require "rails_helper"

RSpec.describe Search::VacancyPaginator do
  subject { described_class.new(page, hits_per_page, jobs_sort) }

  let(:page) { 1 }
  let(:hits_per_page) { 2 }
  let(:jobs_sort) { "" }

  describe "#build_order" do
    context "when jobs_sort is blank" do
      it "uses the default order" do
        expect(subject.send(:build_order)).to eq("publish_on DESC")
      end
    end

    context "when jobs_sort is invalid" do
      let(:jobs_sort) { "invalid_sort" }

      it "uses the default order" do
        expect(subject.send(:build_order)).to eq("publish_on DESC")
      end
    end

    context "when jobs_sort is valid" do
      let(:jobs_sort) { "expires_at_desc" }

      it "uses the specified order" do
        expect(subject.send(:build_order)).to eq("expires_at DESC")
      end
    end
  end

  describe "#build_stats" do
    context "when there are no vacancies" do
      it "builds the correct results stats" do
        expect(subject.stats).to eq([0, 0, 0])
      end
    end

    context "when there are vacancies" do
      let!(:vacancies) { create_list(:vacancy, 5, :complete) }
      let!(:draft_vacancies) { create_list(:vacancy, 2, :draft) }

      context "when the page is the first page" do
        it "builds the correct results stats" do
          expect(subject.stats).to eq([1, 2, 5])
        end
      end

      context "when the page is the last page" do
        let(:page) { 3 }

        it "build the correct results stats" do
          expect(subject.stats).to eq([5, 5, 5])
        end
      end

      context "when the page is out of range" do
        let(:page) { 4 }

        it "build the correct results stats" do
          expect(subject.stats).to eq([0, 0, 0])
        end
      end
    end
  end
end
