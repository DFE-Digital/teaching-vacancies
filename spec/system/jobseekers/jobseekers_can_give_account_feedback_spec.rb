require "rails_helper"

RSpec.describe "Jobseekers can give account feedback" do
  let(:jobseeker) { create(:jobseeker) }
  let(:comment) { "amazing account features!" }
  let(:occupation) { "Teaching assistant" }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  after { logout }

  it "submits account feedback" do
    click_on I18n.t("footer.provide_feedback")

    choose name: "jobseekers_account_feedback_form[report_a_problem]", option: "yes"
    choose I18n.t("helpers.label.jobseekers_account_feedback_form.rating_options.somewhat_satisfied")
    choose name: "jobseekers_account_feedback_form[user_participation_response]", option: "interested"
    fill_in "jobseekers_account_feedback_form[comment]", with: comment
    fill_in "jobseekers_account_feedback_form[occupation]", with: occupation

    expect { click_button I18n.t("buttons.submit") }.to change {
      jobseeker.feedbacks.where(comment: comment,
                                email: jobseeker.email,
                                rating: "somewhat_satisfied",
                                feedback_type: "jobseeker_account",
                                user_participation_response: "interested",
                                occupation: occupation,
                                origin_path: jobseekers_account_path).count
    }.by(1)
    expect(current_path).to eq(jobseekers_account_path)
    expect(page).to have_content(I18n.t("jobseekers.account_feedbacks.create.success"))
  end
end
