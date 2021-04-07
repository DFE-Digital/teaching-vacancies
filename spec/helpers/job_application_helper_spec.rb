require "rails_helper"

RSpec.describe JobApplicationHelper do
  describe "#job_application_review_edit_section_text" do
    subject { helper.job_application_review_edit_section_text(job_application, step) }

    let(:job_application) { build_stubbed(:job_application, completed_steps: %w[personal_details]) }

    context "when the step is completed" do
      let(:step) { :personal_details }

      it "returns `Change`" do
        expect(subject).to eq(I18n.t("buttons.change"))
      end
    end

    context "when the step is not completed" do
      let(:step) { :professional_status }

      it "returns `Complete section`" do
        expect(subject).to eq(I18n.t("buttons.complete_section"))
      end
    end
  end

  describe "#job_application_review_section_tag" do
    subject { helper.job_application_review_section_tag(job_application, step) }

    let(:job_application) do
      build_stubbed(:job_application,
                    completed_steps: %w[personal_details professional_status],
                    in_progress_steps: %w[ask_for_support])
    end

    context "when the step is completed" do
      let(:step) { :personal_details }

      it "returns complete tag" do
        expect(subject).to eq(helper.govuk_tag(text: "complete"))
      end
    end

    context "when the step is in progress" do
      let(:step) { :ask_for_support }

      it "returns in progress tag" do
        expect(subject).to eq(helper.govuk_tag(text: "in progress", colour: "yellow"))
      end
    end

    context "when the step is not started" do
      let(:step) { :personal_statement }

      it "returns not started tag" do
        expect(subject).to eq(helper.govuk_tag(text: "not started", colour: "red"))
      end
    end
  end
end
