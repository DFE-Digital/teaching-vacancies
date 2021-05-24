require "rails_helper"

RSpec.describe DatesHelper do
  describe "#format_date" do
    it "returns the date in the default format" do
      expect(helper.format_date(Date.new(2017, 10, 7))).to eq "7 October 2017"
    end

    it "returns the date in the correct format, if one given" do
      expect(helper.format_date(Date.new(2017, 10, 7), :db)).to eq "2017-10-07"
    end

    it "returns if nil date is given" do
      expect(helper.format_date(nil)).to eq "No date given"
    end
  end
end
