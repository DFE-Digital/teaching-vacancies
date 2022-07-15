require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:email) { "jobseeker@example.com" }
  let(:jobseeker) { create(:jobseeker, email: email) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  it "shows `Applications` tab" do
    within ".tabs-component" do
      expect(page).to have_link(I18n.t("jobseekers.accounts.show.page_title"))
      expect(page).to_not have_link(I18n.t("jobseekers.job_applications.index.page_title"))
      expect(page).to_not have_link(I18n.t("jobseekers.saved_jobs.index.page_title"))
      expect(page).to_not have_link(I18n.t("jobseekers.subscriptions.index.page_title"))
    end
  end
end
