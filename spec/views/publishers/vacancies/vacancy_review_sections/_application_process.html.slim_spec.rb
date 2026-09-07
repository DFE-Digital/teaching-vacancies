require "rails_helper"

RSpec.describe "publishers/vacancies/vacancy_review_sections/_application_process" do
  let(:organisation) { create(:school) }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:review, vacancy: vacancy, organisation: organisation) }

  before do
    render partial: "publishers/vacancies/vacancy_review_sections/application_process",
           locals: { vacancy: vacancy.decorate, current_organisation: organisation, step_process: step_process }
  end

  context "when applications are received via an uploaded form" do
    context "when the form has been uploaded" do
      let(:vacancy) { create(:vacancy, :with_uploaded_application_form, organisations: [organisation]) }

      it "links to the uploaded form" do
        expect(rendered).to have_link(href: job_document_path(vacancy, vacancy.application_form.id), text: /blank_job_spec\.pdf/)
      end
    end

    context "when no form is attached" do
      let(:vacancy) do
        create(:vacancy, enable_job_applications: false, receive_applications: "uploaded_form", organisations: [organisation])
      end

      it "renders the row without a document" do
        expect(rendered).to have_content(I18n.t("jobs.document_name"))
        expect(rendered).to have_no_link(href: %r{/documents/})
      end
    end
  end

  context "when applications are received by email" do
    context "when no form is attached" do
      let(:vacancy) do
        create(:vacancy, enable_job_applications: false, receive_applications: "email", organisations: [organisation])
      end

      it "does not render the application form row" do
        expect(rendered).to have_no_content(I18n.t("jobs.application_form"))
      end
    end
  end
end
