require "rails_helper"

RSpec.describe "Publishers can send reminder for pending self-disclosure request", :perform_enqueued do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, :with_organisation, email: "publisher@contoso.com") }
  let(:vacancy) { create(:vacancy, publisher:, organisations: publisher.organisations) }
  let(:job_application) { create(:job_application, :status_submitted, email_address: "jobseeker@contoso.com", vacancy:) }
  let(:self_disclosure_request) { create(:self_disclosure_request, :sent, updated_at:, job_application:) }

  before do
    create(:self_disclosure, self_disclosure_request:)
  end

  context "when view 47h after request creation" do
    let(:updated_at) { 1.business_day.ago }

    scenario "page has no reminder button" do
      run_with_publisher(publisher) do
        publisher_ats_self_disclosure_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        expect(publisher_ats_self_disclosure_page).not_to have_reminder_btn
      end
    end
  end

  describe "48h after request creation" do
    let(:updated_at) { 2.business_days.ago }

    before do
      ActionMailer::Base.deliveries.clear
    end

    scenario "send reminder" do
      run_with_publisher(publisher) do
        publisher_ats_self_disclosure_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        expect(publisher_ats_self_disclosure_page).to have_reminder_btn
        publisher_ats_self_disclosure_page.reminder_btn.click

        expect(publisher_ats_self_disclosure_page).to be_displayed(vacancy_id: vacancy.id, job_application_id: job_application.id)
        expect(publisher_ats_self_disclosure_page).to have_text("Success")
        expect(publisher_ats_self_disclosure_page).not_to have_reminder_btn
        expect(ActionMailer::Base.deliveries.flat_map(&:to))
          .to contain_exactly("jobseeker@contoso.com")
      end
    end
  end
end
