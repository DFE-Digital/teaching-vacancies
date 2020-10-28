require 'rails_helper'

RSpec.describe 'Cookies consent' do
  let(:root_path_with_utm_parameters) do
    root_path(utm_source: 'test', utm_medium: 'mob', utm_campaign: 'camp', utm_term: 'sep', utm_content: 'lots')
  end
  let(:jobs_path_with_utm_parameters) do
    jobs_path(utm_source: 'test', utm_medium: 'mob', utm_campaign: 'camp', utm_term: 'sep', utm_content: 'lots')
  end
  let(:cookies_preferences_path_with_utm_parameters) do
    cookies_preferences_path(utm_source: 'test', utm_medium: 'mob', utm_campaign: 'camp', utm_term: 'sep',
                             utm_content: 'lots')
  end

  before do
    allow(CookiesBannerFeature).to receive(:enabled?).and_return(cookies_banner_enabled)
  end

  context 'when CookiesBannerFeature is disabled' do
    let(:cookies_banner_enabled) { false }

    scenario 'redirects to cookies page' do
      visit cookies_preferences_path
      expect(page).to have_current_path(page_path('cookies'))
    end
  end

  context 'when CookiesBannerFeature is enabled' do
    let(:cookies_banner_enabled) { true }

    context 'when utm parameters are present' do
      scenario 'can accept all cookies' do
        visit root_path_with_utm_parameters

        click_on I18n.t('cookies.banner.buttons.accept_all')

        expect(page).to have_current_path(root_path_with_utm_parameters)
        expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

        visit cookies_preferences_path
        expect(find('#cookies-preferences-form-cookies-consent-yes-field')).to be_checked
      end

      describe 'setting your preferences' do
        before do
          visit jobs_path_with_utm_parameters
          click_on I18n.t('cookies.banner.buttons.set_preferences')
        end

        scenario 'can consent to cookies' do
          find('#cookies-preferences-form-cookies-consent-yes-field').click
          click_on I18n.t('cookies.form.buttons.save_changes')

          expect(page).to have_current_path(jobs_path_with_utm_parameters)
          expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

          visit cookies_preferences_path
          expect(find('#cookies-preferences-form-cookies-consent-yes-field')).to be_checked
        end

        scenario 'can not consent to cookies' do
          find('#cookies-preferences-form-cookies-consent-no-field').click
          click_on I18n.t('cookies.form.buttons.save_changes')

          expect(page).to have_current_path(jobs_path_with_utm_parameters)
          expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

          visit cookies_preferences_path
          expect(find('#cookies-preferences-form-cookies-consent-no-field')).to be_checked
        end

        scenario 'renders error if no option selected' do
          click_on I18n.t('cookies.form.buttons.save_changes')

          expect(page).to have_current_path(cookies_preferences_path)
          expect(page).to have_content(I18n.t('cookies_preferences_errors.cookies_consent.inclusion'))
        end
      end
    end

    scenario 'can accept all cookies' do
      visit root_path

      click_on I18n.t('cookies.banner.buttons.accept_all')

      expect(page).to have_current_path(root_path)
      expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

      visit cookies_preferences_path
      expect(find('#cookies-preferences-form-cookies-consent-yes-field')).to be_checked
    end

    describe 'setting your preferences' do
      before do
        visit jobs_path
        click_on I18n.t('cookies.banner.buttons.set_preferences')
      end

      scenario 'can consent to cookies' do
        find('#cookies-preferences-form-cookies-consent-yes-field').click
        click_on I18n.t('cookies.form.buttons.save_changes')

        expect(page).to have_current_path(jobs_path)
        expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

        visit cookies_preferences_path
        expect(find('#cookies-preferences-form-cookies-consent-yes-field')).to be_checked
      end

      scenario 'can not consent to cookies' do
        find('#cookies-preferences-form-cookies-consent-no-field').click
        click_on I18n.t('cookies.form.buttons.save_changes')

        expect(page).to have_current_path(jobs_path)
        expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

        visit cookies_preferences_path
        expect(find('#cookies-preferences-form-cookies-consent-no-field')).to be_checked
      end

      scenario 'renders error if no option selected' do
        click_on I18n.t('cookies.form.buttons.save_changes')

        expect(page).to have_current_path(cookies_preferences_path)
        expect(page).to have_content(I18n.t('cookies_preferences_errors.cookies_consent.inclusion'))
      end
    end

    context 'when navigating directly to cookies page' do
      scenario 'redirects to home page after setting preferences' do
        visit cookies_preferences_path

        find('#cookies-preferences-form-cookies-consent-yes-field').click
        click_on I18n.t('cookies.form.buttons.save_changes')

        expect(page).to have_current_path(root_path)
        expect(page).to_not have_content(I18n.t('cookies.banner.heading'))
      end
    end

    context 'when consented-to-cookies has expired' do
      scenario 'must re-set cookies_preferences' do
        visit root_path

        click_on I18n.t('cookies.banner.buttons.accept_all')

        expect(page).to have_current_path(root_path)
        expect(page).to_not have_content(I18n.t('cookies.banner.heading'))

        travel_to 7.months.from_now

        visit root_path

        expect(page).to have_content(I18n.t('cookies.banner.heading'))
      end
    end
  end
end
