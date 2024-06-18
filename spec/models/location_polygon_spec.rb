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
        expect(described_class).to be_contain("London")
      end
    end

    context "when location is not contained on the list of locations to import" do
      it "returns false" do
        expect(described_class).not_to be_contain("Canterbury")
      end
    end
  end
end
