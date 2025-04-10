require "rails_helper"

RSpec.describe StatusTagHelper do
  describe "#review_section_tag" do
    subject { helper.review_section_tag(record, step) }

    context "when it is passed a job application" do
      let(:record) { build_stubbed(:job_application, completed_steps: %w[personal_details professional_status], in_progress_steps: %w[qualifications]) }

      context "when the step has been completed" do
        let(:step) { :personal_details }

        it "returns 'complete' text with no tag" do
          expect(subject).to eq({ text: I18n.t("shared.status_tags.complete") })
        end
      end

      context "when the step has not been started" do
        let(:step) { :personal_statement }

        it "returns 'not started' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.incomplete"), colour: "yellow"))
        end
      end

      context "when the step is in progress" do
        let(:step) { :qualifications }

        it "returns 'in progress' tag" do
          expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.incomplete"), colour: "yellow"))
        end
      end
    end
  end
end
