require "rails_helper"

RSpec.describe "jobseekers/accounts/help" do
  before { render }

  it "the jobseeker can see their account help view" do
    expect(rendered).to have_css("h1", text: I18n.t("jobseekers.accounts.help.page_title"))
    expect(rendered).to have_css("h2", text: I18n.t("jobseekers.accounts.help.change_sign_in.heading"))
    expect(rendered).to have_link(text: I18n.t("jobseekers.accounts.help.change_details_link_text"))

    expect(rendered).to have_css("h2", text: I18n.t("jobseekers.accounts.help.find_account_details.heading"))
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.help.find_account_details.link_text"),
                                  href: new_jobseekers_request_account_transfer_email_path)

    expect(rendered).to have_css("h2", text: I18n.t("jobseekers.accounts.help.close_account"))
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.help.close_account"),
                                  href: jobseekers_confirm_destroy_account_path)
  end
end
