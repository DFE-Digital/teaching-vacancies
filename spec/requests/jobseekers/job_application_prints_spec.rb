require "rails_helper"

RSpec.describe "Job application prints" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
    allow(JobApplicationPdfGenerator).to receive(:new).and_call_original
  end

  after { sign_out(jobseeker) }

  describe "GET #print" do
    subject(:page) { Capybara.string(response.body) }

    before { get jobseekers_job_application_print_path(job_application) }

    it "renders the application as HTML in the print layout" do
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/html")
      expect(response).to render_template(layout: "print")
      expect(page).to have_title("Print application - Teaching Vacancies - GOV.UK")
    end

    it "does not generate a server-side PDF" do
      expect(JobApplicationPdfGenerator).not_to have_received(:new)
    end

    it "renders the print header and instructions" do
      expect(page).to have_text("#{vacancy.job_title} at #{organisation.name}")
      expect(page).to have_css(".print-header__applicant-name", text: job_application.name)
      expect(page).to have_text("Use your browser's print option to print this application or save it as a PDF.")
      expect(page).to have_no_css("[data-print-button], script[src*='print']", visible: :all)
    end

    it "does not render analytics or application chrome" do
      expect(page).to have_css("meta[name='robots'][content='noindex,nofollow']", visible: :all)
      expect(page).to have_no_css("#vwoCode, #clarityCode, #googleTagManagerCode, #facebookCode, #linkedinTrackingCode, #redditCode", visible: :all)
      expect(page).to have_no_css(".govuk-cookie-banner, .govuk-skip-link, .environment-banner-component", visible: :all)
      expect(page).to have_no_css(".govuk-header, .govuk-phase-banner, .govuk-breadcrumbs, .govuk-footer", visible: :all)
    end

    it "renders the consent and personal details" do
      expect(page).to have_css(".print-introduction", text: I18n.t("jobseekers.job_applications.show.consent_text"))
      expect(page).to have_css(".print-section__heading", text: "Personal details")
      expect(page).to have_css(".print-table__row", text: /First name#{Regexp.escape(job_application.first_name)}/)
      expect(page).to have_css(".print-table__row", text: /Last name#{Regexp.escape(job_application.last_name)}/)
      expect(page).to have_css(".print-table__row", text: /Email address#{Regexp.escape(job_application.email_address)}/)
      expect(page).to have_css(".print-table__row", text: /National Insurance number#{Regexp.escape(job_application.national_insurance_number)}/)
    end
  end

  context "when the application is a draft" do
    let(:job_application) { create(:job_application, :status_draft, jobseeker:, vacancy:) }

    it "raises a routing error" do
      expect { get jobseekers_job_application_print_path(job_application) }
        .to raise_error(ActionController::RoutingError, /draft/)
    end
  end

  context "when the application belongs to another jobseeker" do
    let(:job_application) { create(:job_application, :status_submitted, vacancy:) }

    it "does not find the application" do
      expect { get jobseekers_job_application_print_path(job_application) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when the application was uploaded" do
    let(:job_application) do
      create(:uploaded_job_application, :status_submitted, :with_uploaded_application_form, jobseeker:)
    end

    it "serves the uploaded application form" do
      get jobseekers_job_application_print_path(job_application)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("application_form.pdf")
      expect(JobApplicationPdfGenerator).not_to have_received(:new)
    end
  end
end
