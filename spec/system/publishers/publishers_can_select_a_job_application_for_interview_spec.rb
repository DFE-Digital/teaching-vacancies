require "rails_helper"

RSpec.describe "Publishers can select a job application for interview", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:job_title) { Faker::Job.title }
  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation], job_title: job_title, publisher: publisher) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }
  let(:job_application) do
    create(:job_application, :status_submitted,
           email_address: jobseeker.email,
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let!(:current_referee) { create(:referee, email: "employer@contoso.com", is_most_recent_employer: true, job_application: job_application) }
  let!(:old_referee) { create(:referee, email: "previous@contoso.com", is_most_recent_employer: false, job_application: job_application) }

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
      expect(publisher_ats_collect_references_page.errors.map(&:text))
        .to eq(["Select yes if you would like to collect references through the service"])
    end

    context "when choosing yes for references and self disclosure" do
      before do
        choose "Yes"
        click_on "Save and continue"
      end

      let(:emails_with_subjects) do
        ActionMailer::Base.deliveries
                          .group_by { |mail| mail.to.first }
                          .transform_values { |m| m.map { |x| x.subject.split[..3].join(" ") } }
      end

      scenario "no selection" do
        expect(publisher_ats_ask_references_email_page).to be_displayed
        click_on "Save and continue"
        expect(publisher_ats_ask_references_email_page.errors.map(&:text))
          .to eq(["Select yes if you would like the service to email candidates that you are collecting references."])
      end

      scenario "contacting applicant sends emails to referees and applicant" do
        choose "Yes"
        click_on "Save and continue"
        choose "Yes"
        click_on "Save and continue"
        expect(publisher_ats_applications_page).to be_displayed

        expect(emails_with_subjects)
          .to eq({
            current_referee.email => ["Provide a reference for"],
            old_referee.email => ["Provide a reference for"],
            job_application.email_address => ["References are being collected", "Complete your self-disclosure form"],
          })
      end

      context "when not contacting applicant", :versioning do
        before do
          choose "No"
          click_on "Save and continue"
          choose "Yes"
          click_on "Save and continue"
          find_by_id("interviewing") # make sure controller has finished its jobs
        end

        it "only sends referee emails" do
          expect(publisher_ats_interviewing_page).to be_displayed

          expect(emails_with_subjects)
            .to eq({
              current_referee.email => ["Provide a reference for"],
              old_referee.email => ["Provide a reference for"],
              job_application.email_address => ["Complete your self-disclosure form"],
            })
        end

        context "when the reference is declined" do
          before do
            current_referee.reload.job_reference.update!(attributes_for(:job_reference, :reference_declined).merge(updated_at: Date.tomorrow))
            current_referee.reload.reference_request.update!(status: :received)
          end

          it "shows the reference as declined" do
            publisher_ats_interviewing_page.pre_interview_check_links.first.click
            expect(publisher_ats_pre_interview_checks_page).to be_displayed

            publisher_ats_pre_interview_checks_page.reference_links.first.click
            expect(page).to have_content("You will need to request a new referee")
            expect(publisher_ats_pre_interview_checks_page.timeline).to have_content("Reference declined")
          end
        end

        context "when the referee email is incorrect" do
          before do
            ActionMailer::Base.deliveries.clear
            publisher_ats_interviewing_page.pre_interview_check_links.first.click
            publisher_ats_pre_interview_checks_page.reference_links.first.click
            within ".govuk-main-wrapper" do
              within ".govuk-grid-column-two-thirds" do
                find("a.govuk-link").click
              end
            end
          end

          let(:new_email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

          scenario "with a good email" do
            fill_in "publishers-vacancies-job-applications-change-email-address-form-email-field", with: new_email
            click_on I18n.t("buttons.save_and_continue")
            expect(page).to have_content(new_email)
            expect(page).to have_content("Reference email changed")
            expect(ActionMailer::Base.deliveries.group_by { |mail| mail.to.first }.transform_values { |m| m.map(&:subject) })
              .to eq({
                new_email => ["Provide a reference for #{job_application.name} for #{vacancy.job_title} at #{organisation.name}"],
              })
          end

          scenario "without an email" do
            click_on I18n.t("buttons.save_and_continue")
            expect(page).to have_content("Enter a valid email address")
          end
        end

        context "with a received reference" do
          before do
            current_referee.reload
            # simulate receipt of a reference
            current_referee.job_reference.update!(attributes_for(:job_reference, :reference_given).merge(updated_at: Date.tomorrow))
            current_referee.job_reference.mark_as_received
            publisher_ats_interviewing_page.pre_interview_check_links.first.click
          end

          context "with a simple reference" do
            let(:reference_data) { attributes_for(:job_reference, :reference_given) }

            it "can progress to the page where the reference is shown" do
              expect(publisher_ats_pre_interview_checks_page).to be_displayed

              publisher_ats_pre_interview_checks_page.reference_links.first.click
              expect(publisher_ats_reference_request_page).to be_displayed
            end
          end

          context "when reference contains issues" do
            let(:investigation_details) { Faker::Adjective.negative }
            let(:warning_details) { Faker::Adjective.negative }
            let(:undertake_reason) { Faker::Adjective.negative }

            before do
              current_referee.job_reference.update!(attributes_for(:job_reference, :with_issues,
                                                                   under_investigation_details: investigation_details,
                                                                   warning_details: warning_details,
                                                                   unable_to_undertake_reason: undertake_reason))
            end

            it "can progress to the page where the reference is shown" do
              expect(publisher_ats_pre_interview_checks_page).to be_displayed

              publisher_ats_pre_interview_checks_page.reference_links.first.click
              expect(publisher_ats_reference_request_page).to be_displayed
              expect(page).to have_content investigation_details
              expect(page).to have_content warning_details
              expect(page).to have_content undertake_reason
            end
          end

          it "send an email notification to the publisher that the reference had been received" do
            expect(ActionMailer::Base.deliveries.map(&:to).flatten)
              .to contain_exactly("jobseeker@contoso.com", "employer@contoso.com", "previous@contoso.com", "publisher@contoso.com")
          end

          context "when marking reference received" do
            let(:reference_data) { attributes_for(:job_reference, :reference_given) }

            before do
              publisher_ats_pre_interview_checks_page.reference_links.first.click
              click_on "Mark as received"
            end

            it "displays the page correctly" do
              expect(page).to have_content "This reference will be marked as complete"
              expect(page).to have_content "This reference will remain as received"
              expect(page).to have_content "Yes"
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

        scenario "accepting an out of band reference" do
          click_on "Mark as received"

          expect(publisher_ats_satisfactory_reference_page).to be_displayed
          publisher_ats_satisfactory_reference_page.yes.click
          publisher_ats_satisfactory_reference_page.submit_button.click

          expect(publisher_ats_reference_request_page).to be_displayed
          expect(current_referee.reference_request.reload).to be_marked_as_complete
          expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Marked as complete", "Marked as interviewing"])
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
              expect(publisher_ats_pre_interview_checks_page.reference_links.count).to eq(2)
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
              publisher_ats_pre_interview_checks_page.reference_links.last.click

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
