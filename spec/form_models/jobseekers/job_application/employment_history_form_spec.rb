require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EmploymentHistoryForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  let(:attributes) do
    {
      employment_history_section_completed: employment_history_section_completed,
      unexplained_employment_gaps: unexplained_employment_gaps,
      employments: [],
      qualifications: [],
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

    context "with a detectable education-to-employment gap" do
      let(:unexplained_employment_gaps) { {} }

      let(:qualification) { instance_double(Qualification, finished_studying?: true, year: 2018) }
      let(:job) { instance_double(Employment, job?: true, education_gap?: false, break?: false, started_on: Date.new(2021, 3, 1), valid?: true) }

      let(:attributes) do
        {
          employment_history_section_completed: "true",
          unexplained_employment_gaps: {},
          employments: [job],
          qualifications: [qualification],
        }
      end

      it "adds an error when no education gap record exists" do
        expect(form).not_to be_valid
        expect(form.errors[:education_gap]).to include(
          "You have a gap in your work history between your education and first employment",
        )
      end

      context "when an education gap record has been added" do
        let(:gap_record) { instance_double(Employment, job?: false, education_gap?: true, break?: false, started_on: nil, valid?: true) }

        let(:attributes) do
          {
            employment_history_section_completed: "true",
            unexplained_employment_gaps: {},
            employments: [job, gap_record],
            qualifications: [qualification],
          }
        end

        it "does not add an error" do
          expect(form.errors[:education_gap]).to be_empty
        end
      end
    end

    context "when qualification year equals first job year (no provable gap)" do
      let(:unexplained_employment_gaps) { {} }

      let(:qualification) { instance_double(Qualification, finished_studying?: true, year: 2021) }
      let(:job) { instance_double(Employment, job?: true, education_gap?: false, break?: false, started_on: Date.new(2021, 9, 1), valid?: true) }

      let(:attributes) do
        {
          employment_history_section_completed: "true",
          unexplained_employment_gaps: {},
          employments: [job],
          qualifications: [qualification],
        }
      end

      it "does not add an error" do
        expect(form).to be_valid
        expect(form.errors[:education_gap]).to be_empty
      end
    end

    context "when there are no jobs" do
      let(:unexplained_employment_gaps) { {} }
      let(:qualification) { instance_double(Qualification, finished_studying?: true, year: 2018) }

      let(:attributes) do
        {
          employment_history_section_completed: "true",
          unexplained_employment_gaps: {},
          employments: [],
          qualifications: [qualification],
        }
      end

      it "does not add an education gap error" do
        expect(form).to be_valid
      end
    end
  end
end
