require "rails_helper"

RSpec.describe "Publishers can select a job application for interview", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:job_application) do
    create(:job_application, :status_submitted,
           notify_before_contact_referers: notify_candidate,
           email_address: jobseeker.email,
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let(:vacancy) { create(:vacancy, :expired, organisations: [school], publisher: publisher) }
  let(:emails_with_counts) do
    ActionMailer::Base.deliveries
                      .group_by { |mail| mail.to.first }
                      .transform_values(&:count)
  end
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }
  let!(:current_referee) { create(:referee, email: "employer@contoso.com", is_most_recent_employer: true, job_application: job_application) }
  let!(:old_referee) { create(:referee, email: "previous@contoso.com", is_most_recent_employer: false, job_application: job_application) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    # wait for page load
    find_by_id("declarations")
    click_on "Update application status"
    choose "Interviewing"
    click_on "Save and continue"
  end

  after { logout }

  context "without selecting" do
    let(:notify_candidate) { false }

    it "errors" do
      expect(publisher_ats_collect_references_page).to be_displayed
      click_on "Save and continue"
      expect(publisher_ats_collect_references_page.errors.map(&:text))
        .to eq(["Select yes if you would like to collect references through the service"])
    end
  end

  describe "selecting references and self-disclosure" do
    before do
      choose collect_references
      click_on "Save and continue"
    end

    context "when applicant doesn't need to be notified" do
      let(:notify_candidate) { false }
      let(:collect_references) { "Yes" }

      before do
        # 2nd question not asked when candidate doesn't need contacting
        choose "Yes"
        click_on "Save and continue"
        # wait for page load
        find_by_id("interviewing")
      end

      it "sends emails to referees and applicant" do
        expect(publisher_ats_applications_page).to be_displayed

        expect(emails_with_counts)
          .to eq({
            current_referee.email => 1,
            old_referee.email => 1,
            job_application.email_address => 1,
          })
      end
    end

    context "when applicant needs to be notified" do
      let(:notify_candidate) { true }

      context "when choosing yes for references and self disclosure" do
        let(:collect_references) { "Yes" }
        let(:self_disclosure_answer) { "Yes" }

        before do
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

            expect(emails_with_counts)
              .to eq({
                current_referee.email => 1,
                old_referee.email => 1,
                job_application.email_address => 2,
              })
          end
        end

        context "when choosing not to contact applicant through TVS" do
          let(:contact_applicant) { "No" }

          it "only sends referee emails, and doesn't send email about reference collection" do
            expect(publisher_ats_interviewing_page).to be_displayed

            expect(emails_with_counts)
              .to eq({
                current_referee.email => 1,
                old_referee.email => 1,
                job_application.email_address => 1,
              })
          end
        end
      end

      context "when choosing no for references and self disclosures" do
        let(:collect_references) { "No" }

        before do
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
        let(:collect_references) { "Yes" }

        before do
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
        let(:collect_references) { "No" }

        it "only asks the self-disclosure question" do
          choose "Yes"
          click_on "Save and continue"
          expect(publisher_ats_applications_page).to be_displayed
        end
      end
    end
  end
end
