require "rails_helper"

RSpec.describe OnsDataImport::CreateComposites do
  let!(:somewhereshire) { create(:location_polygon, name: "somewhereshire", area: "POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))") }
  let!(:elsewhereshire) { create(:location_polygon, name: "elsewhereshire", area: "POLYGON((0 0, 0 -1, -1 -1, -1 0, 0 0))") }

  let(:composite_locations) { { "other realm" => %w[Somewhereshire Elsewhereshire] } }
  let(:other_realm) { LocationPolygon.find_by(name: "other realm") }

  before do
    stub_const("DOWNCASE_COMPOSITE_LOCATIONS", composite_locations)
  end

  describe "#call" do
    it "generates a composite polygon" do
      subject.call

      expect(other_realm.location_type).to eq("composite")
      expect(other_realm.area.coordinates.sort.flatten).to eq([
        0.0, -1.0,
        -1.0, -1.0,
        -1.0, 0.0,
        0.0, 0.0,
        0.0, -1.0,
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
        0.0, 1.0
      ])
    end
  end
end
