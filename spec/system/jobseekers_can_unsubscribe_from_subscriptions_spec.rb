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
      expect(page).to have_content(I18n.t("jobseekers.unsubscribe_feedbacks.new.header"))
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

      choose "jobseekers-unsubscribe-feedback-form-unsubscribe-reason-other-reason-field"
      fill_in "jobseekers_unsubscribe_feedback_form[other_unsubscribe_reason_comment]", with: "Spam"
      fill_in "jobseekers_unsubscribe_feedback_form[comment]", with: "Eggs"

      expect { click_on I18n.t("buttons.submit_feedback") }
        .to have_triggered_event(:feedback_provided)
        .with_data(comment: "Eggs",
                   feedback_type: "unsubscribe",
                   other_unsubscribe_reason_comment: "Spam",
                   search_criteria: json_including(subscription.search_criteria),
                   subscription_identifier: anything,
                   unsubscribe_reason: "other_reason")

      click_on I18n.t("jobseekers.unsubscribe_feedbacks.confirmation.new_search_link")

      expect(current_path).to eq jobs_path
    end

    context "when jobseeker is signed in" do
      let(:jobseeker) { create(:jobseeker) }

      before { login_as(jobseeker, scope: :jobseeker) }

      it "redirects to the job alerts dashboard after feedback is submitted" do
        choose "jobseekers-unsubscribe-feedback-form-unsubscribe-reason-job-found-field"
        click_on I18n.t("buttons.submit_feedback")

        expect(page).to have_content(I18n.t("jobseekers.unsubscribe_feedbacks.create.success"))
        expect(current_path).to eq jobseekers_subscriptions_path
      end
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
