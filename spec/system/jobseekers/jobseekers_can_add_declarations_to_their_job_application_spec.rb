require "rails_helper"

RSpec.describe "Jobseekers can disclose close relationships or safeguarding issues on a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :declarations)
  end

  after { logout }

  it "passes a11y", :a11y do
    #  https://github.com/alphagov/govuk-frontend/issues/979
    expect(page).to be_axe_clean.skipping "aria-allowed-attr"
  end

  it "allows jobseekers to add their declarations" do
    choose I18n.t("helpers.label.jobseekers_job_application_declarations_form.declarations_section_completed_options.true")

    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Select yes if you have a close relationship with people within the organisation", href: "#jobseekers-job-application-declarations-form-has-close-relationships-field-error")
      expect(page).to have_link("Select yes if you have a safeguarding issue to declare", href: "#jobseekers-job-application-declarations-form-has-safeguarding-issue-field-error")
      expect(page).to have_link("Select yes if you have lived or work outside the UK", href: "#jobseekers-job-application-declarations-form-has-lived-abroad-field-error")
    end

    within ".close-relationships" do
      choose("Yes")
    end
    within ".life-abroad" do
      choose("Yes")
    end
    choose("Yes, I want to share something")

    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Give details about any close relationships with people within the organisation", href: "#jobseekers-job-application-declarations-form-close-relationships-details-field-error")
      expect(page).to have_link("Provide details about your safeguarding issue", href: "#jobseekers-job-application-declarations-form-safeguarding-issue-details-field-error")
      expect(page).to have_link("Give details about your life outside the UK", href: "#jobseekers-job-application-declarations-form-life-abroad-details-field-error")
    end

    fill_in "jobseekers_job_application_declarations_form[close_relationships_details]", with: "My dad is the head teacher"
    fill_in "jobseekers_job_application_declarations_form[safeguarding_issue_details]", with: "I have a criminal record"
    fill_in "jobseekers_job_application_declarations_form[life_abroad_details]", with: "I lived panatagonia for 4 years."

    click_on "Save and continue"

    expect(page).not_to have_css("h2", text: "There is a problem")
    expect(page).to have_current_path(jobseekers_job_application_apply_path(job_application))
    expect(page).to have_css("#declarations .govuk-task-list__status", text: "Completed")
  end
end
