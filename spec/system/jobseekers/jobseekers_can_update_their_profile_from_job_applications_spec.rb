require "rails_helper"

RSpec.describe "Jobseekers can update their profile from job applications" do
  include ActiveJob::TestHelper

  let(:vacancy) { create(:vacancy) }
  let(:application_qualification) { create(:qualification, name: "Application qualification") }
  let(:application_employment) { create(:employment, job_title: "Application employment") }
  let(:application_training) { create(:training_and_cpd, name: "Application training") }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy, qualifications: [application_qualification], employments: [application_employment], training_and_cpds: [application_training], training_and_cpds_section_completed: true) }

  context "when the jobseekers have a profile" do
    let(:jobseeker) { create(:jobseeker) }
    let(:profile_qualification) { create(:qualification, name: "Original profile qualification") }
    let(:profile_employment) { create(:employment, job_title: "Original profile employment") }
    let(:profile_training) { create(:training_and_cpd, name: "Original profile training") }
    let!(:jobseeker_profile) { create(:jobseeker_profile, :with_trn, jobseeker: jobseeker, qualifications: [profile_qualification], employments: [profile_employment], training_and_cpds: [profile_training]) }

    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_job_application_review_path(job_application)
      check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
      check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")
    end

    scenario "jobseekers can update their profile qualifications using the job application information on submission" do
      check I18n.t("helpers.label.jobseekers_job_application_review_form.update_profile_options.qualifications")
      click_on I18n.t("buttons.submit_application")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.submit.panel.title"))

      click_link "Your profile"
      expect(page).to have_css("h3.govuk-summary-card__title", text: "Application qualification")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Original profile qualification")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile employment")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application employment")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile training")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application training")
    end

    scenario "jobseekers can update their profile work history using the job application information on submission" do
      check I18n.t("helpers.label.jobseekers_job_application_review_form.update_profile_options.work_history")
      click_on I18n.t("buttons.submit_application")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.submit.panel.title"))

      click_link "Your profile"

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile qualification")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application qualification")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Application employment")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Original profile employment")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile training")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application training")
    end

    scenario "jobseekers can update their profile training and cpd using the job application information on submission" do
      check I18n.t("helpers.label.jobseekers_job_application_review_form.update_profile_options.training_and_cpds")
      click_on I18n.t("buttons.submit_application")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.submit.panel.title"))

      click_link "Your profile"

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile qualification")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application qualification")

      expect(page).to have_css("h3.govuk-summary-card__title", text: "Original profile employment")
      expect(page).not_to have_css("h3.govuk-summary-card__title", text: "Application employment")

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
  end
end
