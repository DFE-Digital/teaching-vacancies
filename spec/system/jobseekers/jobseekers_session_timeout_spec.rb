require "rails_helper"

RSpec.describe "Jobseekers session timeout" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let(:timeout_period) { 8.hours }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "expires after the desired timeout period" do
    visit jobseekers_saved_jobs_path

    travel(timeout_period + 10.seconds) do
      visit jobseekers_saved_jobs_path

      expect(page).to have_current_path(new_jobseeker_session_path, ignore_query: true)
      expect(page).to have_content(I18n.t("devise.failure.timeout"))
      visit "/"
      expect(page).to have_no_content(I18n.t("devise.failure.timeout"))
    end
  end

  it "doesn't expire before the desired timeout period" do
    visit jobseekers_saved_jobs_path

    travel(timeout_period - 1.day) do
      visit jobseekers_saved_jobs_path

      expect(page).to have_current_path(jobseekers_saved_jobs_path, ignore_query: true)
    end
  end
end
