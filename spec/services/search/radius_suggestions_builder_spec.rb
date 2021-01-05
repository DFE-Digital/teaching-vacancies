require "rails_helper"

RSpec.describe Search::RadiusSuggestionsBuilder do
  let(:subject) { described_class.new(search_params, radius) }

  describe "#get_radius_suggestions" do
    let(:search_params) do
      {
        keyword: "maths",
        coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
        radius: convert_miles_to_metres(1),
        hits_per_page: 10,
        page: 1,
      }
    end

    let(:arguments_for_algolia) { { aroundLatLng: Geocoder::DEFAULT_STUB_COORDINATES, hitsPerPage: 10, page: 1 } }

    context "when there are 5 wider radii" do
      let(:radius) { "1" }
      let(:vacancies_1) { double("vacancies") }
      let(:vacancies_2) { double("vacancies") }
      let(:vacancies_3) { double("vacancies") }
      let(:vacancies_4) { double("vacancies") }
      let(:vacancies_5) { double("vacancies") }

      before do
        mock_algolia_search(
          vacancies_1, 1, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(5))
        )
        mock_algolia_search(
          vacancies_2, 1, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(10))
        )
        mock_algolia_search(
          vacancies_3, 3, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(15))
        )
        mock_algolia_search(
          vacancies_4, 4, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(20))
        )
        mock_algolia_search(
          vacancies_5, 7, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(25))
        )
      end

      it "sets the correct radius suggestions" do
        expect(subject.radius_suggestions).to eq([[5, 1], [15, 3], [20, 4], [25, 7]])
      end
    end

    context "when there are less than 5 wider radii" do
      let(:radius) { "90" }
      let(:vacancies_1) { double("vacancies") }
      let(:vacancies_2) { double("vacancies") }

      before do
        mock_algolia_search(
          vacancies_1, 5, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(100))
        )
        mock_algolia_search(
          vacancies_2, 9, "maths",
          arguments_for_algolia.merge(aroundRadius: convert_miles_to_metres(200))
        )
      end

      it "sets the correct radius suggestions" do
        expect(subject.radius_suggestions).to eq([[100, 5], [200, 9]])
      end
    end
  end
end
