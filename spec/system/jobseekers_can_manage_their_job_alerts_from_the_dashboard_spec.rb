require "rails_helper"

RSpec.describe "Jobseekers can manage their job alerts from the dashboard" do
  let(:jobseeker) { create(:jobseeker) }

  context "when logged in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    context "when there are job alerts" do
      let!(:subscription) { create(:subscription, email: jobseeker.email, search_criteria: { keyword: "Maths" }) }

      before { visit jobseekers_subscriptions_path }

      it "shows job alerts" do
        expect(page).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.subscriptions.index.page_title"))
        expect(page).to have_css(".card-component", count: 1) do |card|
          expect(card).to have_css(".card-component__header", text: "KeywordMaths")
        end
      end

      context "when editing a job alert" do
        before { click_on I18n.t("jobseekers.subscriptions.index.link_manage") }

        it "edits the job alert and redirects to the dashboard" do
          fill_in "jobseekers_subscription_form[location]", with: "London"
          click_button I18n.t("buttons.update_alert")

          expect(page).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.subscriptions.index.page_title"))
          expect(page).to have_content(I18n.t("subscriptions.update.success"))
          expect(page).to have_css(".card-component", count: 1) do |card|
            expect(card).to have_css(".card-component__header", text: "KeywordMaths")
            expect(card).to have_css(".card-component__header", text: "LocationIn London")
          end
        end
      end

      context "when unsubscribing to a job alert" do
        before { click_on I18n.t("jobseekers.subscriptions.index.link_unsubscribe") }

        it "unsubscribes from the job alert and redirects to the dashboard" do
          click_on I18n.t("buttons.unsubscribe")
          choose I18n.t("helpers.label.jobseekers_unsubscribe_feedback_form.unsubscribe_reason_options.job_found")
          choose name: "jobseekers_unsubscribe_feedback_form[user_participation_response]", option: "interested"
          click_button I18n.t("buttons.submit_feedback")

          expect(page).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.subscriptions.index.page_title"))
          expect(page).to have_content(I18n.t("jobseekers.unsubscribe_feedbacks.create.success"))
          expect(page).not_to have_css(".card-component")
          expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
        end
      end
    end

    context "when there are no job alerts" do
      before { visit jobseekers_subscriptions_path }

      it "shows zero job alerts" do
        expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
      end
    end
  end

  context "when logged out" do
    before { visit jobseekers_subscriptions_path }

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
