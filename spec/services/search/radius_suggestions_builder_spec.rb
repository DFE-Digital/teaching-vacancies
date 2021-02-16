require "rails_helper"

RSpec.describe Search::RadiusSuggestionsBuilder do
  subject { described_class.new(radius, search_params) }

  describe "#get_radius_suggestions" do
    let(:search_params) do
      {
        keyword: "maths",
        coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
        radius: convert_miles_to_metres(1),
        per_page: 10,
        page: 1,
      }
    end

    let(:arguments_for_algolia) { { aroundLatLng: Geocoder::DEFAULT_STUB_COORDINATES, hitsPerPage: 10, page: 1 } }

    before do
      search_hits.zip(wider_radii).each do |search_hits_count, radius_option|
        mock_algolia_search(
          double("vacancies", none?: false), search_hits_count, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(radius_option))
        )
      end
    end

    context "when there are 5 wider radii" do
      let(:radius) { "1" }
      let(:wider_radii) { [5, 10, 15, 20, 25] }
      let(:search_hits) { [1, 1, 3, 4, 7] }

      it "sets the correct radius suggestions" do
        expect(subject.radius_suggestions).to eq([[5, 1], [15, 3], [20, 4], [25, 7]])
      end
    end

    context "when there are fewer than 5 wider radii" do
      let(:radius) { "90" }
      let(:wider_radii) { [100, 200] }
      let(:search_hits) { [5, 9] }

      it "sets the correct radius suggestions" do
        expect(subject.radius_suggestions).to eq([[100, 5], [200, 9]])
      end
    end
  end
end
