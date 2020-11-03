require "rails_helper"

RSpec.describe "Cookies banner" do
  let(:cookies_preference_set) { false }

  before do
    allow(CookiesBannerFeature).to receive(:enabled?).and_return(cookies_banner_enabled)
    allow_any_instance_of(ApplicationController).to receive(:cookies_preference_set?).and_return(cookies_preference_set)
    visit root_path
  end

  context "when CookiesBannerFeature is enabled" do
    let(:cookies_banner_enabled) { true }

    scenario "displays cookies banner" do
      within ".cookies-banner" do
        expect(page).to have_content(I18n.t("cookies.banner.heading"))
      end
    end

    context "when visiting cookies_preferences page" do
      scenario "does not display cookies banner" do
        visit cookies_preferences_path
        expect(page).to_not have_content(I18n.t("cookies.banner.heading"))
      end
    end

    context "when cookies_preference_set? is true" do
      let(:cookies_preference_set) { true }

      scenario "does not display cookies banner" do
        expect(page).to_not have_content(I18n.t("cookies.banner.heading"))
      end
    end
  end

  context "when CookiesBannerFeature is disabled" do
    let(:cookies_banner_enabled) { false }

    scenario "does not display cookies banner" do
      expect(page).to_not have_content(I18n.t("cookies.banner.heading"))
    end
  end
end
