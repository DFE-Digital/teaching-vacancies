require "rails_helper"

RSpec.describe FeedbackReportingPeriod do
  let!(:oldest_feedback) { create(:feedback, created_at: "2022-01-09") }
  let!(:newest_feedback) { create(:feedback, created_at: "2022-03-23") }

  describe ".all" do
    subject(:all_periods) { described_class.all }

    it "returns inclusive one per month periods from the oldest feedback to the current month" do
      travel_to(Time.zone.local(2022, 6, 10, 10, 4, 3)) do
        expect(all_periods.first).to eq(described_class.new(from: "2022-01-01", to: "2022-01-31"))
        expect(all_periods.last).to eq(described_class.new(from: "2022-06-01", to: "2022-06-30"))
        expect(all_periods.count).to eq(6)
      end
    end

    context "when there is no feedback" do
      before { Feedback.destroy_all }

      it { should be_empty }
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
    it "returns the calendar month date range that includes the given date" do
      expect(described_class.for("2022-02-09"))
        .to eq(described_class.new(from: "2022-02-01", to: "2022-02-28"))
    end

    it "accepts a date, a datetime, a time or a string for its values" do
      expect(described_class.for("2022-01-09"))
        .to eq(described_class.new(from: "2022-01-01", to: "2022-01-31"))

      expect(described_class.for(Date.new(2022, 1, 9)))
        .to eq(described_class.new(from: "2022-01-01", to: "2022-01-31"))

      expect(described_class.for(DateTime.new(2022, 1, 9, 10, 3)))
        .to eq(described_class.new(from: "2022-01-01", to: "2022-01-31"))

      expect(described_class.for(Time.new(2022, 1, 9, 10, 3)))
        .to eq(described_class.new(from: "2022-01-01", to: "2022-01-31"))
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
    let(:period_start) { Date.new(2022, 1, 4).beginning_of_day }
    let(:period_end) { Date.new(2022, 1, 10).end_of_day }

    it "returns the date range" do
      expect(described_class.new(from: "2022-01-04", to: "2022-01-10").date_range).to eq(period_start..period_end)
    end
  end
end
