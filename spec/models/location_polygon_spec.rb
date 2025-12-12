require "rails_helper"

RSpec.describe LocationPolygon do
  before do
    stub_const("ALL_IMPORTED_LOCATIONS", all_imported_locations)
    stub_const("MAPPED_LOCATIONS", mapped_locations)
  end

  let(:all_imported_locations) { ["London", "East of England", "Camden", "Yorkshire", "Manchester"].map(&:downcase) }
  let(:mapped_locations) { { "manchester" => "greater manchester" } }

  describe ".mapped_name" do
    context "when location is mappable" do
      it "returns the mapped name in downcase" do
        expect(described_class.mapped_name("Manchester")).to eq("greater manchester")
      end
    end

    context "when location is not mappable" do
      it "returns the original name in downcase" do
        expect(described_class.mapped_name("North Southton")).to eq("north southton")
      end
    end
  end

  describe ".contain?" do
    context "when location is contained on the list of locations to import" do
      before { create(:location_polygon, name: "london") }

      it "returns true" do
        expect(described_class.contain?("London")).to be_truthy
      end
    end

    context "when location is not contained on the list of locations to import" do
      it "returns false" do
        expect(described_class.contain?("Canterbury")).to be_falsey
      end
    end
  end

  describe ".find_valid_for_location" do
    it "returns nil when there is no polygon matching the location" do
      expect(described_class.find_valid_for_location("Canterbury")).to be_nil
    end

    context "with a polygon matching the location" do
      let(:area) { instance_double(RGeo::Geographic::SphericalPolygonImpl, invalid_reason: nil) }
      let!(:polygon) { instance_double(described_class, name: "london", uk_area: area) }

      before do
        allow(described_class).to receive(:with_name).with("london").and_return(polygon)
      end

      it "the area of the polygon gets returned if is valid" do
        expect(described_class.find_valid_for_location("london")).to eq(polygon)
      end

      context "when the polygon area has an invalid reason" do
        before do
          allow(area).to receive(:invalid_reason).and_return("Some reason")
        end

        it "doesn't return the polygon" do
          expect(described_class.find_valid_for_location("london")).to be_nil
        end
      end

      context "when the polygon area raises an InvalidGeometry error" do
        before do
          allow(polygon.uk_area).to receive(:invalid_reason).and_raise(RGeo::Error::InvalidGeometry)
        end

        it "doesn't return the polygon" do
          expect(described_class.find_valid_for_location("london")).to be_nil
        end
      end
    end
  end

  describe "#buffered_geometry_area" do
    let!(:polygon) { create(:location_polygon) }

    it "returns a buffered geometry for the polygon with the expected SRID (27700)" do
      buffered = polygon.buffered_geometry_area(1000)

      expect(buffered).to be_present
      expect(buffered).to be_a(RGeo::Cartesian::PolygonImpl)
      expect(buffered).not_to eq(polygon.uk_area)
      expect(buffered.srid).to eq(27_700)
    end

    context "when the area transformation returns no value" do
      before do
        allow(described_class).to receive_message_chain(:where, :pick).and_return(nil) # rubocop:disable RSpec/MessageChain
      end

      it "returns nil" do
        expect(polygon.buffered_geometry_area(1000)).to be_nil
      end
    end

    context "when the area transformation raises an invalid geometry error" do
      before do
        allow(described_class).to receive_message_chain(:where, :pick).and_raise(RGeo::Error::InvalidGeometry) # rubocop:disable RSpec/MessageChain
      end

      it "returns nil" do
        expect(polygon.buffered_geometry_area(1000)).to be_nil
      end
    end
  end
end
