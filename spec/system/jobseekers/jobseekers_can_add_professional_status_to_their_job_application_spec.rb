require "rails_helper"

RSpec.describe "Jobseekers can add details about their qualified teacher status to a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :professional_status)
    choose I18n.t("helpers.label.jobseekers_job_application_professional_status_form.professional_status_section_completed_options.true")
  end

  after { logout }

  it "passes a11y", :a11y do
    #  https://github.com/alphagov/govuk-frontend/issues/979
    expect(page).to be_axe_clean.skipping "aria-allowed-attr"
  end

  it "allows jobseekers to add their professional status" do
    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Select yes if you have qualified teacher status", href: "#jobseekers-job-application-professional-status-form-qualified-teacher-status-field-error")
      expect(page).to have_link("Select yes if you have completed your statutory induction year", href: "#jobseekers-job-application-professional-status-form-is-statutory-induction-complete-field-error")
    end

    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"

    click_on "Save and continue"

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Enter the year your QTS was gained", href: "#jobseekers-job-application-professional-status-form-qualified-teacher-status-year-field-error")
    end

    fill_in "Year QTS was gained", with: "2022"
    fill_in I18n.t("helpers.label.jobseekers_job_application_professional_status_form.qts_age_range_and_subject"), with: "Adding up for little ones"
    choose("Yes, I have completed my induction period")

    click_on "Save and continue"

    fill_in "What is your teacher reference number (TRN)?", with: "1234567"

    click_on "Save and continue"

    expect(page).not_to have_css("h2", text: "There is a problem")
    expect(page).to have_current_path jobseekers_job_application_apply_path(job_application), ignore_query: true
    expect(job_application.reload).to have_attributes(qts_age_range_and_subject: "Adding up for little ones", teacher_reference_number: "1234567")
  end
end
