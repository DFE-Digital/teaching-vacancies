require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EmploymentHistoryForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  let(:attributes) do
    {
      employment_history_section_completed: employment_history_section_completed,
      unexplained_employment_gaps: unexplained_employment_gaps,
      employments: [],
    }
  end

  let(:employment_history_section_completed) { "true" }
  let(:unexplained_employment_gaps) do
    {
      gap1: { started_on: Date.new(2023, 12, 1), ended_on: Date.new(2024, 12, 1) },
      gap2: { started_on: Date.new(2020, 11, 1), ended_on: Date.new(2021, 5, 31) },
    }
  end

  describe "validations" do
    context "with employment history gaps" do
      it "adds errors for each unexplained gap" do
        expect(form).not_to be_valid

        expect(form.errors[:unexplained_employment_gaps]).to include(
          "You have a gap in your work history (about 1 year).",
          "You have a gap in your work history (7 months).",
        )
      end
    end

    context "without unexplained_employment_gaps" do
      let(:unexplained_employment_gaps) { {} }

      it "does not add errors for gaps" do
        expect(form).to be_valid
      end
    end

    context "when employment_history_section_completed is false" do
      let(:employment_history_section_completed) { "false" }

      it "does not add errors for gaps" do
        expect(form).to be_valid
      end
    end
  end
end
