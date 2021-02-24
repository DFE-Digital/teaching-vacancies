require "rails_helper"

RSpec.describe "Jobseekers can give job application feedback after submitting the application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :complete, jobseeker: jobseeker, vacancy: vacancy) }
  let(:comment) { "I will never use any other website again" }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to give job application feedback after submitting the application" do
    visit jobseekers_job_application_review_path(job_application)

    check "Confirm data accurate"
    check "Confirm data usage"

    click_on I18n.t("buttons.submit_application")
    choose I18n.t("helpers.label.jobseekers_job_application_feedback_form.rating_options.somewhat_satisfied")
    fill_in "jobseekers_job_application_feedback_form[comment]", with: comment

    expect { click_button I18n.t("buttons.submit") }.to have_triggered_event(:feedback_provided)
      .with_base_data(
        user_anonymised_jobseeker_id: StringAnonymiser.new(jobseeker.id).to_s,
      ).and_data(comment: comment,
                 feedback_type: "application",
                 rating: "somewhat_satisfied")

    # TODO: Update this expectation when the 'my applications' page has been created.
    expect(current_path).to be_a(String)

    expect(page).to have_content(I18n.t("jobseekers.job_applications.feedbacks.create.success"))
  end
end
