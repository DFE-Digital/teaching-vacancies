require "rails_helper"

RSpec.describe "Publishers can select a job application for interview", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }
  let!(:current_referee) { create(:referee, email: "employer@contoso.com", is_most_recent_employer: true, job_application: job_application) }
  let!(:old_referee) { create(:referee, email: "previous@contoso.com", is_most_recent_employer: false, job_application: job_application) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "when selecting a single candidate" do
    before do
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
      click_on "Update application status"
      choose "Interviewing"
      click_on "Save and continue"
    end

    context "with a religious vacancy", :versioning do
      let(:job_application) do
        create(:job_application, :status_submitted,
               :with_religious_referee,
               notes: build_list(:note, 1),
               notify_before_contact_referers: true,
               vacancy: vacancy, jobseeker: jobseeker)
      end
      let(:vacancy) { create(:vacancy, :catholic, :expired, organisations: [school], publisher: publisher) }
      let(:action_needed) { "Action needed" }

      before do
        choose "Yes"
        click_on "Save and continue"
        choose "No"
        click_on "Save and continue"
        choose "No"
        click_on "Save and continue"
        click_on "Pre-interview checks"
      end

      it "displays action needed" do
        within "#religious_reference" do
          expect(page).to have_content action_needed
        end
      end

      context "when editing a religious reference" do
        before do
          within "#religious_reference" do
            find("a").click
          end
        end

        it "allows the reference to be marked as requested" do
          click_on "Mark as requested"
          within "#religious_reference" do
            expect(page).to have_content "pending"
          end
        end

        describe "completing a religious reference" do
          before do
            click_on "Mark as requested"
            within "#religious_reference" do
              find("a").click
            end
          end

          it "allows the reference to be marked as complete", :js do
            click_on "Mark as complete"
            within "#religious_reference" do
              expect(page).to have_content "completed"
            end
          end
        end

        describe "adding a note" do
          let(:note_content) { Faker::Ancient.hero }

          it "allows notes to be added without disturbing the flow" do
            notes = find_by_id("publishers-job-application-notes-form-content-field")
            notes.fill_in with: note_content
            click_on "Save note"
            find ".govuk-notification-banner"
            expect(page).to have_content "A note has been added"
            expect(page).to have_content note_content
            expect(page).to have_current_path edit_organisation_job_job_application_religious_reference_path(vacancy.id, job_application.id)
          end
        end
      end
    end

    context "with a non-religious vacancy" do
      let(:job_application) do
        create(:job_application, :status_submitted,
               notify_before_contact_referers: notify_candidate,
               email_address: jobseeker.email,
               vacancy: vacancy, jobseeker: jobseeker)
      end
      let(:vacancy) { create(:vacancy, :expired, organisations: [school], publisher: publisher) }
      let(:emails_with_subjects) do
        ActionMailer::Base.deliveries
                          .group_by { |mail| mail.to.first }
                          .transform_values { |m| m.map { |x| x.subject.split[..3].join(" ") } }
      end

      context "when applicant doesn't need to be notified" do
        let(:notify_candidate) { false }

        before do
          choose "Yes"
          click_on "Save and continue"
          # 2nd question not asked when candidate doesn't need contacting
          choose "Yes"
          click_on "Save and continue"
          # wait for page load
          find_by_id("interviewing")
        end

        it "sends emails to referees and applicant" do
          expect(publisher_ats_applications_page).to be_displayed

          expect(emails_with_subjects)
            .to eq({
              current_referee.email => ["Provide a reference for"],
              old_referee.email => ["Provide a reference for"],
              job_application.email_address => ["Complete your self-disclosure form"],
            })
        end
      end

      context "when applicant needs to be notified" do
        let(:notify_candidate) { true }

        scenario "without selecting" do
          expect(publisher_ats_collect_references_page).to be_displayed
          click_on "Save and continue"
          expect(publisher_ats_collect_references_page.errors.map(&:text))
            .to eq(["Select yes if you would like to collect references through the service"])
        end

        context "when choosing yes for references and self disclosure" do
          let(:self_disclosure_answer) { "Yes" }

          before do
            choose "Yes"
            click_on "Save and continue"
            choose contact_applicant
            click_on "Save and continue"
            choose self_disclosure_answer
            click_on "Save and continue"
            # wait for page load
            find_by_id("interviewing")
          end

          context "when choosing to contact applicant via TVS" do
            let(:contact_applicant) { "Yes" }

            it "sends emails to referees and notifies applicant that references are being collected" do
              expect(publisher_ats_applications_page).to be_displayed

              expect(emails_with_subjects)
                .to eq({
                  current_referee.email => ["Provide a reference for"],
                  old_referee.email => ["Provide a reference for"],
                  job_application.email_address => ["References are being collected", "Complete your self-disclosure form"],
                })
            end
          end

          context "when choosing not to contact applicant through TVS" do
            let(:contact_applicant) { "No" }

            it "only sends referee emails, and doesn't send email about reference collection" do
              expect(publisher_ats_interviewing_page).to be_displayed

              expect(emails_with_subjects)
                .to eq({
                  current_referee.email => ["Provide a reference for"],
                  old_referee.email => ["Provide a reference for"],
                  job_application.email_address => ["Complete your self-disclosure form"],
                })
            end
          end
        end

        context "when choosing no for references and self disclosures" do
          before do
            choose "No"
            click_on "Save and continue"
            choose "No"
            click_on "Save and continue"
          end

          it "does not send any emails" do
            expect(ActionMailer::Base.deliveries.count).to eq(0)
            expect(publisher_ats_interviewing_page).to be_displayed
          end

          describe "reference display page", :versioning do
            before do
              publisher_ats_interviewing_page.pre_interview_check_links.first.click
              publisher_ats_pre_interview_checks_page.reference_links.first.click
            end

            scenario "accepting an out of band reference", :js do
              expect(publisher_ats_reference_request_page).to be_displayed
              click_on "Mark as received"

              expect(publisher_ats_reference_request_page).to be_displayed
              expect(current_referee.reference_request.reload).to be_received_off_service
              expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Marked as received", "Marked as interviewing"])
            end

            context "when changing our mind and using TV after all" do
              before do
                publisher_ats_reference_request_page.use_tv_anyway_link.click
              end

              context "without collecting references" do
                before do
                  choose "No"
                  click_on "Save and continue"
                end

                it "redirects straight away back to the pre interview page" do
                  expect(publisher_ats_pre_interview_checks_page).to be_displayed
                end
              end

              context "when collecting references" do
                before do
                  choose "Yes"
                  click_on "Save and continue"
                end

                scenario "errors" do
                  click_on "Save and continue"
                  expect(publisher_ats_pre_interview_checks_page.errors.map(&:text))
                    .to eq(["Select yes if you would like the service to email candidates that you are collecting references."])
                end

                scenario "not contacting applicant" do
                  choose "No"
                  click_on "Save and continue"
                  expect(ActionMailer::Base.deliveries.map(&:to).flatten)
                    .to contain_exactly("employer@contoso.com", "previous@contoso.com")

                  expect(publisher_ats_pre_interview_checks_page).to be_displayed
                  # This now includes the self disclosure
                  expect(publisher_ats_pre_interview_checks_page.reference_links.count).to eq(3)
                  publisher_ats_pre_interview_checks_page.reference_links.first.click

                  expect(publisher_ats_reference_request_page).to be_displayed
                  expect(publisher_ats_reference_request_page.timeline_titles.map(&:text))
                    .to eq(["Reference requested", "Marked as interviewing"])
                end

                scenario "contacting applicant" do
                  choose "Yes"
                  click_on "Save and continue"
                  expect(ActionMailer::Base.deliveries.map(&:to).flatten)
                    .to contain_exactly("employer@contoso.com", "previous@contoso.com", "jobseeker@contoso.com")

                  expect(publisher_ats_pre_interview_checks_page).to be_displayed
                  publisher_ats_pre_interview_checks_page.reference_links.first.click

                  expect(publisher_ats_reference_request_page).to be_displayed
                  expect(publisher_ats_reference_request_page.timeline_titles.map(&:text))
                    .to eq(["Reference requested", "Marked as interviewing"])
                end
              end
            end
          end
        end

        context "without self disclosures" do
          before do
            choose "Yes"
            click_on "Save and continue"
            choose "No"
            click_on "Save and continue"
            choose "No"
            click_on "Save and continue"
          end

          it "loops back to job applications" do
            expect(publisher_ats_applications_page).to be_displayed
          end
        end

        context "without references" do
          before do
            choose "No"
            click_on "Save and continue"
          end

          it "only asks the self-disclosure question" do
            choose "Yes"
            click_on "Save and continue"
            expect(publisher_ats_applications_page).to be_displayed
          end
        end
      end
    end
  end
end
