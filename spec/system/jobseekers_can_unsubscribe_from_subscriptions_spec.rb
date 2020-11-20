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
      expect(subscription.reload.active).to eql(false)
    end

    it "audits the unsubscription" do
      activity = subscription.activities.last
      expect(activity.key).to eq("subscription.daily_alert.delete")
    end

    it "allows me to resubscribe" do
      click_on I18n.t("subscriptions.unsubscribe.resubscribe_link_text")

      expect(page.find_field("subscription-form-keyword-field").value).to eql("English")
      expect(page.find_field("subscription-form-location-field").value).to eql("SW1A1AA")
      expect(page.find_field("subscription-form-radius-field").value).to eql("20")
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
        expect(subscription.reload.active).to eql(false)
      end

      it "audits the unsubscription" do
        activity = subscription.activities.last
        expect(activity.key).to eq("subscription.daily_alert.delete")
      end

      it "allows me to resubscribe" do
        click_on I18n.t("subscriptions.unsubscribe.resubscribe_link_text")

        expect(page.find_field("subscription-form-keyword-field").value).to eql("English")
        expect(page.find_field("subscription-form-location-field").value).to eql("SW1A1AA")
        expect(page.find_field("subscription-form-radius-field").value).to eql("20")
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
