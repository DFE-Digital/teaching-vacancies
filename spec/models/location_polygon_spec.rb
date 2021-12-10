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

  describe ".include?" do
    context "when location is included on the list of locations to import" do
      it "returns true" do
        expect(described_class.include?("London")).to be_truthy
      end
    end

    context "when location is not included on the list of locations to import" do
      it "returns false" do
        expect(described_class.include?("Canterbury")).to be_falsey
      end
    end
  end
end
