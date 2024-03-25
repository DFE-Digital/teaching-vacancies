require "rails_helper"

RSpec.describe "Jobseekers can view a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_path(job_application)
  end

  context "when the vacancy is for a teaching role" do
    let(:vacancy) { create(:vacancy, organisations: [build(:school)], job_roles: ["teacher"]) }

    it "displays all the relevant job application information (including professional status data)" do
      expect(page).to have_content(vacancy.job_title)
      expect(page).to have_content(job_application.status)

      within ".navigation-list-component", text: I18n.t("jobseekers.job_applications.show.application_sections") do
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.personal_details.heading"), href: "#personal_details")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.professional_status.heading"), href: "#professional_status")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.qualifications.heading"), href: "#qualifications")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.employment_history.heading"), href: "#employment_history")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.personal_statement.heading"), href: "#personal_statement")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.references.heading"), href: "#references")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.ask_for_support.heading"), href: "#ask_for_support")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.declarations.heading"), href: "#declarations")
      end

      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.personal_details.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.professional_status.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.qualifications.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.employment_history.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.personal_statement.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.references.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.ask_for_support.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.declarations.heading"))

      expect_work_history_to_be_ordered_most_recent_first

      within ".timeline-component__item", text: I18n.t("jobseekers.job_applications.status_timestamps.submitted") do
        expect(page).to have_content("#{format_date(job_application.submitted_at.to_date)} at #{format_time(job_application.submitted_at)}")
      end
    end
  end

  context "when the vacancy is for a non-teaching role" do
    let(:vacancy) { create(:vacancy, organisations: [build(:school)], job_roles: ["other_support"]) }

    it "displays all the relevant job application information (does not include professional status data)" do
      expect(page).to have_content(vacancy.job_title)
      expect(page).to have_content(job_application.status)

      within ".navigation-list-component", text: I18n.t("jobseekers.job_applications.show.application_sections") do
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.personal_details.heading"), href: "#personal_details")
        expect(page).not_to have_link(I18n.t("jobseekers.job_applications.show.professional_status.heading"), href: "#professional_status")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.qualifications.heading"), href: "#qualifications")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.employment_history.heading"), href: "#employment_history")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.personal_statement.heading"), href: "#personal_statement")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.references.heading"), href: "#references")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.ask_for_support.heading"), href: "#ask_for_support")
        expect(page).to have_link(I18n.t("jobseekers.job_applications.show.declarations.heading"), href: "#declarations")
      end

      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.personal_details.heading"))
      expect(page).not_to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.professional_status.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.qualifications.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.employment_history.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.personal_statement.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.references.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.ask_for_support.heading"))
      expect(page).to have_css(".review-component__section", text: I18n.t("jobseekers.job_applications.show.declarations.heading"))

      expect_work_history_to_be_ordered_most_recent_first

      within ".timeline-component__item", text: I18n.t("jobseekers.job_applications.status_timestamps.submitted") do
        expect(page).to have_content("#{format_date(job_application.submitted_at.to_date)} at #{format_time(job_application.submitted_at)}")
      end
    end
  end

  context "when job application status is shortlisted" do
    let(:job_application) { create(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy) }

    it "displays what happens next notification and shortlisted date" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.show.shortlist_alert.title"))

      within ".timeline-component" do
        expect(page).to have_content(I18n.t("jobseekers.job_applications.status_timestamps.shortlisted"))

        within ".timeline-component__item", text: I18n.t("jobseekers.job_applications.status_timestamps.shortlisted") do
          expect(page).to have_content(format_date(job_application.shortlisted_at.to_date))
        end
      end
    end
  end

  context "when job application status is unsuccessful" do
    let(:job_application) { create(:job_application, :status_unsuccessful, jobseeker: jobseeker, vacancy: vacancy) }

    it "displays feedback and unsuccessful date" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.show.feedback"))
      expect(page).to have_content(job_application.rejection_reasons)

      within ".timeline-component" do
        expect(page).to have_content(I18n.t("jobseekers.job_applications.status_timestamps.unsuccessful"))

        within ".timeline-component__item", text: I18n.t("jobseekers.job_applications.status_timestamps.unsuccessful") do
          expect(page).to have_content(format_date(job_application.unsuccessful_at.to_date))
        end
      end
    end
  end
end
