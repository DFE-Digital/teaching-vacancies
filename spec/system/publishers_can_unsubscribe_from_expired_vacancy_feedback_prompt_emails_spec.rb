require "rails_helper"
RSpec.describe "Publishers can unsubscribe from expired vacancy feedback prompt emails" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "test@example.com") }

  before do
    ActionMailer::Base.deliveries.clear
    create(:vacancy, :published, publisher: publisher, expires_at: 3.weeks.ago)
    perform_enqueued_jobs do
      SendExpiredVacancyFeedbackPromptJob.new.perform
    end
  end

  context "when a publisher receives an expired vacancy feedback prompt email" do
    let(:link_to_unsubscribe) { last_email.body.to_s[/\[Unsubscribe from these emails\]\((.*)\)/, 1] }

    scenario "they can unsubscribe from these emails" do
      visit link_to_unsubscribe

      expect(current_url).to eq(confirm_unsubscribe_publishers_account_url(publisher_id: publisher.signed_id))

      expect {
        click_button I18n.t("buttons.confirm_unsubscribe")
        publisher.reload
      }.to(change { publisher.unsubscribed_from_expired_vacancy_prompt_at })
    end
  end
end
