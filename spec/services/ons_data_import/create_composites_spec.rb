require "rails_helper"

RSpec.describe OnsDataImport::CreateComposites do
  let!(:somewhereshire) do
    create(:location_polygon, name: "somewhereshire",
                              area: "POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))",
                              uk_area: GeoFactories::FACTORY_27700.parse_wkt("POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))"))
  end
  let!(:elsewhereshire) do
    create(:location_polygon, name: "elsewhereshire",
                              area: "POLYGON((0 0, 0 -1, -1 -1, -1 0, 0 0))",
                              uk_area: GeoFactories::FACTORY_27700.parse_wkt("POLYGON((0 0, 0 -1, -1 -1, -1 0, 0 0))"))
  end

  let(:composite_locations) { { "other realm" => %w[Somewhereshire Elsewhereshire] } }
  let(:other_realm) { LocationPolygon.find_by(name: "other realm") }

  before do
    stub_const("DOWNCASE_COMPOSITE_LOCATIONS", composite_locations)
  end

  describe "#call" do
    it "generates a composite polygon" do
      subject.call

      expect(other_realm.location_type).to eq("composite")
      expect(other_realm.area.coordinates).to contain_exactly(
        contain_exactly(
          contain_exactly([-1.0, -1.0],
                          [-1.0, 0.0],
                          [0.0, 0.0],
                          [0.0, -1.0],
                          [-1.0, -1.0]),
        ),
        contain_exactly(
          contain_exactly([1.0, 1.0],
                          [1.0, 0.0],
                          [0.0, 0.0],
                          [0.0, 1.0],
                          [1.0, 1.0]),
        ),
      )
      expect(other_realm.uk_area.coordinates).to contain_exactly(
        contain_exactly(
          contain_exactly([-1.0, -1.0],
                          [-1.0, 0.0],
                          [0.0, 0.0],
                          [0.0, -1.0],
                          [-1.0, -1.0]),
        ),
        contain_exactly(
          contain_exactly([1.0, 1.0],
                          [1.0, 0.0],
                          [0.0, 0.0],
                          [0.0, 1.0],
                          [1.0, 1.0]),
        ),
      )
    end
  end
end
