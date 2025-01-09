require "rails_helper"

RSpec.describe WorkHistoryErrorSummaryPresenter do
  let(:unexplained_employment_gaps) do
    {
      gap1: { started_on: Date.new(2023, 12, 1), ended_on: Date.new(2024, 12, 1) },
      gap2: { started_on: Date.new(2020, 11, 1), ended_on: Date.new(2021, 5, 31) },
    }
  end
  let(:errors) do
    {
      base: [
        "You have a gap in your work history (1 year).",
        "You have a gap in your work history (6 months).",
      ],
    }
  end

  describe "#formatted_error_messages" do
    subject(:presenter) { described_class.new(errors, unexplained_employment_gaps) }

    it "provides links to the correct gap IDs" do
      expect(presenter.formatted_error_messages).to eq(
        [
          [:base, "You have a gap in your work history (1 year).", "#gap-20231201-20241201"],
          [:base, "You have a gap in your work history (6 months).", "#gap-20201101-20210531"],
        ],
      )
    end
  end
end
