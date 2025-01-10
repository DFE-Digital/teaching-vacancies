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
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.not_started"), colour: "grey"))
        end
      end

      context "when the step is in progress" do
        let(:form_classes) { [Jobseekers::JobApplication::QualificationsForm] }

        it "returns 'in progress' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.in_progress"), colour: "yellow"))
        end
      end
    end

    context "when the whole section is optional" do
      let(:record) { build_stubbed(:vacancy, :draft, completed_steps: completed_steps) }
      let(:form_classes) { [Publishers::JobListing::SubjectsForm] }
      let(:steps) { %w[subjects] }

      context "and it is not started" do
        let(:completed_steps) { [] }

        it "shows as 'optional'" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.optional"), colour: "grey"))
        end
      end

      context "and it is completed" do
        let(:completed_steps) { steps }

        it "shows as 'optional'" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.optional"), colour: "grey"))
        end
      end
    end
  end
end
