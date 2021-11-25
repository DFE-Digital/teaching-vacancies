require "rails_helper"

RSpec.describe StatusTagHelper do
  describe "#review_section_tag" do
    context "when it is passed a job application" do
      let(:job_application) { build_stubbed(:job_application, completed_steps: %w[personal_details professional_status]) }
      let(:form_classes) { [Jobseekers::JobApplication::PersonalDetailsForm] }

      subject { helper.review_section_tag(job_application, steps, form_classes) }

      context "when there is an error on the step's form object" do
        let(:steps) { [:personal_details] }

        before { job_application.errors.add(:city) }

        it "returns 'action required' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.action_required"), colour: "red"))
        end
      end

      context "when the step has been completed" do
        let(:steps) { [:personal_details] }

        it "returns 'complete' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.complete")))
        end
      end

      context "when the step has not been started" do
        let(:steps) { [:personal_statement] }

        it "returns 'not started' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.not_started"), colour: "grey"))
        end
      end
    end

    context "when it is passed a vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, completed_steps: %w[job_role job_details]) }
      let(:form_classes) { [Publishers::JobListing::JobDetailsForm] }

      subject { helper.review_section_tag(vacancy, steps, form_classes) }

      context "when there is an error on the step's form object" do
        let(:steps) { %i[job_details] }

        before { vacancy.errors.add(:job_title) }

        it "returns 'action required' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.action_required"), colour: "red"))
        end
      end

      context "when the step has been completed" do
        let(:steps) { %i[job_details] }

        it "returns 'complete' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.complete")))
        end
      end

      context "when the step has not been started" do
        let(:steps) { %i[working_patterns] }

        it "returns 'not started' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.not_started"), colour: "grey"))
        end
      end
    end
  end
end
