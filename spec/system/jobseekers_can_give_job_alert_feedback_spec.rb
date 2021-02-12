require "rails_helper"

RSpec.shared_examples "a correctly created Feedback" do
  it "creates a Feedback with the correct attributes" do
    expect(feedback.relevant_to_user).to eq relevant_to_user
    expect(feedback.search_criteria).to eq subscription.search_criteria
    expect(feedback.job_alert_vacancy_ids).to contain_exactly(vacancies.first.id, vacancies.second.id)
    expect(feedback.subscription_id).to eq subscription.id
  end
end

RSpec.describe "A jobseeker can give feedback on a job alert", recaptcha: true do
  let(:search_criteria) { { keyword: "Math", location: "London" } }
  let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily, search_criteria: search_criteria) }
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
      context "and follows a link from an old job alert email with different parameter names/formats" do
        # TODO: Remove this context after e.g. 30 days.

        let(:search_criteria) { { keyword: "Math", location: "London" }.to_json }

        before { follow_a_link_from_an_old_job_alert_email }

        it_behaves_like "a correctly created Feedback"
      end

      context "and follows the link in the job alert email" do
        before { follow_the_link_in_the_job_alert_email }

        it_behaves_like "a correctly created Feedback"

        it "renders the page title and notification" do
          expect(page.title).to have_content(I18n.t("jobseekers.job_alert_feedbacks.edit.title"))
          expect(page).to have_content(I18n.t("jobseekers.job_alert_feedbacks.new.success"))
        end
      end

      it "triggers a RequestEvent of type 'feedback_provided'" do
        expect { follow_the_link_in_the_job_alert_email }
          .to have_triggered_event(:feedback_provided)
          .with_data(feedback_type: "job_alert",
                     subscription_id: subscription.id,
                     search_criteria: json_including(subscription.search_criteria),
                     job_alert_vacancy_ids: job_alert_vacancy_ids,
                     relevant_to_user: relevant_to_user.to_s)
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

      it "triggers a RequestEvent of type 'feedback_provided'" do
        expect { follow_the_link_in_the_job_alert_email }
          .to have_triggered_event(:feedback_provided)
                .with_data(feedback_type: "job_alert",
                           subscription_id: subscription.id,
                           search_criteria: json_including(subscription.search_criteria),
                           job_alert_vacancy_ids: job_alert_vacancy_ids,
                           relevant_to_user: relevant_to_user.to_s)
      end
    end

    context "when submitting further feedback" do
      let(:comment) { "Excellent" }

      before do
        follow_the_link_in_the_job_alert_email
        fill_in "jobseekers_job_alert_further_feedback_form[comment]", with: comment
      end

      it "allows the user to submit further feedback" do
        click_button I18n.t("buttons.submit")
        expect(current_path).to eq root_path
        expect(page).to have_content(I18n.t("jobseekers.job_alert_feedbacks.update.success"))
        expect(feedback.comment).to eq comment
      end

      it "triggers a RequestEvent of type 'feedback_provided'" do
        expect { click_button I18n.t("buttons.submit") }
          .to have_triggered_event(:feedback_provided)
                .with_data(recaptcha_score: 0.9,
                           comment: comment,
                           search_criteria: json_including(subscription.search_criteria),
                           subscription_id: subscription.id,
                           feedback_type: "job_alert")
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
      params: { job_alert_feedback: { relevant_to_user: relevant_to_user,
                                      job_alert_vacancy_ids: job_alert_vacancy_ids,
                                      search_criteria: search_criteria } },
    )
  end

  def follow_a_link_from_an_old_job_alert_email
    # TODO: Remove this method after e.g. 30 days.

    visit new_subscription_job_alert_feedback_url(
      token,
      params: { job_alert_feedback: { relevant_to_user: relevant_to_user,
                                      vacancy_ids: job_alert_vacancy_ids,
                                      search_criteria: search_criteria } },
    )
  end
end
