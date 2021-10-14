require "rails_helper"

RSpec.describe "Jobseekers can view a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_path(job_application)
  end

  it "displays all the job application information" do
    within ".banner-component" do
      expect(page).to have_content(vacancy.job_title)
      expect(page).to have_content(job_application.status)
    end

    within ".grey-border-box", text: I18n.t("jobseekers.job_applications.show.school_details.heading") do
      expect(page).to have_content(vacancy.parent_organisation_name)
      expect(page).to have_content(vacancy.parent_organisation.school_type)
      expect(page).to have_content(vacancy.contact_number)
      expect(page).to have_content(vacancy.contact_email)
      expect(page).to have_content(vacancy.parent_organisation.url)
      expect(page).to have_content(full_address(vacancy.parent_organisation))
    end

    within ".navigation-list-component", text: I18n.t("shared.job_application.show.application_sections") do
      expect(page).to have_link(I18n.t("shared.job_application.show.personal_details.heading"), href: "#personal_details_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.professional_status.heading"), href: "#professional_status_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.qualifications.heading"), href: "#qualifications_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.employment_history.heading"), href: "#employment_history_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.personal_statement.heading"), href: "#personal_statement_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.references.heading"), href: "#references_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.ask_for_support.heading"), href: "#ask_for_support_summary")
      expect(page).to have_link(I18n.t("shared.job_application.show.declarations.heading"), href: "#declarations_summary")
    end

    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.personal_details.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.professional_status.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.qualifications.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.employment_history.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.personal_statement.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.references.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.ask_for_support.heading"))
    expect(page).to have_css(".review-component", text: I18n.t("shared.job_application.show.declarations.heading"))

    within ".timeline-component__item", text: I18n.t("jobseekers.job_applications.status_timestamps.submitted") do
      expect(page).to have_content("#{format_date(job_application.submitted_at.to_date)} at #{format_time(job_application.submitted_at)}")
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
