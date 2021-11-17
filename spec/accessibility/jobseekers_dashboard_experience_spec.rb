require "rails_helper"

RSpec.describe "Jobseeker dashboardexperience", type: :system, accessibility: true do
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let(:jobseeker_applications_enabled?) { false }

  before { login_as(jobseeker, scope: :jobseeker) }

  context "Jobseeker visits their dashboard and views account details" do
    before { visit jobseekers_account_path }

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end

  context "Jobseeker visits their dashboard and views job alerts" do
    let!(:created_subscription) { create(:subscription, email: jobseeker.email) }

    before { visit jobseekers_subscriptions_path }

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end

  context "Jobseeker visits their dashboard and views saved jobs" do
    let(:school) { create(:school) }
    let(:vacancy) { create(:vacancy, :published, organisations: [school]) }

    before do
      visit job_path(vacancy)
      click_on I18n.t("jobseekers.saved_jobs.save")
      visit jobseekers_saved_jobs_path
    end

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end

  context "Jobseeker visits their dashboard and views my applications" do
    let(:jobseeker_applications_enabled?) { true }
    let(:school) { create(:school) }
    let(:vacancy) { create(:vacancy, :published, organisations: [school]) }
    let!(:submitted_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: vacancy) }

    before do
      visit jobseekers_job_applications_path
    end

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end
end
