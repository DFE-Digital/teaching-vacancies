require "rails_helper"

RSpec.describe VacancyFormsHelper do
  describe "#vacancy_job_title_form_hint_text" do
    let(:vacancy) { build_stubbed(:vacancy, job_roles: [job_role], phases: [phase]) }

    context "with teaching role" do
      let(:job_role) { "teacher" }

      context "when primary" do
        let(:phase) { "primary" }

        it "shows a KS1 example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq(I18n.t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.primary"))
        end
      end

      context "when secondary" do
        let(:phase) { "secondary" }

        it "shows a Maths example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq(I18n.t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.middle_secondary_or_sixth_form_or_college"))
        end
      end
    end

    context "with leadership role" do
      let(:job_role) { "head_of_year_or_phase" }

      context "when primary" do
        let(:phase) { "primary" }

        it "shows a KS1 example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq(I18n.t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.primary"))
        end
      end

      context "when secondary" do
        let(:phase) { "secondary" }

        it "shows a modern languages example" do
          expect(helper.vacancy_job_title_form_hint_text(vacancy)).to eq(I18n.t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.middle_secondary_or_sixth_form_or_college"))
        end
      end
    end
  end
end
