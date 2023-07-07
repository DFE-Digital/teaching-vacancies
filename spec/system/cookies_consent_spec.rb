require "rails_helper"

RSpec.describe "Cookies consent" do
  let(:root_path_with_utm_parameters) do
    root_path(utm_source: "test", utm_medium: "mob", utm_campaign: "camp", utm_term: "sep", utm_content: "lots")
  end
  let(:jobs_path_with_utm_parameters) do
    jobs_path(utm_source: "test", utm_medium: "mob", utm_campaign: "camp", utm_term: "sep", utm_content: "lots")
  end
  let(:cookies_preferences_path_with_utm_parameters) do
    cookies_preferences_path(utm_source: "test", utm_medium: "mob", utm_campaign: "camp", utm_term: "sep",
                             utm_content: "lots")
  end

  context "when utm parameters are present" do
    scenario "can accept cookies from the cookies banner" do
      visit root_path_with_utm_parameters

      click_on I18n.t("cookies_preferences.banner.buttons.accept")

      expect(page).to have_current_path(root_path_with_utm_parameters)
      expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find("#cookies-preferences-form-cookies-consent-yes-field")).to be_checked
    end

    describe "setting your preferences" do
      before do
        visit jobs_path_with_utm_parameters
        click_on I18n.t("cookies_preferences.banner.buttons.view")
      end

      scenario "does not default to any choice on additional cookies" do
        expect(find("#cookies-preferences-form-cookies-consent-yes-field")).not_to be_checked
        expect(find("#cookies-preferences-form-cookies-consent-no-field")).not_to be_checked
      end

      scenario "can consent to additional cookies" do
        find("#cookies-preferences-form-cookies-consent-yes-field").click
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_current_path(jobs_path_with_utm_parameters)
        expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

        visit cookies_preferences_path
        expect(find("#cookies-preferences-form-cookies-consent-yes-field")).to be_checked
      end

      scenario "can reject the additional cookies" do
        find("#cookies-preferences-form-cookies-consent-no-field").click
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_current_path(jobs_path_with_utm_parameters)
        expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

        visit cookies_preferences_path
        expect(find("#cookies-preferences-form-cookies-consent-no-field")).to be_checked
      end
    end
  end

  scenario "can accept all cookies from the cookies banner" do
    visit root_path

    click_on I18n.t("cookies_preferences.banner.buttons.accept")

    expect(page).to have_current_path(root_path)
    expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

    visit cookies_preferences_path
    expect(find("#cookies-preferences-form-cookies-consent-yes-field")).to be_checked
  end

  describe "setting your preferences" do
    before do
      visit jobs_path
      click_on I18n.t("cookies_preferences.banner.buttons.view")
    end

    scenario "does not default to any choice on additional cookies" do
      expect(find("#cookies-preferences-form-cookies-consent-yes-field")).not_to be_checked
      expect(find("#cookies-preferences-form-cookies-consent-no-field")).not_to be_checked
    end

    scenario "can consent to additional cookies" do
      find("#cookies-preferences-form-cookies-consent-yes-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(jobs_path)
      expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find("#cookies-preferences-form-cookies-consent-yes-field")).to be_checked
    end

    scenario "can reject the additional cookies" do
      find("#cookies-preferences-form-cookies-consent-no-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(jobs_path)
      expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find("#cookies-preferences-form-cookies-consent-no-field")).to be_checked
    end
  end

  context "when navigating directly to cookies page" do
    scenario "redirects to home page with a success banner after setting preferences" do
      visit cookies_preferences_path

      find("#cookies-preferences-form-cookies-consent-yes-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(root_path)
      within ".govuk-notification-banner" do
        expect(page).to have_content(I18n.t("cookies_preferences.success"))
      end
      expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))
    end
  end

  context "when the cookie with the consent has expired" do
    scenario "must re-set cookies_preferences" do
      visit root_path

      click_on I18n.t("cookies_preferences.banner.buttons.accept")

      expect(page).to have_current_path(root_path)
      expect(page).to_not have_content(I18n.t("cookies_preferences.banner.heading"))

      travel_to 7.months.from_now

      visit root_path

      expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
    end
  end
end
