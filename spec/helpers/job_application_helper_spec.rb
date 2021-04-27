require "rails_helper"

RSpec.describe JobApplicationHelper do
  describe "#job_application_qualified_teacher_status_info" do
    subject { helper.job_application_qualified_teacher_status_info(job_application) }

    context "when QTS is 'yes'" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "yes") }

      it "returns the correct info" do
        expect(subject)
          .to eq(tag.div("Yes, awarded in #{job_application.qualified_teacher_status_year}", class: "govuk-body"))
      end
    end

    context "when QTS is 'no'" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "no") }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([tag.div("No", class: "govuk-body"),
                                         tag.p(job_application.qualified_teacher_status_details, class: "govuk-body")]))
      end
    end

    context "when QTS is 'on_track" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "on_track") }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("I'm on track to receive my QTS", class: "govuk-body"))
      end
    end

    context "when QTS is blank" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "") }

      it "returns the correct info" do
        expect(subject).to be_blank
      end
    end
  end

  describe "#job_application_support_needed_info" do
    subject { helper.job_application_support_needed_info(job_application) }

    context "when support_needed is 'yes'" do
      let(:job_application) { build_stubbed(:job_application, support_needed: "yes") }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([tag.div("Yes", class: "govuk-body"),
                                         tag.p(job_application.support_needed_details, class: "govuk-body")]))
      end
    end

    context "when support_needed is 'no'" do
      let(:job_application) { build_stubbed(:job_application, support_needed: "no") }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("No", class: "govuk-body"))
      end
    end

    context "when support_needed is blank" do
      let(:job_application) { build_stubbed(:job_application, support_needed: "") }

      it "returns the correct info" do
        expect(subject).to be_blank
      end
    end
  end

  describe "job_application_close_relationships_info" do
    subject { helper.job_application_close_relationships_info(job_application) }

    context "when close_relationships is 'yes'" do
      let(:job_application) { build_stubbed(:job_application, close_relationships: "yes") }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([tag.div("Yes", class: "govuk-body"),
                                         tag.p(job_application.close_relationships_details, class: "govuk-body")]))
      end
    end

    context "when close_relationships is 'no'" do
      let(:job_application) { build_stubbed(:job_application, close_relationships: "no") }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("No", class: "govuk-body"))
      end
    end

    context "when close_relationships is blank" do
      let(:job_application) { build_stubbed(:job_application, close_relationships: "") }

      it "returns the correct info" do
        expect(subject).to be_blank
      end
    end
  end

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
