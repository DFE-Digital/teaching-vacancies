require "rails_helper"

RSpec.describe Search::AlgoliaSearchRequest do
  let(:subject) { described_class.new(search_params) }

  describe "#build_stats" do
    let(:search_params) { {} }
    let(:page) { 0 }
    let(:pages) { 6 }
    let(:results_per_page) { 10 }
    let(:total_results) { 57 }

    it "returns the correct array" do
      expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eq([1, 10, 57])
    end

    context "when there are no results" do
      let(:total_results) { 0 }

      it "returns the correct array" do
        expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eq([0, 0, 0])
      end
    end

    context "when on the last page of results" do
      let(:page) { 5 }

      it "returns the correct array" do
        expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eq([51, 57, 57])
      end
    end
  end

  describe "#search" do
    let(:vacancies) { double("vacancies") }

    let(:search_params) do
      {
        keyword: "maths",
        coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
        radius: convert_miles_to_metres(10),
        hits_per_page: 10,
        page: 1,
      }
    end

    let(:arguments_to_algolia) do
      {
        aroundLatLng: Geocoder::DEFAULT_STUB_COORDINATES,
        aroundRadius: convert_miles_to_metres(10),
        hitsPerPage: 10,
        page: 1,
      }
    end

    before { mock_algolia_search(vacancies, 1, "maths", arguments_to_algolia) }

    it "carries out search with the correct parameters" do
      expect(subject.vacancies).to eq(vacancies)
    end
  end
end
