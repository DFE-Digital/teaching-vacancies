require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/show" do
  let(:vacancy) { build_stubbed(:vacancy, :expired, organisations:, job_applications: [job_application]) }
  let(:organisations) { build_stubbed_list(:school, 1) }
  let(:job_application) do
    build_stubbed(:job_application,
                  :"status_#{status}",
                  training_and_cpds: build_stubbed_list(:training_and_cpd, 1),
                  working_patterns: %w[full_time part_time])
  end
  let(:status) { "submitted" }

  before do
    assign :vacancy, vacancy
    assign :job_application, job_application.decorate
    assign :note, build_stubbed(:note)
    render
  end

  describe "navigation quick links" do
    context "when non religious vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :expired, organisations:, job_applications: [job_application]) }

      it "renders no religious information quick link" do
        expect(rendered).to have_no_css(".navigation-list-component__anchors .govuk-link[href=\"#following_religion\"]", text: "Religious information")
      end

      it "renders no religious information section" do
        expect(rendered).to have_no_css(".govuk-summary-card__title", text: "Religious information")
      end
    end

    context "when religious vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :catholic, :expired, organisations:, job_applications: [job_application]) }

      it "renders religious information quick link" do
        expect(rendered).to have_css(".navigation-list-component__anchors .govuk-link[href=\"#following_religion\"]", text: "Religious information")
      end

      it "renders a religious information section" do
        expect(rendered).to have_css(".govuk-summary-card__title", text: "Religious information")
      end
    end
  end

  it "allows hiring staff to view the jobseekers personal details on the job application" do
    expect(rendered).to have_content "Personal details"
    expect(rendered).to have_css(".govuk-summary-list__key", text: "First name")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.first_name)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Last name")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.last_name)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Previous names")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.previous_names)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Your address")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.street_address)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Phone number")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.phone_number)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Email address")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.email_address)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Do you need Skilled Worker visa sponsorship?")
    expect(rendered).to have_css(".govuk-summary-list__value", text: I18n.t("jobseekers.profiles.personal_details.work.options.true"))

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Do you have a national insurance number?")
    expect(rendered).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_job_application_personal_details_form.has_ni_number_options.yes"))

    expect(rendered).to have_css(".govuk-summary-list__key", text: "National Insurance number")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.national_insurance_number)

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Full, part time or job share")
    expect(rendered).to have_css(".govuk-summary-list__value", text: "Full time, part time")

    expect(rendered).to have_css(".govuk-summary-list__key", text: "Working pattern preference details")
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.working_pattern_details)
  end

  context "with anonymised applications" do
    let(:vacancy) { build_stubbed(:vacancy, :expired, anonymise_applications: true, organisations:, job_applications: [job_application]) }

    it "doesn't show all personal details" do
      expect(rendered).to have_content "Personal details"
      expect(rendered).to have_css(".govuk-summary-list__key", text: "First name")
      expect(rendered).to have_no_content(job_application.first_name)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Last name")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.last_name)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Previous names")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.previous_names)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Your address")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.street_address)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Phone number")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.phone_number)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Email address")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.email_address)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Do you need Skilled Worker visa sponsorship?")
      expect(rendered).to have_css(".govuk-summary-list__value", text: I18n.t("jobseekers.profiles.personal_details.work.options.true"))

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Do you have a national insurance number?")
      expect(rendered).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_job_application_personal_details_form.has_ni_number_options.yes"))

      expect(rendered).to have_css(".govuk-summary-list__key", text: "National Insurance number")
      expect(rendered).to have_no_css(".govuk-summary-list__value", text: job_application.national_insurance_number)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Full, part time or job share")
      expect(rendered).to have_css(".govuk-summary-list__value", text: "Full time, part time")

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Working pattern preference details")
      expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.working_pattern_details)
    end
  end

  it "has the application status of 'unread'" do
    expect(rendered).to have_css(".application-status.govuk-tag", text: "unread")
  end

  it "does not show the section status indicators" do
    expect(rendered).to have_no_css(".review-component__section__heading .govuk-tag")
  end

  it "does not allow the jobseeker to edit or update any sections" do
    expect(rendered).to have_no_css(".review-component__section__heading a")
  end

  it "removes the 'submit application' section" do
    expect(rendered).to have_no_css(".new_jobseekers_job_application_review_form")
  end

  context "when the job application is an uploaded job application" do
    let(:uploaded_form_vacancy) { create(:vacancy, :expired, receive_applications: 2, job_title: "Yup this is the one") }
    let(:uploaded_job_application) do
      build_stubbed(:uploaded_job_application, :status_submitted, :with_uploaded_application_form, vacancy: uploaded_form_vacancy)
    end

    before do
      allow(uploaded_form_vacancy).to receive(:uploaded_form?).and_return(true)
      assign :vacancy, uploaded_form_vacancy
      assign :job_application, uploaded_job_application
      render
    end

    it "shows jobseeker details and a download link for the application form" do
      expect(rendered).to have_content "Personal details"

      expect(rendered).to have_css(".govuk-summary-list__key", text: "First name")
      expect(rendered).to have_css(".govuk-summary-list__value", text: uploaded_job_application.first_name)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Last name")
      expect(rendered).to have_css(".govuk-summary-list__value", text: uploaded_job_application.last_name)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Phone number")
      expect(rendered).to have_css(".govuk-summary-list__value", text: uploaded_job_application.phone_number)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Email address")
      expect(rendered).to have_css(".govuk-summary-list__value", text: uploaded_job_application.email_address)

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Do you need Skilled Worker visa sponsorship?")
      expect(rendered).to have_css(".govuk-summary-list__value", text: I18n.t("jobseekers.profiles.personal_details.work.options.true"))

      expect(rendered).to have_css(".govuk-summary-list__key", text: "Teacher reference number (TRN)")
      expect(rendered).to have_css(".govuk-summary-list__value", text: uploaded_job_application.teacher_reference_number)

      expect(rendered).to have_link("Download application", href: organisation_job_job_application_download_path(uploaded_job_application.vacancy.id, uploaded_job_application))
    end
  end

  describe "pre-interviewing link" do
    let(:pre_interview_text) { "Pre-interview checks" }

    context "when interviewing" do
      let(:status) { "interviewing" }

      it { expect(rendered).to have_link(pre_interview_text) }
    end

    context "when submitted" do
      let(:status) { "submitted" }

      it { expect(rendered).to have_no_link(pre_interview_text) }
    end

    context "when offered" do
      let(:status) { "offered" }

      it { expect(rendered).to have_link(pre_interview_text) }
    end
  end

  describe "action buttons" do
    context "when status not terminal" do
      let(:status) { "interviewing" }

      it { expect(rendered).to have_link("Update application status") }
    end

    context "when status is terminal" do
      let(:status) { "withdrawn" }

      it { expect(rendered).to have_no_link("Update application status") }
    end

    context "when status is offered" do
      let(:status) { "offered" }

      it { expect(rendered).to have_link("Mark offer as declined") }
      it { expect(rendered).to have_no_link("Update application status") }
    end
  end
end
