require 'rails_helper'

RSpec.describe 'Cookies banner' do
  before do
    allow(CookiesBannerFeature).to receive(:enabled?).and_return(cookies_banner_enabled)
    visit root_path
  end

  context 'when CookiesBannerFeature is enabled' do
    let(:cookies_banner_enabled) { true }

    scenario 'displays cookies banner' do
      within '.cookies-banner' do
        expect(page).to have_content(I18n.t('cookies_banner.heading'))
      end
    end

    context 'when visiting cookies page' do
      scenario 'does not display cookies banner' do
        visit page_path('cookies')
        expect(page).to_not have_content(I18n.t('cookies_banner.heading'))
      end
    end
  end

  context 'when CookiesBannerFeature is disabled' do
    let(:cookies_banner_enabled) { false }

    scenario 'does not display cookies banner' do
      expect(page).to_not have_content(I18n.t('cookies_banner.heading'))
    end
  end
end
