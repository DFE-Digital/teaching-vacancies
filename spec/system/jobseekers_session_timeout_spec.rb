require "rails_helper"

RSpec.describe "Jobseekers session timeout" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let(:timeout_period) { 2.weeks }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "expires after the desired timeout period" do
    visit jobseekers_saved_jobs_path
    expect(page).to have_content(jobseeker.email)

    travel(timeout_period + 10.seconds) do
      visit jobseekers_saved_jobs_path

      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end

  it "doesn't expire before the desired timeout period" do
    visit jobseekers_saved_jobs_path
    expect(page).to have_content(jobseeker.email)

    travel(timeout_period - 10.seconds) do
      visit jobseekers_saved_jobs_path

      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(jobseeker.email)
    end
  end
end
