require "rails_helper"

RSpec.describe Search::BufferSuggestionsBuilder do
  let(:subject) { described_class.new(location, search_params) }

  describe "#get_buffers_suggestions" do
    let(:search_params) do
      {
        hits_per_page: 10,
      }
    end
    let(:buffer_coordinates_five_miles) { [[5.004562496029994090, 56.50833566307333], [5.005710530794815389, 56.5051084208278]] }
    let(:buffer_coordinates_ten_miles) { [[10.004562496029994090, 56.50833566307333], [10.005710530794815389, 56.5051084208278]] }
    let(:buffer_coordinates_fifteen_miles) { [[15.004562496029994090, 56.50833566307333], [15.005710530794815389, 56.5051084208278]] }
    let(:buffer_coordinates_twenty_miles) { [[20.004562496029994090, 56.50833566307333], [20.005710530794815389, 56.5051084208278]] }
    let(:buffer_coordinates_twenty_five_miles) { [[25.004562496029994090, 56.50833566307333], [25.005710530794815389, 56.5051084208278]] }
    let(:all_buffer_coordinates) do
      [buffer_coordinates_five_miles, buffer_coordinates_ten_miles, buffer_coordinates_fifteen_miles, buffer_coordinates_twenty_miles, buffer_coordinates_twenty_five_miles]
    end
    let(:buffer_hash) { ImportPolygons::BUFFER_DISTANCES_IN_MILES.map(&:to_s).zip(all_buffer_coordinates).to_h }
    let(:arguments_for_algolia) { { hitsPerPage: 10 } }

    context "when searching in a location that corresponds to a polygon" do
      let(:location) { "Tower Hamlets" }

      before do
        allow(LocationPolygon).to receive_message_chain(:with_name, :buffers).and_return(buffer_hash)
        search_hits.zip(all_buffer_coordinates).each do |search_hits_count, buffered_polygons|
          mock_algolia_search(
            double("vacancies"), search_hits_count, nil,
            arguments_for_algolia.merge(insidePolygon: buffered_polygons)
          )
        end
      end

      context "when there is only one vacancy in any of the buffer polygons" do
        let(:search_hits) { [1, 1, 1, 1, 1] }

        it "suggests the buffer with the smallest radius" do
          expect(subject.buffer_suggestions).to eq([["5", 1]])
        end
      end

      context "when there are vacancies in the wider buffer polygons not found in the smaller polygons" do
        let(:search_hits) { [1, 2, 3, 4, 5] }

        it "suggests the wider buffer radii as well" do
          expect(subject.buffer_suggestions).to eq([["5", 1], ["10", 2], ["15", 3], ["20", 4], ["25", 5]])
        end
      end

      context "when there are zero vacancies in a buffer polygon" do
        let(:search_hits) { [0, 0, 0, 0, 5] }

        it "only returns buffer radii that include vacancies" do
          expect(subject.buffer_suggestions).to eq([["25", 5]])
        end
      end
    end

    context "when searching in a composite location" do
      let(:location) { "Bedfordshire" }
      let(:districts) { ["Bedford", "Central Bedfordshire", "Luton"] }
      let(:search_hits) { [0, 1, 1, 2, 3] }

      before do
        districts.each do |name|
          create(:location_polygon, name: name.downcase, location_type: "counties", buffers: buffer_hash)
        end

        search_hits.zip(all_buffer_coordinates).each do |search_hits_count, buffered_polygons|
          buffer_coordinates_for_all_districts = []
          districts.length.times { buffered_polygons.each { |polygon| buffer_coordinates_for_all_districts.push(polygon) } }
          mock_algolia_search(
            double("vacancies"), search_hits_count, nil,
            arguments_for_algolia.merge(insidePolygon: buffer_coordinates_for_all_districts)
          )
        end
      end

      it "returns the appropriate buffer suggestions" do
        expect(subject.buffer_suggestions).to eq([["10", 1], ["20", 2], ["25", 3]])
      end
    end
  end
end
