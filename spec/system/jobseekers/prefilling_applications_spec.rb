require "rails_helper"

RSpec.describe "Jobseekers can prefill applications" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, :published, :at_one_school) }
  let(:school) { vacancy.organisation_vacancies.first.organisation }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  context "when the jobseeker has a completed profile" do
    let(:profile) { create(:jobseeker_profile, :completed, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020") }
    let(:jobseeker) { profile.jobseeker }

    context "and when the jobseeker also has a previous application" do
      let(:reference) { create(:reference, job_title: "Reference4Testing") }
      let(:employment1) { create(:employment) }
      let(:employment2) { create(:employment) }
      let(:qualification1) { create(:qualification) }
      let(:qualification2) { create(:qualification) }
      let(:training) { create(:training_and_cpd) }
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020", 
                                                             references: [reference], employments: [employment1, employment2], qualifications: [qualification1, qualification2]) }

      it "prefills the new application with the previous application details, not the profile details" do
        visit job_path(vacancy.id)

      expect(page).to have_content("Your details have been imported from your last job application or profile")
      
      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      expect(page).to have_content("We saved your information from the last job you applied for")

      click_on I18n.t("buttons.start_application")

<<<<<<< HEAD
      expect(page).to have_content(previous_application.first_name)
      expect(page).to have_content(previous_application.last_name)
      expect(page).to have_content(previous_application.phone_number)
=======
        expect(page).to have_content(previous_application.first_name)
        expect(page).to have_content(previous_application.last_name)
        expect(page).to have_content(previous_application.phone_number)
        expect(page).to have_content(previous_application.personal_statement)
        # qualified teacher status
        expect(page).to have_content("Yes, awarded in 2020")
        # skilled worker visa sponsorship
        expect(page).to have_content("No, I already have the right to work in the UK")
        # references
        expect(page).to have_content(reference.job_title)
        expect(page).to have_content(reference.organisation)
        expect(page).to have_content(reference.relationship)
        # work history
        expect(page).to have_content(employment1.main_duties)
        expect(page).to have_content(employment1.organisation)
        expect(page).to have_content(employment2.main_duties)
        expect(page).to have_content(employment2.organisation)

        expect(page).to have_content(I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{qualification1.category}"))
        expect(page).to have_content(qualification1.institution)
        expect(page).to have_content(I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{qualification1.category}"))
        expect(page).to have_content(qualification2.institution)

        expect(page).to have_content(training.name)
        expect(page).to have_content(training.provider)
        expect(page).to have_content(training.grade)
        expect(page).to have_content(training.year_awarded)
>>>>>>> e685dce7a (Add specs)
      end
    end

    context "when the jobseeeker does not have a previous application" do
      it "prefills the application form with the jobseeker's profile details" do
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
    end
  end

  context "when the jobseeker has a previous application" do
    let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

    it "uses the details from the previous application" do
      visit job_path(vacancy.id)

      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      expect(page).to have_content("Your details have been imported from your last job application")

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
