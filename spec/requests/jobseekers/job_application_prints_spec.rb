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

    let(:qualification) do
      create(
        :qualification,
        category: :undergraduate,
        grade: "First class honours",
        institution: "Example University",
        job_application:,
        month: 6,
        subject: "Mathematics",
        year: 2020,
      )
    end
    let(:training_and_cpd) do
      create(
        :training_and_cpd,
        course_length: "2 days",
        grade: "Pass",
        job_application:,
        name: "Safeguarding training",
        provider: "Example Training Provider",
        year_awarded: "2024",
      )
    end
    let(:professional_body_membership) do
      create(
        :professional_body_membership,
        job_application:,
        membership_number: "MEM-123",
        membership_type: "Full member",
        name: "Example Teaching Association",
        year_membership_obtained: "2022",
      )
    end
    let(:employment) do
      create(
        :employment,
        :current_role,
        job_application:,
        job_title: "Mathematics teacher",
        main_duties: "Teaching mathematics across key stages 3 and 4",
        organisation: "Example Secondary School",
        started_on: Date.new(2022, 9, 1),
        subjects: "Mathematics",
      )
    end
    let(:employment_break) do
      create(
        :employment_break,
        ended_on: Date.new(2022, 8, 31),
        job_application:,
        reason_for_break: "Caring responsibilities",
        started_on: Date.new(2021, 9, 1),
      )
    end

    before do
      qualification
      training_and_cpd
      professional_body_membership
      employment
      employment_break
      get jobseekers_job_application_print_path(job_application)
    end

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

    it "renders professional status" do
      expect(page).to have_css(".print-section__heading", text: "Professional status")
      expect(page).to have_css(".print-table__row", text: /Do you have qualified teacher status \(QTS\)\?Yes, gained in 1990/)
      expect(page).to have_css(".print-table__row", text: /Teacher reference number \(TRN\)#{job_application.teacher_reference_number}/)
      expect(page).to have_css(".print-table__row", text: /Have you completed your induction period\?Yes/)
    end

    it "renders qualifications" do
      expect(page).to have_css(".print-section__heading", text: "Qualifications")
      expect(page).to have_css(".print-subsection__heading", text: "Undergraduate degree")
      expect(page).to have_css(".print-table__row", text: /Subject:Mathematics/)
      expect(page).to have_css(".print-table__row", text: /Institution:Example University/)
      expect(page).to have_css(".print-table__row", text: /Grade:First class honours/)
      expect(page).to have_css(".print-table__row", text: /Date completed:June 2020/)
    end

    context "without qualifications" do
      let(:qualification) { nil }

      it "renders the no-qualifications message" do
        expect(page).to have_css(
          ".print-section__empty",
          text: I18n.t("jobseekers.job_applications.show.qualifications.none"),
        )
      end
    end

    it "renders training and continuing professional development" do
      expect(page).to have_css(
        ".print-section__heading",
        text: "Training and continuing professional development (CPD)",
      )
      expect(page).to have_css(".print-table__row", text: /NameSafeguarding training/)
      expect(page).to have_css(".print-table__row", text: /ProviderExample Training Provider/)
      expect(page).to have_css(".print-table__row", text: /Course length2 days/)
      expect(page).to have_css(".print-table__row", text: /Awarded Year2024/)
    end

    it "renders professional body memberships" do
      expect(page).to have_css(".print-section__heading", text: "Professional body memberships")
      expect(page).to have_css(".print-table__row", text: /Name of professional body:Example Teaching Association/)
      expect(page).to have_css(".print-table__row", text: /Membership type or level:Full member/)
      expect(page).to have_css(".print-table__row", text: /Membership or registration number:MEM-123/)
      expect(page).to have_css(".print-table__row", text: /Date obtained:2022/)
    end

    it "renders employment history" do
      expect(page).to have_css(".print-section__heading", text: "Work history")
      expect(page).to have_css(".print-record", minimum: 2)
      expect(page).to have_css(".print-table__row", text: /Job Title:Mathematics teacher/)
      expect(page).to have_css(".print-table__row", text: /School or other:Example Secondary School/)
      expect(page).to have_css(".print-table__row", text: /Employment currently held:Yes/)
      expect(page).to have_css(".print-table__row", text: /End date:present/)
      expect(page).to have_css(".print-table__row", text: /Reason:Caring responsibilities/)
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
