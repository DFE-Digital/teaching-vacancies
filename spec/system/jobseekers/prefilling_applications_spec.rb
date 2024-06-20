require "rails_helper"

RSpec.describe "Jobseekers can prefill applications" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, :published, :at_one_school) }
  let(:school) { vacancy.organisation_vacancies.first.organisation }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  context "when the jobseeker has a completed profile" do
    let(:profile) { create(:jobseeker_profile, :completed, qualified_teacher_status: "yes") }
    let(:jobseeker) { profile.jobseeker }

    it "prefills the application form with the jobseeker's details" do
      visit job_path(vacancy.id)

      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      expect(page).to have_content("Your details have been imported from your last job application or profile")

      click_on I18n.t("buttons.start_application")

      expect(page).to have_content(profile.personal_details.first_name)
      expect(page).to have_content(profile.personal_details.last_name)
      expect(page).to have_content(profile.personal_details.phone_number)
      expect(page).to have_content(profile.qualified_teacher_status_year)
      expect(page).to have_content(profile.qualifications.first.institution)
      expect(page).to have_content(profile.employments.first.job_title)
      expect(page).to have_content(profile.employments.first.subjects)
    end

    context "and the jobseeker has a previous application" do
      before do
        create(:job_application, :status_submitted, jobseeker:)
      end

      it "prefers the jobseeker's profile details over the previous application" do
        visit job_path(vacancy.id)

        within ".banner-buttons" do
          click_on I18n.t("jobseekers.saved_jobs.index.apply")
        end

        click_on I18n.t("buttons.start_application")

        expect(page).to have_content(profile.personal_details.first_name)
        expect(page).to have_content(profile.personal_details.last_name)
        expect(page).to have_content(profile.personal_details.phone_number)
      end
    end
  end

  context "when the jobseeker has a previous application" do
    let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

    it "uses the details from the previous application" do
      visit job_path(vacancy.id)

      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      expect(page).to have_content("We saved your information from the last job you applied for")

      click_on I18n.t("buttons.start_application")

      expect(page).to have_content(previous_application.first_name)
      expect(page).to have_content(previous_application.last_name)
      expect(page).to have_content(previous_application.phone_number)
    end
  end

  context "when the jobseeker has neither previous application nor completed profile" do
    it "doesn't prefill anything" do
      visit job_path(vacancy.id)

      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      click_on I18n.t("buttons.start_application")

      expect(page).to have_field("jobseekers_job_application_personal_details_form[first_name]")
      expect(page.find("#jobseekers-job-application-personal-details-form-first-name-field").value).to be_blank
    end
  end
end
