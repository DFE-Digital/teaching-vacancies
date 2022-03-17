require "rails_helper"

RSpec.describe DatesHelper do
  describe "#format_date" do
    it "returns the date in the default format" do
      expect(helper.format_date(Date.new(2017, 10, 7))).to eq "7 October 2017"
    end

    it "returns the date in the correct format, if one given" do
      expect(helper.format_date(Date.new(2017, 10, 7), :db)).to eq "2017-10-07"
    end

    it "returns 'No date given' if nil date is given" do
      expect(helper.format_date(nil)).to eq "No date given"
    end
  end

  describe "#format_time" do
    it "returns the time in the GDS style format" do
      expect(helper.format_time(DateTime.new(2017, 10, 7, 14, 12))).to eq "2:12pm"
    end

    it "returns the date in the correct format, if one given" do
      expect(helper.format_time(DateTime.new(2017, 10, 7, 14, 12), :db)).to eq "2017-10-07 14:12:00"
    end

    it "returns nil if nil time is given" do
      expect(helper.format_time(nil)).to be_nil
    end
  end

  describe "#format_time_to_datetime_at" do
    it "returns the date in the correct format" do
      expect(helper.format_time_to_datetime_at(DateTime.new(2017, 10, 7, 14, 12))).to eq "7 October 2017 at 2:12pm"
    end

    it "returns nil if nil time is given" do
      expect(helper.format_time_to_datetime_at(nil)).to be_nil
    end
  end

  describe "days_to_apply" do
    context "when the deadline is today" do
      it "displays that the deadline is today" do
        expect(helper.days_to_apply(Date.current)).to eq("Deadline is today")
      end
    end

    context "when the deadline is tomorrow" do
      it "displays that the deadline is tomorrow" do
        expect(helper.days_to_apply(Date.tomorrow)).to eq("Deadline is tomorrow")
      end
    end

    context "with more than 2 days to apply" do
      it "displays a countdown in days" do
        expect(helper.days_to_apply(3.days.from_now.to_date)).to eq("3 days remaining to apply")
      end
    end
  end
end
