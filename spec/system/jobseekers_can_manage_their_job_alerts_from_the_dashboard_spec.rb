require "rails_helper"

RSpec.describe "Jobseekers can manage their job alerts from the dashboard" do
  let(:jobseeker) { create(:jobseeker) }

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
    end

    context "when there are job alerts" do
      before do
        create(:subscription, email: jobseeker.email, search_criteria: { keyword: "Maths" })
        visit jobseekers_subscriptions_path
      end

      it "shows their job alerts" do
        expect(page).to have_content("Keyword: Maths")
      end

      it "allows to edit a job alert" do
        click_on I18n.t("jobseekers.subscriptions.index.link_manage")
        fill_in "jobseekers_subscription_form[location]", with: "London"
        click_button I18n.t("buttons.update_alert")

        expect(page).to have_content(I18n.t("subscriptions.update.success"))
      end

      it "allows to unsubscribe from a job alert" do
        click_on I18n.t("jobseekers.subscriptions.index.link_unsubscribe")
        click_on I18n.t("subscriptions.unsubscribe.button_text")
        choose I18n.t("helpers.label.jobseekers_unsubscribe_feedback_form.unsubscribe_reason_options.job_found")
        click_button I18n.t("buttons.submit_feedback")

        expect(page).to have_content(I18n.t("jobseekers.unsubscribe_feedbacks.create.success"))
      end
    end

    context "when there are no job alerts" do
      before do
        visit jobseekers_subscriptions_path
      end

      it "shows zero job alerts" do
        expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
      end
    end
  end

  context "when logged out" do
    before do
      visit jobseekers_subscriptions_path
    end

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
