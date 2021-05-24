require "rails_helper"

RSpec.describe "Jobseekers can give account feedback" do
  let(:jobseeker) { create(:jobseeker) }
  let(:comment) { "amazing account features!" }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseeker_root_path
  end

  it "submits account feedback" do
    click_on I18n.t("jobseekers.account_survey_link_component.survey_link")

    choose I18n.t("helpers.label.jobseekers_account_feedback_form.rating_options.somewhat_satisfied")
    fill_in "jobseekers_account_feedback_form[comment]", with: comment
    expect { click_button I18n.t("buttons.submit") }.to change {
      jobseeker.feedbacks.where(comment: comment, rating: "somewhat_satisfied", feedback_type: "jobseeker_account").count
    }.by(1)
    expect(current_path).to eq(jobseeker_root_path)
    expect(page).to have_content(I18n.t("jobseekers.account_feedbacks.create.success"))
  end
end
