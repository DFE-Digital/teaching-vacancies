require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  after { logout }

  scenario "the jobseeker can see their dashboard" do
    expect(page).to have_css("h1", text: I18n.t("jobseekers.accounts.show.page_title"))
    expect(page).to have_css("h2", text: I18n.t("jobseekers.accounts.show.change_sign_in.heading"))
    expect(page).to have_link(text: I18n.t("jobseekers.accounts.show.change_details_link_text"))

    expect(page).to have_css("h2", text: I18n.t("jobseekers.accounts.show.find_account_details.heading"))
    expect(page).to have_link(I18n.t("jobseekers.accounts.show.find_account_details.link_text"),
                              href: new_jobseekers_request_account_transfer_email_path)

    expect(page).to have_css("h2", text: I18n.t("jobseekers.accounts.show.close_account"))
    expect(page).to have_link(I18n.t("jobseekers.accounts.show.close_account"),
                              href: jobseekers_confirm_destroy_account_path)
  end
end
