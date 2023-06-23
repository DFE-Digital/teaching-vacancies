require "rails_helper"

RSpec.describe "Cookies banner" do
  def set_cookie(name, value)
    headers = {}
    Rack::Utils.set_cookie_header!(headers, name, value)
    cookie_string = headers["Set-Cookie"]
    Capybara.current_session.driver.browser.set_cookie cookie_string
  end

  context "when the user has not set their cookies preferences" do
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
  end

  context "when user has set all their cookies preferences" do
    before do
      set_cookie("consented-to-analytics-cookies", "yes")
      set_cookie("consented-to-marketing-cookies", "no")
    end

    scenario "does not display cookies banner" do
      visit root_path
      expect(page).to_not have_css(".cookies-banner-component")
    end
  end

  context "when user has only partially set their cookies preferences" do
    before do
      set_cookie("consented-to-analytics-cookies", "yes")
    end

    scenario "displays cookies banner" do
      visit root_path
      within ".cookies-banner-component" do
        expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
      end
    end
  end
end
