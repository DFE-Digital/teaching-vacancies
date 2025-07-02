require "rails_helper"

RSpec.describe "Publishers manage self disclosure" do
  include ActiveJob::TestHelper

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

  describe "using TV self-disclosure form" do
    before do
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
      choose "Yes"
      click_on "Save and continue"
      choose "Yes"
    end

    it "sends the notification email" do
      click_on("Save and continue")
      expect {
        perform_enqueued_jobs
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(job_application.email, job_application.email)
    end

    it "create the self disclosure request and model" do
      expect {
        click_on "Save and continue"
      }.to change(SelfDisclosureRequest, :count).by(1)
       .and change(SelfDisclosure, :count).by(1)
    end

    describe "visit self disclosure form" do
      let(:request) { create(:self_disclosure_request, job_application: job_application) }

      before do
        create(:self_disclosure, self_disclosure_request: request)
        request.sent!
      end

      it "can be manually marked as complete by publisher" do
        publisher_ats_self_disclosure_page.load(
          vacancy_id: vacancy.id,
          job_application_id: job_application.id,
        )

        expect(publisher_ats_self_disclosure_page.status.text).to eq("Pending")
        expect(publisher_ats_self_disclosure_page.button.text).to eq("Manually mark as complete")
        expect(publisher_ats_self_disclosure_page).not_to have_goto_references_and_declaration_form

        publisher_ats_self_disclosure_page.button.click

        expect(publisher_ats_self_disclosure_page.banner_title.text).to eq("Success")
        expect(publisher_ats_self_disclosure_page.status.text).to eq("Completed")
      end

      context "when completed by jobseeker", :inline_jobs do
        before do
          request.self_disclosure.mark_as_received
          # perform_enqueued_jobs
          # perform_enqueued_jobs
        end

        it "shows the form" do
          publisher_ats_self_disclosure_page.load(
            vacancy_id: vacancy.id,
            job_application_id: job_application.id,
          )

          expect(publisher_ats_self_disclosure_page.status.text).to eq("Completed")
          expect(publisher_ats_self_disclosure_page.button.text).to eq("Print self-disclosure")
          expect(publisher_ats_self_disclosure_page.personal_details.heading.text).to eq("Personal details")
          expect(publisher_ats_self_disclosure_page.criminal_details.heading.text).to eq("Criminal record declaration")
          expect(publisher_ats_self_disclosure_page.conduct_details.heading.text).to eq("Conduct declaration")
          expect(publisher_ats_self_disclosure_page.confirmation_details.heading.text).to eq("Confirmation declaration")
        end
      end
    end
  end

  describe "not using TV self-disclosure" do
    before do
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
      choose "No"
    end

    it "does not send any notification email" do
      expect {
        click_on "Save and continue"
      }.not_to have_enqueued_email(Jobseekers::JobApplicationMailer, :declarations)
    end

    it "creates a self disclosure request" do
      expect {
        click_on "Save and continue"
      }.to change(SelfDisclosureRequest, :count).by(1)
       .and not_change(SelfDisclosure, :count)
    end

    describe "visit jobseeker self disclosure form" do
      let(:request) { create(:self_disclosure_request, job_application_id: job_application.id) }

      before { request.manual! }

      context "when request is pending" do
        it "publisher can go to the references and declaration form" do
          publisher_ats_self_disclosure_page.load(
            vacancy_id: vacancy.id,
            job_application_id: job_application.id,
          )
          expect(publisher_ats_self_disclosure_page.status.text).to eq("Pending")
          expect(publisher_ats_self_disclosure_page.button.text).to eq("Manually mark as complete")
          expect(
            publisher_ats_self_disclosure_page.goto_references_and_declaration_form.text,
          ).to eq("Would you like to collect this self-disclosure form through Teaching Vacancies?")

          publisher_ats_self_disclosure_page.goto_references_and_declaration_form.click

          expect(page).to have_content("Would you like to collect references and declarations through the Teaching Vacancies service?")
        end
      end
    end
  end
end
