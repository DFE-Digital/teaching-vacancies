require "rails_helper"

RSpec.describe "A jobseeker can unsubscribe from subscriptions" do
  let(:search_criteria) { { keyword: "English", location: "SW1A1AA", radius: 20 } }
  let(:subscription) { create(:subscription, frequency: :daily, search_criteria: search_criteria.to_json) }

  before do
    visit unsubscribe_subscription_path(token)
  end

  context "with the correct token" do
    let(:token) { subscription.token }

    it "unsubscribes successfully" do
      expect(page).to have_content(I18n.t("subscriptions.unsubscribe.header"))
    end

    it "removes the email from the subscription" do
      expect(subscription.reload.email).to be_blank
    end

    it "updates the subscription status" do
      expect(subscription.reload.active).to eq(false)
    end

    it "allows me to provide a feeback" do
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content("There is a problem")

      choose "unsubscribe-feedback-form-reason-job-found-field"
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content(I18n.t("subscriptions.feedback_received.header"))

      click_on I18n.t("subscriptions.feedback_received.new_search_link")

      expect(current_path).to eq jobs_path
    end

    context "with deprecated search criteria" do
      let(:search_criteria) { { keyword: "English", location: "SW1A1AA", radius: 20 } }

      it "unsubscribes successfully" do
        expect(page).to have_content(I18n.t("subscriptions.unsubscribe.header"))
      end

      it "removes the email from the subscription" do
        expect(subscription.reload.email).to be_blank
      end

      it "updates the subscription status" do
        expect(subscription.reload.active).to eq(false)
      end

      it "allows me to provide a feeback" do
        click_on I18n.t("buttons.submit_feedback")

        expect(page).to have_content("There is a problem")

        choose "unsubscribe-feedback-form-reason-job-found-field"
        click_on I18n.t("buttons.submit_feedback")

        expect(page).to have_content(I18n.t("subscriptions.feedback_received.header"))

        click_on I18n.t("subscriptions.feedback_received.new_search_link")

        expect(current_path).to eq jobs_path
      end
    end
  end

  context "with the incorrect token" do
    let(:token) { subscription.id }

    it "returns not found" do
      expect(page.status_code).to eq(404)
    end
  end

  context "with an old token" do
    let(:token) { subscription.token }

    scenario "still returns 200" do
      travel 3.days do
        expect(page.status_code).to eq(200)
      end
    end
  end
end
