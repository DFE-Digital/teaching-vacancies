require "rails_helper"

RSpec.describe Search::BufferSuggestionsBuilder do
  let(:subject) { described_class.new(location, search_params) }

  describe "#get_buffers_suggestions" do
    let(:search_params) do
      {
        hits_per_page: 10,
      }
    end
    let(:location) { "Tower Hamlets" }
    # In this step (2) of the LocationPolygon refactor, the format of buffers will be different
    # before and after running the import task. Before it's a 1D array; after, it's 2D. So I include both
    # formats in this test. This will be reverted in step 3.
    let(:buffer_coordinates_five_miles) { [[5.004562496029994090, 56.50833566307333], [5.005710530794815389, 56.5051084208278]] }
    let(:buffer_coordinates_ten_miles) { [10.004562496029994090, 56.50833566307333, 10.005710530794815389, 56.5051084208278] }
    let(:buffer_coordinates_fifteen_miles) { [15.004562496029994090, 56.50833566307333, 15.005710530794815389, 56.5051084208278] }
    let(:buffer_coordinates_twenty_miles) { [20.004562496029994090, 56.50833566307333, 20.005710530794815389, 56.5051084208278] }
    let(:buffer_coordinates_twenty_five_miles) { [25.004562496029994090, 56.50833566307333, 25.005710530794815389, 56.5051084208278] }
    let(:buffer_hash) do
      {
        "5" => buffer_coordinates_five_miles,
        "10" => buffer_coordinates_ten_miles,
        "15" => buffer_coordinates_fifteen_miles,
        "20" => buffer_coordinates_twenty_miles,
        "25" => buffer_coordinates_twenty_five_miles,
      }
    end
    let(:vacancies1) { double("vacancies") }
    let(:vacancies2) { double("vacancies") }
    let(:vacancies3) { double("vacancies") }
    let(:vacancies4) { double("vacancies") }
    let(:vacancies5) { double("vacancies") }
    let(:arguments_for_algolia) { { hitsPerPage: 10 } }

    before do
      allow(LocationPolygon).to receive_message_chain(:with_name, :buffers).and_return(buffer_hash)
    end

    context "when there is only one vacancy in any of the buffer polygons" do
      before do
        mock_algolia_search(
          vacancies1, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_hash["5"].first])
        )
        mock_algolia_search(
          vacancies2, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_ten_miles])
        )
        mock_algolia_search(
          vacancies3, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_fifteen_miles])
        )
        mock_algolia_search(
          vacancies4, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_miles])
        )
        mock_algolia_search(
          vacancies5, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_five_miles])
        )
      end

      it "suggests the buffer with the smallest radius" do
        expect(subject.buffer_suggestions).to eq([["5", 1]])
      end
    end

    context "when there are vacancies in the wider buffer polygons not found in the smaller polygons" do
      before do
        mock_algolia_search(
          vacancies1, 1, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_hash["5"].first])
        )
        mock_algolia_search(
          vacancies2, 2, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_ten_miles])
        )
        mock_algolia_search(
          vacancies3, 3, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_fifteen_miles])
        )
        mock_algolia_search(
          vacancies4, 4, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_miles])
        )
        mock_algolia_search(
          vacancies5, 5, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_five_miles])
        )
      end

      it "suggests the wider buffer radii as well" do
        expect(subject.buffer_suggestions).to eq([["5", 1], ["10", 2], ["15", 3], ["20", 4], ["25", 5]])
      end
    end

    context "when there are zero vacancies in a buffer polygon" do
      before do
        mock_algolia_search(
          vacancies1, 0, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_hash["5"].first])
        )
        mock_algolia_search(
          vacancies2, 0, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_ten_miles])
        )
        mock_algolia_search(
          vacancies3, 0, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_fifteen_miles])
        )
        mock_algolia_search(
          vacancies4, 0, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_miles])
        )
        mock_algolia_search(
          vacancies5, 5, nil,
          arguments_for_algolia.merge(insidePolygon: [buffer_coordinates_twenty_five_miles])
        )
      end

      it "only returns buffer radii that include vacancies" do
        expect(subject.buffer_suggestions).to eq([["25", 5]])
      end
    end
  end
end
