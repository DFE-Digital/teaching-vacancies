require "rails_helper"

RSpec.describe "Jobseekers can update their profile from job applications" do
  include ActiveJob::TestHelper

  let(:vacancy) { create(:vacancy) }
  let(:application_qualification) { build(:qualification, name: "Application qualification") }
  let(:application_employment) { build(:employment, :current_role, job_title: "Application employment") }
  let(:application_training) { build(:training_and_cpd, name: "Application training") }
  let(:job_application) do
    create(:native_job_application, create_details: true, jobseeker: jobseeker, vacancy: vacancy,
                                    qualifications: [application_qualification], employments: [application_employment], training_and_cpds: [application_training])
  end

  context "when the jobseekers have a profile" do
    let(:jobseeker) { create(:jobseeker) }
    let(:profile_qualification) { build(:qualification, job_application: nil, name: "Original profile qualification") }
    let(:profile_employment) { build(:employment, job_application: nil, job_title: "Original profile employment") }
    let(:profile_training) { build(:training_and_cpd, job_application: nil, name: "Original profile training") }
    let!(:jobseeker_profile) do
      create(:jobseeker_profile, :with_trn, jobseeker: jobseeker, qualifications: [profile_qualification], employments: [profile_employment],
                                            training_and_cpds: [profile_training])
    end

    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_job_application_review_path(job_application)
      check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
      check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")
    end

    after { logout }

    scenario "jobseekers can update their profile qualifications using the job application information on submission" do
      check I18n.t("helpers.label.jobseekers_job_application_review_form.update_profile_options.1")
      click_on I18n.t("buttons.submit_application")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))

      click_link "Your profile"
      expect(page).to have_css("h3.govuk-summary-card__title", text: "Application qualification")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Original profile qualification")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Application employment")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Original profile employment")

      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Original profile training")
      expect(page).to have_css("h3.govuk-summary-card__title", text: "Application training")
    end
  end

  context "when the jobseekers do not have a profile" do
    let(:jobseeker) { create(:jobseeker, jobseeker_profile: nil) }

    scenario "they are not offered to update their qualifications or work history on submission" do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_job_application_review_path(job_application)
      expect(page.body).not_to have_content(I18n.t(".jobseekers.job_applications.review.confirmation.update_your_profile.heading"))
    end

    after { logout }
  end
end
