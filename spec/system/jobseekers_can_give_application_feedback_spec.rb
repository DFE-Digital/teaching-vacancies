require "rails_helper"

RSpec.describe "Jobseekers can give job application feedback after submitting the application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }
  let(:comment) { "I will never use any other website again" }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to give job application feedback after submitting the application" do
    visit jobseekers_job_application_review_path(job_application)

    check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
    check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

    click_on I18n.t("buttons.submit_application")
    click_on I18n.t("buttons.submit_feedback")

    expect(page).to have_content("There is a problem")

    choose I18n.t("helpers.label.jobseekers_job_application_feedback_form.rating_options.somewhat_satisfied")
    choose I18n.t("helpers.label.jobseekers_job_application_feedback_form.user_participation_response_options.interested")
    fill_in "jobseekers_job_application_feedback_form[comment]", with: comment

    expect { click_on I18n.t("buttons.submit_feedback") }.to change {
      jobseeker.feedbacks.where(comment: comment, email: jobseeker.email, feedback_type: "application", rating: "somewhat_satisfied", user_participation_response: "interested").count
    }.by(1)

    expect(current_path).to eq(jobseekers_job_applications_path)

    expect(page).to have_content(I18n.t("jobseekers.job_applications.feedbacks.create.success"))
  end
end
