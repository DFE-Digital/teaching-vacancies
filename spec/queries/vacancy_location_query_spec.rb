require "rails_helper"

RSpec.describe VacancyLocationQuery do
  subject { described_class.new(default_scope) }

  let(:default_scope) { double("ActiveRecord scope") }

  describe "#call" do
    let(:result_scope) { subject.call(location, radius) }

    context "when not given any search location" do
      let(:location) { "" }
      let(:radius) { nil }

      it "returns the default scope" do
        expect(result_scope).to eq(default_scope)
      end
    end

    context "when given a nationwide location" do
      let(:location) { "england" }
      let(:radius) { 100 }

      it "returns the default scope" do
        expect(result_scope).to eq(default_scope)
      end
    end

    context "when given a location that resolves to a LocationPolygon" do
      let(:location) { "Lincolnshire" }
      let(:radius) { 42 }

      let!(:location_polygon) { create(:location_polygon, name: "lincolnshire") }

      let(:join_scope) { double("join scope") }
      let(:where_scope) { double("where scope") }

      before do
        expect(default_scope).to receive(:joins).with(
          /ST_DWithin\(vacancies.geolocation, location_polygons.area, 67578\)/i,
        ).and_return(join_scope)
        expect(join_scope).to receive(:where).with("location_polygons.id = ?", location_polygon.id).and_return(where_scope)
      end

      it "returns a scope for searching within a location polygon" do
        expect(result_scope).to eq(where_scope)
      end
    end

    context "when given a location that resolves to a point" do
      let(:location) { "Louth" }
      let(:radius) { 89 }

      let(:where_scope) { double("where scope") }

      let(:geocoder) { double(Geocoding, coordinates: [-7, 7]) }

      before do
        expect(Geocoding).to receive(:new).with("louth").and_return(geocoder)

        expect(default_scope).to receive(:where).with(
          "ST_DWithin(geolocation, ?, ?)",
          "POINT(7 -7)",
          143_201,
        ).and_return(where_scope)
      end

      it "returns a scope for searching around a point" do
        expect(result_scope).to eq(where_scope)
      end
    end
  end
end
