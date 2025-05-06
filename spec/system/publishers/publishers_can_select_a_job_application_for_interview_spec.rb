require "rails_helper"

RSpec.describe "Publishers can select a job application for interview" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) do
    create(:job_application, :status_submitted,
           referees: [
             build(:referee, is_most_recent_employer: true),
             build(:referee, is_most_recent_employer: false),
           ],
           vacancy: vacancy, jobseeker: jobseeker)
  end

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
  end

  after { logout }

  describe "interview flow" do
    before do
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
    end

    scenario "without selecting" do
      expect(publisher_ats_collect_references_page).to be_displayed
      click_on "Save and continue"
      expect(publisher_ats_collect_references_page.errors.map(&:text)).to eq(["Select yes if you would like to collect references and declarations through the service"])
    end

    context "when choosing yes for refs and decls" do
      before do
        choose "Yes"
        click_on "Save and continue"
      end

      scenario "no selection" do
        expect(publisher_ats_ask_references_email_page).to be_displayed
        click_on "Save and continue"
        expect(publisher_ats_ask_references_email_page.errors.map(&:text)).to eq(["Select yes if you would like the service to email applicants that you are collecting references."])
      end

      scenario "choose yes for contact applicant", :js do
        choose "Yes"
        click_on "Save and continue"
        expect(publisher_ats_applications_page).to be_displayed
        publisher_ats_interviewing_page.pre_interview_check_links.first.click
        expect(publisher_ats_pre_interview_checks_page).to be_displayed
        sleep 3
        perform_enqueued_jobs
        job_application.referees.map(&:job_reference).each do |ref|
          ref.update!(attributes_for(:job_reference))
        end
        publisher_ats_pre_interview_checks_page.reference_links.first.click
        expect(publisher_ats_reference_page).to be_displayed
        sleep 24
      end

      scenario "choose no for contact applicant" do
        choose "No"
        click_on "Save and continue"
        expect(publisher_ats_interviewing_page).to be_displayed
      end
    end

    scenario "choosing no for refs and decls" do
      choose "No"
      click_on "Save and continue"
      expect(publisher_ats_applications_page).to be_displayed
    end
  end
end
