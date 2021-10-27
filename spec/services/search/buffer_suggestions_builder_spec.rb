require "rails_helper"

RSpec.describe Search::BufferSuggestionsBuilder do
  subject { described_class.new(location, search_params) }

  describe "#get_buffers_suggestions" do
    let(:search_params) do
      {
        per_page: 10,
      }
    end
    let(:arguments_for_algolia) { { hitsPerPage: 10 } }

    context "when searching in a location that corresponds to a polygon" do
      let(:location) { "Tower Hamlets" }
      let!(:polygon) { create(:location_polygon, name: "tower hamlets") }

      before do
        RADIUS_OPTIONS.each_with_index do |radius, idx|
          buffered_polygon = LocationPolygon.buffered(radius).with_name(location)

          mock_algolia_search(
            double("vacancies", none?: false), search_hits[idx], nil,
            arguments_for_algolia.merge(insidePolygon: buffered_polygon.to_algolia_polygons)
          )
        end
      end

      context "when there is only one vacancy in any of the buffer polygons" do
        let(:search_hits) { [1, 1, 1, 1, 1, 1, 1] }

        it "suggests the buffer with the smallest radius" do
          expect(subject.buffer_suggestions).to eq([["1", 1]])
        end
      end

      context "when there are vacancies in the wider buffer polygons not found in the smaller polygons" do
        let(:search_hits) { [1, 2, 3, 4, 5, 6, 7] }

        it "suggests the wider buffer radii as well" do
          expect(subject.buffer_suggestions).to eq([["1", 1], ["5", 2], ["10", 3], ["25", 4], ["50", 5], ["100", 6], ["200", 7]])
        end
      end

      context "when there are zero vacancies in a buffer polygon" do
        let(:search_hits) { [0, 0, 0, 0, 0, 0, 5] }

        it "only returns buffer radii that include vacancies" do
          expect(subject.buffer_suggestions).to eq([["200", 5]])
        end
      end
    end
  end
end
