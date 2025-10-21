require "rails_helper"

RSpec.describe "Publishers can select multiple candidates for interview", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  # needs JS driver to prevent tests seeing multiple tabs at once
  context "when selecting multiple candidates", :js do
    let(:vacancy) { create(:vacancy, :catholic, :expired, organisations: [school], publisher: publisher) }
    let!(:job_application) do
      create(:job_application, :status_submitted,
             notify_before_contact_referers: false,
             email_address: jobseeker.email,
             referees: build_list(:referee, 1, email: "employer@contoso.com", is_most_recent_employer: true),
             vacancy: vacancy, jobseeker: jobseeker)
    end

    let!(:extra_job_application) do
      create(:job_application, :status_submitted, notify_before_contact_referers: contact_referee,
                                                  vacancy: vacancy)
    end

    before do
      publisher_ats_applications_page.load(vacancy_id: vacancy.id)
      publisher_ats_applications_page.select_candidate(job_application)
      publisher_ats_applications_page.select_candidate(extra_job_application)
      click_on "Update application status"
      choose "Interviewing"
    end

    context "when someone needs contacting" do
      let(:contact_referee) { true }

      it "shows the contact references form" do
        click_on "Save and continue"
        choose "Yes"
        click_on "Save and continue"
        expect(page).to have_content "notified when you are collecting references"
      end
    end

    context "when no-one needs contacting" do
      let(:contact_referee) { false }

      it "does not show the contact references form" do
        click_on "Save and continue"
        choose "Yes"
        click_on "Save and continue"
        expect(page).to have_no_content "notified when you are collecting references"
      end
    end
  end
end
