require "rails_helper"

RSpec.describe "A jobseeker can unsubscribe from subscriptions" do
  let(:subscription) { create(:subscription) }

  context "with the correct token" do
    before do
      visit unsubscribe_subscription_path(token)
      click_on I18n.t("subscriptions.unsubscribe.button_text")
    end

    let(:token) { subscription.token }

    it "unsubscribes successfully" do
      expect(page).to have_content(I18n.t("unsubscribe_feedbacks.new.header"))
    end

    it "removes the email from the subscription" do
      expect(subscription.reload.email).to be_blank
    end

    it "updates the subscription status" do
      expect(subscription.reload.active).to eq(false)
    end

    it "allows me to provide feedback" do
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content("There is a problem")

      choose "unsubscribe-feedback-form-reason-job-found-field"
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content(I18n.t("unsubscribe_feedbacks.confirmation.header"))

      click_on I18n.t("unsubscribe_feedbacks.confirmation.new_search_link")

      expect(current_path).to eq jobs_path
    end
  end

  context "with an incorrect token" do
    before do
      visit unsubscribe_subscription_path(token)
    end

    let(:token) { subscription.id }

    it "returns not found" do
      expect(page.status_code).to eq(404)
    end
  end

  context "with an old token" do
    before do
      visit unsubscribe_subscription_path(token)
    end

    let(:token) { subscription.token }

    scenario "still returns 200" do
      travel 3.days do
        expect(page.status_code).to eq(200)
      end
    end
  end
end
