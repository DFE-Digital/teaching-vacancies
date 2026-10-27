require "rails_helper"

RSpec.describe "Jobseekers can keep their job alerts" do
  let!(:subscription) { create(:subscription, keyword: "Maths", frequency: :daily) }

  describe "when a job alert has not been updated for a year" do
    before do
      travel 12.months + 1.day
      SendSubscriptionGovernanceEmailsJob.perform_now
    end

    scenario "the jobseeker is warned, and the job alert is deleted a month later if they do nothing" do
      expect(subscription.reload.deletion_warning_email_sent_at).to be_present

      travel 1.month - 1.day
      DeleteUnconfirmedSubscriptionsJob.perform_now
      expect(subscription.reload).not_to be_discarded

      travel 2.days
      DeleteUnconfirmedSubscriptionsJob.perform_now
      expect(subscription.reload).to be_discarded
    end

    scenario "the jobseeker keeps the job alert, and is warned again every year" do
      visit keep_subscription_path(subscription.token)
      expect(page).to have_content(I18n.t("subscriptions.keep.success"))

      travel 1.month + 1.day
      DeleteUnconfirmedSubscriptionsJob.perform_now
      expect(subscription.reload).not_to be_discarded

      travel 11.months
      expect { SendSubscriptionGovernanceEmailsJob.perform_now }
        .to have_enqueued_mail(Jobseekers::SubscriptionMailer, :governance_email_unregistered_was_updated)
      expect(subscription.reload.deletion_warning_email_sent_at).to be_present

      travel 1.month + 1.day
      DeleteUnconfirmedSubscriptionsJob.perform_now
      expect(subscription.reload).to be_discarded
    end

    scenario "the jobseeker updates the job alert, which keeps it" do
      visit edit_subscription_path(subscription.token)
      fill_in "jobseekers-subscription-form-keyword-field", with: "English"
      choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.weekly")
      click_on I18n.t("buttons.update_alert")
      expect(page).to have_content(I18n.t("subscriptions.confirm.header.update"))

      travel 1.month + 1.day
      DeleteUnconfirmedSubscriptionsJob.perform_now
      expect(subscription.reload).not_to be_discarded
      expect(subscription.deletion_warning_email_sent_at).to be_nil
    end
  end
end
