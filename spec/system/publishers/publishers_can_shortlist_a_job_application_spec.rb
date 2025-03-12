require "rails_helper"

RSpec.describe "Publishers can shortlist a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker, :with_profile) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_job_application_path(vacancy.id, job_application.id)
  end

  after { logout }

  it "shortlists the job application", :js do
    click_on "Update application status"
    expect(page).to have_no_css("strong.govuk-tag.govuk-tag--green.application-status", text: "shortlisted")
    choose "Shortlisted"
    click_on "Save and continue"
    # wait for page reload
    find(".govuk-tabs")

    expect(page).to have_css("strong.govuk-tag.govuk-tag--green.application-status", text: "shortlisted")
    expect(current_path).to eq(organisation_job_job_applications_path(vacancy.id))
    expect(job_application.reload.status).to eq("shortlisted")
  end
end
