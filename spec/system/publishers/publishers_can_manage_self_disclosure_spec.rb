require "rails_helper"

RSpec.describe "Publishers manage self disclosure" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation], publisher: publisher) }
  let(:jobseeker) { create(:jobseeker, :with_personal_details) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

  describe "using TV self-disclosure form", :versioning do
    describe "emails and models" do
      before do
        login_publisher(publisher: publisher, organisation: organisation)
        publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        click_on "Update application status"
        choose "Interviewing"
        click_on "Save and continue"
        choose "Yes"
        click_on "Save and continue"
        choose "Yes"
      end

      after { logout }

      it "sends the notification email", :perform_enqueued do
        click_on("Save and continue")
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(job_application.email_address, job_application.email_address)
      end

      it "create the self disclosure request and model" do
        expect {
          click_on "Save and continue"
        }.to change(SelfDisclosureRequest, :count).by(1)
         .and change(SelfDisclosure, :count).by(1)
      end
    end

    describe "visit self disclosure form" do
      let(:disclosure_request) { SelfDisclosureRequest.order(:created_at).last }

      before do
        run_with_publisher_and_organisation(publisher, organisation) do
          publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
          click_on "Update application status"
          choose "Interviewing"
          click_on "Save and continue"
          choose "Yes"
          click_on "Save and continue"
          choose "Yes"
          click_on "Save and continue"
        end
      end

      it "can be manually marked as complete by publisher" do
        run_with_publisher_and_organisation(publisher, organisation) do
          publisher_ats_self_disclosure_page.load(
            vacancy_id: vacancy.id,
            job_application_id: job_application.id,
          )

          expect(publisher_ats_self_disclosure_page.status.text).to eq("pending")
          expect(publisher_ats_self_disclosure_page.button.text).to eq("Manually mark as complete")
          expect(publisher_ats_self_disclosure_page).not_to have_goto_references_and_self_disclosure_form

          publisher_ats_self_disclosure_page.button.click

          expect(publisher_ats_self_disclosure_page.banner_title.text).to eq("Success")
          expect(publisher_ats_self_disclosure_page.status.text).to eq("completed")
        end
      end

      context "when completed by jobseeker", :perform_enqueued do
        before do
          # clear the mail queue so that we can show just the publisher notification email being sent
          ActionMailer::Base.deliveries.clear
          run_with_jobseeker(jobseeker) do
            visit jobseekers_job_application_path job_application
            within ".govuk-notification-banner__heading" do
              find("a").click
            end
            fill_in "jobseekers_job_applications_self_disclosure_personal_details_form[date_of_birth(1i)]", with: 2007
            fill_in "jobseekers_job_applications_self_disclosure_personal_details_form[date_of_birth(2i)]", with: 5
            fill_in "jobseekers_job_applications_self_disclosure_personal_details_form[date_of_birth(3i)]", with: 26

            find("label[for='jobseekers-job-applications-self-disclosure-personal-details-form-has-unspent-convictions-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-personal-details-form-has-spent-convictions-true-field']").click
            click_on "Save and continue"

            find("label[for='jobseekers-job-applications-self-disclosure-barred-list-form-is-barred-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-barred-list-form-has-been-referred-true-field']").click
            click_on "Save and continue"

            find("label[for='jobseekers-job-applications-self-disclosure-conduct-form-is-known-to-children-services-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-conduct-form-has-been-dismissed-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-conduct-form-has-been-disciplined-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-conduct-form-has-been-disciplined-by-regulatory-body-true-field']").click
            click_on "Save and continue"

            find("label[for='jobseekers-job-applications-self-disclosure-confirmation-form-agreed-for-processing-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-confirmation-form-agreed-for-criminal-record-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-confirmation-form-agreed-for-organisation-update-true-field']").click
            find("label[for='jobseekers-job-applications-self-disclosure-confirmation-form-agreed-for-information-sharing-true-field']").click
            click_on "Save and continue"
          end
        end

        it "send an email notification to the publisher that the disclosure had been received" do
          expect(ActionMailer::Base.deliveries.flat_map(&:to))
            .to contain_exactly("publisher@contoso.com")
        end

        it "shows the form with a timeline" do
          run_with_publisher_and_organisation(publisher, organisation) do
            publisher_ats_self_disclosure_page.load(
              vacancy_id: vacancy.id,
              job_application_id: job_application.id,
            )

            expect(all(".timeline-component__value").map { |x| x.text.split.first(6).join(" ") })
              .to eq(["#{jobseeker.jobseeker_profile.personal_details.first_name} #{jobseeker.jobseeker_profile.personal_details.last_name} - #{Date.current.to_fs}",
                      "#{publisher.given_name} #{publisher.family_name} - #{Date.current.to_fs}"])

            expect(publisher_ats_self_disclosure_page.status.text).to eq("completed")
            expect(publisher_ats_self_disclosure_page.button.text).to eq("Print self-disclosure")
            expect(publisher_ats_self_disclosure_page.personal_details.heading.text).to eq("Personal details")
            expect(publisher_ats_self_disclosure_page.criminal_details.heading.text).to eq("Criminal record self-disclosure")
            expect(publisher_ats_self_disclosure_page.conduct_details.heading.text).to eq("Conduct self-disclosure")
            expect(publisher_ats_self_disclosure_page.confirmation_details.heading.text).to eq("Confirmation self-disclosure")
          end
        end
      end
    end
  end

  describe "not using TV self-disclosure" do
    before do
      login_publisher(publisher: publisher, organisation: organisation)
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
      choose "No"
    end

    after { logout }

    it "does not send any notification email" do
      expect {
        click_on "Save and continue"
      }.not_to have_enqueued_email(Jobseekers::JobApplicationMailer, :self_disclosure)
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
        it "publisher can go to the references and self_disclosure form" do
          publisher_ats_self_disclosure_page.load(
            vacancy_id: vacancy.id,
            job_application_id: job_application.id,
          )
          expect(publisher_ats_self_disclosure_page.status.text).to eq("pending")
          expect(publisher_ats_self_disclosure_page.button.text).to eq("Manually mark as complete")
          expect(
            publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.text,
          ).to eq("Would you like to collect this self-disclosure form through Teaching Vacancies?")

          publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.click

          expect(page).to have_content("Would you like to collect references and self-disclosure through the Teaching Vacancies service?")
        end
      end
    end
  end
end
