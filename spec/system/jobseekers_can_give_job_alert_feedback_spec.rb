require "rails_helper"

RSpec.shared_examples "a correctly created Feedback" do
  it "creates a Feedback with the correct attributes" do
    expect(feedback.feedback_type).to eq("job_alert")
    expect(feedback.relevant_to_user).to eq relevant_to_user
    expect(feedback.search_criteria).to eq subscription.search_criteria
    expect(feedback.job_alert_vacancy_ids).to contain_exactly(vacancies.first.id, vacancies.second.id)
    expect(feedback.subscription_id).to eq subscription.id
  end
end

RSpec.describe "A jobseeker can give feedback on a job alert", recaptcha: true do
  let(:search_criteria) { { keyword: "Math", location: "London" } }
  let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily, search_criteria:) }
  let(:relevant_to_user) { true }
  let(:vacancies) { create_list(:vacancy, 2, :published) }
  let(:job_alert_vacancy_ids) { vacancies.pluck(:id) }
  let(:verify_recaptcha) { true }

  before do
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(verify_recaptcha)
  end

  context "with the correct token" do
    let(:token) { subscription.token }
    let(:feedback) { Feedback.where(subscription_id: subscription.id).first }

    context "when the user selects Yes" do
      context "and follows the link in the job alert email" do
        before { follow_the_link_in_the_job_alert_email }

        it_behaves_like "a correctly created Feedback"

        it "renders the page title and notification" do
          expect(page.title).to have_content(I18n.t("jobseekers.job_alert_feedbacks.edit.title"))
          expect(page).to have_content(I18n.t("jobseekers.job_alert_feedbacks.new.success"))
        end
      end
    end

    context "when the user selects No" do
      let(:relevant_to_user) { false }

      context "and follows the link in the job alert email" do
        before { follow_the_link_in_the_job_alert_email }

        it "shows a link to edit the job alert" do
          click_on I18n.t("jobseekers.job_alert_feedbacks.edit.change_alert_link")
          expect(page).to have_content I18n.t("subscriptions.edit.title")
        end

        it_behaves_like "a correctly created Feedback"

        it "renders the page title and notification" do
          expect(page.title).to have_content(I18n.t("jobseekers.job_alert_feedbacks.edit.title"))
          expect(page).to have_content(I18n.t("jobseekers.job_alert_feedbacks.new.success"))
        end
      end
    end

    context "when submitting further feedback" do
      let(:comment) { "Excellent" }
      let(:email) { subscription.email }

      before do
        follow_the_link_in_the_job_alert_email
        fill_in "jobseekers_job_alert_further_feedback_form[comment]", with: comment
        choose name: "jobseekers_job_alert_further_feedback_form[user_participation_response]", option: "interested"
        fill_in "email", with: email
      end

      it "allows the user to submit further feedback" do
        click_button I18n.t("buttons.submit")
        expect(current_path).to eq root_path
        expect(page).to have_content(I18n.t("jobseekers.job_alert_feedbacks.update.success"))
        expect(feedback.comment).to eq comment
        expect(feedback.email).to eq email
        expect(feedback.user_participation_response).to eq("interested")
        expect(feedback.recaptcha_score).to eq(0.9)
      end

      context "when recaptcha is invalid" do
        let(:verify_recaptcha) { false }

        before { click_button I18n.t("buttons.submit") }

        context "and the form is valid" do
          scenario "redirects to invalid_recaptcha path" do
            expect(page).to have_current_path(invalid_recaptcha_path(form_name: "Jobseekers job alert further feedback form"))
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
    before { follow_the_link_in_the_job_alert_email }

    let(:token) { subscription.id }

    it "returns not found" do
      expect(page.status_code).to eq(404)
    end
  end

  context "with an old token" do
    before { follow_the_link_in_the_job_alert_email }

    let(:token) { subscription.token }

    scenario "still returns 200" do
      travel 3.days do
        expect(page.status_code).to eq(200)
      end
    end
  end

  def follow_the_link_in_the_job_alert_email
    visit new_subscription_job_alert_feedback_url(
      token,
      params: { job_alert_feedback: { relevant_to_user:,
                                      job_alert_vacancy_ids:,
                                      search_criteria: } },
    )
  end
end
