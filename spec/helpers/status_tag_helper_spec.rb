require "rails_helper"

RSpec.describe StatusTagHelper do
  describe "#review_section_tag" do
    subject { helper.review_section_tag(record, steps, form_classes) }

    context "when it is passed a job application" do
      let(:record) { build_stubbed(:job_application, completed_steps: %w[personal_details professional_status], in_progress_steps: %w[qualifications]) }
      let(:form_classes) { [Jobseekers::JobApplication::PersonalDetailsForm] }

      context "when there is an error on the step's form object" do
        let(:steps) { [:personal_details] }

        before { record.errors.add(:city) }

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

      context "when the step is in progress" do
        let(:steps) { [:qualifications] }

        it "returns 'in progress' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.in_progress"), colour: "yellow"))
        end
      end
    end

    context "when it is passed a vacancy" do
      let(:record) { build_stubbed(:vacancy, :draft, completed_steps: %w[job_role job_details]) }
      let(:form_classes) { [Publishers::JobListing::JobDetailsForm] }

      context "when is published" do
        let(:record) { build_stubbed(:vacancy) }
        let(:steps) { [] }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when there is an error on the step's form object" do
        let(:steps) { %i[job_details] }

        before { record.errors.add(:job_title) }

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

    context "when the whole section is optional" do
      let(:record) { build_stubbed(:vacancy, :draft, completed_steps: completed_steps) }
      let(:form_classes) { [Publishers::JobListing::DocumentsForm] }
      let(:steps) { %w[documents] }

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
