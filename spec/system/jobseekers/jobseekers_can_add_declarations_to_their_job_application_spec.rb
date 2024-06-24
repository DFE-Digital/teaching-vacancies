require "rails_helper"

RSpec.describe "Jobseekers can disclose close relationships or safeguarding issues on a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to add their declarations" do
    visit jobseekers_job_application_build_path(job_application, :declarations)

    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Select yes if you have a close relationship with people within the organisation", href: "#jobseekers-job-application-declarations-form-close-relationships-field-error")
      expect(page).to have_link("Select yes if you have a safeguarding issue to declare", href: "#jobseekers-job-application-declarations-form-safeguarding-issue-field-error")
    end

    choose("Yes")
    choose("Yes, I want to share something")

    click_on "Save and continue"

    expect(page).to have_css("h2", text: "There is a problem")

    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Give details about any close relationships with people within the organisation", href: "#jobseekers-job-application-declarations-form-close-relationships-details-field-error")
      expect(page).to have_link("Provide details about your safeguarding issue", href: "#jobseekers-job-application-declarations-form-safeguarding-issue-details-field-error")
    end

    fill_in "jobseekers_job_application_declarations_form[close_relationships_details]", with: "My dad is the head teacher"
    fill_in "jobseekers_job_application_declarations_form[safeguarding_issue_details]", with: "I have a criminal record"

    click_on "Save and continue"

    expect(page).to have_no_css("h2", text: "There is a problem")
  end
end
