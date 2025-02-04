require "rails_helper"

RSpec.describe "Jobseekers can prefill applications" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, :published, :at_one_school) }
  let(:school) { vacancy.organisation_vacancies.first.organisation }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  context "when the jobseeker has a completed profile" do
    let(:profile) { create(:jobseeker_profile, :completed, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020") }
    let(:jobseeker) { profile.jobseeker }
    let(:current_job_application) { JobApplication.order(:created_at).last }

    context "and when the jobseeker also has a previous application" do
      let(:reference) { create(:reference, job_title: "Reference4Testing") }
      let(:employment1) { create(:employment) }
      let(:employment2) { create(:employment) }
      let(:qualification1) { create(:qualification) }
      let(:qualification2) { create(:qualification) }
      let(:training) { create(:training_and_cpd) }
      let!(:previous_application) do
        create(:job_application, :status_submitted, jobseeker:, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020", created_at: 1.year.ago,
                                                    references: [reference], employments: [employment1, employment2], qualifications: [qualification1, qualification2])
      end

      it "prefills the new application with the previous application details, not the profile details and marks steps as imported`" do
        visit job_path(vacancy.id)

        within ".banner-buttons" do
          click_on I18n.t("jobseekers.saved_jobs.index.apply")
        end

        click_on I18n.t("buttons.start_application")

        expect(page).to have_content("Your details have been imported from your last job application.")

        expect(current_job_application.first_name).to eq(previous_application.first_name)
        expect(current_job_application.last_name).to eq(previous_application.last_name)
        expect(current_job_application.phone_number).to eq(previous_application.phone_number)
        within("#personal_details") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end

        # saving converts 'imported' sections to 'completed'
        click_on "Personal statement"
        expect(page).to have_content(previous_application.personal_statement)
        click_on "Save and continue"
        within("#personal_statement") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--green", text: I18n.t("shared.status_tags.complete"))
        end

        # qualified teacher status
        expect(current_job_application.qualified_teacher_status).to eq("yes")
        expect(current_job_application.qualified_teacher_status_year).to eq("2020")
        # skilled worker visa sponsorship
        expect(current_job_application.right_to_work_in_uk).to eq("yes")

        within("#professional_status") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end
        # references
        click_on "References"
        expect(page).to have_content(reference.job_title)
        expect(page).to have_content(reference.organisation)
        expect(page).to have_content(reference.relationship)
        click_on "Back"
        # work history
        click_on "Work history"
        expect(page).to have_content(employment1.main_duties)
        expect(page).to have_content(employment1.organisation)
        expect(page).to have_content(employment2.main_duties)
        expect(page).to have_content(employment2.organisation)
        click_on "Back"
        within("#employment_history") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end

        click_on "Qualifications"
        previous_application.qualifications.each do |qualification|
          expect(page).to have_content(I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{qualification.category}"))
          expect(page).to have_content(qualification.institution)
          if qualification.display_attributes.include?("grade")
            expect(page).to have_content("(#{qualification.grade})")
          end
        end
        click_on "Back"

        within("#qualifications") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end

        click_on I18n.t("jobseekers.job_applications.build.training_and_cpds.heading")
        expect(page).to have_content(training.name)
        expect(page).to have_content(training.provider)
        expect(page).to have_content(training.grade)
        expect(page).to have_content(training.year_awarded)
        click_on "Back"

        within("#training_and_cpds") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end

        click_on I18n.t("jobseekers.job_applications.build.ask_for_support.heading")
        expect(page).to have_content(previous_application.support_needed.capitalize)
        expect(page).to have_content(previous_application.support_needed_details)
        click_on "Back"
        within("#ask_for_support") do
          expect(page).to have_css("strong.govuk-tag.govuk-tag--blue", text: I18n.t("shared.status_tags.imported"))
        end
      end
    end

    context "when the jobseeeker does not have a previous application" do
      it "prefills the application form with the jobseeker's profile details" do
        visit job_path(vacancy.id)

        within ".banner-buttons" do
          click_on I18n.t("jobseekers.saved_jobs.index.apply")
        end

        click_on I18n.t("buttons.start_application")

        expect(current_job_application.first_name).to eq(profile.personal_details.first_name)
        expect(current_job_application.last_name).to eq(profile.personal_details.last_name)
        expect(current_job_application.phone_number).to eq(profile.personal_details.phone_number)

        expect(current_job_application.qualified_teacher_status_year).to eq(profile.qualified_teacher_status_year)

        click_on "Qualifications"
        expect(page).to have_content(profile.qualifications.first.institution)
        profile.qualifications.each do |qualification|
          expect(page).to have_content(I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{qualification.category}"))
          expect(page).to have_content(qualification.institution)
          if qualification.display_attributes.include?("grade")
            expect(page).to have_content("(#{qualification.grade})")
          end
        end
        click_on "Back"

        click_on "Work history"
        expect(page).to have_content(profile.employments.first.job_title)
        expect(page).to have_content(profile.employments.first.subjects)
        click_on "Back"
      end
    end
  end

  context "when the jobseeker has neither previous application nor completed profile" do
    it "doesn't prefill anything" do
      visit job_path(vacancy.id)

      within ".banner-buttons" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
      end

      click_on I18n.t("buttons.start_application")

      click_on "Personal details"
      expect(page).to have_field("jobseekers_job_application_personal_details_form[first_name]")
      expect(page.find("#jobseekers-job-application-personal-details-form-first-name-field").value).to be_blank
    end
  end
end
