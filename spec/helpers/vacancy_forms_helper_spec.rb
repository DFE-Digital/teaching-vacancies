require "rails_helper"

RSpec.describe VacancyFormsHelper do
  describe "#vacancy_job_title_form_hint_text" do
    let(:vacancy) { build(:vacancy, job_roles: [job_role], phases: [phase]) }

    context "with teaching role" do
      let(:job_role) { "teacher" }

      context "when primary" do
        let(:phase) { "primary" }

        it "shows a KS1 example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq("For example ‘Teacher of KS1’")
        end
      end

      context "when secondary" do
        let(:phase) { "secondary" }

        it "shows a Maths example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq("For example ‘Teacher of Maths’")
        end
      end
    end

    context "with leadership role" do
      let(:job_role) { "head_of_year_or_phase" }

      context "when primary" do
        let(:phase) { "primary" }

        it "shows a KS1 example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq("For example ‘KS1 phase leader’")
        end
      end

      context "when secondary" do
        let(:phase) { "secondary" }

        it "shows a Maths example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq("For example ’Head of modern foreign languages’")
        end
      end
    end
  end
end
