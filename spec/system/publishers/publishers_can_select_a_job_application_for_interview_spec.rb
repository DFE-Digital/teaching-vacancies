require "rails_helper"

RSpec.describe "Publishers can select a job application for interview" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) do
    create(:job_application, :status_submitted,
           email_address: jobseeker.email,
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let!(:current_referee) { create(:referee, is_most_recent_employer: true, job_application: job_application) }
  let!(:old_referee) { create(:referee, is_most_recent_employer: false, job_application: job_application) }

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

      scenario "contacting applicant sends emails to refs and applicant" do
        choose "Yes"
        click_on "Save and continue"
        expect(publisher_ats_applications_page).to be_displayed

        expect {
          perform_enqueued_jobs
        }.to change(ActionMailer::Base.deliveries, :count).by(3)
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(current_referee.email, old_referee.email, job_application.email_address)
      end

      context "when not contacting applicant" do
        before do
          choose "No"
          click_on "Save and continue"
        end

        it "only sends referee emails" do
          expect(publisher_ats_interviewing_page).to be_displayed

          expect {
            perform_enqueued_jobs
          }.to change(ActionMailer::Base.deliveries, :count).by(2)
          expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(current_referee.email, old_referee.email)
        end

        context "with a received reference", :versioning do
          before do
            perform_enqueued_jobs
            # simulate receipt of a reference
            current_referee.reload.job_reference.update!(attributes_for(:job_reference).merge(updated_at: Date.tomorrow))
            current_referee.reload.reference_request.update!(status: :received)
          end

          it "can progress to the page where the reference is shown", :js do
            publisher_ats_interviewing_page.pre_interview_check_links.first.click
            expect(publisher_ats_pre_interview_checks_page).to be_displayed

            publisher_ats_pre_interview_checks_page.reference_links.first.click
            expect(publisher_ats_reference_request_page).to be_displayed
          end

          context "when marking reference received" do
            before do
              publisher_ats_interviewing_page.pre_interview_check_links.first.click
              publisher_ats_pre_interview_checks_page.reference_links.first.click
              click_on "Mark as received"
            end

            scenario "error bounce" do
              expect(publisher_ats_satisfactory_reference_page).to be_displayed
              publisher_ats_satisfactory_reference_page.submit_button.click
              expect(publisher_ats_satisfactory_reference_page.errors.map(&:text)).to eq(["Select yes if the reference received is satisfactory"])
            end

            scenario "accept reference", :versioning do
              publisher_ats_satisfactory_reference_page.yes.click
              publisher_ats_satisfactory_reference_page.submit_button.click
              expect(current_referee.reference_request.reload).to be_marked_as_complete

              expect(publisher_ats_reference_request_page).to be_displayed
              expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Marked as complete", "Reference received", "Reference requested"])
            end

            scenario "decline reference" do
              publisher_ats_satisfactory_reference_page.no.click
              publisher_ats_satisfactory_reference_page.submit_button.click
              expect(current_referee.reference_request.reload.status).to eq("received")
            end
          end
        end
      end
    end

    context "when choosing no for refs and decls" do
      before do
        choose "No"
        click_on "Save and continue"
      end

      it "does not send any emails" do
        expect {
          perform_enqueued_jobs
        }.not_to change(ActionMailer::Base.deliveries, :count)
        expect(publisher_ats_interviewing_page).to be_displayed
      end

      describe "reference display page" do
        before do
          publisher_ats_interviewing_page.pre_interview_check_links.first.click
          publisher_ats_pre_interview_checks_page.reference_links.first.click
        end

        scenario "accepting an out of band reference", :versioning do
          click_on "Mark as received"

          expect(publisher_ats_satisfactory_reference_page).to be_displayed
          publisher_ats_satisfactory_reference_page.yes.click
          publisher_ats_satisfactory_reference_page.submit_button.click

          expect(publisher_ats_reference_request_page).to be_displayed
          expect(current_referee.reference_request.reload).to be_marked_as_complete
          expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Marked as complete", "Marked as interviewing"])
        end

        scenario "changing our mind and using TV after all", :versioning do
          expect(publisher_ats_reference_request_page).to be_displayed
          publisher_ats_reference_request_page.use_tv_anyway_link.click

          expect(publisher_ats_collect_references_page).to be_displayed
          choose "Yes"
          click_on "Save and continue"

          expect(publisher_ats_ask_references_email_page).to be_displayed
          # don't contact applicant
          choose "No"
          click_on "Save and continue"

          expect(publisher_ats_interviewing_page).to be_displayed
          publisher_ats_interviewing_page.pre_interview_check_links.first.click

          expect(publisher_ats_pre_interview_checks_page).to be_displayed
          publisher_ats_pre_interview_checks_page.reference_links.first.click

          expect(publisher_ats_reference_request_page).to be_displayed
          expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Reference requested", "Marked as interviewing"])
        end
      end
    end
  end
end
