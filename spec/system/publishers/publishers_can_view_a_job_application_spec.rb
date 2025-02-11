require "rails_helper"

RSpec.describe "Publishers can view a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, working_patterns: %w[full_time part_time]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    create(:training_and_cpd, job_application: job_application)
  end

  context "when the job application status is withdrawn" do
    let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

    it "redirects to a page notifying them that the application has been withdrawn" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      expect(page).to have_current_path(organisation_job_job_application_withdrawn_path(vacancy.id, job_application))
      expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.withdrawn.heading"))
      expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.withdrawn.view_more_applications"), href: organisation_job_job_applications_path(vacancy.id))
    end
  end

  it "allows hiring staff to view the jobseekers personal details on the job application" do
    visit organisation_job_job_application_path(vacancy.id, job_application)

    expect(page).to have_content "Personal details"
    expect(page).to have_css(".govuk-summary-list__key", text: "First name")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.first_name)

    expect(page).to have_css(".govuk-summary-list__key", text: "Last name")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.last_name)

    expect(page).to have_css(".govuk-summary-list__key", text: "Previous names")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.previous_names)

    expect(page).to have_css(".govuk-summary-list__key", text: "Your address")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.street_address)

    expect(page).to have_css(".govuk-summary-list__key", text: "Phone number")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.phone_number)

    expect(page).to have_css(".govuk-summary-list__key", text: "Email address")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.email)

    expect(page).to have_css(".govuk-summary-list__key", text: "Do you need Skilled Worker visa sponsorship?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("jobseekers.profiles.personal_details.work.options.true"))

    expect(page).to have_css(".govuk-summary-list__key", text: "Do you have a national insurance number?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_job_application_personal_details_form.has_ni_number_options.yes"))

    expect(page).to have_css(".govuk-summary-list__key", text: "National Insurance number")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.national_insurance_number)

    expect(page).to have_css(".govuk-summary-list__key", text: "Full, part time or job share")
    expect(page).to have_css(".govuk-summary-list__value", text: "Full time, part time")

    expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern preference details")
    expect(page).to have_css(".govuk-summary-list__value", text: job_application.working_pattern_details)
  end
end
