require "rails_helper"

RSpec.describe Jobseekers::SearchResults::PolygonVisualizerComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search, auth: auth) }

  before do
    allow(ENV).to receive(:fetch).with("GOOGLE_MAPS_API_KEY").and_return("123secret")
    allow(vacancies_search).to receive_message_chain(:location_search, :polygon_boundaries).and_return(polygon_boundaries)
    render_inline(subject)
  end

  let(:auth) { true }
  let(:vacancies_search) { instance_double(Search::SearchBuilder) }
  let(:polygon_boundaries) { [[1, 2, 1, 2], [3, 4, 3, 4]] }

  describe "#render?" do
    context "when unauthenticated" do
      context "when auth is not exactly true but is truthy" do
        let(:auth) { "string" }

        it "does not render" do
          expect(rendered_component).to be_blank
        end
      end
    end
  end

  describe "#no_polygons?" do
    context "when there are some polygons involved in the search" do
      it "renders no notification" do
        expect(rendered_component).not_to include(I18n.t("vacancies.index.no_polygons"))
      end
    end

    context "when there are no polygons involved in the search" do
      let(:polygon_boundaries) { nil }

      it "renders the notification" do
        expect(rendered_component).to include(I18n.t("vacancies.index.no_polygons"))
      end
    end
  end

  describe "#polygon_boundaries" do
    context "when there are polygon boundaries to show" do
      it "converts the polygons into the format required by map" do
        expect(subject.polygon_boundaries).to eq(
          [[{ lat: 1, lng: 2 }, { lat: 1, lng: 2 }], [{ lat: 3, lng: 4 }, { lat: 3, lng: 4 }]],
        )
      end
    end

    context "when there are no polygon boundaries to show" do
      let(:polygon_boundaries) { nil }

      it "returns string to tell map to show DfE" do
        expect(subject.polygon_boundaries).to eq("no polygons")
      end
    end
  end
end
