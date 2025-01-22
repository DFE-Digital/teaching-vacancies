require "rails_helper"

RSpec.describe StatusTagHelper do
  describe "#review_section_tag" do
    subject { helper.review_section_tag(record, form_classes) }

    context "when it is passed a job application" do
      let(:record) { build_stubbed(:job_application, completed_steps: %w[personal_details professional_status], in_progress_steps: %w[qualifications]) }

      context "when there is an error on the step's form object" do
        let(:form_classes) { [Jobseekers::JobApplication::PersonalDetailsForm] }

        before { record.errors.add(:city) }

        it "returns 'action required' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.action_required"), colour: "red"))
        end
      end

      context "when the step has been completed" do
        let(:form_classes) { [Jobseekers::JobApplication::PersonalDetailsForm] }

        it "returns 'complete' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.complete"), colour: "green"))
        end
      end

      context "when the step has not been started" do
        let(:form_classes) { [Jobseekers::JobApplication::PersonalStatementForm] }

        it "returns 'not started' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.in_progress"), colour: "yellow"))
        end
      end

      context "when the step is in progress" do
        let(:form_classes) { [Jobseekers::JobApplication::QualificationsForm] }

        it "returns 'in progress' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.in_progress"), colour: "yellow"))
        end
      end
    end
  end
end
