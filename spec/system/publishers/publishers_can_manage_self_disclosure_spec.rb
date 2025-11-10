require "rails_helper"

RSpec.describe "Publishers manage self disclosure", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation], publisher: publisher) }
  let(:jobseeker) { create(:jobseeker, :with_personal_details) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker, create_self_disclosure: false) }
  let(:disclosure_request) { SelfDisclosureRequest.order(:created_at).last }

  describe "using TV self-disclosure form", :versioning do
    describe "interviewing and asking for self-disclosure" do
      before do
        login_publisher(publisher: publisher, organisation: organisation)
        publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        click_on "Update application status"
        choose "Interviewing"
        click_on "Save and continue"
        choose "No"
        click_on "Save and continue"
        choose "Yes"
        click_on("Save and continue")
      end

      after { logout }

      it "sends the notification email and creates self disclosure models" do
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(job_application.email_address)
        expect(SelfDisclosureRequest.count).to eq(1)
        expect(SelfDisclosure.count).to eq(1)
      end

      it "can be manually marked as received by the publisher" do
        publisher_ats_self_disclosure_page.load(
          vacancy_id: vacancy.id,
          job_application_id: job_application.id,
        )

        expect(publisher_ats_self_disclosure_page.status.text).to eq("pending")
        expect(publisher_ats_self_disclosure_page.button.text).to eq("Mark as received")
        expect(publisher_ats_self_disclosure_page).not_to have_goto_references_and_self_disclosure_form

        publisher_ats_self_disclosure_page.button.click

        expect(publisher_ats_self_disclosure_page.banner_title.text).to eq("Success")
        expect(publisher_ats_self_disclosure_page.status.text).to eq("received")

        click_on "Mark as completed"
        expect(page).to have_content "Marked as complete"
      end
    end

    describe "visit self disclosure form" do
      let(:request) { create(:self_disclosure_request, :sent, job_application: job_application, self_disclosure: build(:self_disclosure, :pending)) }

      before do
        Jobseekers::SelfDisclosureRequestReceivedNotifier.with(record: request)
                                                         .deliver
      end

      describe "jobseeker filling in form" do
        let(:dummy_self_disclosure) { build(:self_disclosure) }

        before do
          login_as(jobseeker, scope: :jobseeker)
          visit jobseekers_job_application_path job_application
        end

        after { logout }

        it "shows as a notification to the jobseeker", :js do
          find(".count-badge").click
          within ".notification" do
            find("a").click
          end
          expect(page).to have_current_path jobseekers_job_application_self_disclosure_path(job_application, :personal_details)
        end

        context "when filling in the disclosure form" do
          before do
            within ".govuk-notification-banner__heading" do
              find("a").click
            end
          end

          it "passes a11y", :a11y do
            # wait for page load
            find "label[for='jobseekers-job-applications-self-disclosure-personal-details-form-name-field']"
            expect(page).to be_axe_clean
            jobseeker_self_disclosure_personal_details_page.fill_in_and_submit_form(dummy_self_disclosure)

            # wait for page load
            find("form[action='/jobseekers/job_applications/#{job_application.id}/self_disclosure/barred_list']")
            expect(page).to be_axe_clean
            jobseeker_self_disclosure_barred_list_page.fill_in_and_submit_form(dummy_self_disclosure)

            # wait for page load
            find("form[action='/jobseekers/job_applications/#{job_application.id}/self_disclosure/conduct']")
            expect(page).to be_axe_clean
            jobseeker_self_disclosure_conduct_page.fill_in_and_submit_form(dummy_self_disclosure)

            # wait for page load
            find("form[action='/jobseekers/job_applications/#{job_application.id}/self_disclosure/confirmation']")
            expect(page).to be_axe_clean
          end
        end
      end

      context "when completed by jobseeker" do
        let(:dummy_self_disclosure) { build(:self_disclosure) }

        before do
          # clear the mail queue so that we can show just the publisher notification email being sent
          ActionMailer::Base.deliveries.clear
          run_with_jobseeker(jobseeker) do
            visit jobseekers_job_application_path job_application
            within ".govuk-notification-banner__heading" do
              find("a").click
            end
            jobseeker_self_disclosure_personal_details_page.fill_in_and_submit_form(dummy_self_disclosure)
            jobseeker_self_disclosure_barred_list_page.fill_in_and_submit_form(dummy_self_disclosure)
            jobseeker_self_disclosure_conduct_page.fill_in_and_submit_form(dummy_self_disclosure)
            jobseeker_self_disclosure_confirmation_page.fill_in_and_submit_form(dummy_self_disclosure)
          end
          job_application.self_disclosure_request.update!(marked_as_complete: true)
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
              .to eq([
                "Teaching Vacancies - #{Date.current.to_fs.strip}",
                "#{jobseeker.jobseeker_profile.personal_details.first_name} #{jobseeker.jobseeker_profile.personal_details.last_name} - #{Date.current.to_fs.strip}",
                "Teaching Vacancies - #{Date.current.to_fs.strip}",
              ])

            expect(publisher_ats_self_disclosure_page.status.text).to eq("completed")
            expect(page).to have_content("Download self-disclosure")
            expect(publisher_ats_self_disclosure_page.personal_details.heading.text).to eq("Personal details")
            expect(publisher_ats_self_disclosure_page.criminal_details.heading.text).to eq("Criminal record self-disclosure")
            expect(publisher_ats_self_disclosure_page.conduct_details.heading.text).to eq("Conduct self-disclosure")
            expect(publisher_ats_self_disclosure_page.confirmation_details.heading.text).to eq("Confirmation self-disclosure")
          end
        end
      end
    end
  end

  describe "not using TV self-disclosure", :versioning do
    before do
      login_publisher(publisher: publisher, organisation: organisation)
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
      choose "No"
      click_on "Save and continue"
      choose "No"
    end

    after { logout }

    it "does not send any notification email" do
      expect {
        click_on "Save and continue"
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "creates a self disclosure request" do
      expect {
        click_on "Save and continue"
      }.to change(SelfDisclosureRequest, :count).by(1)
       .and not_change(SelfDisclosure, :count)
    end

    describe "visit jobseeker self disclosure form" do
      before do
        click_on "Save and continue"
        publisher_ats_self_disclosure_page.load(
          vacancy_id: vacancy.id,
          job_application_id: job_application.id,
        )
      end

      scenario "handling errors" do
        publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.click
        click_on "Save and continue"
        expect(publisher_ats_self_disclosure_page.errors.map(&:text))
          .to eq(["Select yes if you would like to collect self disclosure through the service"])
      end

      scenario "not really changing your mind" do
        publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.click
        choose "No"
        click_on "Save and continue"
        expect(publisher_ats_pre_interview_checks_page).to be_displayed
        expect(disclosure_request.reload.status).to eq("manual")
      end

      scenario "publisher changing their mind and choosing TV for self-disclosure" do
        expect(publisher_ats_self_disclosure_page.status.text).to eq("created")
        expect(publisher_ats_self_disclosure_page.button.text).to eq("Mark as received")
        expect(
          publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.text,
        ).to eq("Would you like to collect this self-disclosure form through Teaching Vacancies?")

        publisher_ats_self_disclosure_page.goto_references_and_self_disclosure_form.click
        choose "Yes"
        click_on "Save and continue"
        expect(publisher_ats_pre_interview_checks_page).to be_displayed
        expect(disclosure_request.reload.status).to eq("sent")
      end
    end
  end
end
