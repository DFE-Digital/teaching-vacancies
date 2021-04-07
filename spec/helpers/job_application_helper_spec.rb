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
end
