require "rails_helper"

RSpec.describe DistanceHelper do
  describe "#convert_miles_to_metres" do
    it "converts miles to metres and returns an integer" do
      expect(helper.convert_miles_to_metres(10)).to eq(16_090)
    end
  end
end
