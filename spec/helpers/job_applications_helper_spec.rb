require "rails_helper"

RSpec.describe JobApplicationsHelper do
  describe "#job_application_qualified_teacher_status_info" do
    subject { helper.job_application_qualified_teacher_status_info(job_application) }

    context "when QTS is 'yes'" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "yes") }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([
          tag.span("Yes, awarded in ", class: "govuk-body", id: "qualified_teacher_status"),
          tag.span(job_application.qualified_teacher_status_year, class: "govuk-body", id: "qualified_teacher_status_year"),
        ]))
      end
    end

    context "when QTS is 'no'" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "no") }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([
          tag.div("No", class: "govuk-body", id: "qualified_teacher_status"),
          tag.p(job_application.qualified_teacher_status_details, class: "govuk-body", id: "qualified_teacher_status_details"),
        ]))
      end
    end

    context "when QTS is 'on_track" do
      let(:job_application) { build_stubbed(:job_application, qualified_teacher_status: "on_track") }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("I'm on track to receive my QTS", class: "govuk-body", id: "qualified_teacher_status"))
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

    context "when is_support_needed is 'true'" do
      let(:job_application) { build_stubbed(:job_application, is_support_needed: true) }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([tag.div("Yes", class: "govuk-body", id: "support_needed"),
                                         tag.p(job_application.support_needed_details, class: "govuk-body", id: "support_needed_details")]))
      end
    end

    context "when is_support_needed is 'false'" do
      let(:job_application) { build_stubbed(:job_application, is_support_needed: false) }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("No", id: "support_needed"))
      end
    end

    context "when is_support_needed is nil" do
      let(:job_application) { build_stubbed(:job_application, is_support_needed: nil) }

      it "returns the correct info" do
        expect(subject).to be_blank
      end
    end
  end

  describe "job_application_close_relationships_info" do
    subject { helper.job_application_close_relationships_info(job_application) }

    context "when has_close_relationships is 'true'" do
      let(:job_application) { build_stubbed(:job_application, has_close_relationships: true) }

      it "returns the correct info" do
        expect(subject).to eq(safe_join([
          tag.div("Yes", class: "govuk-body", id: "close_relationships"),
          tag.p(job_application.close_relationships_details, class: "govuk-body", id: "close_relationships_details"),
        ]))
      end
    end

    context "when has_close_relationships is 'false'" do
      let(:job_application) { build_stubbed(:job_application, has_close_relationships: false) }

      it "returns the correct info" do
        expect(subject).to eq(tag.div("No", class: "govuk-body", id: "close_relationships"))
      end
    end

    context "when has_close_relationships is nil" do
      let(:job_application) { build_stubbed(:job_application, has_close_relationships: nil) }

      it "returns the correct info" do
        expect(subject).to be_blank
      end
    end
  end

  describe "#job_application_page_title_prefix" do
    subject { helper.job_application_page_title_prefix(form, title) }

    let(:title) { "A page title" }

    context "when the form has errors" do
      let(:form) { double("some_form", errors: ["an error"]) }

      it "prepends `Error:` to the title" do
        expect(subject).to eq("Error: A page title")
      end
    end

    context "when the form does not have errors" do
      let(:form) { double("some_form", errors: []) }

      it "returns the title" do
        expect(subject).to eq("A page title")
      end
    end
  end
end
