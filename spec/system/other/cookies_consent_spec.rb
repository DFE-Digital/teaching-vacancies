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
    it "can accept cookies from the cookies banner" do
      visit root_path_with_utm_parameters

      click_on I18n.t("cookies_preferences.banner.buttons.accept")

      expect(page).to have_current_path(root_path_with_utm_parameters)
      expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).to be_checked
    end

    describe "setting your preferences" do
      before do
        visit jobs_path_with_utm_parameters
        click_on I18n.t("cookies_preferences.banner.buttons.view")
      end

      it "does not default to any choice on additional cookies" do
        expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).not_to be_checked
        expect(find_by_id("cookies-preferences-form-cookies-consent-no-field")).not_to be_checked
      end

      it "can consent to additional cookies" do
        find_by_id("cookies-preferences-form-cookies-consent-yes-field").click
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_current_path(jobs_path_with_utm_parameters)
        expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

        visit cookies_preferences_path
        expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).to be_checked
      end

      it "can reject the additional cookies" do
        find_by_id("cookies-preferences-form-cookies-consent-no-field").click
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_current_path(jobs_path_with_utm_parameters)
        expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

        visit cookies_preferences_path
        expect(find_by_id("cookies-preferences-form-cookies-consent-no-field")).to be_checked
      end
    end
  end

  it "can accept all cookies from the cookies banner" do
    visit root_path

    click_on I18n.t("cookies_preferences.banner.buttons.accept")

    expect(page).to have_current_path(root_path)
    expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

    visit cookies_preferences_path
    expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).to be_checked
  end

  describe "setting your preferences" do
    before do
      visit jobs_path
      click_on I18n.t("cookies_preferences.banner.buttons.view")
    end

    it "does not default to any choice on additional cookies" do
      expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).not_to be_checked
      expect(find_by_id("cookies-preferences-form-cookies-consent-no-field")).not_to be_checked
    end

    it "can consent to additional cookies" do
      find_by_id("cookies-preferences-form-cookies-consent-yes-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(jobs_path)
      expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find_by_id("cookies-preferences-form-cookies-consent-yes-field")).to be_checked
    end

    it "can reject the additional cookies" do
      find_by_id("cookies-preferences-form-cookies-consent-no-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(jobs_path)
      expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

      visit cookies_preferences_path
      expect(find_by_id("cookies-preferences-form-cookies-consent-no-field")).to be_checked
    end
  end

  context "when navigating directly to cookies page" do
    it "redirects to home page with a success banner after setting preferences" do
      visit cookies_preferences_path

      find_by_id("cookies-preferences-form-cookies-consent-yes-field").click
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_current_path(root_path)
      within ".govuk-notification-banner" do
        expect(page).to have_content(I18n.t("cookies_preferences.success"))
      end
      expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))
    end
  end

  context "when the cookie with the consent has expired" do
    it "must re-set cookies_preferences" do
      visit root_path

      click_on I18n.t("cookies_preferences.banner.buttons.accept")

      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content(I18n.t("cookies_preferences.banner.heading"))

      travel_to 7.months.from_now

      visit root_path

      expect(page).to have_content(I18n.t("cookies_preferences.banner.heading"))
    end
  end
end
