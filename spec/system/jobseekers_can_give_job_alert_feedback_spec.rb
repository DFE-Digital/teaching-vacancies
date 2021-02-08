require "rails_helper"

RSpec.describe "A jobseeker can give feedback on a job alert", recaptcha: true do
  let(:search_criteria) { { keyword: "Math", location: "London" } }
  let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily, search_criteria: search_criteria) }
  let(:relevant_to_user) { true }
  let(:vacancies) { create_list(:vacancy, 2, :published) }
  let(:verify_recaptcha) { true }

  before do
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(verify_recaptcha)
    # Follow the link in the job alert email
    visit new_subscription_job_alert_feedback_url(
      token,
      params: { job_alert_feedback: { relevant_to_user: relevant_to_user,
                                      vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end

  context "with the correct token" do
    let(:token) { subscription.token }
    let(:feedback) { subscription.job_alert_feedbacks.last }
    let(:activity) { feedback.activities.last }

    context "when the user selects Yes" do
      it "creates a JobAlertFeedback with the correct attributes" do
        expect(feedback.relevant_to_user).to eq true
        expect(feedback.search_criteria).to eq subscription.search_criteria
        expect(feedback.vacancy_ids).to include vacancies.first.id
        expect(feedback.vacancy_ids).to include vacancies.second.id
        expect(feedback.subscription_id).to eq subscription.id
      end

      it "audits the creation of the feedback" do
        expect(activity.key).to eq("job_alert_feedback.create")
      end

      it "renders the page title and notification" do
        expect(page.title).to have_content(I18n.t("job_alert_feedbacks.edit.title"))
        expect(page).to have_content(I18n.t("job_alert_feedbacks.new.success"))
      end
    end

    context "when the user selects No" do
      let(:relevant_to_user) { false }

      it "creates a JobAlertFeedback with the correct attributes" do
        expect(feedback.relevant_to_user).to eq false
        expect(feedback.search_criteria).to eq subscription.search_criteria
        expect(feedback.vacancy_ids).to include vacancies.first.id
        expect(feedback.vacancy_ids).to include vacancies.second.id
        expect(feedback.subscription_id).to eq subscription.id
      end

      it "shows a link to edit the job alert" do
        click_on I18n.t("job_alert_feedbacks.edit.change_alert_link")
        expect(page).to have_content I18n.t("subscriptions.edit.title")
      end

      it "audits the creation of the feedback" do
        expect(activity.key).to eq("job_alert_feedback.create")
      end

      it "renders the page title and notification" do
        expect(page.title).to have_content(I18n.t("job_alert_feedbacks.edit.title"))
        expect(page).to have_content(I18n.t("job_alert_feedbacks.new.success"))
      end
    end

    context "when submitting further feedback" do
      let(:comment) { "Excellent" }

      before do
        fill_in "jobseekers_job_alert_feedback_form[comment]", with: comment
        click_on "Submit"
      end

      it "allows the user to submit further feedback" do
        expect(current_path).to eq root_path
        expect(page).to have_content(I18n.t("job_alert_feedbacks.update.success"))
        expect(feedback.comment).to eq comment
      end

      it "audits the update" do
        expect(activity.key).to eq("job_alert_feedback.update")
      end

      context "when recaptcha is invalid" do
        let(:verify_recaptcha) { false }

        context "and the form is valid" do
          scenario "redirects to invalid_recaptcha path" do
            expect(page).to have_current_path(invalid_recaptcha_path(form_name: "Job alert feedback"))
          end
        end

        context "and the form is invalid" do
          let(:comment) { nil }

          scenario "does not redirect to invalid_recaptcha path" do
            expect(page).to have_content("There is a problem")
          end
        end
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
