require "rails_helper"

RSpec.describe "Jobseekers can manage their job alerts from the dashboard" do
  let(:jobseeker) { create(:jobseeker) }

  let(:subscriptions_page) { PageObjects::Jobseekers::Subscriptions::Index.new }

  context "when logged in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    context "when there are job alerts" do
      let!(:subscription) { create(:subscription, email: jobseeker.email, search_criteria: { keyword: "Maths" }) }

      before { subscriptions_page.load }

      it "shows job alerts" do
        expect(subscriptions_page.heading).to have_content(I18n.t("jobseekers.subscriptions.index.page_title"))
        expect(subscriptions_page).to have_cards(count: 1)
        expect(subscriptions_page.cards[0].header).to have_content("KeywordMaths")
      end

      context "when editing a job alert" do
        before { subscriptions_page.cards[0].actions.links(text: I18n.t("jobseekers.subscriptions.index.link_manage")).first.click }

        it "edits the job alert and redirects to the dashboard" do
          fill_in "jobseekers_subscription_form[location]", with: "London"
          click_button I18n.t("buttons.update_alert")

          expect(subscriptions_page.heading).to have_content(I18n.t("jobseekers.subscriptions.index.page_title"))
          expect(subscriptions_page).to have_content(I18n.t("subscriptions.update.success"))
          expect(subscriptions_page.cards[0].header).to have_content("KeywordMaths")
          expect(subscriptions_page.cards[0].header).to have_content("LocationIn London")
        end
      end

      context "when unsubscribing to a job alert" do
        before { subscriptions_page.cards[0].actions.links(text: I18n.t("jobseekers.subscriptions.index.link_unsubscribe")).first.click }

        it "unsubscribes from the job alert and redirects to the dashboard" do
          click_on I18n.t("subscriptions.unsubscribe.button_text")
          choose I18n.t("helpers.label.jobseekers_unsubscribe_feedback_form.unsubscribe_reason_options.job_found")
          click_button I18n.t("buttons.submit_feedback")

          expect(subscriptions_page.heading).to have_content(I18n.t("jobseekers.subscriptions.index.page_title"))
          expect(subscriptions_page).to have_content(I18n.t("jobseekers.unsubscribe_feedbacks.create.success"))
          expect(subscriptions_page).not_to have_cards
          expect(subscriptions_page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
        end
      end
    end

    context "when there are no job alerts" do
      before { subscriptions_page.load }

      it "shows zero job alerts" do
        expect(subscriptions_page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
      end
    end
  end

  context "when logged out" do
    before { subscriptions_page.load }

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
