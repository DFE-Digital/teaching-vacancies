require "rails_helper"

RSpec.describe "Publishers can view a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  it "shows the timeline" do
    visit organisation_job_job_application_path(vacancy.id, job_application)

    expect_work_history_to_be_ordered_most_recent_first

    click_on I18n.t("buttons.shortlist")
    fill_in "publishers_job_application_update_status_form[further_instructions]", with: "Some further instructions"
    click_on I18n.t("buttons.shortlist")

    visit organisation_job_job_application_path(vacancy.id, job_application)

    click_on I18n.t("buttons.reject")
    fill_in "publishers_job_application_update_status_form[rejection_reasons]", with: "Horrible name"
    click_on I18n.t("buttons.confirm_rejection")

    visit organisation_job_job_application_path(vacancy.id, job_application)

    job_application.reload

    expect(page).to have_css(".timeline-component") do |timeline|
      expect(timeline).to have_css(".timeline-component__items", text: I18n.t("jobseekers.job_applications.status_timestamps.rejected")) do |item|
        expect(item).to have_content("#{format_date(job_application.unsuccessful_at.to_date)} at #{format_time(job_application.unsuccessful_at)}")
      end

      expect(timeline).to have_css(".timeline-component__items", text: I18n.t("jobseekers.job_applications.status_timestamps.shortlisted")) do |item|
        expect(item).to have_content("#{format_date(job_application.shortlisted_at.to_date)} at #{format_time(job_application.shortlisted_at)}")
      end

      expect(timeline).to have_css(".timeline-component__items", text: I18n.t("jobseekers.job_applications.status_timestamps.reviewed")) do |item|
        expect(item).to have_content("#{format_date(job_application.reviewed_at.to_date)} at #{format_time(job_application.reviewed_at)}")
      end

      expect(timeline).to have_css(".timeline-component__items", text: I18n.t("jobseekers.job_applications.status_timestamps.submitted")) do |item|
        expect(item).to have_content("#{format_date(job_application.submitted_at.to_date)} at #{format_time(job_application.submitted_at)}")
      end
    end
  end

  context "when the job application status is withdrawn" do
    let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

    it "redirects to a page notifying them that the application has been withdrawn" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      expect(page).to have_current_path(organisation_job_job_application_withdrawn_path(vacancy.id, job_application))
      expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.withdrawn.heading"))
      expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.withdrawn.view_more_applications"), href: organisation_job_job_applications_path(vacancy.id))
    end
  end

  context "when the job application status is unsuccessful" do
    let(:job_application) { create(:job_application, :status_unsuccessful, vacancy: vacancy) }

    it "shows the correct calls to action" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      within("#main-content") do
        expect(page).to have_css(".govuk-button-group") do |actions|
          expect(actions).not_to have_css("a", class: "govuk-button", text: I18n.t("buttons.shortlist"))
          expect(actions).not_to have_css("a", class: "govuk-button--warning", text: I18n.t("buttons.reject"))
          expect(actions).to have_css("a", class: "govuk-button--secondary", text: I18n.t("buttons.download_application"))
        end
      end
    end
  end

  context "when the job application status is shortlisted" do
    let(:job_application) { create(:job_application, :status_shortlisted, vacancy: vacancy) }

    it "shows the correct calls to action and timeline" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      within("#main-content") do
        expect(page).to have_css(".govuk-button-group") do |actions|
          expect(actions).not_to have_css("a", class: "govuk-button", text: I18n.t("buttons.shortlist"))
          expect(actions).to have_css("a", class: "govuk-button--warning", text: I18n.t("buttons.reject"))
          expect(actions).to have_css("a", class: "govuk-button--secondary", text: I18n.t("buttons.download_application"))
        end
      end
    end
  end

  context "when the job application status is submitted" do
    let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

    it "shows the correct calls to action and timeline" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      within("#main-content") do
        expect(page).to have_css(".govuk-button-group") do |actions|
          expect(actions).to have_css("a", class: "govuk-button", text: I18n.t("buttons.shortlist"))
          expect(actions).to have_css("a", class: "govuk-button--warning", text: I18n.t("buttons.reject"))
          expect(actions).to have_css("a", class: "govuk-button--secondary", text: I18n.t("buttons.download_application"))
        end
      end
    end
  end
end
