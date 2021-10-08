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

  describe ".component_location_names" do
    before do
      stub_const("DOWNCASE_COMPOSITE_LOCATIONS", downcase_composite_locations)
    end

    let(:downcase_composite_locations) do
      { "yorkshire" => ["west yorkshire", "rest of yorkshire"],
        "greater manchester" => ["west manchester", "rest of manchester"] }
    end

    context "when location is a composite location" do
      context "when location is mapped" do
        it "returns the list of component locations" do
          expect(described_class.component_location_names("Manchester")).to eq(["west manchester", "rest of manchester"])
        end
      end

      context "when location is not mapped" do
        it "returns the list of component locations" do
          expect(described_class.component_location_names("Yorkshire")).to eq(["west yorkshire", "rest of yorkshire"])
        end
      end
    end
  end

  describe "#to_algolia_polygons" do
    before do
      subject.area = "POLYGON((0 0, 1 1, 0 1, 0 0))"
    end

    it "returns an Algolia representation of the area field" do
      expect(subject.to_algolia_polygons).to eq([[0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0]])
    end
  end
end
