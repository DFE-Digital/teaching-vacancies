require "rails_helper"

RSpec.describe "Cookies banner" do
  let(:cookies_preference_set) { false }

  before do
    allow_any_instance_of(ApplicationController).to receive(:cookies_preference_set?).and_return(cookies_preference_set)
  end

  scenario "displays cookies banner" do
    visit root_path
    within ".cookies-banner-component" do
      expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
    end
  end

  context "when visiting cookies_preferences page" do
    scenario "does not display cookies banner" do
      visit cookies_preferences_path
      expect(page).to_not have_css(".cookies-banner-component")
    end
  end

  context "when cookies_preference_set? is true" do
    let(:cookies_preference_set) { true }

    scenario "does not display cookies banner" do
      visit root_path
      expect(page).to_not have_css(".cookies-banner-component")
    end
  end
end
