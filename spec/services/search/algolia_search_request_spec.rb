require "rails_helper"

RSpec.describe Search::AlgoliaSearchRequest do
  let(:subject) { described_class.new(search_params) }

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

  before { mock_algolia_search(vacancies, 42, "maths", arguments_to_algolia) }

  describe "#total_count" do
    it "returns the total count from Algolia" do
      expect(subject.total_count).to eq(42)
    end
  end

  describe "#search" do
    it "carries out search with the correct parameters" do
      expect(subject.vacancies).to eq(vacancies)
    end
  end
end
