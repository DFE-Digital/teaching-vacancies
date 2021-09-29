require "rails_helper"

RSpec.describe "Publishers can request an account" do
  it "shows a success message when filling the form" do
    visit root_path
    within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_publisher")
    click_on I18n.t("publishers.sessions.new.no_account.link_text")
    click_on I18n.t("buttons.request_account")

    expect(current_url).to eq("https://profile.signin.education.gov.uk/register")
  end
end
