require "rails_helper"

RSpec.describe "A jobseeker can unsubscribe from subscriptions" do
  let(:subscription) { create(:subscription) }
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:occupation) { "teacher" }

  context "with the correct token" do
    before do
      visit unsubscribe_subscription_path(token)
      click_on I18n.t("buttons.unsubscribe")
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

    context "when jobseeker is not signed in" do
      context "with a blank form" do
        it "generates an error" do
          click_on I18n.t("buttons.submit_feedback")

          expect(page).to have_content("There is a problem")
        end
      end

      context "with valid data" do
        before do
          fill_in "jobseekers_unsubscribe_feedback_form[comment]", with: "Eggs"
          choose name: "jobseekers_unsubscribe_feedback_form[user_participation_response]", option: "interested"
          fill_in "jobseekers_unsubscribe_feedback_form[email]", with: email
          fill_in "jobseekers_unsubscribe_feedback_form[occupation]", with: occupation
        end

        context "with other reason" do
          it "allows the user to provide feedback and redirects to the jobs path" do
            choose "jobseekers-unsubscribe-feedback-form-unsubscribe-reason-other-reason-field"
            fill_in "jobseekers_unsubscribe_feedback_form[other_unsubscribe_reason_comment]", with: "Spam"

            expect { click_on I18n.t("buttons.submit_feedback") }.to change {
              subscription.feedbacks.where(comment: "Eggs",
                                           email: email,
                                           feedback_type: "unsubscribe",
                                           other_unsubscribe_reason_comment: "Spam",
                                           search_criteria: subscription.search_criteria,
                                           unsubscribe_reason: "other_reason",
                                           occupation: occupation).count
            }.by(1)

            click_on I18n.t("jobseekers.unsubscribe_feedbacks.confirmation.new_search_link")

            expect(current_path).to eq jobs_path
          end
        end

        context "with new job reason" do
          before do
            choose "jobseekers-unsubscribe-feedback-form-unsubscribe-reason-job-found-field"
          end

          it "errors without a comment" do
            click_on I18n.t("buttons.submit_feedback")

            expect(page).to have_content("There is a problem")
          end

          it "allows the user to provide feedback" do
            fill_in "jobseekers_unsubscribe_feedback_form[job_found_unsubscribe_reason_comment]", with: "NewJob"

            expect { click_on I18n.t("buttons.submit_feedback") }.to change {
              subscription.feedbacks.where(comment: "Eggs",
                                           email: email,
                                           feedback_type: "unsubscribe",
                                           job_found_unsubscribe_reason_comment: "NewJob",
                                           search_criteria: subscription.search_criteria,
                                           unsubscribe_reason: "job_found",
                                           occupation: occupation).count
            }.by(1)
          end
        end
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
