require "rails_helper"

RSpec.describe Jobseekers::SearchResults::SearchVisualizerComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search, render: true) }

  before do
    allow(ENV).to receive(:fetch).with("GOOGLE_MAPS_API_KEY").and_return("123secret")
    allow(vacancies_search).to receive_message_chain(:location_search, :polygon_boundaries).and_return(polygon_boundaries)
    allow(vacancies_search).to receive(:point_coordinates).and_return(point_coordinates)

    render_inline(subject)
  end

  let(:vacancies_search) { instance_double(Search::SearchBuilder) }
  let(:polygon_boundaries) { [[1, 2, 1, 2], [3, 4, 3, 4]] }
  let(:point_coordinates) { [1, 2] }

  describe "#polygon_boundaries" do
    context "when there are polygon boundaries to show" do
      let(:point_coordinates) { nil }

      it "converts the polygons into the format required by map" do
        expect(subject.polygon_boundaries).to eq(
          [[{ lat: 1, lng: 2 }, { lat: 1, lng: 2 }], [{ lat: 3, lng: 4 }, { lat: 3, lng: 4 }]].to_json,
        )
      end
    end

    context "when there are no polygon boundaries to show" do
      let(:polygon_boundaries) { nil }

      it "returns nil" do
        expect(subject.polygon_boundaries).to be_nil
      end
    end
  end

  describe "#point_coordinates" do
    context "when there are point coordinates to show" do
      let(:polygon_boundaries) { nil }

      it "converts the coordinates into the format required by map" do
        expect(subject.point_coordinates).to eq({ lat: 1, lng: 2 }.to_json)
      end
    end

    context "when there are no point coordinates to show" do
      let(:point_coordinates) { nil }

      it "returns nil" do
        expect(subject.point_coordinates).to be_nil
      end
    end
  end
end
