require "rails_helper"

RSpec.describe "Jobseekers can add details about their qualified teacher status to a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  it "allows jobseekers to add their professional status" do
    visit jobseekers_job_application_build_path(job_application, :professional_status)

    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Select yes if you have qualified teacher status", href: "#jobseekers-job-application-professional-status-form-qualified-teacher-status-field-error")
      expect(page).to have_link("Select yes if you have completed your statutory induction year", href: "#jobseekers-job-application-professional-status-form-statutory-induction-complete-field-error")
    end

    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"

    click_on "Save and continue"

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Enter the year your QTS was awarded", href: "#jobseekers-job-application-professional-status-form-qualified-teacher-status-year-field-error")
    end

    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"
    fill_in "Year QTS was awarded", with: "2022"
    fill_in "Please provide more detail (optional field)", with: "It was hard work but I made it"
    choose("I'm on track to complete it")

    click_on "Save and continue"

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Enter a teacher reference number (TRN)", href: "#jobseekers-job-application-professional-status-form-teacher-reference-number-field-error")
      expect(page).to have_link("Select yes if you have a teacher reference number. If you have qualified teacher status (QTS) you must select yes.", href: "#jobseekers-job-application-professional-status-form-has-teacher-reference-number-field-error")
    end

    choose "Yes", name: "jobseekers_job_application_professional_status_form[has_teacher_reference_number]"
    fill_in "What is your Teacher reference number (TRN)?", with: "1234567"

    click_on "Save and continue"

    expect(page).not_to have_css("h2", text: "There is a problem")
  end
end
