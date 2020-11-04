require "rails_helper"

RSpec.describe DatesHelper, type: :helper do
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

    it "raises an error if an invalid format is given" do
      expect { helper.format_date(Date.new(2017, 10, 7), :invalid) }.to raise_error(DatesHelper::FormatDateError)
    end
  end

  describe "#compose_expiry_time" do
    it "returns nil if any of the fields are blank" do
      time_attr = {
        day: 10,
        month: 10,
        year: 2012,
        hour: 12,
        min: 12,
        meridiem: "",
      }
      expect(helper.compose_expiry_time(time_attr)).to eq nil
    end

    it "creates a date time from of the attributes" do
      expected_date_time = Time.zone.parse("7-10-2017 12:12 pm")
      time_attr = {
        day: 7,
        month: 10,
        year: 2017,
        hour: 12,
        min: 12,
        meridiem: "pm",
      }
      expect(helper.compose_expiry_time(time_attr)).to eq(expected_date_time)
    end
  end

  describe "#format_datetime_with_seconds" do
    it "returns nil if string is nil" do
      expect(helper.format_datetime_with_seconds(nil)).to eq(nil)
    end

    it "formats a date to d Month YYYY HH:MM:SS" do
      string_date = "2019-06-19T15:09:58.683Z"
      expected_date_time = "19 June 2019 16:09:58"
      expect(helper.format_datetime_with_seconds(string_date)).to eq(expected_date_time)
    end
  end
end
