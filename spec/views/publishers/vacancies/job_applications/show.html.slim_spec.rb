require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/show" do
  let(:vacancy) { create(:vacancy, :expired, organisations: build_list(:school, 1)) }
  let(:job_application) do
    create(:job_application, :status_submitted, vacancy: vacancy,
                                                training_and_cpds: build_list(:training_and_cpd, 1),
                                                working_patterns: %w[full_time part_time])
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
    expect(rendered).to have_css(".govuk-summary-list__value", text: job_application.email)

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
end
