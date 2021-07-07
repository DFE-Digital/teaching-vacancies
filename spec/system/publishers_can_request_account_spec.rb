require "rails_helper"

RSpec.describe "Publishers can request an account" do
  it "shows a success message when filling the form" do
    visit root_path
    within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_publisher")
    click_on I18n.t("publishers.sessions.new.no_account.link_text")
    click_on I18n.t("buttons.request_account")

    expect(page).to have_content("There is a problem")

    fill_in "publishers_account_request_form[full_name]", with: "Thom Yorke"
    fill_in "publishers_account_request_form[email]", with: "thom@radiohead.com"
    fill_in "publishers_account_request_form[organisation_name]", with: "Radiohead"
    fill_in "publishers_account_request_form[organisation_identifier]", with: "42"
    click_on I18n.t("buttons.request_account")

    expect(page).to have_content(I18n.t("publishers.account_requests.create.success_message"))
  end
end
