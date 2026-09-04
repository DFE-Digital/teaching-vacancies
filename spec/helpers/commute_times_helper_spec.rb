require "rails_helper"

RSpec.describe CommuteTimesHelper do
  describe "#commute_time_duration" do
    it "formats durations shorter than an hour" do
      expect(helper.commute_time_duration(26)).to eq("26 minutes")
    end

    it "formats whole hours" do
      expect(helper.commute_time_duration(60)).to eq("1 hour")
    end

    it "formats hours and minutes" do
      expect(helper.commute_time_duration(95)).to eq("1 hour 35 minutes")
    end
  end
end
