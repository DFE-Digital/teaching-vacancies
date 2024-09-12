require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:email) { "jobseeker@example.com" }
  let(:jobseeker) { create(:jobseeker, email: email) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  after { logout }

  it "displays a summary list with their email address and password" do
    within ".govuk-summary-list" do
      expect(page).to have_content(I18n.t("jobseekers.accounts.show.summary_list.email"))
      expect(page).to have_content(I18n.t("jobseekers.accounts.show.summary_list.password"))
    end
  end

  it "allows the jobseeker to change their email address" do
    expect(page).to have_link(href: edit_jobseeker_registration_path)
  end

  it "allows the jobseeker to change their email address" do
    expect(page).to have_link(href: edit_jobseeker_registration_path(password_update: true))
  end
end
