require "rails_helper"

RSpec.describe AddressHelper, type: :helper do
  describe "#address_join" do
    let(:address_lines) { [nil, "", "10", "Downing Street", "Not recorded", "London"] }

    it "omits 'Not recorded' and blank attributes" do
      expect(helper.address_join(address_lines)).to eq("10, Downing Street, London")
    end
  end
end
