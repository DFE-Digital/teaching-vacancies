require "rails_helper"

RSpec.describe Vacancies::Import::Parser::StartDate do
  describe "#new" do
    it "doesnt't parse a null value" do
      start_date = described_class.new(nil)
      expect(start_date).to have_attributes(input: nil, type: nil, date: nil)
    end

    it "doesnt't parse an empty string" do
      start_date = described_class.new("")
      expect(start_date).to have_attributes(input: "", type: nil, date: nil)
    end

    it "doesnt't parse an empty string with spaces" do
      start_date = described_class.new("   ")
      expect(start_date).to have_attributes(input: "   ", type: nil, date: nil)
    end

    exact_dates = ["04-09-2023", "4-9-23", "04-09-23", "4-09-2023", "04-9-2023", " 04-09-2023 ",
                   "04/09/2023", "04/09/23", "4/9/23", " 04/09/2023 ",
                   "04.09.2023", "4.9.2023", "4.9.23", " 04.09.2023 ",
                   "2023-09-04", "23-9-4", "23-09-04", "2023-09-4", "2023-9-04", " 2023-09-04 ",
                   "2023/09/04", "23/09/04", "23/9/4", " 2023/09/04 ",
                   "2023.09.04", "2023.9.4", "23.9.4", " 2023.09.04 ",
                   "2023-09-04T00:00:00", "2023-09-04 T00:00:00", "2023-09-04 00:00:00",
                   "04-09-2023T00:00:00", "04-09-2023 T00:00:00", "04-09-2023 00:00:00"]

    exact_dates.each do |date|
      it "parses '#{date}' as type 'specific_date' with value '2023-09-04'" do
        start_date = described_class.new(date)
        expect(start_date).to have_attributes(input: date, type: "specific_date", date: "2023-09-04")
      end
    end

    freetext_dates = ["TBC", "ASAP", "Immediate", "Flexible", "Flexible start date", "Flexible start date - ASAP",
                      "1st September 2023 / As soon as possible", "30th October 2023", "September 2023",
                      "1st January 2024", "September 2023 or January 2024", "Sept 2023",
                      "2023-09-04 or later", "From 2023-09-04", "2023/09/04 onwards",
                      "2023-09-04T00:00:00 and next day", "From 2023-09-04T00:00:00"]

    freetext_dates.each do |date|
      it "parses '#{date}' as type 'other' without modifying the given date" do
        start_date = described_class.new(date)
        expect(start_date).to have_attributes(input: date, type: "other", date: date)
      end
    end
  end

  describe "#specific?" do
    it "returns true when the start date is a specific date" do
      expect(described_class.new("04-09-2023")).to be_specific
    end

    it "returns false when the start date is a freetext" do
      expect(described_class.new("ASAP")).not_to be_specific
    end

    it "returns false when there is no start date" do
      expect(described_class.new(nil)).not_to be_specific
    end
  end
end
