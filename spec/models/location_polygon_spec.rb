require "rails_helper"

RSpec.describe LocationPolygon, type: :model do
  before do
    stub_const("MAPPED_LOCATIONS", mapped_locations)
    LocationPolygon.create(name: "london")
  end

  let(:mapped_locations) { { "the big smoke" => "London" } }

  describe ".with_name?" do
    it "translates the user-input name into the name of our LocationPolygon and retrieves that record" do
      expect(described_class.with_name("the big smoke").name).to eq("london")
    end

    context "when the search query has a preceding or trailing whitespace" do
      it "strips the whitespace before retrieving the requested record" do
        expect(described_class.with_name(" the big smoke ").name).to eq("london")
      end
    end
  end
end
