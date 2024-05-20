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

      expect(page).to have_content("You have recently made a candidate profile")

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
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, statutory_induction_complete: "on_track", support_needed: "no") }
      # let!(:reference1) { create(:reference, :reference1, job_application: previous_application) }
      # let!(:reference2) { create(:reference, :reference2, job_application: previous_application) }

      before do
        visit job_path(vacancy.id)

        within ".banner-buttons" do
          click_on I18n.t("jobseekers.saved_jobs.index.apply")
        end

        click_on I18n.t("buttons.start_application")
      end

      it "prefers the jobseeker's profile details over the previous application, but populates any missing fields from the previous application" do
        expect(page).to have_content(profile.personal_details.first_name)
        expect(page).to have_content(profile.personal_details.last_name)
        expect(page).to have_content(profile.personal_details.phone_number)
        expect(page).to have_content(profile.qualified_teacher_status_year)
        expect(page).to have_content(profile.qualifications.first.institution)
        expect(page).to have_content(profile.employments.first.job_title)
        expect(page).to have_content(profile.employments.first.subjects)
        expect(page).to have_content(previous_application.street_address)
        expect(page).to have_content(previous_application.teacher_reference_number)
        expect(page).to have_content(previous_application.national_insurance_number)
        expect(page).to have_css('dd.govuk-summary-list__value #support_needed', text: 'No')
        expect(page).to have_content(previous_application.references.first.name)
        expect(page).to have_content(previous_application.references.second.name)
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
      expect(page).to have_content(previous_application.street_address)
      expect(page).to have_content(previous_application.teacher_reference_number)
      expect(page).to have_content(previous_application.national_insurance_number)
      expect(page).to have_css('dd.govuk-summary-list__value #support_needed', text: 'No')
      expect(page).to have_content(previous_application.references.first.name)
      expect(page).to have_content(previous_application.references.second.name)
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
