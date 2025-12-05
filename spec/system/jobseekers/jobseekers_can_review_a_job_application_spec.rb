require "rails_helper"

RSpec.describe "Jobseekers can review a job application" do
  include JobApplicationsHelper

  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_review_path(job_application)
  end

  after { logout }

  it "passes a11y", :a11y do
    expect(page).to be_axe_clean
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
      expect(page).to have_content(job_application.national_insurance_number)
      expect(page).to have_content(readable_working_patterns(job_application))
      expect(page).to have_content(job_application.working_pattern_details)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.professional_status.heading") do
      expect(page).to have_content(job_application.qualified_teacher_status.humanize)
      expect(page).to have_content(job_application.qualified_teacher_status_year)
      expect(page).to have_content(job_application.is_statutory_induction_complete? ? "Yes" : "No")
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.employment_history.heading") do
      job_application.employments.job.each do |employment|
        expect(page).to have_content(employment.job_title)
        expect(page).to have_content(employment.organisation)
        expect(page).to have_content(employment.subjects)
        expect(page).to have_content(employment.main_duties)
        expect(page).to have_content(employment.started_on.to_fs(:month_year))
        expect(page).to have_content(employment.is_current_role ? "Yes" : "No")
        expect(page).to have_content(employment.ended_on.to_fs(:month_year)) unless employment.is_current_role?
      end

      expect_work_history_to_be_ordered_most_recent_first
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.employment_history.heading") do
      job_application.employments.break.each do |employment|
        expect(page).to have_content(employment.reason_for_break)
        expect(page).to have_content(employment.started_on.to_fs(:month_year))
        expect(page).to have_content(employment.ended_on.to_fs(:month_year))
      end
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.personal_statement.heading") do
      expect(page).to have_content(job_application.personal_statement_richtext.to_plain_text)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.referees.heading") do
      job_application.referees.each do |referee|
        expect(page).to have_content(referee.name)
        expect(page).to have_content(referee.job_title)
        expect(page).to have_content(referee.organisation)
        expect(page).to have_content(referee.relationship)
        expect(page).to have_content(referee.email)
        expect(page).to have_content(referee.phone_number)
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
      expect(page).to have_content(job_application.is_support_needed? ? "Yes" : "No")
      expect(page).to have_content(job_application.support_needed_details)
    end

    within ".review-component__section", text: I18n.t("jobseekers.job_applications.build.declarations.heading") do
      expect(page).to have_content(job_application.has_close_relationships? ? "Yes" : "No")
      expect(page).to have_content(job_application.close_relationships_details)
      expect(page).to have_content(job_application.has_right_to_work_in_uk? ? "Yes" : "No")
    end
  end
end
