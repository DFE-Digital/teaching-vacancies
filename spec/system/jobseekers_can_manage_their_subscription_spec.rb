require "rails_helper"

RSpec.describe "A jobseeker can manage a subscription" do
  let(:search_criteria) { { keyword: "Math", location: "London", radius: 10 } }
  let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily, search_criteria: search_criteria.to_json) }

  before do
    visit edit_subscription_path(token)
  end

  context "with the correct token" do
    let(:token) { subscription.token }

    it "shows the page title" do
      expect(page).to have_content(I18n.t("subscriptions.edit.title"))
    end

    context "when updating the subscription" do
      before do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:update) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)

        fill_in "subscription-form-keyword-field", with: "English"
        fill_in "subscription-form-email-field", with: "jimi@hendrix.com"
        page.choose("Weekly")

        click_on I18n.t("buttons.update_alert")
      end

      it "audits the update" do
        activity = subscription.activities.last
        expect(activity.key).to eq("subscription.update")
      end

      it "shows the confirmation page" do
        expect(page).to have_content(I18n.t("subscriptions.confirm_update.header"))
      end

      it "updates the subscription" do
        subscription.reload
        expect(subscription.email).to eq("jimi@hendrix.com")
        expect(subscription.frequency).to eq("weekly")
        expect(JSON.parse(subscription.search_criteria).symbolize_keys[:keyword]).to eq("English")
      end
    end

    context "when updating with no criteria" do
      before do
        fill_in "subscription-form-keyword-field", with: ""
        fill_in "subscription-form-location-field", with: ""
        fill_in "subscription-form-email-field", with: "jimi@hendrix.com"
        page.choose("Weekly")

        click_on I18n.t("buttons.update_alert")
      end

      it "does not create the subscription" do
        subscription.reload
        expect(subscription.email).to eq("bob@dylan.com")
        expect(subscription.frequency).to eq("daily")
        expect(JSON.parse(subscription.search_criteria).symbolize_keys[:keyword]).to eq("Math")
        expect(JSON.parse(subscription.search_criteria).symbolize_keys[:location]).to eq("London")
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
