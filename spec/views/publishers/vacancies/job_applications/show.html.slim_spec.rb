require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/show" do
  let(:vacancy) do
    build_stubbed(:vacancy, :expired, organisations: build_stubbed_list(:school, 1),
                                      job_applications:
                                  build_stubbed_list(:job_application, 1, :status_submitted,
                                                     training_and_cpds: build_stubbed_list(:training_and_cpd, 1),
                                                     working_patterns: %w[full_time part_time]))
  end
  let(:job_application) do
    vacancy.job_applications.first
  end

  before do
    assign :vacancy, vacancy
    assign :job_application, job_application
    assign :notes_form, Publishers::JobApplication::NotesForm.new

    render
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
end
