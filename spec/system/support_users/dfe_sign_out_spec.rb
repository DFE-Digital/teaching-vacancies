require "rails_helper"
RSpec.describe "Support users can sign out with DfE Sign In" do
  let(:support_user) { create(:support_user) }

  scenario "as an authenticated user" do
    login_as(support_user, scope: :support_user)
    visit root_path

    click_on(I18n.t("nav.sign_out"))

    within("nav") { expect(page).not_to have_content(I18n.t("nav.sign_out")) }
    expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
  end
end
