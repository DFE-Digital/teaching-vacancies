require "rails_helper"

RSpec.describe "Hiring staff can manage vacancies from a link on home page" do
  let(:school) { create(:school) }

  scenario "as an authenticated user" do
    stub_publishers_auth(urn: school.urn)

    visit root_path

    within("div.manage-vacancies") do
      click_on(I18n.t("home.signin_publishers.manage_link"))
    end

    expect(page).to have_content(I18n.t("schools.jobs.index_html", organisation: school.name))
  end
end
