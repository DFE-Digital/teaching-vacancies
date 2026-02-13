require "rails_helper"

RSpec.describe "Publishers manage online checks" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation], publisher: publisher) }
  let(:jobseeker) { create(:jobseeker, :with_personal_details) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  describe "updating online checks status" do
    it "allows publisher to mark online checks as completed" do
      publisher_ats_pre_interview_checks_page.load(
        vacancy_id: vacancy.id,
        job_application_id: job_application.id,
      )

      expect(page).to have_content("Online checks")
      expect(page).to have_content("pending")

      click_on "Online checks"

      expect(page).to have_content("Have online checks been completed?")
      expect(page).to have_checked_field("No")

      choose "Yes"
      click_on "Save and update"

      expect(page).to have_content("Online checks updated")
      expect(page).to have_content("completed")

      expect(job_application.reload.online_checks).to eq("yes")
      expect(job_application.online_checks_updated_at).to be_present
    end

    it "allows publisher to mark as not doing online checks" do
      publisher_ats_pre_interview_checks_page.load(
        vacancy_id: vacancy.id,
        job_application_id: job_application.id,
      )

      click_on "Online checks"

      choose "Not doing online checks"
      click_on "Save and update"

      expect(page).to have_content("Online checks updated")
      expect(page).to have_content("completed")
      expect(job_application.reload.online_checks).to eq("not_doing")
    end

    it "can change status multiple times" do
      publisher_ats_pre_interview_checks_page.load(
        vacancy_id: vacancy.id,
        job_application_id: job_application.id,
      )

      click_on "Online checks"
      choose "Yes"
      click_on "Save and update"
      expect(page).to have_content("completed")

      click_on "Online checks"
      choose "No"
      click_on "Save and update"
      expect(page).to have_content("pending")

      expect(job_application.reload.online_checks).to eq("no")
    end
  end
end
