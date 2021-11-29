require "rails_helper"

RSpec.describe "Jobseekers can give account feedback" do
  let(:jobseeker) { create(:jobseeker) }
  let(:comment) { "amazing account features!" }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  it "submits account feedback" do
    click_on I18n.t("jobseekers.account_survey_link_component.survey_link")

    choose name: "jobseekers_account_feedback_form[report_a_problem]", option: "yes"
    choose I18n.t("helpers.label.jobseekers_account_feedback_form.rating_options.somewhat_satisfied")
    choose name: "jobseekers_account_feedback_form[user_participation_response]", option: "interested"
    fill_in "jobseekers_account_feedback_form[comment]", with: comment

    expect { click_button I18n.t("buttons.submit") }.to change {
      jobseeker.feedbacks.where(comment: comment, email: jobseeker.email, rating: "somewhat_satisfied", feedback_type: "jobseeker_account", user_participation_response: "interested").count
    }.by(1)
    expect(current_path).to eq(jobseekers_account_path)
    expect(page).to have_content(I18n.t("jobseekers.account_feedbacks.create.success"))
  end
end
