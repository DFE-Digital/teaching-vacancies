require "rails_helper"

RSpec.describe "jobseekers/accounts/show" do
  subject(:show_view) { Capybara.string(rendered) }

  before { render }

  it "the jobseeker can see their account show_view" do
    expect(show_view).to have_css("h1", text: I18n.t("jobseekers.accounts.show.page_title"))
    expect(show_view).to have_css("h2", text: I18n.t("jobseekers.accounts.show.change_sign_in.heading"))
    expect(show_view).to have_link(text: I18n.t("jobseekers.accounts.show.change_details_link_text"))

    expect(show_view).to have_css("h2", text: I18n.t("jobseekers.accounts.show.find_account_details.heading"))
    expect(show_view).to have_link(I18n.t("jobseekers.accounts.show.find_account_details.link_text"),
                                   href: new_jobseekers_request_account_transfer_email_path)

    expect(show_view).to have_css("h2", text: I18n.t("jobseekers.accounts.show.close_account"))
    expect(show_view).to have_link(I18n.t("jobseekers.accounts.show.close_account"),
                                   href: jobseekers_confirm_destroy_account_path)
  end
end
