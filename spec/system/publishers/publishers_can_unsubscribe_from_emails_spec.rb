require "rails_helper"

RSpec.describe "Publishers can unsubscribe from emails" do
  let(:publisher) { create(:publisher) }

  describe "Unsubscribing from vacancy feedback prompt emails" do
    include ActiveJob::TestHelper

    before do
      ActionMailer::Base.deliveries.clear
      create(:vacancy, publisher: publisher, expires_at: 3.weeks.ago)
      perform_enqueued_jobs do
        SendExpiredVacancyFeedbackPromptJob.perform_later
      end
    end

    context "when a publisher receives an expired vacancy feedback prompt email" do
      let(:link_to_unsubscribe) { ActionMailer::Base.deliveries.last.personalisation.fetch(:expired_vacancy_unsubscribe_link) }

      scenario "they can unsubscribe from these emails and future emails won't be sent" do
        visit link_to_unsubscribe

        expect(current_url).to eq(confirm_unsubscribe_publishers_account_url(publisher_id: publisher.signed_id))

        expect {
          click_button I18n.t("buttons.confirm_unsubscribe")
          publisher.reload
        }.to change(publisher, :unsubscribed_from_expired_vacancy_prompt_at)

        ActionMailer::Base.deliveries.clear

        perform_enqueued_jobs do
          SendExpiredVacancyFeedbackPromptJob.perform_later
        end

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe "Opting out from service email communications" do
    scenario "publishers can opt out from service email communications" do
      visit confirm_email_opt_out_publishers_account_url(publisher_id: publisher.signed_id)

      expect(page).to have_content("Are you sure you want to opt out from service email communications?")
      expect {
        click_button("Opt out")
        publisher.reload
      }.to change(publisher, :email_opt_out).from(false).to(true)
      expect(page).to have_css("h1", text: "You have now opted out")
      expect(page).to have_content("You will no longer receive service email communications")
    end
  end
end
