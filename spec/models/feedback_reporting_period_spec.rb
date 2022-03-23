require "rails_helper"

RSpec.describe FeedbackReportingPeriod do
  let!(:oldest_feedback) { create(:feedback, created_at: "2022-01-09") } # Sunday
  let!(:newest_feedback) { create(:feedback, created_at: "2022-03-23") } # Wednesday

  describe ".all" do
    subject(:all_periods) { described_class.all }

    it "returns inclusive two-week periods from the oldest to the newest feedback, starting on Tuesdays and ending on Mondays" do
      expect(all_periods.first)
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(all_periods.last).to eq(described_class.for(Date.today))
      expect(all_periods.count).to eq(((all_periods.first.from...all_periods.last.from).count / 7) + 1)
    end
  end

  describe ".new(from:, to:)" do
    it "accepts a date, a datetime, a time or a string for its values" do
      expect(described_class.new(from: "2022-01-04", to: Date.new(2022, 1, 10)))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(described_class.new(from: Date.new(2022, 1, 4), to: DateTime.new(2022, 1, 10, 13, 5, 3)))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))
    end
  end

  describe ".for(date)" do
    it "returns a two-week Tueday-starting range that includes the given date" do
      expect(described_class.for("2022-01-09"))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))
    end

    it "accepts a date, a datetime, a time or a string for its values" do
      expect(described_class.for("2022-01-09"))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(described_class.for(Date.new(2022, 1, 9)))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(described_class.for(DateTime.new(2022, 1, 9, 10, 3)))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(described_class.for(Time.new(2022, 1, 9, 10, 3)))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))
    end
  end

  describe "equality" do
    it "treats equal ranges as equal" do
      expect(described_class.new(from: "2022-01-04", to: "2022-01-10"))
        .to eq(described_class.new(from: "2022-01-04", to: "2022-01-10"))

      expect(described_class.new(from: "2022-01-04", to: "2022-01-10"))
        .not_to eq(described_class.new(from: "2022-01-04", to: "2025-05-05"))
    end

    it "treats older start dates as older ranges" do
      expect(described_class.new(from: "2022-01-04", to: "2022-01-10"))
        .to be < described_class.new(from: "2022-01-05", to: "2022-01-11")
    end
  end

  describe "#to_s" do
    it "renders the range visually" do
      expect(described_class.new(from: "2022-01-04", to: "2022-01-10").to_s)
        .to eq("2022-01-04 -> 2022-01-10")
    end
  end

  describe "#date_range" do
    it "returns the date range" do
      expect(described_class.new(from: "2022-01-04", to: "2022-01-10").date_range)
        .to eq(Date.new(2022, 1, 4)..Date.new(2022, 1, 10))
    end
  end
end
