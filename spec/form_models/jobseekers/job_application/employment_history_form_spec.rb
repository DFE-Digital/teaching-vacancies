require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EmploymentHistoryForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  let(:attributes) do
    {
      employment_history_section_completed: employment_history_section_completed,
      unexplained_employment_gaps: unexplained_employment_gaps,
      employments: employments,
      qualifications: qualifications,
    }
  end

  let(:employment_history_section_completed) { "true" }
  let(:employments) { [] }
  let(:qualifications) { [] }
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

    context "when there is a gap between education and first job" do
      let(:unexplained_employment_gaps) { {} }
      let(:employments) { [build_stubbed(:employment, started_on: Date.new(2021, 3, 1), ended_on: Date.new(2022, 1, 1))] }
      let(:qualifications) { [build_stubbed(:qualification, finished_studying: true, year: 2018)] }

      it "adds an error when there is an unexplained gap between education and first job" do
        expect(form).not_to be_valid
        expect(form.errors[:education_gap]).to include(
          "You have a gap in your work history between your education and first employment",
        )
      end

      context "when the gap between education and first job is explained" do
        let(:employments) do
          [
            build_stubbed(:employment, started_on: Date.new(2021, 3, 1), ended_on: Date.new(2022, 1, 1)),
            build_stubbed(:education_gap, started_on: Date.new(2018, 7, 1), ended_on: Date.new(2021, 2, 28)),
          ]
        end

        it "does not add an error" do
          expect(form).to be_valid
        end
      end

      context "when a current role is the first job" do
        let(:employments) { [build_stubbed(:employment, :current_role, started_on: Date.new(2021, 3, 1))] }

        it "adds an error" do
          expect(form).not_to be_valid
          expect(form.errors[:education_gap]).to include(
            "You have a gap in your work history between your education and first employment",
          )
        end
      end
    end

    context "when there is no gap between education and first job" do
      let(:unexplained_employment_gaps) { {} }
      let(:employments) { [build_stubbed(:employment, started_on: Date.new(2021, 9, 1), ended_on: Date.new(2022, 6, 1))] }
      let(:qualifications) { [build_stubbed(:qualification, finished_studying: true, year: 2021)] }

      it "does not add an error" do
        expect(form).to be_valid
      end
    end

    context "when there are no jobs" do
      let(:unexplained_employment_gaps) { {} }
      let(:qualifications) { [build_stubbed(:qualification, finished_studying: true, year: 2018)] }

      it "does not add an education gap error" do
        expect(form).to be_valid
      end
    end

    context "when qualifications are unfinished" do
      let(:unexplained_employment_gaps) { {} }
      let(:employments) { [build_stubbed(:employment, started_on: Date.new(2021, 3, 1), ended_on: Date.new(2022, 1, 1))] }
      let(:qualifications) { [build_stubbed(:qualification, finished_studying: false, year: nil)] }

      it "does not add an education gap error" do
        expect(form).to be_valid
      end
    end
  end
end
