require "rails_helper"

RSpec.describe "Cookies banner" do
  def set_cookie(name, value)
    headers = {}
    Rack::Utils.set_cookie_header!(headers, name, value)
    cookie_string = headers["Set-Cookie"]
    Capybara.current_session.driver.browser.set_cookie cookie_string
  end

  context "when the user has not set their cookies preferences" do
    it "displays the cookies banner" do
      visit root_path
      within ".cookies-banner-component" do
        expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
      end
    end

    context "when visiting cookies_preferences page" do
      it "does not display the cookies banner" do
        visit cookies_preferences_path
        expect(page).to have_no_css(".cookies-banner-component")
      end
    end
  end

  context "when user has set their cookies preferences" do
    before do
      set_cookie("consented-to-additional-cookies", "yes")
    end

    it "does not display the cookies banner" do
      visit root_path
      expect(page).to have_no_css(".cookies-banner-component")
    end
  end

  context "when user has a non valid cookie set" do
    before do
      set_cookie("consented-to-cookies", "yes")
    end

    it "displays the cookies banner" do
      visit root_path
      within ".cookies-banner-component" do
        expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
      end
    end
  end
end
