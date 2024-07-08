require "rails_helper"

RSpec.describe GuidingPagesHelper do
  describe "#format_title" do
    it "capitalizes 'england'" do
      expect(helper.format_title("return-to-teaching-to-england")).to eq("Return to teaching to England")
    end
  end
end
