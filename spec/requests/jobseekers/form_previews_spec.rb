require "rails_helper"

RSpec.describe "Jobseekers::FormPreviewController" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:religion_type) { :no_religion }
  let(:vacancy) { create(:vacancy, organisations: [organisation], religion_type:) }
  let(:job_application) { create(:job_application, :status_withdrawn, jobseeker:, vacancy:) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  after { sign_out(jobseeker) }

  describe "GET #show" do
    subject(:page) { Capybara.string(response.body) }

    before do
      allow(DocumentPreviewService).to receive(:call).and_call_original
      allow(JobApplicationPdfGenerator).to receive(:new).and_call_original

      get jobseekers_job_application_form_preview_path(job_application, :blank)
    end

    it "renders the blank application as HTML in the print layout" do
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/html")
      expect(response).to render_template(layout: "print")
      expect(page).to have_title("Blank application form - Teaching Vacancies - GOV.UK")
    end

    it "does not generate a server-side PDF" do
      expect(DocumentPreviewService).not_to have_received(:call)
      expect(JobApplicationPdfGenerator).not_to have_received(:new)
    end

    it "renders the vacancy-specific content" do
      expect(page).to have_text("#{vacancy.job_title} at #{organisation.name}")
      expect(page).to have_text("Do you have a family or close relationship with anyone who works at #{organisation.name}")
    end

    it "renders the print control" do
      expect(page).to have_button("Print or save as PDF")
      expect(page).to have_css("[class~='govuk-!-display-none-print']", text: "Print or save as PDF")
      expect(page).to have_css("script[src*='print']", visible: :all)
    end

    it "does not render analytics or application chrome" do
      expect(page).to have_no_css("#vwoCode, #clarityCode, #googleTagManagerCode, #facebookCode, #linkedinTrackingCode, #redditCode", visible: :all)
      expect(page).to have_no_css(".govuk-cookie-banner, .govuk-skip-link, .environment-banner-component", visible: :all)
      expect(page).to have_no_css(".govuk-header, .govuk-phase-banner, .govuk-breadcrumbs, .govuk-footer", visible: :all)
    end

    it "renders all standard application sections" do
      [
        "Personal details",
        "Professional status",
        "Qualifications",
        "Training and continuing professional development (CPD)",
        "Professional body memberships",
        "Work history",
        "Personal statement",
        "References",
        "Do you need support or adjustments for your interview?",
        "Declarations",
        "Confirmation",
        "How your data is used",
      ].each do |heading|
        expect(page).to have_css(".print-section__heading", text: heading)
      end
    end

    it "renders the requested number of repeatable entries" do
      qualification_groups = page.all(".print-subsection")

      expect(qualification_groups[0]).to have_css(".print-subsection__heading", text: "Postgraduate qualification")
      expect(qualification_groups[0]).to have_css(".print-qualification", count: 1)
      expect(qualification_groups[1]).to have_css(".print-subsection__heading", text: "Undergraduate degree")
      expect(qualification_groups[1]).to have_css(".print-qualification", count: 1)
      expect(qualification_groups[2]).to have_css(".print-subsection__heading", text: "A levels")
      expect(qualification_groups[2]).to have_css(".print-qualification", count: 3)
      expect(qualification_groups[3]).to have_css(".print-subsection__heading", text: "GCSEs")
      expect(qualification_groups[3]).to have_css(".print-qualification", count: 5)
      expect(page).to have_css(".print-training-record", count: 2)
      expect(page).to have_css(".print-membership-record", count: 2)
      expect(page).to have_css(".print-employment-record", count: 5)
      expect(page).to have_css(".print-reference-record", count: 2)
    end

    it "renders empty writing spaces" do
      expect(page).to have_css(".print-table__writing-space", minimum: 1)
      expect(page.all(".print-table__writing-space")).to all(have_no_text(/\S/))
    end

    it "renders the confirmation and data-use consent verbatim" do
      expect(page).to have_text("I confirm that the above information is accurate and complete")
      expect(page).to have_text("When you submit your application, your data will shared with:")
      expect(page).to have_text("the Department for Education")
      expect(page).to have_text("the school, trust or local authority which posted the job listing")
      expect(page).to have_text("the school or schools the job is at")
      expect(page).to have_text("Please read the Teaching Vacancies Privacy Policy for more information on how your data is used.")
      expect(page).to have_text("I consent to my data being shared with and processed by these organisations for recruitment purposes (for example, background and qualification checks)")
      expect(page).to have_css(".print-checkbox", count: 2)
    end

    context "when the vacancy has no religious character" do
      it "does not render religious information" do
        expect(page).to have_no_css(".print-section__heading", text: "Religious information")
      end
    end

    context "when the vacancy is Catholic" do
      let(:religion_type) { :catholic }

      it "renders the Catholic questions" do
        expect(page).to have_css(".print-section__heading", text: "Religious information")
        expect(page).to have_text("Can you provide a religious referee?")
        expect(page).to have_text("can you provide a baptism certificate?")
      end
    end

    context "when the vacancy has another religious character" do
      let(:religion_type) { :other_religion }

      it "renders the other-religion questions" do
        expect(page).to have_css(".print-section__heading", text: "Religious information")
        expect(page).to have_text("How will you support the school's ethos and aims?")
        expect(page).to have_no_text("baptism certificate")
      end
    end
  end

  describe "GET #show with another preview ID" do
    %i[plain religious catholic self_disclosure job_reference unknown].each do |preview|
      it "returns not found for #{preview}" do
        get "/jobseekers/job_applications/#{job_application.id}/form_previews/#{preview}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
