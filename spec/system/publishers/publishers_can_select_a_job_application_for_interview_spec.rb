require "rails_helper"

RSpec.describe "Publishers can select a job application for interview" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

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

      scenario "choose yes for contact applicant" do
        choose "Yes"
        click_on "Save and continue"
        expect(publisher_ats_applications_page).to be_displayed
      end

      scenario "choose no for contact applicant" do
        choose "No"
        click_on "Save and continue"
        expect(publisher_ats_applications_page).to be_displayed
      end
    end

    scenario "choosing no for refs and decls" do
      choose "No"
      click_on "Save and continue"
      expect(publisher_ats_applications_page).to be_displayed
    end
  end
end
