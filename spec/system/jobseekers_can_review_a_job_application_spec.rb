require "rails_helper"

RSpec.describe "Jobseekers can review a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_review_path(job_application)
  end

  it "displays all the job application information" do
    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.personal_details.heading") do
      expect(page).to have_content(job_application.first_name)
      expect(page).to have_content(job_application.last_name)
      expect(page).to have_content(job_application.previous_names)
      expect(page).to have_content(job_application.street_address)
      expect(page).to have_content(job_application.city)
      expect(page).to have_content(job_application.postcode)
      expect(page).to have_content(job_application.country)
      expect(page).to have_content(job_application.phone_number)
      expect(page).to have_content(job_application.teacher_reference_number)
      expect(page).to have_content(job_application.national_insurance_number)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.professional_status.heading") do
      expect(page).to have_content(job_application.qualified_teacher_status.humanize)
      expect(page).to have_content(job_application.qualified_teacher_status_year)
      expect(page).to have_content(job_application.statutory_induction_complete.humanize)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.employment_history.heading") do
      job_application.employments.job.each do |employment|
        expect(page).to have_content(employment.job_title)
        expect(page).to have_content(employment.organisation)
        expect(page).to have_content(employment.subjects)
        expect(page).to have_content(employment.main_duties)
        expect(page).to have_content(employment.started_on)
        expect(page).to have_content(employment.current_role.humanize)
        expect(page).to have_content(employment.ended_on)
      end
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.employment_history.heading") do
      job_application.employments.break.each do |employment|
        expect(page).to have_content(employment.reason_for_break)
        expect(page).to have_content(employment.started_on.to_s(:month_year))
        expect(page).to have_content(employment.ended_on.to_s(:month_year))
      end
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.personal_statement.heading") do
      expect(page).to have_content(job_application.personal_statement)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.references.heading") do
      job_application.references.each do |reference|
        expect(page).to have_content(reference.name)
        expect(page).to have_content(reference.job_title)
        expect(page).to have_content(reference.organisation)
        expect(page).to have_content(reference.relationship)
        expect(page).to have_content(reference.email)
        expect(page).to have_content(reference.phone_number)
      end
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.equal_opportunities.heading") do
      expect(page).to have_content(job_application.disability.humanize)
      expect(page).to have_content(job_application.gender.humanize)
      expect(page).to have_content(job_application.gender_description)
      expect(page).to have_content(job_application.orientation.humanize)
      expect(page).to have_content(job_application.orientation_description)
      expect(page).to have_content(job_application.ethnicity.humanize)
      expect(page).to have_content(job_application.ethnicity_description)
      expect(page).to have_content(job_application.religion.humanize)
      expect(page).to have_content(job_application.religion_description)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.ask_for_support.heading") do
      expect(page).to have_content(job_application.support_needed.humanize)
      expect(page).to have_content(job_application.support_needed_details)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.declarations.heading") do
      expect(page).to have_content(job_application.close_relationships.humanize)
      expect(page).to have_content(job_application.close_relationships_details)
      expect(page).to have_content(job_application.right_to_work_in_uk.humanize)
    end
  end
end
