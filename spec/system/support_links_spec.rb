require "rails_helper"

RSpec.describe "A visitor to the website can access the support links" do
  describe "the cookie policy" do
    before do
      allow(CookiesBannerFeature).to receive(:enabled?).and_return(cookies_banner_feature)
    end

    context "when CookiesBannerFeature is enabled" do
      let(:cookies_banner_feature) { true }

      scenario "can access cookies policy" do
        visit root_path
        click_on "Cookies"

        expect(page.current_path).to eql(cookies_preferences_path)
      end
    end

    context "when CookiesBannerFeature is disabled" do
      let(:cookies_banner_feature) { false }

      scenario "can access cookies policy" do
        visit root_path
        click_on "Cookies"

        expect(page).to have_content("Cookies")
        expect(page).to have_content("Teaching Vacancies puts small files (known as 'cookies') onto your computer " \
                                     "to collect information about how you use the service.")
      end
    end
  end

  scenario "the privacy policy" do
    visit root_path
    click_on "Privacy policy"

    expect(page).to have_content("Privacy Notice: Teaching Vacancies")
    expect(page).to have_content(I18n.t("static_pages.privacy_policy.who_we_are.about"))
  end

  scenario "the terms and conditions" do
    visit root_path
    click_on "Terms and Conditions"
    expect(page).to have_content(/terms and conditions/i)
    expect(page).to have_content(/unacceptable use/i)
  end

  scenario "the accessibility statement" do
    visit root_path
    click_on "Accessibility"

    expect(page).to have_content(I18n.t("static_pages.accessibility.page_title"))
    expect(page).to have_content(I18n.t("static_pages.accessibility.mission.opening_text"))
  end
end
