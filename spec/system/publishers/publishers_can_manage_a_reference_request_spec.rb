require "rails_helper"

RSpec.describe "Publishers can manage a reference request", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:job_application) do
    create(:job_application, :status_submitted,
           email_address: jobseeker.email,
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let(:vacancy) { create(:vacancy, :expired, organisations: [school], publisher: publisher) }
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }
  let(:current_referee) do
    create(:referee, email: "referee@contoso.com", is_most_recent_employer: true, job_application: job_application,
                     reference_request: reference_request)
  end

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_ats_reference_request_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id, reference_request_id: current_referee.reload.reference_request.id)
  end

  after { logout }

  context "when the reference is declined", :versioning do
    let(:reference_request) { build(:reference_request, :reference_received, job_reference: build(:job_reference, :reference_declined)) }

    it "shows the reference as declined" do
      expect(page).to have_content("You will need to request a new referee")
      expect(publisher_ats_pre_interview_checks_page.timeline).to have_content("Reference declined")
    end
  end

  context "with a pending reference" do
    let(:reference_request) { build(:reference_request, updated_at: updated_at, job_reference: build(:job_reference)) }

    context "when the referee email is incorrect" do
      let(:reference_request) { build(:reference_request, job_reference: build(:job_reference)) }
      let(:new_email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

      before do
        within ".govuk-main-wrapper" do
          within ".govuk-grid-column-two-thirds" do
            find("a.govuk-link").click
          end
        end
      end

      scenario "with a valid email", :versioning do
        fill_in "publishers-vacancies-job-applications-change-email-address-form-email-field", with: new_email
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_content(new_email)
        expect(page).to have_content("Reference email changed")
        expect(ActionMailer::Base.deliveries.group_by { |mail| mail.to.first }.transform_values { |m| m.map(&:subject) })
          .to eq({
            new_email => ["Provide a reference for #{job_application.name} for #{vacancy.job_title} at #{school.name}"],
          })
      end

      scenario "without an email" do
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_content("Enter a valid email address")
      end
    end
  end

  context "with a reference" do
    let(:reference_request) { build(:reference_request, :reference_received, job_reference: job_reference) }
    # let(:reference_request) { build(:reference_request) }

    context "with a simple reference" do
      let(:job_reference) { build(:job_reference, :reference_given) }

      context "when marking reference as complete" do
        it "displays the page correctly" do
          expect(page).to have_content "Mark as received"
        end

        context "when marking reference as complete" do
          before do
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
            expect(page).to have_content "completed"

            expect(publisher_ats_reference_request_page).to be_displayed
            expect(publisher_ats_reference_request_page.timeline_titles.map(&:text)).to eq(["Marked as complete", "Reference received"])
          end

          scenario "decline reference" do
            publisher_ats_satisfactory_reference_page.no.click
            publisher_ats_satisfactory_reference_page.submit_button.click
            expect(current_referee.reference_request.reload.status).to eq("received")
          end
        end
      end
    end

    context "when reference contains issues" do
      let(:job_reference) do
        build(:job_reference, :reference_given, :with_issues,
              under_investigation_details: investigation_details,
              warning_details: warning_details,
              unable_to_undertake_reason: undertake_reason)
      end

      let(:investigation_details) { Faker::Adjective.negative }
      let(:warning_details) { Faker::Adjective.negative }
      let(:undertake_reason) { Faker::Adjective.negative }

      it "can progress to the page where the reference is shown" do
        expect(page).to have_content investigation_details
        expect(page).to have_content warning_details
        expect(page).to have_content undertake_reason
      end
    end
  end
end
